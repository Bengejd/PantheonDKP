local _, core = ...;
local _G = _G;
local L = core.L;

local Defaults, Util = core.Defaults, core.Util;
local Character = core.Character;
local bank_name = Defaults.bank_name;

local setmetatable, strsplit, pairs = setmetatable, strsplit, pairs

local Member = core.Member;
Member.__index = Member; -- Set the __index parameter to reference Character

function Member:new(guildIndex)
    local self = {};
    setmetatable(self, Member); -- Set the metatable so we used Members's __index

    self.name, self.rank, self.rankIndex, self.lvl, self.class, self.zone,
    self.note, self.officerNote, self.online, self.status, self.classFileName = GetGuildRosterInfo(guildIndex)
    self.canEdit = self.rankIndex <= 3;
    self.isOfficer = self.canEdit;
    self.name = strsplit('-', self.name) -- Remove the server name from their name.
    self.isClassLeader = self.rankIndex == 4;
    self.formattedName, self.coloredClass = Util:ColorTextByClass(self.name, self.class) -- Color their name & class.
    self.isBank = self.name == bank_name
    if self.name == Character:GetMyName() then core.canEdit = self.canEdit end

    self.dkp = {};
    self.isDkpOfficer = false

    for _, raid in pairs(Defaults.raids) do
        if raid ~= 'Onyxia\'s Lair' then
            self.dkp[raid] = {
                previousTotal = 0,
                total = 0,
                entries = {},
                deleted = {}
            }
        end
    end
    return self
end

function Member:Save()

end