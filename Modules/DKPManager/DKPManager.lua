local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils;

local GetServerTime = GetServerTime
local tinsert, tsort, pairs = table.insert, table.sort, pairs

local DKP = {}

local DKP_DB, _, CommsManager, LEDGER;

function DKP:Initialize()
    DKP_DB = MODULES.Database:DKP()
    CommsManager = MODULES.CommsManager;

    LEDGER = MODULES.Database:Ledger()

    self.entries = {}
    self.encoded_entries = {}
    self.decoded_entries = {}
    self.numOfEntries = 0
    self.numOfDecoded = 0
    self.numOfEncoded = 0

    self.currentWeekNumber = Utils.weekNumber - 4
    self.currentLoadedWeek = Utils.weekNumber
    self.currentLoadedWeekEntries = {}
    self.currentLoadedSet = false
    self.numCurrentLoadedWeek = 0

    self.compressedCurrentWeekEntries = ''
    self.lastAutoSync = GetServerTime()
    self.autoSyncInProgress = false

    self:_LoadEncodedDatabase()
    self:LoadPrevFourWeeks()

    C_Timer.After(5, function()
        PDKP.CORE:Print(tostring(self.numOfEntries) .. ' entries have been loaded')
    end)
end

-----------------------------
--      Load Functions     --
-----------------------------

function DKP:_LoadEncodedDatabase()
    for index, entry in pairs(DKP_DB) do
        self.encoded_entries[index] = entry
        self.numOfEncoded = self.numOfEncoded + 1
    end

    PDKP:PrintD('Loaded', self.numOfEncoded, 'Encoded entries')
end

function DKP:LoadPrevFourWeeks()
    self.currentLoadedWeek = self.currentLoadedWeek - 4
    self.numOfEncoded = 0

    for index, encoded_entry in pairs(self.encoded_entries) do
        self.numOfEncoded = self.numOfEncoded + 1

        local weekNumber = Utils:GetWeekNumber(index)
        if weekNumber >= self.currentLoadedWeek then
            local decoded_entry = CommsManager:DatabaseDecoder(encoded_entry)
            if decoded_entry == nil then
                decoded_entry = encoded_entry;
            end
            local entry = MODULES.DKPEntry:new(decoded_entry)
            self.entries[index] = entry
            self.numOfEntries = self.numOfEntries + 1

            if not self.currentLoadedSet then
                self.currentLoadedWeekEntries[index] = encoded_entry
                self.numCurrentLoadedWeek = self.numCurrentLoadedWeek + 1
            end
        end
    end

    self.currentLoadedSet = true

    for index, _ in pairs(self.entries) do
        if self.encoded_entries[index] ~= nil then
            self.encoded_entries[index] = nil
            self.numOfEncoded = self.numOfEncoded - 1
        end
    end
    return self.numOfEncoded
end

function DKP:_RecompressCurrentLoaded()
    self.compressedCurrentWeekEntries = MODULES.CommsManager:DataEncoder({ ['total'] = self.numCurrentLoadedWeek, ['entries'] = self.currentLoadedWeekEntries })
end

-----------------------------
--     Export Functions    --
-----------------------------

function DKP:ExportEntry(entry)
    local save_details = MODULES.LedgerManager:GenerateEntryHash(entry)
    MODULES.CommsManager:SendCommsMessage('SyncSmall', save_details)
end

-----------------------------
--     Import Functions    --
-----------------------------

function DKP:ImportEntry(entry, skipLockoutCheck)
    skipLockoutCheck = skipLockoutCheck or false
    local importEntry = MODULES.DKPEntry:new(entry)

    if skipLockoutCheck then
        importEntry.lockoutsChecked = true
    end

    local no_lockout_members = MODULES.Lockouts:AddMemberLockouts(importEntry)

    if #no_lockout_members == 0 and not skipLockoutCheck then
        self:_UpdateTables()
        PDKP:PrintD('No eligible members found for', entry.reason, 'Skipping import')
        return
    end

    local saved_ledger_entry = MODULES.LedgerManager:ImportEntry(importEntry)

    if saved_ledger_entry or skipLockoutCheck then
        importEntry:Save(true)

        self.currentLoadedWeekEntries[entry['id']] = MODULES.CommsManager:DataEncoder(entry)
        self.numCurrentLoadedWeek = self.numCurrentLoadedWeek + 1
        self:_RecompressCurrentLoaded()
    end

    return importEntry
