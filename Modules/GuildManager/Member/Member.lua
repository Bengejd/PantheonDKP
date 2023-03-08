local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils

local GetGuildRosterInfo, GetGuildRosterLastOnline = GetGuildRosterInfo, GetGuildRosterLastOnline
local setmetatable = setmetatable
local strsplit, strlower = strsplit, strlower
local tinsert, tremove, unpack = table.insert, table.remove, unpack
local floor, max, abs = math.floor, math.max, math.abs;
local GetServerTime = GetServerTime

local Member = {}

local guildDB, _;

local playerName = UnitName("PLAYER")

Member.__index = Member; -- Set the __index parameter to reference Member

function Member:new(guildIndex, server_time, leadershipRanks, numEntriesToBeActive)
    local self = {};
    setmetatable(self, Member); -- Set the metatable so we used Members's __index

    guildDB = MODULES.Database:Guild()

    self.guildIndex = guildIndex
    self.server_time = server_time
    self.numEntriesToBeActive = numEntriesToBeActive

    self.officerRank, self.classLeadRank = unpack(leadershipRanks)

    self:_GetMemberData(guildIndex)

    if self:IsStrictRaidReady() then
        self:_InitializeDKP()
        self:Save()
    end

    if self.name == "Snaildaddy" then
        PDKP:PrintD(self:_GetAverageEntryDistance())
    end

    if strlower(self.name) == strlower(playerName) then
        PDKP.char = self;
    end

    return self
end

function Member:Save()
    local dkp = {
        ['total'] = self.dkp['total'],
        ['snapshot'] = self.dkp['snapshot'],
    }

    if not Utils:tEmpty(self.dkp['entries']) then
        dkp['entries'] = self.dkp['entries']
    else
        return -- Don't save guildies who have no data associated with them.
    end

    guildDB[self.name] = dkp
end

function Member:IsRaidReady()
    local isOfficer = self.canEdit or self.isOfficer;
    local isMaxLevel = self.lvl >= MODULES.Constants.MAX_LEVEL;
    return (isOfficer or isMaxLevel);
end

function Member:IsInactive()
    local years = self.lastOnline["years"];
    local months = self.lastOnline["months"];

    if years ~= nil and years > 0 then
        return true
    elseif months ~= nil and months >= 1 then
        return true
    end

    return false
end

function Member:IsActiveRaider()
    local dkp = self:GetDKP('Decimal');

    -- Their DKP has been updated at least once.
    if dkp ~= 30 then
        return true
    end

    local numOfEntries = self:GetNumEntries();

    -- In case it is a new member
    if numOfEntries == 0 then
        return true
    end

    -- Check their activity as well, incase they are currently online.
    if self.lastOnline["months"] == nil then
        return true
    end

    -- Has the minimum amount of entries required
    if numOfEntries > self.numEntriesToBeActive then
        return true
    end

    return self:_GetAverageEntryDistance() < 1
end

function Member:IsStrictRaidReady()
    return self:IsRaidReady() and not self:IsInactive() and self:IsActiveRaider()
end

function Member:CanEdit()
    return self.canEdit or self.rankIndex <= 3 or self.isOfficer
end

function Member:GetDKP(dkpVariable)
    if self.dkp['total'] == nil then
        return 0;
    end
    if dkpVariable == nil then
        return floor(self.dkp['total']);
    elseif dkpVariable == 'display' then
        if PDKP:IsDev() and PDKP.showInternalDKP then
            return self.dkp['total'];
        end
        return floor(self.dkp['total']);
    elseif dkpVariable == 'Decimal' then
        return self.dkp['total'];
    end
    return self.dkp[dkpVariable]
end

function Member:HasEntries()
    return self.dkp['entries'] ~= nil and #self.dkp['entries'] > 0;
end

function Member:GetNumEntries()
    if self.dkp['entries'] ~= nil then
        return #self.dkp['entries']
    end
    return 0
end

function Member:AddEntry(entryId)
    local memberEntries = self.dkp['entries']
    local _, entryIndex = Utils:tfind(memberEntries, entryId);

    if entryIndex == nil then
        tinsert(self.dkp['entries'], entryId);
    end
end

function Member:RemoveEntry(entryId)
    local memberEntries = self.dkp['entries']
    local _, entryIndex = Utils:tfind(memberEntries, entryId);

    if entryIndex ~= nil then
        tremove(self.dkp['entries'], entryIndex);
    end
end

function Member:UpdateDKP(dkpChange)
    self.dkp['total'] = self:GetUpdatedDKPTotal(dkpChange);
    self:Save();
end

function Member:GetUpdatedDKPTotal(dkpChange)
    return self:GetDKP('Decimal') + dkpChange
end

