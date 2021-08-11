local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils;

local GetServerTime = GetServerTime
local tinsert, tsort, pairs = table.insert, table.sort, pairs

local DKP = {}

local DKP_DB, Lockouts, CommsManager, Ledger;
local DKP_Entry;

function DKP:Initialize()
    DKP_DB = MODULES.Database:DKP()
    CommsManager = MODULES.CommsManager;
    DKP_Entry = MODULES.DKPEntry;
    Lockouts = MODULES.Lockouts;
    Ledger = MODULES.LedgerManager;

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
    self.compressedCurrentWeekEntries = CommsManager:DataEncoder({ ['total'] = self.numCurrentLoadedWeek, ['entries'] = self.currentLoadedWeekEntries })
end

-----------------------------
--     Export Functions    --
-----------------------------

function DKP:ExportEntry(entry)
    PDKP:PrintD("DKP:ExportEntry()")
    local save_details = MODULES.LedgerManager:GenerateEntryHash(entry)
    CommsManager:SendCommsMessage('SyncSmall', save_details)
end

function DKP:PrepareOverwriteExport()
    local exportDetails = {
        ['dkp'] = MODULES.Database:DKP(),
        ['ledger'] = MODULES.Database:Ledger(),
        ['lockouts'] = MODULES.Database:Lockouts(),
        ['guild'] = MODULES.Database:Guild(),
    }
    CommsManager:SendCommsMessage('SyncOver', exportDetails)
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

function DKP:_EntryAdlerExists(entryId, entryAdler)
    local db_entry = DKP_DB[entryId]
    return db_entry ~= nil and CommsManager:_Adler(db_entry) == entryAdler
end

-- Import Types: Small, Large, Ad?
function DKP:ImportEntry2(entry, entryAdler, importType)
    PDKP:PrintD("Importing new entry");
    if entry == nil then return end
    local importEntry = DKP_Entry:new(entry)
    importEntry.adler = entryAdler;

    if self:_EntryAdlerExists(importEntry.id, entryAdler) then
        return -- We already have the entry, and it matches.
    end

    if importEntry.reason == "Boss Kill" and importEntry.lockoutsChecked == false then
        -- There are no valid members, then do not import the entry
        if not Lockouts:VerifyMemberLockouts(importEntry) then
            self:_UpdateTables();
            PDKP:PrintD("Entry does not have valid members for this boss lockout");
            return;
        end
    end

    -- Roll back entries here

    Lockouts:AddMemberLockouts(importEntry)
    local entryMembers, _ = importEntry:GetMembers();

    if #entryMembers == 0 then
        PDKP:PrintD('No members found for:', importEntry.reason, ' Skipping import')
        DKP:_UpdateTables()
        return
    end

    importEntry.formattedNames = importEntry:_GetFormattedNames()

    importEntry:ApplyEntry();
    local encoded_entry = importEntry:Save();

    self.entries[importEntry.id] = importEntry
    self.numOfEntries = self.numOfEntries + 1
    self.currentLoadedWeekEntries[importEntry.id] = encoded_entry
    self.numCurrentLoadedWeek = self.numCurrentLoadedWeek + 1;

    if importType ~= 'Large' then
        self:_StartRecompressTimer();
    end

    if #self.rolledBackEntries then
        self:RollForwardEntries();
    end

    if importType ~= 'Large' then
        self:RecalibrateDKP();
        DKP:_UpdateTables();
    end

    return importEntry;
end

function DKP:DeleteEntry(entry, sender, isImport)
    isImport = isImport or false;
    local importEntry = MODULES.DKPEntry:new(entry)
    local temp_entry = {
        ['reason'] = 'Other',
        ['names'] = importEntry['names'],
        ['officer'] = sender,
        ['dkp_change'] = importEntry['dkp_change'] * -1,
        ['other_text'] = 'DKP Correction'
    }

    if importEntry.reason == 'Decay' then
        temp_entry['reason'] = 'Decay'
        temp_entry['decayReversal'] = true
        temp_entry['previousDecayId'] = importEntry['id']
    end

    if self:GetEntryByID(entry.id) ~= nil then
        if importEntry['deleted'] and sender ~= importEntry['deletedBy'] then
            PDKP:PrintD(entry['id'], "Entry has previously been deleted, skipping delete sequence")
            return
        else
            PDKP:PrintD("Entry was found during delete")
            importEntry:MarkAsDeleted(sender)
            Lockouts:DeleteMemberFromLockout(entry)
            local import_sd = importEntry:GetSaveDetails()
            DKP_DB[entry.id] = CommsManager:DatabaseEncoder(import_sd)
            self.entries[entry.id] = importEntry
        end
    else
        if entry.reason ~= "Decay" then
            PDKP:PrintD(entry['id'], "Entry was not found during delete, importing it first...");
            local encoded_entry = CommsManager:DatabaseEncoder(entry);
            self:ImportEntry2(entry, CommsManager:_Adler(encoded_entry), 'Large');
            return self:DeleteEntry(entry, sender, true);
        else
            return -- Don't fuck with decay entries that you don't already have. Wait for an import.
        end
    end

    if PDKP.canEdit and sender == Utils:GetMyName() then
        local corrected_entry = MODULES.DKPEntry:new(temp_entry)
        corrected_entry:Save(false, true)
    end

    if not isImport then
        self:RecalibrateDKP();
    end
end

