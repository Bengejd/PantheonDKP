local _, core = ...;
local _G = _G;
local L = core.L;

local Raid = core.Raid;

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

    self.dkp['Molten Core'].total = guildIndex;

    --if self.name == 'Neekio' or self.name == 'Athico' then
    --    self.dkp['Molten Core'].total = math.random(100000)
    --end

    return self
end

function Member:GetDKP(raidName, variableName)
    raidName = raidName and tContains(Defaults.raids, raidName) or Raid:GetCurrentRaid()
    if tContains(DKPVariables, variableName) then
        return self.dkp[raidName][variableName]
    elseif variableName == 'all' then
        return self.dkp[raidName]
    end

    --if Util:IsEmpty(raidName) then
    --    return Util:ThrowError('No raid provided to GetDKP')
    --elseif not acceptableDKPVariables[variableName] then
    --    return Util:ThrowError('Invalid dkpVariable ' .. variableName)
    --end
    --if raidName == 'Onyxia\'s Lair' then raidName = 'Molten Core'; end
    --if variableName == 'all' then return self.dkp[raidName] end
    --return self.dkp[raidName][variableName]
end

function Member:Changed(event, name, key, value, dataobj)
    --    print('LDB Changed', event, name, key, tostring(value))
    print("LDB: "..name.. ".".. key.. " was changed to ".. tostring(value))
end

function Member:ShouldShow()
    local dkp = self:GetDKP(nil, 'total')
    self.visible = dkp > 0
    return self.visible
end

function Member:Save()

end