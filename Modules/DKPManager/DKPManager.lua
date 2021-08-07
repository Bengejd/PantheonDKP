local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils;

local GetServerTime = GetServerTime
local tinsert, tsort, pairs = table.insert, table.sort, pairs

local DKP = {}

local DKP_DB, _, CommsManager;

function DKP:Initialize()
    DKP_DB = MODULES.Database:DKP()
    CommsManager = MODULES.CommsManager;

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
    self.entrySyncCacheCounter = 0

    self.entrySyncCache = {}
    self.entrySyncTimer = nil
    self.processedCacheEntries = {}

    self.rolledBackEntries = {}

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

            if entry ~= nil then
                self.entries[index] = entry
                self.numOfEntries = self.numOfEntries + 1

                if not self.currentLoadedSet then
                    self.currentLoadedWeekEntries[index] = encoded_entry
                    self.numCurrentLoadedWeek = self.numCurrentLoadedWeek + 1
                end
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
    PDKP:PrintD("DKP:ExportEntry()")
    local save_details = MODULES.LedgerManager:GenerateEntryHash(entry)
    MODULES.CommsManager:SendCommsMessage('SyncSmall', save_details)
end

function DKP:PrepareOverwriteExport()
    local exportDetails = {
        ['dkp'] = MODULES.Database:DKP(),
        ['ledger'] = MODULES.Database:Ledger(),
        ['lockouts'] = MODULES.Database:Lockouts(),
        ['guild'] = MODULES.Database:Guild(),
    }
    MODULES.CommsManager:SendCommsMessage('SyncOver', exportDetails)
end

function DKP:ProcessOverwriteSync(message, sender)
    PDKP.CORE:Print("Processing database overwrite from", sender)
    for dbName, db in pairs(message) do
        MODULES.Database:ProcessDBOverwrite(dbName, db)
    end
    PDKP.CORE:Print("Database overwrite has completed. Please reload for it to take effect.");
end

-----------------------------
--     Import Functions    --
-----------------------------

function DKP:_CheckForPreviousDecay()
    local decayDB = MODULES.Database:Decay()
    local weekDecay = decayDB[self.weekNumber]
    if weekDecay then
        if next(weekDecay) ~= nil then
            PDKP:Print("Error: decay already submitted for this week");
            self.previousDecayEntry = decayDB[self.weekNumber][1]
            return true, decayDB[self.weekNumber]
        end
    else
        decayDB[self.weekNumber] = {}
    end
    return false, decayDB[self.weekNumber]
end

-- TODO: SkipLockoutCheck isn't used anymore. Probably can safely remove it?
function DKP:ImportEntry(entry, skipLockoutCheck)

    PDKP:PrintD("DKP:ImportEntry(): Importing new entry");

    skipLockoutCheck = skipLockoutCheck or false
    local importEntry = MODULES.DKPEntry:new(entry)

    if skipLockoutCheck then
        importEntry.lockoutsChecked = true
    end

    -- Does nothing if entry.reason ~= 'Boss Kill' or entry.lockoutsChecked is true.
    local no_lockout_members = MODULES.Lockouts:AddMemberLockouts(importEntry)

    if #no_lockout_members == 0 and not skipLockoutCheck then
        PDKP:PrintD("DKP:ImportEntry(): No Lockout Members, Updating tables & returning")
        self:_UpdateTables()
        return
    end

    -- TODO: Remove lockout members from deleted boss_kill entries.
    local saved_ledger_entry = MODULES.LedgerManager:ImportEntry(importEntry)

    -- Only does something if the entry isn't already imported into the ledger or we're skipping the lockout check.
    if saved_ledger_entry or skipLockoutCheck then

        PDKP:PrintD("DKP:ImportEntry(): Saved_ledger_entry", saved_ledger_entry, "SkippedLockoutCheck", skipLockoutCheck);

        self:RollBackEntries(importEntry)
        if entry.reason == 'Decay' then
            PDKP:PrintD("DKP:ImportEntry(): Decay entry found");
            importEntry:CalculateDecayAmounts(true)
        end

        importEntry:Save(true)
        self.currentLoadedWeekEntries[entry['id']] = MODULES.CommsManager:DataEncoder(entry)
        self.numCurrentLoadedWeek = self.numCurrentLoadedWeek + 1
        self:_StartRecompressTimer()

        if #self.rolledBackEntries then
            self:RollForwardEntries()
        end
    end

    return importEntry
end