function DKP:ImportBulkEntries(message, sender)
    local data = MODULES.CommsManager:DataDecoder(message)
    local total, entries = data['total'], data['entries']

    local entryCounter = 0;

    local decodedEntries = {};
    local entryAdlers = {};

    for key, encoded_entry in pairs(entries) do
        local entryAdler = CommsManager:_Adler(encoded_entry)
        if not self:_EntryAdlerExists(key, entryAdler) then
            entryAdlers[key] = entryAdler;
            decodedEntries[key] = CommsManager:_Decompress(encoded_entry);
        else
            entryCounter = entryCounter + 1;
        end
    end

    for key, decompressedEntry in Utils:PairByKeys(decodedEntries) do
        local entry = CommsManager:_Deserialize(decompressedEntry);
        if entry['deleted'] then
            self:DeleteEntry(entry, sender, true);
        else
            self:ImportEntry2(entry, entryAdlers[key], 'Large');
        end

        if entryCounter >= total then
            C_Timer.After(5, function()
                DKP:RecalibrateDKP()
                DKP:_UpdateTables()
                DKP:_RecompressCurrentLoaded()
            end)
        end
    end
end

function DKP:GetPreviousDecayEntry(entry)
    if entry.previousDecayId and DKP_DB[entry.previousDecayId] then
        return CommsManager:DatabaseDecoder(DKP_DB[entry.previousDecayId])
    end
    return nil;
end

function DKP:RecalibrateDKP()
    if true then return end;

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
    for entryId, encoded_entry in Utils:PairByReverseKeys(DKP_DB) do
        if entryId > decayEntry.id then
            local decoded_entry = CommsManager:DatabaseDecoder(encoded_entry)
            local entry = MODULES.DKPEntry:new(decoded_entry)

            if entry.reason == 'Decay' and (entry['decayAmounts'] == nil or next(entry['decayAmounts']) == nil) then
                entry:CalculateDecayAmounts(true)
            end

            for _, member in pairs(entry.members) do
                if member ~= nil then
                    local dkp_change = entry.dkp_change
                    if entry.reason == 'Decay' then
                        if entry['decayAmounts'][member.name] == nil then
                            entry:CalculateDecayAmounts(true)
                            self:RecalibrateDKP();
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

    --if #keys_to_rollback == 0 then return end;
    --
    --for i=1, #keys_to_rollback do
    --    local encoded_entry = DKP_DB[keys_to_rollback[i]]
    --end

    --[[
    for entryID, _ in pairs(DKP_DB) do
        table.insert(all_keys, entryID)
    end
    table.sort(all_keys)
    if #all_keys == 0 then return end
   --]]
    --[[
    if all_keys[#all_keys] > decayEntry.id then
        for i=1, #all_keys do
            local key = all_keys[i]
           if key > decayEntry.id then
               table.insert(keys_to_rollback, key)
            end
        end
    end
    ---- Reverse them in order from newest to oldest.
    table.sort(keys_to_rollback, function(a,b) return a>b end)
    --]]

    --for i=1, #keys_to_rollback do
    --    local encoded_entry = DKP_DB[keys_to_rollback[i]]
    --    local decoded_entry = CommsManager:DatabaseDecoder(encoded_entry)
    --    local entry = MODULES.DKPEntry:new(decoded_entry)
    --    table.insert(entries, entry)
    --end
    --
    --if #entries >= 1 then
    --    PDKP:PrintD("Rolling back", #entries, "Entries")
    --    for i=1, #entries do
    --        local entry = entries[i]
    --
    --        if entry.reason == 'Decay' and (entry['decayAmounts'] == nil or next(entry['decayAmounts']) == nil) then
    --            entry:CalculateDecayAmounts(true)
    --        end
    --
    --        for _, member in pairs(entry.members) do
    --            if member ~= nil then
    --                local dkp_change = entry.dkp_change
    --                if entry.reason == 'Decay' then
    --                    if entry['decayAmounts'][member.name] == nil then
    --                        entry:CalculateDecayAmounts(true)
    --                        self:RecalibrateDKP();
    --                    end
    --                    dkp_change = entry['decayAmounts'][member.name]
    --                end
    --                member.dkp['total'] = member.dkp['total'] + (dkp_change * -1)
    --                member:Save()
    --            end
    --        end
    --        table.insert(self.rolledBackEntries, entry)
    --    end
    --end
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
--      Time Functions     --
-----------------------------

function DKP:_CreateBatches(entries, total)
    local batches = {}
    local index = 1

    local total_batches = math.ceil(total / 50)
    for i = 1, total_batches do
        batches[i] = {}
    end

    for key, entry in Utils:PairByKeys(entries) do
        if #batches[index] >= 50 then
            index = index + 1
        end
        batches[index][key] = entry
    end
    return batches, total_batches
end

function DKP:_ProcessEntryBatch(batch, sender)
    if type(batch) ~= "table" then return end

    for key, encoded_entry in Utils:PairByKeys(batch) do
        local shouldContinue = true;

        if encoded_entry ~= nil then
            local entryAdler = CommsManager:_Adler(encoded_entry)

            if self:_EntryAdlerExists(key, entryAdler) then
                shouldContinue = false;
            end

            if shouldContinue then
                PDKP:PrintD("ProcessEntryBatch", encoded_entry)
                local entry = CommsManager:DatabaseDecoder(encoded_entry)

                if entry['deleted'] then
                    self:DeleteEntry(entry, sender)
                else
                    self:ImportEntry2(entry, entryAdler, 'Large');
                end
            end
        else
            PDKP:PrintD("Encoded entry was nil", key);
        end
    end
    return true;
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
        transmission_entries[id] = CommsManager:DatabaseEncoder(save_details)
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
