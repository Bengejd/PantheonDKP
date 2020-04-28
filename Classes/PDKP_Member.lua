local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local Util = core.Util;
local Guild = core.Guild;
local Defaults = core.defaults;

local raids = core.raids

local Member = core.Member;
Member.__index = Member; -- Set the __index parameter to reference Character

local acceptableDKPVariables = { ['previousTotal'] = true, ['total'] = true, ['entries'] = true, ['deleted'] = true, ['all'] = true }

function Member:new(guildIndex)
    local self = {};
    setmetatable(self, Member); -- Set the metatable so we used Members's __index

    self.name, self.rank, self.rankIndex, self.lvl, self.class, self.zone,
    self.note, self.officerNote, self.online, self.status, self.classFileName = GetGuildRosterInfo(guildIndex)

    self.name = Util:RemoveServerName(self.name) -- Remove the server name from the member's name.

    self.formattedName = Util:GetClassColoredName(self.name, self.class) -- Get their colored name.
    self.coloredClass = Util:FormatFontTextColor(Util:GetClassColor(self.class), self.class)

    self.canEdit = self.rankIndex <= 3;

    self.isOfficer = self.canEdit;
    self.isBank = self.name == Defaults.bank_name

    if self.name == Util:GetMyName() then core.canEdit = self.canEdit end

    self.dkp = {};

    for key, raid in pairs(raids) do
        if key > 1 then
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

function Member:GetDKP(raidName, variableName)
    if Util:IsEmpty(raidName) then
        return Util:ThrowError('No raid provided to GetDKP')
    elseif not acceptableDKPVariables[variableName] then
        return Util:ThrowError('Invalid dkpVariable ' .. variableName)
    end
    if variableName == 'all' then return self.dkp[raidName] end
    return self.dkp[raidName][variableName]
end

function Member:ValidateTable()
--    local histKeys = self:GetHistory('Blackwing Lair')
--    local dkpDB = DKP.dkpDB
--    local allHistory = dkpDB.history.all
--    local deletedHistory = dkpDB.history.deleted
--    if #histKeys == 0 then return false end -- Only want to look at people that have entries.
--    local validDKP = 0
--    local dkp = self.dkp['Blackwing Lair']['total']
--
--    for i=1, #histKeys do
--        local entryKey = histKeys[i]
--        local entry = allHistory[entryKey]
--        if entry and entry['raid'] == 'Blackwing Lair' then
--            if entry and entry['deleted'] == false then
--                validDKP  = validDKP + entry.dkpChange
--            elseif entry and entry['deleted'] == true then
--                validDKP  = validDKP - entry.dkpChange
--            end
--        end
--    end
--
--    if validDKP ~= dkp then
--        if validDKP < 0 then
--            print(self.name, ' is broken?', dkp, validDKP)
--        elseif dkp > validDKP then
--            print(self.name, dkp, validDKP)
----            if dkp > validDKP + 200 then
----                --                   self.dkp['Blackwing Lair']['total'] = validDKP
----            elseif dkp > 400 and validDKP == 400 then
----                --                   self.dkp['Blackwing Lair']['total'] = validDKP
----            elseif dkp > validDKP + 150 then
----                --                   self.dkp['Blackwing Lair']['total'] = validDKP
----            else
----                if dkp > 500 then
----                    --                       self.dkp['Blackwing Lair']['total'] = dkp - 200
----                else
----                    --                       self.dkp['Blackwing Lair']['total'] = validDKP - 100
----                end
----            end
--        end
--    end

--    self:Save()
end

function Member:GetHistory(raid)
--    Util:Debug('Getting history for ' .. self.name)
    return self.dkp[raid].entries
end

function Member:CheckForEntryHistory(entry)
    local raid = entry['raid'];
    local isInHistory = false
    local isInDeleted = false

    if raid == 'Onyxia\'s Lair' then raid = 'Molten Core'; end

    local entryKey = entry['id']

    local dkp = self.dkp;

    if dkp == nil then
        Util:ThrowError(self.name .. ' has nil DKP!!!!')
        return true, true;
    else
        dkp = self.dkp[raid];
    end

    local history = dkp.entries;
    local deleted = dkp.deleted;

    for _, entryId in pairs(history) do
        if entryId == entryKey then
            isInHistory = true
            break;
        end
    end

    for _, entryId in pairs(deleted) do
        if entryId == entryKey then
            isInDeleted = true
            break;
        end
    end

    return isInDeleted, isInHistory;
end

function Member:QuickCalculate(type, raid)
    local percent = 0.1;
    if type == 'shroud' then percent = 0.5 end;
    return math.ceil(self.dkp[raid].total * percent);
end

function Member:SetDKP(raidName, histObj)
    if Util:IsEmpty(raidName) then return Util:ThrowError('No raid provided to GetDKP')
    elseif histObj == nil then return Util:ThrowError('History Object is nil!')
    end
end

-- Returns whether the user can edit the databases on their own.
function Member:CanEdit()
    return self.canEdit;
end

function Member:Save()
    if self.lvl == nil then return end;
    if (self.lvl < 55 and not self.canEdit) then return end
    if self.name == nil then return Util:Debug('There is a rogue player!') end;

    local db = Guild.db.members

    local dbMember = {
        name = self.name,
        rankIndex = self.rankIndex,
        class = self.class,
        canEdit = self.canEdit,
        formattedname = self.formattedName,
        dkp = {},
    }

    for key, raid in pairs(raids) do
        if key > 1 then
            dbMember.dkp[raid] = {
                previousTotal = self.dkp[raid].previousTotal,
                total = self.dkp[raid].total,
                entries = self.dkp[raid].entries,
                deleted = self.dkp[raid].deleted
            }
        end
    end
    db[self.name] = dbMember
end

function Member:MigrateAndLocate()
    local db = DKP.dkpDB.members
    local hist = DKP.dkpDB.history;
    local dkp = self.dkp

    if db[self.name] ~= nil then -- We have some data to migrate
        Util:Debug('Migrating data')
        local dbEntity = db[self.name]
        local mc = dkp['Molten Core']
        local bwl = dkp['Blackwing Lair']
        bwl.total = dbEntity['Blackwing Lair']
        mc.total = dbEntity['Molten Core']

        local entries = dbEntity['entries'];

        if type(entries) == type({}) then
            for key, entryId in pairs(dbEntity['entries']) do
                if entryId > 1 then
                    local entry = hist['all'][entryId];
                    if entry ~= nil then
                        local entryRaid = entry['raid']
                        if entryRaid ~= nil then
                            if entryRaid == 'Molten Core' then
                                table.insert(dkp['Molten Core'].entries, entryId)
                            elseif entryRaid == 'Blackwing Lair' then
                                table.insert(dkp['Blackwing Lair'].entries, entryId)
                            end
                        end
                    end
                end
            end
        end
        db[self.name] = {} -- release the data. We've migrated already.
    elseif Guild.db.members[self.name] ~= nil then -- We have the dkp data in the database already.
        local gmember = Guild.db.members[self.name]
        for _, raid in pairs(raids) do
            if gmember.dkp[raid] ~= nil then
                self.dkp[raid] = gmember.dkp[raid]
            end
        end
    elseif self.name then
--        Util:Debug('Falling back to defaults for '.. self.name)
    end
end