end

function DKP:DeleteEntry(entry, sender)
    local importEntry = MODULES.DKPEntry:new(entry)
    local temp_entry = {
        ['reason'] = 'Other',
        ['names'] = importEntry['names'],
        ['officer'] = importEntry['officer'],
        ['dkp_change'] = importEntry['dkp_change'] * -1,
        ['other_text'] = 'DKP Correction'
    }

    PDKP:PrintD('Deleting Entry', entry.id)

    if importEntry['previousTotals'] and next(importEntry['previousTotals']) ~= nil then
        temp_entry['previousTotals'] = importEntry['previousTotals']
    end

    if self:GetEntryByID(entry.id) ~= nil then
        if importEntry['deleted'] and sender ~= importEntry['deletedBy'] then
            PDKP:PrintD("Entry has previously been deleted, skipping delete sequence")
            return
        else
            PDKP:PrintD("Entry was found during delete")
            importEntry:MarkAsDeleted(sender)
            local import_sd = importEntry:GetSaveDetails()
            DKP_DB[entry.id] = MODULES.CommsManager:DatabaseEncoder(import_sd)
            self.entries[entry.id] = importEntry
        end
    else
        PDKP:PrintD("Entry was not found during delete")
        self:ImportEntry(entry, false)
    end

    if PDKP.canEdit and sender == Utils:GetMyName() then
        local corrected_entry = MODULES.DKPEntry:new(temp_entry)
        corrected_entry:Save(false, true)
    end
end

function DKP:ImportBulkEntries(message, _)
    local data = MODULES.CommsManager:DataDecoder(message)
    local total, entries = data['total'], data['entries']
    local batches, total_batches = self:_CreateBatches(entries, total)
    local currentBatch = 0
    self.importTicker = C_Timer.NewTicker(0.5, function()
        currentBatch = currentBatch + 1
        DKP:_ProcessEntryBatch(batches[currentBatch])
        if currentBatch >= total_batches then
            DKP:_UpdateTables()
            DKP.importTicker:Cancel()
            self:_RecompressCurrentLoaded()
        end
    end, total_batches)
end

-----------------------------
--      Boss Functions     --
-----------------------------

function DKP:BossKillDetected(_, bossName)
    if not PDKP.canEdit then
        return
    end
    local dkpAwardAmount = 10

    if MODULES.Constants.BOSS_TO_RAID[bossName] ~= nil then
        GUI.Dialogs:Show('PDKP_RAID_BOSS_KILL', { bossName, dkpAwardAmount }, bossName)
    end
end

function DKP:AwardBossKill(boss_name)
    if not PDKP.canEdit then
        return
    end

    PDKP.CORE:Print('Awarding DKP for ' .. boss_name .. ' Kill')
    MODULES.GroupManager:Refresh()

    local GuildManager = MODULES.GuildManager

    local memberNames = MODULES.GroupManager.memberNames;

    local myName, _ = Utils:GetMyName()

    local dummy_entry = {
        ['officer'] = myName,
        ['reason'] = 'Boss Kill',
        ['names'] = {},
        ['dkp_change'] = 10,
        ['boss'] = boss_name,
        ['pugNames'] = {},
    }

    for i = 1, #memberNames do
        local memberName = memberNames[i]
        local member = GuildManager:GetMemberByName(memberName)
        if member then
            tinsert(dummy_entry['names'], member.name)
        else
            tinsert(dummy_entry['pugNames'], memberName)
        end
    end

    local entry = PDKP.MODULES.DKPEntry:new(dummy_entry)

    if entry:IsValid() then
        entry:Save(false, true)
    end
end

-----------------------------
--      Time Functions     --
-----------------------------

function DKP:_CreateBatches(entries, total)
    local batches = {}
    local index = 1

    local total_batches = math.ceil(total / 50)
    for i = 1, total_batches do
        batches[i] = {}
    end
    for key, entry in pairs(entries) do
        if #batches[index] >= 50 then
            index = index + 1
        end
        batches[index][key] = entry
    end
    return batches, total_batches
end

