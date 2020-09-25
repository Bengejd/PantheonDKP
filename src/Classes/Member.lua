local _, core = ...;
local _G = _G;
local L = core.L;

local Raid = core.Raid;
local Guild = core.Guild;
local DKP = core.DKP;
local Settings = core.Settings;

local setmetatable, strsplit, pairs, next = setmetatable, strsplit, pairs, next

local Defaults, Util = core.Defaults, core.Util;
local Character = core.Character;
local bank_name = Defaults.bank_name;

local guildDB, memberDB;

local GetGuildRosterInfo = GetGuildRosterInfo

local Member = core.Member;
Member.__index = Member; -- Set the __index parameter to reference Character

local DKPVariables = { 'previousTotal', 'total', 'entries', 'deleted'}

function Member:new(guildIndex)
    local self = {};
    setmetatable(self, Member); -- Set the metatable so we used Members's __index

    self.guildIndex = guildIndex

    self:GetGuildData(guildIndex)

    guildDB = Guild.db
    memberDB = Guild.db.members

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

    self:InitializeDKP()

    self:Save()

    return self
end

function Member:GetGuildData(index)
    index = index or self.guildIndex;
    self.name, self.rank, self.rankIndex, self.lvl, self.class, self.zone,
    self.note, self.officerNote, self.online, self.status, self.classFileName = GetGuildRosterInfo(index)
end

function Member:InitializeDKP()
    if tEmpty(memberDB[self.name]) then
        memberDB[self.name] = {}
        print('member is empty')
    end

    for _, raid in pairs(Defaults.dkp_raids) do
        if tEmpty(memberDB[self.name]) or not memberDB[self.name][raid] or tEmpty(memberDB[self.name][raid]) then
            self:InitRaidDKP(raid)
        else -- Member exists in the database, raid exists in the member data, and the raid has values.
            self.dkp[raid] = memberDB[self.name][raid]
        end
    end
end

function Member:InitRaidDKP(raid)
    self.dkp[raid] = {
        previousTotal = 0,
        total = 0,
        entries = {},
        deleted = {}
    }

    if raid == 'Molten Core' and self.dkp['Molten Core'].total == 0 then
        print('Defaulting Molten Core')
        self.dkp['Molten Core'].total = self.guildIndex;
    end
end

function Member:GetDKP(raidName, variableName)
    raidName = raidName or Raid:GetCurrentRaid()
    if tContains(DKPVariables, variableName) then
        return self.dkp[raidName][variableName]
    elseif variableName == 'all' then
        return self.dkp[raidName]
    end
end

function Member:QuickCalc(raid, calc_name)
    local dkpTotal = self.dkp[raid].total
    if dkpTotal > 0 then
        calc_name = calc_name or 'Shroud';
        local calcs = {
            ['Shroud']=0.5,
            ['Roll']=0.1,
            ['Unexcused Absence']=0.15
        }
        local percent = calcs[calc_name]
        return math.ceil(dkpTotal * percent)
    else
        return dkpTotal
    end
end

function Member:UpdateDKP(raid, entry)
    raid = raid or Raid:GetCurrentRaid()
    --entry = entry or {};
    self.dkp[raid].total = self.dkp[raid].total + 10
    self:Save()
end

function Member:Save()
    for _, raid in pairs(Defaults.dkp_raids) do
        local dkp = self.dkp[raid]
        if dkp.total > 0 or #dkp.entries > 0 or dkp.previousTotal > 0 or #dkp.deleted > 0 then
            memberDB[self.name] = memberDB[self.name] or {}
            memberDB[self.name][raid] = dkp
        end
    end
end

--- TESTING FUNCTIONS BELOW
---
function Member:UpdateDKPTest(raid, newTotal)
    raid = raid or Raid:GetCurrentRaid()
    self.dkp[raid].total = newTotal
end