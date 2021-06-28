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

function DKP:ExportEntry(entry)
    MODULES.CommsManager:SendCommsMessage('SyncSmall', entry.sd, 'GUILD', nil, 'BULK', nil)
--    Comms:SendCommsMessage

    --function Comms:SendCommsMessage(prefix, data, distro, sendTo, bulk, func)
    --    local transmitData = Comms:DataEncoder(data)
    --    PDKP:SendCommMessage(prefix, transmitData, distro, sendTo, bulk, func)
    --end
end

function DKP:ImportEntry(entry, sender)
    local importEntry = MODULES.DKPEntry:new(entry)
    importEntry:Save(true)
end

function DKP:ImportBulkEntries(entries, sender)
    print('Importing bulk entries')
end

function DKP:AddNewEntryToDB(entry, updateTable)
    if updateTable == nil then updateTable = true end

    for _, member in pairs(entry.members) do
        member:_UpdateDKP(entry.sd.dkp_change)
        member:Save()
    end
    DKP_DB[entry.id] = MODULES.CommsManager:DatabaseEncoder(entry.sd)

    self.entries[entry.id] = entry
    self.numOfEntries = self.numOfEntries + 1

    if updateTable then
        PDKP.memberTable:DataChanged()
        GUI.HistoryGUI:RefreshData()
        GUI.LootGUI:RefreshData()
    end
end

function DKP:_LoadEncodedDatabase()
    for index, entry in pairs(DKP_DB) do
        self.encoded_entries[index] = entry
        self.numOfEncoded = self.numOfEncoded + 1
    end
end

MODULES.DKPManager = DKP