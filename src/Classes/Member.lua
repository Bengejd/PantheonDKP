local _G = _G;
local PDKP = _G.PDKP

local Member, Raid, Guild, Defaults, Util, Character, Dev = PDKP:GetInst('Member', 'Raid', 'Guild', 'Defaults', 'Util', 'Character', 'Dev')

local GetGuildRosterInfo = GetGuildRosterInfo
local setmetatable, strsplit, pairs, next = setmetatable, strsplit, pairs, next

Member.__index = Member; -- Set the __index parameter to reference Character

function Member:new(guildIndex)
    local self = {};
    setmetatable(self, Member); -- Set the metatable so we used Members's __index

    self.guildIndex = guildIndex
    self:GetMemberData(guildIndex)

    return self
end

function Member:GetMemberData(index)
    index = index or self.guildIndex;
    self.name, self.rank, self.rankIndex, self.lvl, self.class, self.zone,
    self.note, self.officerNote, self.online, self.status, self.classFileName = GetGuildRosterInfo(index)

    self.name, self.server = strsplit('-', self.name) -- Remove the server name from their name.

    self.canEdit = self.rankIndex <= 3 or Defaults.dev_names[self.name]
    self.isOfficer = self.canEdit

    self.isClassLeader = self.rankIndex == 4

    self.formattedName, self.coloredClass = Util:FormatTextByClass(self.name, self.class) -- Color their name & class.
    self.isBank = self.name == Defaults.bank_name

    if self.name == Character.name then _G.PDKP.canEdit = self.canEdit end
    self.visible = true

    self.dkp = {};
    self.isDkpOfficer = false
end

function Member:IsRaidReady()
    return self.lvl >= 55 or self.canEdit or self.isOfficer;
end

function Member:CanEdit()
    self.canEdit = self.rankIndex <= 3;
    self.isOfficer = self.canEdit;
end

function Member:GetDKP()
    -- TODO: Finish Member.GetDKP
    return 30
end