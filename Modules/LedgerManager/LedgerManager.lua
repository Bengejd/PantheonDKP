local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;

local GetServerTime = GetServerTime
local _, _, pairs = table.insert, table.sort, pairs
local strfind = string.find

local _, Guild, CommsManager, LEDGER;

local Ledger = { _initialized = false }

function Ledger:Initialize()
    CommsManager = MODULES.CommsManager;
    LEDGER = MODULES.Database:Ledger()
    Guild = MODULES.GuildManager

    self.weekNumber = Utils:GetWeekNumber(GetServerTime())

    if LEDGER[self.weekNumber] == nil then
        LEDGER[self.weekNumber] = {}
    end

    self.weekHashes = {}
    self.finalWeekEntries = {}
    self.entryCount = 0

    self.syncLocked = false

    self:GetLastFourWeeks()

    local f = CreateFrame("Frame", "PDKP_Ledger_EventsFrame")
    f:RegisterEvent("CHAT_MSG_SYSTEM")
    f:SetScript("OnEvent", function(_, eventName, arg1, ...)
        if eventName == 'CHAT_MSG_SYSTEM' and PDKP.canEdit then
            local isOnlineEvent, _ = strfind(arg1, "has come online", 1, true)
            if isOnlineEvent ~= nil then
                local formattedPlayerName, _ = strsplit(" ", arg1, 2)
                local _, firstItter = strsplit(":", formattedPlayerName, 2)
                local playerName, _ = strsplit("|h", firstItter, 2)
                if Guild.initiated then
                    local member = Guild:GetMemberByName(playerName)
                    if member ~= nil and member.canEdit then
                        C_Timer.After(5, function()
                            self:CheckSyncStatus()
                        end)
                    end
                end
            end
        end
    end)

    self:CheckSyncStatus()
end

function Ledger:CheckSyncStatus()
    if not self._initialized then
        PDKP.CORE:Print('Synchronizing databases...')
    else
        PDKP.CORE:Print('Re-syncing database in the next 30 seconds')
    end

    CommsManager:SendCommsMessage('SyncReq', self.weekHashes)
    self._initialized = true
end