function Member:UpdateSnapshot(previousTotal)
    if previousTotal == nil then
        --PDKP:PrintD(self.name, "PreviousTotal was nil still");
        return;
    end;

    if previousTotal < 0 then
        previousTotal = previousTotal * -1;
    end

    self.dkp['snapshot'] = previousTotal;
    self:Save();
end

function Member:_InitializeDKP()
    if Utils:tEmpty(guildDB[self.name]) and self.dkp['total'] == nil then
    end

    if Utils:tEmpty(guildDB[self.name]) then
        --PDKP:PrintD("Initializing Default DKP For", self.name);
        self:_DefaultDKP()
    else
        self:_LoadDatabaseData()
    end

    self:Save()
end

function Member:_DefaultDKP()
    self.dkp = {
        ['total'] = 30,
        ['snapshot'] = 30,
        ['entries'] = {},
    }
end

function Member:Reinitialize()
    guildDB = MODULES.Database:Guild()
    self:_LoadDatabaseData();
end

function Member:_LoadDatabaseData()
    local dbData = guildDB[self.name]
    if dbData ~= nil then
        self.dkp = {
            ['total'] = dbData['total'] or 0,
            ['snapshot'] = dbData['snapshot'] or 30,
            ['entries'] = dbData['entries'] or {},
        }
    end
end

function Member:_GetMemberData(index)
    index = index or self.guildIndex;

    self.name, self.rank, self.rankIndex, self.lvl, self.class, self.zone,
    self.note, self.officerNote, self.online, self.status, self.classFileName = GetGuildRosterInfo(index)

    if self.name == nil then
        self.name = '';
    end

    self.name, self.server = strsplit('-', self.name) -- Remove the server name from their name.

    self.isOfficer = self.rankIndex <= self.officerRank
    self.canEdit = self.isOfficer
    self.isOfficer = self.canEdit

    --self.isClassLeader = self.rankIndex == self.classLeadRank -- BUG: A bunch of people are getting this flag set. Probably a guild permission issue?
    self.isClassLeader = false;

    self.isInLeadership = self.isOfficer or self.isClassLeader

    self.lastOnline = {}
    self.lastOnline['years'], self.lastOnline['months'], self.lastOnline['days'], self.lastOnline['hours'] = GetGuildRosterLastOnline(index);

    self.formattedName, self.coloredClass = Utils:FormatTextByClass(self.name, self.class) -- Color their name & class.
    self.isBank = self.name == MODULES.Constants.BANK_NAME

    --@do-not-package@
    if (self.name == 'Lariese' or self.name == 'Karenbaskins' or self.name == 'Testio' or self.name == 'Rachelmae') and PDKP:IsDev() then
        self.canEdit = true
        self.isOfficer = true
        self.isInLeadership = true
    end

    --@end-do-not-package@

    self.visible = true

    self.dkp = {};
    self.lockouts = {}
end

function Member:_GetAverageEntryDistance()
    if not self:HasEntries() then
        return nil
    end

    local count = #self.dkp['entries']
    local lastThree = {}
    for i = count, max(count - 2, 1), -1 do
        tinsert(lastThree, self.dkp['entries'][i])
    end

    local totalWeeks = 0
    for i = 1, #lastThree - 1 do
        local week1 = Utils:GetWeekNumber(lastThree[i])
        local week2 = Utils:GetWeekNumber(lastThree[i + 1])
        totalWeeks = totalWeeks + math.abs(week1 - week2)
    end
    local averageWeekDistance = totalWeeks / (#lastThree - 1);
    return averageWeekDistance;
end

function Member:HasSub30DKP()
    return self.dkp['total'] ~= nil and self.dkp['total'] < 30;
end

function Member:GetEntries()
    if self:HasEntries() then
        return true, self.dkp['entries'];
    end
    return false, {};
end

function Member:CheckForWrongfulDecay()
    return self:CheckForEmptyEntries() and self.dkp['total'] < 30;
end

function Member:IsSyncReady()
    if not self.isInLeadership then return false end

    local syncSettings = MODULES.Database:Sync()

    if syncSettings['autoSync'] == nil or syncSettings['autoSync'] == false then
        return false;
    else
        local server_time = GetServerTime()
        local officerSyncs = syncSettings['officerSyncs']
        local lastSync = officerSyncs[self.name]
        if lastSync == nil then
            return true
        else
            local timeSinceSync = Utils:SubtractTime(lastSync, server_time)
            return timeSinceSync > Utils:GetSecondsInDay()
        end
    end
end

function Member:MarkSyncReceived()
    local syncSettings = MODULES.Database:Sync()
    local server_time = GetServerTime()
    syncSettings['officerSyncs'][self.name] = server_time
end

MODULES.Member = Member;
