local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local GetServerTime = GetServerTime
local tinsert, tsort, pairs = table.insert, table.sort, pairs

local DKP_DB, Guild, CommsManager, LEDGER;

local Ledger = {}

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

    self:CheckSyncStatus()
end

function Ledger:CheckSyncStatus()
    PDKP.CORE:Print('Synchronizing databases')
    CommsManager:SendCommsMessage('SyncReq', self.weekHashes)
end

function Ledger:CheckRequestKeys(message, sender)
    local isOfficer = Guild:IsMemberOfficer(sender)
    if self.syncLocked and not isOfficer then
        if PDKP:IsDev() then
            PDKP.CORE:Print('Sync is locked, returning')
        end
        return
    end
    if not isOfficer then
        self.syncLocked = true
        self:_StartSyncUnlockTimer()
        if PDKP:IsDev() then
            PDKP.CORE:Print('Locking sync responses for 3 minutes')
        end
    end
    local requestData = CommsManager:DataDecoder(message)

    local missing_keys = {}
    local requestHasKeys = false
    for weekNumber, weekTable in pairs(requestData) do
        for officerName, officerTable in pairs(weekTable) do
            local myOfficerTable = self:_GetOfficerTable(weekNumber, officerName)
            local myLastEntry = #myOfficerTable
            local theirLastEntry = #officerTable

            requestHasKeys = true

            if myLastEntry > theirLastEntry then
                local entry_keys = self:_GetEntriesBetweenRange(weekNumber, officerName, theirLastEntry, myLastEntry)
                for i=1, #entry_keys do
                    table.insert(missing_keys, entry_keys[i])
                end
            end
        end
    end

    if Utils:tEmpty(missing_keys) and not requestHasKeys then -- Request User has 0 keys from the last 4 weeks
        missing_keys = self:GetLastFourWeekEntryIds()
    end

    local entries = {}
    for _, entry_id in pairs(missing_keys) do
        local entry = MODULES.DKPManager:GetEntryByID(entry_id)
        local save_details = entry:GetSaveDetails()
        entries[entry_id] = save_details
    end

    if Utils:tEmpty(entries) then
        if PDKP:IsDev() then
            PDKP.CORE:Print('DEV: Entries were empty, returning')
        end
        return
    end
    CommsManager:SendCommsMessage('SyncAd', entries)
end

function Ledger:GetLastFourWeekEntryIds()
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
    for i=fourWeeksAgo, self.weekNumber do
        self.weekHashes[i] = self:_GetWeekTable(i)
    end
end

function Ledger:GenerateEntryHash(entry)
    local weekNumber = entry.weekNumber
    local officer = entry.officer

    if LEDGER[weekNumber] == nil then
        LEDGER[weekNumber] = {}
    end

    local ledger_path = LEDGER[weekNumber][officer]

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

    for i=1, #hashMakeup do
        if hashMakeup[i] ~= "" then
            table.insert(tbl, hashMakeup[i])
        end
    end

    local weekNumber = tonumber(tbl[1])
    local officer = tbl[2]
    local index = tbl[3]

    weekNumber = tonumber(weekNumber)

    self:_GetWeekTable(weekNumber)
    self:_GetOfficerTable(weekNumber, officer)

    if tContains(LEDGER[weekNumber][officer], entry.id) then
        if PDKP:IsDev() then
            PDKP.CORE:Print('Entry already exists')
        end
        return false
    end

    --self.weekHashes[weekNumber][officer][index] = entry.id
    table.insert(LEDGER[weekNumber][officer], entry.id)
    table.sort(LEDGER[weekNumber][officer], function(a,b)
        return a < b
    end)
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
    for i=startIndex + 1, endIndex do
        local entry_key = LEDGER[weekNumber][officerName][i]
        table.insert(entry_keys, entry_key)
    end
    return entry_keys
end

function Ledger:_StartSyncUnlockTimer()
    C_Timer.After(180, function()
        Ledger.syncLocked = false
    end)
end

MODULES.LedgerManager = Ledger