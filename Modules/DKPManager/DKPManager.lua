local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils;

local GetServerTime = GetServerTime
local tinsert, tsort, pairs = table.insert, table.sort, pairs

local DKP = {}

local DKP_DB, Lockouts, CommsManager, _;
local DKP_Entry;

function DKP:Initialize()
    DKP_DB = MODULES.Database:DKP()
    CommsManager = MODULES.CommsManager;
    DKP_Entry = MODULES.DKPEntry;
    Lockouts = MODULES.Lockouts;
    --Ledger = MODULES.LedgerManager;

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
    self.calibratedTotals = {}

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
            local entry = MODULES.DKPEntry:new(encoded_entry)

            --if entry.id == 1628721427 then
            --    CommsManager:DatabaseEncoder(entry, true);
            --end

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

    MODULES.GuildManager:Initialize();
    self:Initialize();
    self:_UpdateTables();
    PDKP.CORE:Print("Database overwrite has completed. Please reload for it to take effect.");
end

-----------------------------
--     Import Functions    --
-----------------------------

function DKP:_FindAdlerDifference(importEntry, dbEntry)
    local dbEntrySD, dbEntryKeys = dbEntry:GetSerializedSelf();
    local importEntrySD, importEntryKeys = importEntry:GetSerializedSelf();
    local keysMatch = #importEntryKeys == #dbEntryKeys

    PDKP:PrintD("Keys Match:", keysMatch);

    Utils:WatchVar(importEntry, 'Import');
    Utils:WatchVar(dbEntry, 'DB');

    for _, v in pairs(importEntryKeys) do
        local importVal = importEntrySD[v]
        local dbVal = dbEntrySD[v];
        if type(v) ~= "table" then
            if importVal ~= dbVal then
                PDKP.CORE:Print("Entry mismatch found, skipping import for safety reasons");
                return false;
            end
        end
    end

    if importEntry['hash'] ~= dbEntry['hash'] then
        return true;
    end
    return true;
end

function DKP:_EntryAdlerExists(entryId, entryAdler)
    local entryExists, dbEntry = self:_EntryExists(entryId)
    local adlerMatches = false;
    if entryExists then
        adlerMatches = self:_AdlerMatches(dbEntry, entryAdler);
    end
    return entryExists, adlerMatches;
end

function DKP:_AdlerMatches(db_entry, entryAdler)
    return CommsManager:_Adler(db_entry) == entryAdler;
end

function DKP:_EntryExists(entryId)
    return DKP_DB[entryId] ~= nil, DKP_DB[entryId];
end

-- Import Types: Small, Large, Ad?
function DKP:ImportEntry2(entryDetails, entryAdler, importType)
    if entryDetails == nil then return end
    local importEntry = DKP_Entry:new(entryDetails)

    if entryAdler == nil and type(entryDetails == "string") then
        entryAdler = importEntry.adler;
        if entryAdler == nil then
            return;
        end
    end

    local entryExists, adlerMatches = self:_EntryAdlerExists(importEntry.id, entryAdler)

    PDKP:PrintD("ID:", importEntry.id, "EntryExists", entryExists, "AdlerMatches", adlerMatches);

    if entryExists then
        if adlerMatches then
            PDKP:PrintD("Entry Adler Exists already, returning");
            return;
        end
        PDKP:PrintD("Entry Adler does not match", importEntry.id);

        local dbEntry = DKP_Entry:new(DKP_DB[importEntry.id]);
        local shouldContinue = self:_FindAdlerDifference(importEntry, dbEntry);

        if not shouldContinue then
            return;
        end

        dbEntry:UndoEntry();
        DKP_DB[importEntry.id] = nil;
    end

    if importEntry.reason == "Boss Kill" and importEntry.lockoutsChecked == false then
        -- There are no valid members, then do not import the entry
        if not Lockouts:VerifyMemberLockouts(importEntry) then
            self:_UpdateTables();
            PDKP:PrintD("Entry does not have valid members for this boss lockout");
            return;
        end
    end

    -- Add members to the lockout, if appropriate.
    Lockouts:AddMemberLockouts(importEntry)
    local entryMembers, _ = importEntry:GetMembers();

    if #entryMembers == 0 then
        PDKP:PrintD('No members found for:', importEntry.reason, ' Skipping import')
        DKP:_UpdateTables()
        return
    end

    PDKP:PrintD("Importing new entry", importEntry.id);

    -- Roll back entries here
    self:RollBackEntries(importEntry);

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
        --self:RecalibrateDKP();
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
        --self:RecalibrateDKP();
    end
