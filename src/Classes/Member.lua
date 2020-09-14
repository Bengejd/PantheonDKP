local _, core = ...;
local _G = _G;
local L = core.L;

local Raid = core.Raid;
local Guild = core.Guild;
local DKP = core.DKP

local Defaults, Util = core.Defaults, core.Util;
local Character = core.Character;
local bank_name = Defaults.bank_name;

local setmetatable, strsplit, pairs = setmetatable, strsplit, pairs

local GetGuildRosterInfo = GetGuildRosterInfo

local Member = core.Member;
Member.__index = Member; -- Set the __index parameter to reference Character

local DKPVariables = { 'previousTotal', 'total', 'entries', 'deleted'}

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
    self.visible = true

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

    -- TODO: Save / Retrieve this data instead of using guildIndex
    self.dkp['Molten Core'].total = guildIndex;

    return self
end

function Member:GetDKP(raidName, variableName)
    raidName = raidName and tContains(Defaults.raids, raidName) or Raid:GetCurrentRaid()
    if tContains(DKPVariables, variableName) then
        return self.dkp[raidName][variableName]
    elseif variableName == 'all' then
        return self.dkp[raidName]
    end
end

function Member:UpdateDKP(raid, entry)
    raid = raid or Raid:GetCurrentRaid()
    --entry = entry or {};
    self.dkp[raid].total = self.dkp[raid].total + 10
end

function Member:Save()
    local hasEntries = false

    for _, raid in pairs(Defaults.raids) do
        if raid ~= 'Onyxia\'s Lair' then
            dkp = self.dkp[raid]
            if dkp.total > 0 or #dkp.entries > 0 or dkp.previousTotal > 0 or dkp.deleted > 0 then
                hasEntries = true
            end
        end
    end

    if hasEntries then
        print('Fuck yeah!')
    end
end