local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils;
local GUtils = PDKP.GUtils;

local GetServerTime = GetServerTime
local tinsert, tsort, pairs = table.insert, table.sort, pairs
local floor = math.floor

local coroutine_create = coroutine.create
local coroutine_resume = coroutine.resume
local coroutine_yield = coroutine.yield

local UIParent = UIParent
local C_Timer = C_Timer;

local maxProcessCount = 2;

local DKP = {}

local DKP_DB, Lockouts, CommsManager, _;
local DKP_Entry;

function DKP:Initialize()
    DKP_DB = MODULES.Database:DKP()
    CommsManager = MODULES.CommsManager;
    DKP_Entry = MODULES.DKPEntry;
    Lockouts = MODULES.Lockouts;

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

    self.syncStatuses = {};
    self.syncFrame = nil;
    self.syncProcessing = false;
    self.syncCache = MODULES.Database:Cache();

    self.leftoverSync = #self.syncCache > 0;

    self.compressedCurrentWeekEntries = ''
    self.lastAutoSync = GetServerTime()
    self.autoSyncInProgress = false

    self.entrySyncCacheCounter = 0
    self.syncReqLocked = false;

    self.entrySyncCache = {}
    self.entrySyncTimer = nil
    self.processedCacheEntries = {}

    self.consolidationEntry = nil;

    self.rolledBackEntries = {}
    self.calibratedTotals = {}

    self:_LoadEncodedDatabase()
    self:LoadPrevFourWeeks()

    self:CheckForNegatives()

    self:ProcessCache();

    C_Timer.After(5, function()
        PDKP.CORE:Print(tostring(self.numOfEntries) .. ' entries have been loaded')
        self:_UpdateTables();
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

function DKP:PrepareAdRequest()
    if self.autoSyncInProgress then return end
    local lastTwoWeekNumber = Utils.weekNumber - 2
    local entries = {};
    for index, entry in Utils:PairByKeys(self.currentLoadedWeekEntries) do
        local weekNumber = Utils:GetWeekNumber(index)
        if weekNumber >= lastTwoWeekNumber then
            entries[index] = entry;
        end
    end

    return CommsManager:SendCommsMessage(Utils:GetMyName(), { ['total'] = 0, ['entries'] = entries });
end

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
        ['phases'] = MODULES.Database:Phases(),
    }
    CommsManager:SendCommsMessage('SyncOver', exportDetails)
end

function DKP:ProcessOverwriteSync(message, sender)
    PDKP.CORE:Print("Processing database overwrite from", sender)

    for dbName, db in pairs(message) do
        --Utils:WatchVar(db, dbName);
        MODULES.Database:ProcessDBOverwrite(dbName, db)
    end

    C_Timer.After(3, function()
        PDKP.CORE:_Reinitialize()
        PDKP.CORE:Print("Database overwrite has completed");
    end)
end

function DKP:ProcessSquish(entry)
    PDKP:PrintD("ProcessSquish Called");
    if self.syncProcessing then
        PDKP:PrintD("Skipping Squish Processing");
        self.consolidationEntry = entry;
        return;
    end

    PDKP.CORE:Print("Processing Phase DKP Entry Consolidation");
    local newer_entries = {}
    local olderEntryCounter = 0;
    for id, encoded_entry in pairs(DKP_DB) do
        if id >= entry.id then
            newer_entries[id] = encoded_entry
        elseif id < entry.id then
            olderEntryCounter = olderEntryCounter + 1;
        end
    end

    if newer_entries[entry.id] == nil then
        newer_entries[entry.id] = CommsManager:DatabaseEncoder(entry:GetSaveDetails());
    end

    self.consolidationEntry = nil;

    if olderEntryCounter >= 1 then
        PDKP:PrintD("Overwriting dkp db after squish");
        MODULES.Database:ProcessDBOverwrite('dkp', newer_entries)

        C_Timer.After(2, function()
            PDKP.CORE:_Reinitialize();
        end)
    end
end

-----------------------------
--     Import Functions    --
-----------------------------