function DKP:_ProcessEntryBatch(batch)
    for key, encoded_entry in pairs(batch) do

        local shouldContinue = true

        if DKP_DB[key] ~= nil then
            local dbAdler = PDKP.LibDeflate:Adler32(DKP_DB[key])
            local eAdler = PDKP.LibDeflate:Adler32(encoded_entry)
            shouldContinue = dbAdler ~= eAdler
            PDKP:PrintD('Skipping Entry')
        end

        -- TODO: This should also include the entry in self.currentLoadedWeekEntries if it falls in it's week number range.
        if shouldContinue then
            local entry = MODULES.CommsManager:DatabaseDecoder(encoded_entry)
            local importEntry = MODULES.DKPEntry:new(entry)
            importEntry:Save(false)
            local weekNumber = Utils:GetWeekNumber(key)
            if weekNumber >= self.currentWeekNumber then
                self.currentLoadedWeekEntries[key] = encoded_entry
                self.numCurrentLoadedWeek = self.numCurrentLoadedWeek + 1
            end
        end
    end
end

function DKP:AddNewEntryToDB(entry, updateTable, skipLockouts)
    updateTable = updateTable or true
    skipLockouts = skipLockouts or false

    if entry.reason == 'Boss Kill' and not skipLockouts then
        MODULES.Lockouts:AddMemberLockouts(entry)
        entry:GetMembers()
    end

    if entry ~= nil then
        for i = #entry.members, 1, -1 do
            local member = entry.members[i]

            if entry.reason == "Decay" then
                if entry['previousTotals'][member.name] == nil then
                    entry['previousTotals'][member.name] = member.dkp['total']
                else
                    if member.dkp['total'] ~= entry['previousTotals'][member.name] then
                        PDKP.CORE:Print("Missing entries, skipping decay calculations")
                        return -- Skipping the Decay, because the numbers don't match up.
                    end
                end
            end

            member:_UpdateDKP(entry)
            member:Save()
        end

        local entryMembers = entry:GetMembers()
        entry.formattedNames = entry:_GetFormattedNames()
        entry:GetSaveDetails()

        if #entryMembers == 0 then
            PDKP:PrintD('No members found for:', entry.reason, ' Skipping import')
            DKP:_UpdateTables()
            return
        end

        DKP_DB[entry.id] = MODULES.CommsManager:DatabaseEncoder(entry.sd)

        self.entries[entry.id] = entry
        self.numOfEntries = self.numOfEntries + 1
    end

    if updateTable then
        DKP:_UpdateTables()
    end
end

function DKP:_UpdateTables()
    if PDKP.memberTable._initialized then
        PDKP.memberTable:DataChanged()
    end
    if GUI.HistoryGUI._initialized then
        GUI.HistoryGUI:RefreshData()
    end
    if GUI.LootGUI._initialized then
        GUI.LootGUI:RefreshData()
    end
end

-----------------------------
--    Data Req Functions   --
-----------------------------

function DKP:GetEntries()
    return self.entries;
end

function DKP:GetEncodedEntries()
    return self.encoded_entries;
end

function DKP:GetEntriesForSync(loadAfterWeek)
    loadAfterWeek = loadAfterWeek or 0

    local encoded_entries = self:GetEncodedEntries()
    local decoded_entries = self:GetEntries()

    local transmission_entries = {}
    local total_entries = 0

    for id, decoded_entry in pairs(decoded_entries) do
        local save_details = decoded_entry:GetSaveDetails()
        transmission_entries[id] = MODULES.CommsManager:DatabaseEncoder(save_details)
        total_entries = total_entries + 1
    end
    for id, entry in pairs(encoded_entries) do
        transmission_entries[id] = entry;
        total_entries = total_entries + 1
    end

    return transmission_entries, total_entries;
end

function DKP:GetEntryKeys(sorted, filterReasons)
    sorted = sorted or false
    local keys = {}

    local excludedTypes = {}
    if type(filterReasons) == "table" then
        for i = 1, #filterReasons do
            excludedTypes[filterReasons[i]] = true
        end
    elseif type(filterReasons) == "string" then
        excludedTypes[filterReasons] = true
    end

    for key, entry in pairs(self.entries) do
        if excludedTypes[entry.reason] == nil then
            tinsert(keys, key)
        end
    end

    if sorted then
        tsort(keys, function(a, b)
            return a > b
        end)
    end

    return keys;
end

function DKP:GetEntryByID(id)
    return self.entries[id]
end

function DKP:GetNumEncoded()
    return self.numOfEncoded
end

function DKP:GetMyDKP()
    local myMember = MODULES.GuildManager:GetMemberByName(Utils:GetMyName())
    if myMember ~= nil then
        return myMember:GetDKP('total')
    else
        return 0
    end
end

MODULES.DKPManager = DKP