function DKP:DeleteEntry(entry, sender)
    local importEntry = MODULES.DKPEntry:new(entry)
    local temp_entry = {
        ['reason'] = 'Other',
        ['names'] = importEntry['names'],
        ['officer'] = sender,
        ['dkp_change'] = importEntry['dkp_change'] * -1,
        ['other_text'] = 'DKP Correction'
    }

    PDKP:PrintD('Deleting Entry', entry.id)

    if importEntry.reason == 'Decay' then
        temp_entry['reason'] = 'Decay'
    end

    if importEntry['previousTotals'] and next(importEntry['previousTotals']) ~= nil then
        importEntry:GetPreviousTotals()
        temp_entry['previousTotals'] = importEntry['previousTotals']
    end

    if importEntry['decayAmounts'] and next(importEntry['decayAmounts']) ~= nil then
        temp_entry['decayAmounts'] = importEntry['decayAmounts']
        for name, amt in pairs(temp_entry['decayAmounts']) do
            temp_entry['decayAmounts'][name] = amt * -1
            if temp_entry['decayReversal'] == nil then
                temp_entry['decayReversal'] = (amt * -1) > 0
                temp_entry['previousDecayId'] = importEntry['id']
            end
        end
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

function DKP:GetPreviousDecayEntry(entry)
    if entry.previousDecayId and DKP_DB[entry.previousDecayId] then
        return MODULES.CommsManager:DatabaseDecoder(DKP_DB[entry.previousDecayId])
    end
    return nil;
end

function DKP:RecalibrateDKP()
    local members = MODULES.GuildManager.members
    for _, member in pairs(members) do
        member.dkp['total'] = 30
        member:Save()
    end

    local entryIDS = {}

    for entryID, _ in pairs(DKP_DB) do
        table.insert(entryIDS, entryID)
    end

    table.sort(entryIDS)

    for i=1, #entryIDS do
        local encoded_entry = DKP_DB[entryIDS[i]]
        local decoded_entry = MODULES.CommsManager:DatabaseDecoder(encoded_entry)
        local entry = MODULES.DKPEntry:new(decoded_entry)

        entry:GetPreviousTotals()

        if entry.reason == 'Decay' then
            entry:CalculateDecayAmounts(true)
        end

        local previousDecayEntry = self:GetPreviousDecayEntry(entry);

        for _, member in pairs(entry.members) do
            local dkp_change = entry.dkp_change

            if entry.reason == 'Decay' then
                dkp_change = entry['decayAmounts'][member.name]
                if entry.decayReversal and not entry.deleted and dkp_change < 0 then
                    if previousDecayEntry ~= nil then
                        dkp_change = previousDecayEntry['decayAmounts'][member.name];
                    else
                        dkp_change = math.ceil(dkp_change * -1.1111);
                    end
                end
            end

            member.dkp['total'] = member.dkp['total'] + dkp_change
            member:Save()
        end
    end
    self:_UpdateTables();
end