function DKP:_FindAdlerDifference(importEntry, dbEntry)
    local dbEntrySD, dbEntryKeys = dbEntry:GetSerializedSelf();
    local importEntrySD, importEntryKeys = importEntry:GetSerializedSelf();
    local keysMatch = #importEntryKeys == #dbEntryKeys

    PDKP:PrintD("Keys Match:", keysMatch);

    --Utils:WatchVar(importEntry, 'Import');
    --Utils:WatchVar(dbEntry, 'DB');

    for _, v in pairs(importEntryKeys) do
        local importVal = importEntrySD[v]
        local dbVal = dbEntrySD[v];
        if type(v) ~= "table" then
            if importVal ~= dbVal then
                PDKP:PrintD("Entry mismatch found, skipping import for safety reasons");
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
    if entryDetails == nil then return nil end
    local importEntry = DKP_Entry:new(entryDetails)

    if not self:_ShouldImportNewEntry(importEntry.id) then
        return nil
    end

    if entryAdler == nil and type(entryDetails == "string") then
        entryAdler = importEntry.adler;
        if entryAdler == nil then
            return nil
        end
    end

    local entryExists, adlerMatches = self:_EntryAdlerExists(importEntry.id, entryAdler)

    if entryExists then
        if adlerMatches then
            PDKP:PrintD("Entry Adler Exists already, returning");
            return nil
        end
        PDKP:PrintD("Entry Exists, but Adler does not match", importEntry.id);

        local dbEntry = DKP_Entry:new(DKP_DB[importEntry.id]);
        local shouldContinue = self:_FindAdlerDifference(importEntry, dbEntry);

        if not shouldContinue then
            return nil
        end

        dbEntry:UndoEntry();
        DKP_DB[importEntry.id] = nil;
    end

    if importEntry.reason == "Boss Kill" and importEntry.lockoutsChecked == false then
        -- There are no valid members, then do not import the entry
        if not Lockouts:VerifyMemberLockouts(importEntry) then
            self:_UpdateTables();
            PDKP:PrintD("Entry does not have valid members for this boss lockout");
            return nil
        end
    end

    -- Add members to the lockout, if appropriate.
    Lockouts:AddMemberLockouts(importEntry)
    local entryMembers, _ = importEntry:GetMembers();

    if #entryMembers == 0 then
        PDKP:PrintD('No members found for:', importEntry.reason, ' Skipping import')
        DKP:_UpdateTables()
        return nil
    end

    -- Roll back entries here
    if importType ~= "Large" then
        self:RollBackEntries(importEntry);
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
        DKP:_UpdateTables();
    end

    if importEntry.isNewPhaseEntry == true and importEntry.reason == "Phase" then
        local phaseDB = MODULES.Database:Phases()
        tinsert(phaseDB, importEntry.id);
        Utils:WatchVar(importEntry, 'phase');
        importEntry:_UpdateSnapshots();
        self:ProcessSquish(importEntry);
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

    if importEntry.reason == 'Phase' then
        temp_entry['reason'] = 'Phase'
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
        if entry.reason ~= "Decay" and entry.reason ~= "Phase" then
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
        corrected_entry:Save(true)
    end

    if not isImport then
        --self:RecalibrateDKP();
    end
end