function Ledger:CheckRequestKeys(message, sender)
    local isOfficer = Guild:IsMemberOfficer(sender)
    if self.syncLocked and not isOfficer then
        PDKP:PrintD('Sync is locked, returning')
        return
    end
    if not isOfficer then
        self.syncLocked = true
        self:_StartSyncUnlockTimer()
        PDKP:PrintD('Locking sync responses for 3 minutes')
    end
    local requestData = CommsManager:DataDecoder(message)

    local missing_keys = {}
    local requestHasKeys = false
    local mismatchedKeys = false

    for weekNumber, weekTable in pairs(self.weekHashes) do
        local theirWeekTable = requestData[weekNumber]
        for officerName, officerTable in pairs(weekTable) do
            if theirWeekTable ~= nil then
                local theirOfficerTable = theirWeekTable[officerName]
                if theirOfficerTable == nil then -- They have not gotten this officer table before.
                    mismatchedKeys = true
                elseif theirOfficerTable[#theirOfficerTable] ~= officerTable[#officerTable] then
                    mismatchedKeys = true
                end
            else
                mismatchedKeys = true
            end
        end
    end

    if not mismatchedKeys then
        for weekNumber, weekTable in pairs(requestData) do
            for officerName, officerTable in pairs(weekTable) do
                local myOfficerTable = self:_GetOfficerTable(weekNumber, officerName)

                local myLastEntry = #myOfficerTable
                local theirLastEntry = #officerTable

                requestHasKeys = true

                if myLastEntry > theirLastEntry then
                    local entry_keys = self:_GetEntriesBetweenRange(weekNumber, officerName, 1, myLastEntry)
                    for i = 1, #entry_keys do
                        table.insert(missing_keys, entry_keys[i])
                    end
                elseif officerTable[theirLastEntry] ~= myOfficerTable[myLastEntry] then
                    mismatchedKeys = true
                    break
                end
            end
        end
    end

    -- Request User has 0 keys from the last 4 weeks, or your keys got mismatched somehow.
    if (Utils:tEmpty(missing_keys) and not requestHasKeys) or mismatchedKeys then
        missing_keys = self:GetLastFourWeekEntryIds()
    end

    PDKP:PrintD('requestHasKeys', requestHasKeys)
    PDKP:PrintD('missing_keys Empty', Utils:tEmpty(missing_keys))

    local entries = {}
    for _, entry_id in pairs(missing_keys) do
        local entry = MODULES.DKPManager:GetEntryByID(entry_id)

        if entry ~= nil then
            local save_details = entry:GetSaveDetails()
            entries[entry_id] = save_details
        else
            PDKP:PrintD('Could not find entry', entry_id)
        end
    end

    if Utils:tEmpty(entries) then
        PDKP:PrintD('Entries were empty, returning')
        return
    end
    CommsManager:SendCommsMessage('SyncAd', entries)
end

function Ledger:GetLastFourWeekEntryIds()
    self:GetLastFourWeeks()

    local keys = {}
    for _, weekTable in pairs(self.weekHashes) do
        for _, officerTable in pairs(weekTable) do
            for _, entryId in pairs(officerTable) do
                table.insert(keys, entryId)
            end
        end
    end
    return keys
end

function Ledger:GetLastFourWeeks()
    local fourWeeksAgo = self.weekNumber - 4
    for i = fourWeeksAgo, self.weekNumber do
        self.weekHashes[i] = self:_GetWeekTable(i)
        if PDKP:IsDev() then
            for key, v in pairs(self.weekHashes[i]) do
                PDKP:PrintD('WeekEntries', i, key, #v)
            end
        end
    end
end

function Ledger:GenerateEntryHash(entry)
    local weekNumber = entry.weekNumber
    local officer = entry.officer

    if LEDGER[weekNumber] == nil then
        LEDGER[weekNumber] = {}
    end

    if LEDGER[weekNumber][officer] == nil then
        LEDGER[weekNumber][officer] = {}
    end

    local entry_index = #LEDGER[weekNumber][officer] + 1
    entry.hash = string.format("%d__%s__%d", weekNumber, officer, entry_index)
    return entry:GetSaveDetails()
end

function Ledger:ImportEntry(entry)
    local hashMakeup = { strsplit("__", entry.hash) }
    local tbl = {}

    for i = 1, #hashMakeup do
        if hashMakeup[i] ~= "" then
            table.insert(tbl, hashMakeup[i])
        end
    end

    local weekNumber = tonumber(tbl[1])
    local officer = tbl[2]
    --local index = tbl[3]

    weekNumber = tonumber(weekNumber)

    self:_GetWeekTable(weekNumber)
    self:_GetOfficerTable(weekNumber, officer)

    if tContains(LEDGER[weekNumber][officer], entry.id) then
        return false
    end

    --self.weekHashes[weekNumber][officer][index] = entry.id
    table.insert(LEDGER[weekNumber][officer], entry.id)
    table.sort(LEDGER[weekNumber][officer], function(a, b)
        return a < b
    end)

    self:GetLastFourWeeks()
    return true
end

function Ledger:GetLedgerEntryIndex(entryID, LedgerPath)
    for entry_index, val in pairs(LedgerPath) do
        if val == entryID then
            return entry_index
        end
    end
    return nil
end

function Ledger:_GetWeekTable(weekNumber)
    if LEDGER[weekNumber] == nil then
        LEDGER[weekNumber] = {}
    end
    return LEDGER[weekNumber]
end

function Ledger:_GetOfficerTable(weekNumber, officerName)
    if LEDGER[weekNumber][officerName] == nil then
        LEDGER[weekNumber][officerName] = {}
    end
    return LEDGER[weekNumber][officerName]
end

function Ledger:_GetEntriesBetweenRange(weekNumber, officerName, startIndex, endIndex)
    local entry_keys = {}
    for i = startIndex + 1, endIndex do
        local entry_key = LEDGER[weekNumber][officerName][i]
        table.insert(entry_keys, entry_key)
    end
    return entry_keys
end

function Ledger:_StartSyncUnlockTimer()
    C_Timer.After(30, function()
        Ledger.syncLocked = false
    end)
end

MODULES.LedgerManager = Ledger