end

function DKP:ImportBulkEntries(message, sender)
    local data = MODULES.CommsManager:DataDecoder(message)
    local _, entries = data['total'], data['entries']

    for _, encoded_entry in Utils:PairByKeys(entries) do
        local entryAdler = CommsManager:_Adler(encoded_entry)
        self:ImportEntry2(encoded_entry, entryAdler, 'Large');
    end

    DKP:_UpdateTables()
    --for key, decompressedEntry in Utils:PairByKeys(decodedEntries) do
    --    local entry = CommsManager:_Deserialize(decompressedEntry);
    --    if entry['deleted'] then
    --        self:DeleteEntry(entry, sender, true);
    --    else
    --        self:ImportEntry2(entry, entryAdlers[key], 'Large');
    --    end
    --
    --    if entryCounter >= total then
    --        C_Timer.After(5, function()
    --            DKP:RecalibrateDKP()
    --
    --            DKP:_RecompressCurrentLoaded()
    --        end)
    --    end
    --end
end

function DKP:GetPreviousDecayEntry(entry)
    if entry.previousDecayId and DKP_DB[entry.previousDecayId] then
        return CommsManager:DatabaseDecoder(DKP_DB[entry.previousDecayId])
    end
    return nil;
end

function DKP:RecalibrateDKP()
    PDKP.CORE:Print("Recalibrating DKP totals... this may cause some temporary lag...");

    self:RollBackEntries({ ['id']  = 0 } );

    local members = MODULES.GuildManager.members
    for _, member in pairs(members) do
        self.calibratedTotals[member.name] = member.dkp['total'];
        member.dkp['total'] = 30
        member:Save()
    end

    self:RollForwardEntries();
    self:_UpdateTables();

    local calibratedMembers = {};
    for _, member in pairs(members) do
        local memberDKP = member:GetDKP();
        if memberDKP ~= self.calibratedTotals[member.name] then
            table.insert(calibratedMembers, member);
            PDKP:PrintD(member.name, memberDKP, self.calibratedTotals[member.name]);
        end
    end

    PDKP.CORE:Print('Updated ', #calibratedMembers, 'members totals');
end

function DKP:RollBackEntries(decayEntry)
    for entryId, encoded_entry in Utils:PairByReverseKeys(DKP_DB) do
        if entryId > decayEntry.id then
            local decoded_entry = CommsManager:DatabaseDecoder(encoded_entry)
            local entry = MODULES.DKPEntry:new(decoded_entry)
            entry:UndoEntry();
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
        if entry.reason == 'Decay' then
            entry:GetPreviousTotals(true);
            entry:GetDecayAmounts(true);
        end
        entry:ApplyEntry();
    end
    wipe(self.rolledBackEntries)

    if self.calibrationTimer ~= nil then
        self.calibrationTimer:Cancel()
        self.calibrationTimer = nil
        shouldCalibrate = true
    end
    if shouldCalibrate then
        --self.calibrationTimer = C_Timer.NewTicker(1, function()
        --    self:RecalibrateDKP()
        --end, 1)
    end
end

function DKP:AddToCache(entry)
    if self.entrySyncCache[entry.id] ~= nil or self.processedCacheEntries[entry.id] ~= nil then return end

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
        for key, cacheEntry in Utils:PairByKeys(self.entrySyncCache) do
            self:ImportEntry2(cacheEntry, nil, 'Large');
            self.entrySyncCache[key] = nil;
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