function DKP:ImportBulkEntries(message, sender, decoded)
    if self.syncProcessing then
        self:AddToCache(message, sender, decoded);
        return self:UpdateSyncProgress(sender, 'queued', 1, 100);
    else
        self.syncProcessing = true;
    end

    maxProcessCount = MODULES.Options:processingChunkSize()

    local data
    if decoded ~= true then
        data = MODULES.CommsManager:DataDecoder(message, true)
    else
        data = message
    end

    local member = MODULES.GuildManager:GetMemberByName(sender)

    if member ~= nil then
        member:MarkSyncReceived()
    end

    local _, entries = data['total'], data['entries']
    local total = 0;
    for _, _ in pairs(entries) do
        total = total + 1
    end

    local processing = CreateFrame('Frame')
    local processCount = 0;

    local co = coroutine_create(function()
        for _, encoded_entry in Utils:PairByKeys(entries) do
            local entryAdler = CommsManager:_Adler(encoded_entry)
            local importEntry = self:ImportEntry2(encoded_entry, entryAdler, 'Large');
            if importEntry ~= nil and importEntry.reason == "Phase" and importEntry.isNewPhaseEntry then
                PDKP:PrintD("New Phase Entry Found", importEntry.id);
                self.syncStatuses[sender] = nil;
                self:AddToCache({['total'] = total, ['entries'] = Utils:DeepCopy(entries) }, sender, true);
                self.syncProcessing = false;
                self:ProcessSquish(importEntry);
                break;
            end

            processCount = processCount + 1;
            if processCount >= (maxProcessCount -1) and processCount % (maxProcessCount -1) == 0 then
                coroutine_yield()
            end
        end
    end)

    processing:SetScript('OnUpdate', function()
        self:UpdateSyncProgress(sender, '2/4', processCount, total);
        local ongoing = coroutine_resume(co)
        if not ongoing then
            processing:SetScript('OnUpdate', nil)
            if self.consolidationEntry == nil then
                self:RecalibrateDKPBulk(sender, total)
            end
        end
    end)
end

function DKP:GetPreviousDecayEntry(entry)
    if entry.previousDecayId and DKP_DB[entry.previousDecayId] then
        return CommsManager:DatabaseDecoder(DKP_DB[entry.previousDecayId])
    end
    return nil;
end