function DKP:RollBackEntries(decayEntry)
    PDKP:PrintD("DKP:RollBackEntries()");
    local all_keys = {}
    local keys_to_rollback = {}

    for entryID, _ in pairs(DKP_DB) do
        table.insert(all_keys, entryID)
    end
    table.sort(all_keys)

    if #all_keys == 0 then return end

    if all_keys[#all_keys] > decayEntry.id then
        for i=1, #all_keys do
            local key = all_keys[i]
            if key > decayEntry.id then
                table.insert(keys_to_rollback, key)
            end
        end
    end
    -- Reverse them in order from newest to oldest.
    table.sort(keys_to_rollback, function(a,b) return a>b end)

    local entries = {}
    for i=1, #keys_to_rollback do
        local encoded_entry = DKP_DB[keys_to_rollback[i]]
        local decoded_entry = CommsManager:DatabaseDecoder(encoded_entry)
        local entry = MODULES.DKPEntry:new(decoded_entry)
        table.insert(entries, entry)
    end

    if #entries >= 1 then
        PDKP:PrintD("Rolling back", #entries, "Entries")
        for i=1, #entries do
            local entry = entries[i]

            if entry.reason == 'Decay' and (entry['decayAmounts'] == nil or next(entry['decayAmounts']) == nil) then
                entry:CalculateDecayAmounts(true)
            end

            for _, member in pairs(entry.members) do
                if member ~= nil then
                    local dkp_change = entry.dkp_change
                    if entry.reason == 'Decay' then
                        if entry['decayAmounts'][member.name] == nil then
                            entry:CalculateDecayAmounts(true)
                        end
                        dkp_change = entry['decayAmounts'][member.name]
                    end
                    member.dkp['total'] = member.dkp['total'] + (dkp_change * -1)
                    member:Save()
                end
            end
            table.insert(self.rolledBackEntries, entry)
        end
    end
end

function DKP:RollForwardEntries()
    --- Since they are sorted in reverse, just start at the oldest entry (end)
    --- and work you way to the newest entry (start).

    local shouldCalibrate = #self.rolledBackEntries >= 1
    for i=#self.rolledBackEntries, 1, -1 do
        local entry = self.rolledBackEntries[i]

        for _, member in pairs(entry.members) do
            local dkp_change = entry.dkp_change
            if entry.reason == 'Decay' then
                entry:CalculateDecayAmounts(true)
                dkp_change = entry['decayAmounts'][member.name]
            end
            member.dkp['total'] = member.dkp['total'] + dkp_change
            member:Save()
        end
    end
    wipe(self.rolledBackEntries)

    if self.calibrationTimer ~= nil then
        self.calibrationTimer:Cancel()
        self.calibrationTimer = nil
        shouldCalibrate = true
    end
    if shouldCalibrate then
        self.calibrationTimer = C_Timer.NewTicker(1, function()
            self:RecalibrateDKP()
        end, 1)
    end
end

function DKP:AddToCache(entry)
    if (self.entrySyncCache[entry.id] ~= nil and DKP_DB[entry.id] ~= nil) or self.processedCacheEntries[entry.id] ~= nil then return end

    if self.entrySyncTimer ~= nil then
        self.entrySyncTimer:Cancel();
        self.entrySyncTimer = nil
    end

    self.entrySyncCacheCounter = self.entrySyncCacheCounter + 1
    self.entrySyncCache[entry.id] = entry
    self.processedCacheEntries[entry.id] = true

    self.entrySyncTimer = C_Timer.NewTicker(5, function()
        self.autoSyncInProgress = true
        PDKP:PrintD("Processing", self.entrySyncCacheCounter, "Cached Sync entries...")
        local keys = {}
        for key, _ in pairs(self.entrySyncCache) do table.insert(keys, key) end
        table.sort(keys)

        for i=1, #keys do
            local key = keys[i]
            local cache_entry = self.entrySyncCache[key]
            self:ImportEntry(cache_entry)
            self.entrySyncCache[key] = nil
            self.entrySyncCacheCounter = self.entrySyncCacheCounter - 1
        end

        self.autoSyncInProgress = false
    end, 1)
end

function DKP:_StartRecompressTimer()
    if self.recompressTimer ~= nil then
        self.recompressTimer:Cancel()
        self.recompressTimer = nil
    end
    self.recompressTimer = C_Timer.NewTicker(5, function()
        self:_RecompressCurrentLoaded()
    end, 1)
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
    if type(batch) ~= "table" then return end

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
            if importEntry ~= nil then
                importEntry:Save(false)
                local weekNumber = Utils:GetWeekNumber(key)
                if weekNumber >= self.currentWeekNumber then
                    self.currentLoadedWeekEntries[key] = encoded_entry
                    self.numCurrentLoadedWeek = self.numCurrentLoadedWeek + 1
                end
            end
        end
    end
end

function DKP:AddNewEntryToDB(entry, updateTable, skipLockouts)
    updateTable = updateTable or true
    skipLockouts = skipLockouts or false

    PDKP:PrintD("DKP:AddNewEntryToDB(): updateTables: ", updateTable, "SkipLockouts", skipLockouts);

    if entry ~= nil then
        local previousDecayEntry = self:GetPreviousDecayEntry(entry);
        if entry.reason == 'Boss Kill' and not skipLockouts then
            PDKP:PrintD("DKP:AddNewEntryToDB() > Lockouts:AddMemberLockouts()");
            MODULES.Lockouts:AddMemberLockouts(entry)
            entry:GetMembers()
        end

        local dkp_change = nil;
        for _, member in pairs(entry.members) do
            if entry.reason == "Decay" then
                dkp_change = entry['decayAmounts'][member.name]

                if entry.decayReversal and not entry.deleted and dkp_change < 0 then
                    if previousDecayEntry ~= nil then
                        dkp_change = previousDecayEntry['decayAmounts'][member.name]
                    else
                        dkp_change = math.ceil(dkp_change * -1.1111);
                    end
                end
            end

            member:_UpdateDKP(entry, dkp_change)
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

function DKP:GetEntriesForSync()
    --loadAfterWeek = loadAfterWeek or 0

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
