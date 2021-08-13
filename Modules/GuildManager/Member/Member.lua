local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils

local GetGuildRosterInfo = GetGuildRosterInfo
local setmetatable = setmetatable
local strsplit = strsplit
local tinsert, tremove = table.insert, table.remove
local floor = math.floor;

local Member = {}

local guildDB, _;

local playerName = UnitName("PLAYER")

Member.__index = Member; -- Set the __index parameter to reference Member

function Member:new(guildIndex, server_time, leadershipRanks)
    local self = {};
    setmetatable(self, Member); -- Set the metatable so we used Members's __index

    guildDB = MODULES.Database:Guild()

    self.guildIndex = guildIndex
    self.server_time = server_time

    self.officerRank, self.classLeadRank = unpack(leadershipRanks)

    self:_GetMemberData(guildIndex)

    if self:IsRaidReady() then
        self:_InitializeDKP()
        self:Save()
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
    return self.lvl >= 68 or self.canEdit or self.isOfficer
end

function Member:CanEdit()
    return self.canEdit or self.rankIndex <= 3 or self.isOfficer
end

function Member:GetDKP(dkpVariable)
    if dkpVariable == nil then
        return self.dkp['total']
    elseif dkpVariable == 'display' then
        if PDKP:IsDev() and PDKP.showInternal then
            return self.dkp['total'];
        end
        return floor(self.dkp['total']);
    end
    return self.dkp[dkpVariable]
end

function Member:HasEntries()
    return self.dkp['entries'] ~= nil and #self.dkp['entries'] > 0;
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
    self.dkp['total'] = self.dkp['total'] + dkpChange;
    guildDB[self.name] = self.dkp;
end

function Member:_UpdateDKP(entry, decayAmount)
    local amount = entry.sd.dkp_change

    if decayAmount ~= nil then
        amount = decayAmount;
    elseif amount == nil and decayAmount == nil then
        return
    end

    if entry.reason == 'Decay' then
        if (not self:HasEntries() or self.dkp['total'] <= 30 or not self:IsRaidReady()) and not entry['decayReversal'] and not entry['adEntry'] then
            entry:RemoveMember(self.name)
            return
        end -- Do not decay non-active members or members without at least 31 DKP.

        if entry['decayReversal'] and entry['decayAmounts'][self.name] ~= nil and entry['decayAmounts'][self.name] < 0 then
            entry['decayAmounts'][self.name] = entry['decayAmounts'][self.name] * -1
            self.dkp['total'] = self.dkp['total'] + entry['decayAmounts'][self.name]
        else
            self.dkp['total'] = math.floor(self.dkp['total'] * 0.9)
        end
    else
        self.dkp['total'] = self.dkp['total'] + amount
    end

    table.insert(self.dkp['entries'], entry.id)
end

function Member:_InitializeDKP()
    if Utils:tEmpty(guildDB[self.name]) then
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

function Member:_LoadDatabaseData()
    local dbData = guildDB[self.name]
    self.dkp = {
        ['total'] = dbData['total'],
        ['snapshot'] = dbData['snapshot'],
        ['entries'] = dbData['entries'] or {},
    }
end

function Member:_GetMemberData(index)
    index = index or self.guildIndex;

    self.name, self.rank, self.rankIndex, self.lvl, self.class, self.zone,
    self.note, self.officerNote, self.online, self.status, self.classFileName = GetGuildRosterInfo(index)

    self.name, self.server = strsplit('-', self.name) -- Remove the server name from their name.

    self.isOfficer = self.rankIndex <= self.officerRank
    self.canEdit = self.isOfficer
    self.isOfficer = self.canEdit

    --self.isClassLeader = self.rankIndex == self.classLeadRank -- BUG: A bunch of people are getting this flag set. Probably a guild permission issue?
    self.isClassLeader = false;

    self.isInLeadership = self.isOfficer or self.isClassLeader

    self.formattedName, self.coloredClass = Utils:FormatTextByClass(self.name, self.class) -- Color their name & class.
    self.isBank = self.name == MODULES.Constants.BANK_NAME

    --@do-not-package@
    if (self.name == 'Lariese' or self.name == 'Karenbaskins') and PDKP:IsDev() then
        self.canEdit = true
        self.isOfficer = true
        self.isInLeadership = true
    end
    --@end-do-not-package@

    self.visible = true

    self.dkp = {};
    self.lockouts = {}
end

MODULES.Member = Member;