function DKP:RecalibrateDKP()
    --PDKP.CORE:Print("Recalibrating DKP totals...");

    local members = MODULES.GuildManager.members
    for _, member in pairs(members) do
        self.calibratedTotals[member.name] = Utils:ShallowCopy(member:GetDKP());
    end

    self:RollBackEntries({ ['id']  = 0 } );
    for _, member in pairs(members) do
        member.dkp['total'] = member.dkp['snapshot']
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

    PDKP.CORE:Print('Calibrated', #calibratedMembers, 'members DKP totals');
end

function DKP:RecalibrateDKPBulk(sender, total)
    self:RollBackEntriesBulk(sender, total)
end

function DKP:RollBackEntriesBulk(sender, ttl)
    local rollBackProcessing = CreateFrame('Frame')
    local processCount = 0;

    local total = 0;
    for _, _ in pairs(DKP_DB) do
        total = total + 1;
    end

    local rollBackCo = coroutine_create(function()
        for _, encoded_entry in Utils:PairByReverseKeys(DKP_DB) do
            local decoded_entry = CommsManager:DatabaseDecoder(encoded_entry)
            local entry = MODULES.DKPEntry:new(decoded_entry)
            entry:UndoEntry();
            tinsert(self.rolledBackEntries, entry)
            processCount = processCount + 1;
            if processCount >= maxProcessCount and processCount % maxProcessCount == 0 then
                coroutine_yield()
            end
        end
    end)

    rollBackProcessing:SetScript('OnUpdate', function()
        self:UpdateSyncProgress(sender, '3/4', processCount, total);
        local ongoing  = coroutine_resume(rollBackCo)
        if not ongoing then
            rollBackProcessing:SetScript('OnUpdate', nil)
            local members = MODULES.GuildManager.members
            for _, member in pairs(members) do
                self.calibratedTotals[member.name] = member.dkp['total'];
                member.dkp['total'] = member.dkp['snapshot']
                member:Save()
            end
            self:RollForwardEntriesBulk(sender, total);
        end
    end)
end

function DKP:RollForwardEntriesBulk(sender)
    --- Since they are sorted in reverse, just start at the oldest entry (end)
    --- and work you way to the newest entry (start).

    local total = #self.rolledBackEntries
    local processing = CreateFrame('Frame')
    local processCount = 0;
    local co = coroutine_create(function()
        for i=#self.rolledBackEntries, 1, -1 do
            local entry = self.rolledBackEntries[i]

            if entry.reason == 'Decay' or entry.reason == 'Phase' then
                local refresh = entry.reason == "Decay";
                entry:GetPreviousTotals(refresh);
                entry:GetDecayAmounts(refresh);
            end
            entry:ApplyEntry();
            processCount = processCount + 1;
            if processCount >= maxProcessCount and processCount % maxProcessCount == 0 then
                coroutine_yield()
            end
        end
    end)

    processing:SetScript('OnUpdate', function()
        self:UpdateSyncProgress(sender, '4/4', processCount, total);
        local ongoing  = coroutine_resume(co)
        if not ongoing then
            processing:SetScript('OnUpdate', nil)
            C_Timer.NewTicker(1, function()
                wipe(self.rolledBackEntries)
                self:_UpdateTables();
                self.syncProcessing = false;
                self:UpdateSyncProgress(sender, 'complete', 100, 100);

                if not self.leftoverSync then
                    self:ProcessCache();
                end
            end, 1);
        end
    end)
end

function DKP:RollBackEntries(decayEntry, fullReset)
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

    for i=#self.rolledBackEntries, 1, -1 do
        local entry = self.rolledBackEntries[i]
        if entry.reason == 'Decay' or entry.reason == 'Phase' then
            local refresh = entry.reason == "Decay";
            entry:GetPreviousTotals(refresh);
            entry:GetDecayAmounts(refresh);
        end
        entry:ApplyEntry();
    end
    wipe(self.rolledBackEntries)
end

function DKP:ProcessCache()
    PDKP:PrintD("Processing Cache: ", #self.syncCache)
    if #self.syncCache > 0 then
        local d = self.syncCache[1];
        self:ImportBulkEntries(d['message'], d['sender'], d['decoded'])
        if self.consolidationEntry == nil then
            print('Removing cache item');
            table.remove(self.syncCache, 1);
        end
    end
end

function DKP:AddToCache(message, sender, decoded)
    if self.syncStatuses[sender] == nil then
        table.insert(self.syncCache, { ['message'] = message, ['sender'] = sender, ['decoded'] = decoded });
    else
        PDKP:PrintD("Skipping cache for", sender);
    end
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
    if PDKP.memberTable ~= nil and PDKP.memberTable._initialized then
        PDKP.memberTable:DataChanged()
    end
    if GUI.HistoryGUI ~= nil and GUI.HistoryGUI._initialized then
        GUI.HistoryGUI:RefreshData()
    end
    if GUI.HistoryGUI ~= nil and GUI.LootGUI._initialized then
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
        entry:Save(true)
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

function DKP:GetCaps()
    local members = MODULES.GuildManager.members;
    local _, groupMembers = MODULES.GroupManager:GetRaidMemberObjects();
    local guildCap, groupCap = 0, 0;
    for _, groupMember in pairs(groupMembers) do
        local dkp = groupMember:GetDKP();
        if dkp > groupCap then
            groupCap = dkp;
        end
    end
    for _, guildMember in pairs(members) do
        local dkp = guildMember:GetDKP();
        if dkp > guildCap then
            guildCap = dkp;
        end
    end
    return guildCap, groupCap;
end

function DKP:GetMaxBid()
    local guildCap, _ = self:GetCaps()

    if self:_HasPhaseEntries() then
        return math.floor(guildCap * 0.9);
    else
        return guildCap
    end
end

function DKP:GetTheoreticalCap()
    local previousCap, _ = self:GetCaps();
    local newCap, _ = self:GetCaps();
    newCap = newCap + 0.1;

    local raids = MODULES.Constants.RAID_BOSSES
    local boss_count = 0;
    for _, raid in pairs(raids) do
        boss_count = boss_count + #raid['boss_names']
    end

    local weekCount = 0;
    local capReached = false;

    while newCap >= previousCap do
        weekCount = weekCount + 1;
        newCap = math.floor(newCap);
        newCap = newCap + (10 * boss_count);
        newCap = math.floor((newCap * 0.9));
        if newCap > previousCap then
            previousCap = newCap
        else
            capReached = true;
            break;
        end

        if weekCount >= 666 then
            break
        end
    end
    PDKP.CORE:Print(previousCap, " DKP cap will be reached in", weekCount, "weeks")
    return previousCap, weekCount;
end

function DKP:CheckForNegatives()
    local shouldCalibrate = MODULES.GuildManager:CheckForNegatives()
    if shouldCalibrate then
        self:RecalibrateDKP();
    end
end

-----------------------------
-- Visual Sync Functions   --
-----------------------------

function DKP:UpdateSyncProgress(sender, stage, processed, total)
    if processed == 0 then processed = 1 end
    if total == 0 then total = 1 end
    self.syncStatuses[sender] = { ['stage'] = stage, ['progress'] = floor((processed / total) * 100) }

    if self.syncFrame == nil then
        local f = GUtils:createBackdropFrame('pdkp_DKPSync_frame', UIParent, 'PDKP Sync Progress');
        f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
        f:SetSize(200, 150)
        f.border:SetBackdropColor(unpack({ 0, 0, 0, 0.85 }))
        local scroll = PDKP.SimpleScrollFrame:new(f.content)
        local scrollFrame = scroll.scrollFrame
        local scrollContent = scrollFrame.content;
        GUtils:setMovable(f)

        local close_btn = GUtils:createCloseButton(f, true);
        close_btn:SetSize(24, 22)
        close_btn:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 5)

        f.closeBtn = close_btn;

        f.scrollContent = scrollContent;
        f.scrollContent:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT");
        f.scroll = scroll;
        f.scrollFrame = scrollFrame;
        f:Hide()

        f:SetScript("OnHide", function()
            PDKP.CORE:Print("Sync complete");
        end)

        self.syncFrame = f;
    end

    local scrollContent = self.syncFrame.scrollContent;
    scrollContent:WipeChildren() -- Wipe previous shrouding children frames.

    if not self.syncFrame.forceClosed then
        self.syncFrame:Show()
    end

    local createProgressFrame = function()
        local f = CreateFrame("Frame", nil, scrollContent, nil)
        f:SetSize(scrollContent:GetWidth(), 18)
        f.name = f:CreateFontString(f, "OVERLAY", "GameFontHighlightLeft")
        f.stage = f:CreateFontString(f, 'OVERLAY', 'GameFontNormalRight')
        f.progress = f:CreateFontString(f, 'OVERLAY', 'GameFontNormalRight')
        f.name:SetHeight(18)
        f.stage:SetHeight(18)
        f.progress:SetHeight(18)
        f.name:SetPoint("LEFT")
        f.stage:SetPoint("CENTER", 15, 0)
        f.progress:SetPoint("RIGHT")
        return f
    end

    self.syncFrame:SetHeight(50);

    for name, status in pairs(self.syncStatuses) do
        local pf = createProgressFrame()
        pf.name:SetText(string.sub(name, 0, 8) .. '...');
        pf.progress:SetText(tostring(status['progress']) .. "%");
        pf.stage:SetText(status['stage'])
        scrollContent:AddChild(pf)
        self.syncFrame:SetHeight(self.syncFrame:GetHeight() + 20);
    end

    if self.syncStatuses[sender]['progress'] >= 100 and stage == 'complete' then
        self.syncStatuses[sender] = nil
        self.syncProcessing = false;

        C_Timer.After(1, function()
            if next(self.syncStatuses) == nil and self.syncFrame ~= nil and self.syncFrame:IsVisible() and not self.syncProcessing then
                self.syncFrame:Hide()
                scrollContent:WipeChildren() -- Wipe previous children frames.
                self.syncFrame.forceClosed = false;
            end
        end)
    end
end

function DKP:_ShouldImportNewEntry(id)
    local shouldImport = true;
    for _, p in Utils:PairByKeys(MODULES.Database:Phases()) do
        if p > id then
            shouldImport = false;
        end
    end
    return shouldImport;
end

function DKP:_HasPhaseEntries()
    local total = 0;
    for _, p in Utils:PairByKeys(MODULES.Database:Phases()) do
        total = total + 1;
    end
    return total > 0;
end

MODULES.DKPManager = DKP
