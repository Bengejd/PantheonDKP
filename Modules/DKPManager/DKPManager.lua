local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local GetServerTime = GetServerTime
local tinsert, tsort, pairs = table.insert, table.sort, pairs

local DKP = {}

local DKP_DB, GUILD_DB, CommsManager;

function DKP:Initialize()
    DKP_DB = MODULES.Database:DKP()
    CommsManager = MODULES.CommsManager;

    self.entries = {}
    self.encoded_entries = {}
    self.decoded_entries = {}
    self.numOfEntries = 0
    self.numOfDecoded = 0
    self.numOfEncoded = 0

    self.currentLoadedWeek = Utils.weekNumber

    self:_LoadEncodedDatabase()
    self:LoadPrevFourWeeks()
end

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
        for i=1, #filterReasons do
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

    if sorted then tsort(keys, function(a, b) return a > b end) end

    return keys;
end

function DKP:GetEntryByID(id)
    return self.entries[id]
end

function DKP:GetNumEncoded()
    return self.numOfEncoded
end

function DKP:LoadPrevFourWeeks()
    self.currentLoadedWeek = self.currentLoadedWeek - 4

    self.numOfEncoded = 0

    for index, entry in pairs(self.encoded_entries) do
        self.numOfEncoded = self.numOfEncoded + 1

        local weekNumber = Utils:GetWeekNumber(index)
        if weekNumber >= self.currentLoadedWeek then
            local decoded_entry = CommsManager:DatabaseDecoder(entry)
            if decoded_entry == nil then decoded_entry = entry; end
            self.entries[index] = MODULES.DKPEntry:new(decoded_entry)
            self.numOfEntries = self.numOfEntries + 1
        end
    end

    for index, _ in pairs(self.entries) do
        if self.encoded_entries[index] ~= nil then
            self.encoded_entries[index] = nil
            self.numOfEncoded = self.numOfEncoded - 1
        end
    end

    PDKP.CORE:Print(tostring(self.numOfEntries) .. ' entries have been loaded')

    return self.numOfEncoded
end

function DKP:GetOldestAndNewestEntry()
    local newestEntry = 0
    local oldestEntry = GetServerTime()

    for index, _ in pairs(DKP_DB) do
        if index > newestEntry then
            newestEntry = index
        end
        if index < oldestEntry then
            oldestEntry = index;
        end
    end
    return oldestEntry, newestEntry;
end

function DKP:GetMyDKP()
    local dkpTotal = 0
    if PDKP.char ~= nil then
        dkpTotal = PDKP.char:GetDKP('total')
    end
    if dkpTotal == nil then
        return 0
    end
    return dkpTotal
end

function DKP:ExportEntry(entry)
    MODULES.CommsManager:SendCommsMessage('SyncSmall', entry.sd)
end

function DKP:ImportEntry(entry, sender)
    local importEntry = MODULES.DKPEntry:new(entry)
    importEntry:Save(true)
end

function DKP:ImportBulkEntries(message, sender)
    PDKP.CORE:Print('Importing bulk entries from', sender)
    local data = MODULES.CommsManager:DataDecoder(message)

    local total, entries = data['total'], data['entries']

    local batches, total_batches = self:_CreateBatches(entries, total)
    local currentBatch = 0
    self.importTicker = C_Timer.NewTicker(0.5, function()
        currentBatch = currentBatch + 1
        DKP:_ProcessEntryBatch(batches[currentBatch])

        if PDKP:IsDev() then
            PDKP.CORE:Print('Processing import batch', tostring(currentBatch) .. '/' .. tostring(total_batches))
        end

        if currentBatch == total_batches then
            DKP:_UpdateTables()
            DKP.importTicker:Cancel()
        end
    end, total_batches)
end

function DKP:BossKillDetected(bossID, bossName)
    if not PDKP.canEdit then return end
    local dkpAwardAmount = 10

    if MODULES.Constants.BOSS_TO_RAID[bossName] ~= nil then
        GUI.Dialogs:Show( 'PDKP_RAID_BOSS_KILL', { bossName, dkpAwardAmount }, bossName)
    end
end

function DKP:AwardBossKill(boss_name)
    if not PDKP.canEdit then return end

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
        ['boss'] = boss_name
    }

    for i=1, #memberNames do
        local memberName = memberNames[i]
        local member = GuildManager:GetMemberByName(memberName)
        if member then
            tinsert(dummy_entry['names'], member.name)
        elseif true then
            --print('FUCK', memberName)
        end
    end

    local entry = PDKP.MODULES.DKPEntry:new(dummy_entry)

    if entry:IsValid() then
        entry:Save(false, true)
    end
end

function DKP:_CreateBatches(entries, total)
    local batches = {}
    local index = 1

    local total_batches = math.ceil(total / 50)
    for i=1, total_batches do
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
        PDKP.CORE:Print(GetFramerate())
        local entry = MODULES.CommsManager:DatabaseDecoder(encoded_entry)
        local importEntry = MODULES.DKPEntry:new(entry)
        importEntry:Save(false)
    end
end

function DKP:AddNewEntryToDB(entry, updateTable)
    if updateTable == nil then updateTable = true end

    if entry ~= nil then
        for _, member in pairs(entry.members) do
            member:_UpdateDKP(entry.sd.dkp_change)
            member:Save()
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
    PDKP.memberTable:DataChanged()
    GUI.HistoryGUI:RefreshData()
    GUI.LootGUI:RefreshData()
end

function DKP:_LoadEncodedDatabase()
    for index, entry in pairs(DKP_DB) do
        self.encoded_entries[index] = entry
        self.numOfEncoded = self.numOfEncoded + 1
    end
    if PDKP:IsDev() then
        PDKP.CORE:Print('Loaded', self.numOfEncoded, 'Encoded entries');
    end
end

MODULES.DKPManager = DKP