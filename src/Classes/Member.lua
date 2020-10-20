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
    self.isBank = self.name == Defaults.bank_name
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
        --Util:Debug("Member is empty " .. self.name)
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
end

function Member:GetDKP(raidName, variableName)
    raidName = raidName or Raid:GetCurrentRaid()
    if tContains(DKPVariables, variableName) then
        return self.dkp[raidName][variableName]
    elseif variableName == 'all' then
        return self.dkp[raidName]
    end
end

function Member:GetShroudDKP()
    local shroud_dkp = {}
    for _, raid in pairs(Defaults.dkp_raids) do
        shroud_dkp[raid] = self.dkp[raid]['total']
    end
    return shroud_dkp
end

function Member:QuickCalc(raid, calc_name)
    local dkpTotal = self.dkp[raid].total
    if dkpTotal > 0 then
        calc_name = calc_name or 'Shroud';
        local calcs = {
            ['Shroud']=0.5,
            ['Roll']=0.1,
            ['Unexcused Absence']=0
        }
        local percent = calcs[calc_name]
        return math.ceil(dkpTotal * percent)
    else
        return dkpTotal
    end
end

function Member:DeleteEntry(entry)
    local rdkp = self.dkp[entry['raid']]

    if tContains(rdkp['deleted'], entry['id']) then
        return -- We've already deleted this entry.
    end

    rdkp.total = rdkp.total - entry['dkp_change'] --- Figure out a more elegant way to get previous DKP difference from this value.
    tremoveByKey(rdkp.entries, entry['id'])

    local t_entries = {}
    for i=1, #rdkp['entries'] do
        local e = rdkp['entries'][i]
        if e ~= nil then tinsert(t_entries, e) end
    end
    rdkp['entries'] = t_entries
    tinsert(rdkp.deleted, entry['id'])
end

function Member:NewEntry(entry)
    local raid = entry['raid'] or 'Molten Core'
    self.dkp[raid].previousTotal = self.dkp[raid].total
    self.dkp[raid].total = self.dkp[raid].total + entry['dkp_change']
    table.insert(self.dkp[raid].entries, entry.id)
    self:Save()
end

function Member:PreparePushData()
    local pushData = {}
    for _, raid in pairs(Defaults.dkp_raids) do
        pushData[raid] = {}
        local raid_dkp = self.dkp[raid]
        if raid_dkp['total'] ~= nil and raid_dkp['total'] > 0 then
            pushData[raid] = raid_dkp
        end
    end
    return pushData
end

function Member:GetGuildBankSync()
    if self.name ~= Defaults.bank_name then Util:Debug('Error getting bank data', self.name) return end

    local lastEdit, lastSync = strsplit(',', self.officerNote)
    if lastEdit ~= nil then lastEdit = tonumber(lastEdit) end
    if lastSync ~= nil then lastSync = tonumber(lastSync) end
    return lastEdit, lastSync
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

        if dkp == nil or (dkp.total == nil) or (dkp.entries) == nil or (dkp.deleted) == nil or (dkp.previousTotal == nil) then
            self:InitRaidDKP(raid)
        end

        dkp = self.dkp[raid]

        if dkp.total > 0 or #dkp.entries > 0 or dkp.previousTotal > 0 or #dkp.deleted > 0 then
            memberDB[self.name] = memberDB[self.name] or {}
            memberDB[self.name][raid] = dkp
        end
    end
end

function Member:OverwriteDKP(dkp)
    for _, raid in pairs(Defaults.dkp_raids)  do
        self:InitRaidDKP(raid) -- Reset their DKP and Whatnot.

        if dkp[raid] ~= nil then
            local entries = {}
            local deleted = {}
            for _, val in pairs(DKPVariables) do
                local dkpVarVal = dkp[raid][val]
                if dkpVarVal ~= nil then
                    self.dkp[raid][val] = dkp[raid][val]
                end
            end

            for _, id in pairs(self.dkp[raid]['entries']) do table.insert(entries, id) end
            for _, id in pairs(self.dkp[raid]['deleted']) do table.insert(deleted, id) end

            self.dkp[raid]['entries']=entries;
            self.dkp[raid]['deleted']=deleted;
        end
    end
    self:Save()
end

--- TESTING FUNCTIONS BELOW
function Member:UpdateDKPTest(raid, newTotal)
    raid = raid or Raid:GetCurrentRaid()
    self.dkp[raid].total = newTotal

    self:Save()

    for key, val in pairs({'entries', 'deleted'}) do
        self.dkp[raid][val] = {}
        if self.dkp[raid] ~= nil and memberDB[self.name][raid] ~= nil and memberDB[self.name][raid][val] ~= nil then
            memberDB[self.name][raid][val] = {}
        else
            memberDB[self.name][raid] = {}
            memberDB[self.name][raid][val] = {}
        end
    end

    self:Save()
end

function Member:DataOverwrite(memberData)

end