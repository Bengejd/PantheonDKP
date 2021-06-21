local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local GetGuildRosterInfo = GetGuildRosterInfo
local setmetatable = setmetatable
local strsplit = strsplit

local Member = {}

local guildDB, pugDB;

Member.__index = Member; -- Set the __index parameter to reference Member

function Member:new(guildIndex, server_time)
    local self = {};
    setmetatable(self, Member); -- Set the metatable so we used Members's __index

    guildDB = MODULES.Database:Guild()

    self.guildIndex = guildIndex
    self.server_time = server_time

    self:GetMemberData(guildIndex)

    if self:IsRaidReady() then
        self:InitializeDKP()
        self:Save()
    end

    return self
end

function Member:InitializeDKP()
    if Utils:tEmpty(guildDB[self.name]) then
        self.dkp = {
            ['total'] = 30,
            ['initOn'] = self.server_time,
            ['entries'] = {},
        }
    else
        self.dkp = guildDB[self.name]
    end

    self:Save()
end

function Member:Save()
    local dkp = {
        ['total'] = self.dkp['total'],
        ['initOn'] = self.dkp['initOn'],
    }

    if not Utils:tEmpty(self.dkp['entries']) then
        dkp['entries'] = self.dkp['entries']
    end

    guildDB[self.name] = dkp
end

function Member:GetMemberData(index)
    index = index or self.guildIndex;
    self.name, self.rank, self.rankIndex, self.lvl, self.class, self.zone,
    self.note, self.officerNote, self.online, self.status, self.classFileName = GetGuildRosterInfo(index)

    self.name, self.server = strsplit('-', self.name) -- Remove the server name from their name.

    self.isOfficer = self.rankIndex <= 3
    self.canEdit = self.isOfficer or PDKP:IsDev()
    self.isOfficer = self.canEdit

    self.isClassLeader = self.rankIndex == 4

    self.formattedName, self.coloredClass = Utils:FormatTextByClass(self.name, self.class) -- Color their name & class.
    self.isBank = self.name == MODULES.Constants.BANK_NAME

    -- TODO: Hook this up, potentially?
    if self.name == 'Lariese' and PDKP:IsDev() then
        self.canEdit = true
        PDKP.canEdit = true
    end

    self.visible = true

    self.dkp = {};
    self.init = false
    self.isDkpOfficer = false

    self.lockouts = {}
end

function Member:IsRaidReady()
    return self.lvl >= 68 or self.canEdit or self.isOfficer;
end

function Member:CanEdit()
    return self.canEdit or self.rankIndex <= 3 or self.ifOfficer
end

function Member:GetDKP(dkpVariable)
    if dkpVariable == nil then
        return self.dkp['total']
    end
end

function Member:GetLockouts()

end

function Member:UpdateLockouts()

end

MODULES.Member = Member;