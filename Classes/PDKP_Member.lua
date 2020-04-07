local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local Util = core.Util;
local Guild = core.Guild;
local Defaults = core.defaults;

local Member = core.Member;
Member.__index = Member;    -- Set the __index parameter to reference Character

local acceptableDKPVariables = {['previousTotal']=true, ['total']=true, ['entries']=true, ['deleted']=true, ['all']=true}

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

    self.dkp = {
        ['Molten Core'] = {
            previousTotal = 0,
            total = 0,
            entries = {},
            deleted = {}
        },
        ['Blackwing Lair'] = {
            previousTotal = 0,
            total = 0,
            entries = {},
            deleted = {}
        },
    };
    return self
end

function Member:GetDKP(raidName, variableName)
    if Util:IsEmpty(raidName) then
        return Util:ThrowError('No raid provided to GetDKP')
    elseif not acceptableDKPVariables[variableName] then
        return Util:ThrowError('Invalid dkpVariable '.. variableName)
    end
    if variableName == 'all' then return self.dkp[raidName] end
    return self.dkp[raidName][variableName]
end

function Member:GetHistory(raid)
    Util:Debug('Getting history for ' .. self.name)
    return self.dkp[raid].entries
end

function Member:SetDKP(raidName, histObj)
    if Util:IsEmpty(raidName) then return Util:ThrowError('No raid provided to GetDKP')
    elseif histObj == nil then return Util:ThrowError('History Object is nil!') end
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
    db[self.name] = {
        name=self.name,
        rankIndex=self.rankIndex,
        class=self.class,
        canEdit = self.canEdit,
        formattedname = self.formattedName,
        dkp = {
            ['Blackwing Lair'] = {
                previousTotal = self.dkp['Blackwing Lair'].previousTotal,
                total = self.dkp['Blackwing Lair'].total,
                entries = self.dkp['Blackwing Lair'].entries,
                deleted = self.dkp['Blackwing Lair'].deleted
            },
            ['Molten Core'] = {
                previousTotal = self.dkp['Molten Core'].previousTotal,
                total = self.dkp['Molten Core'].total,
                entries = self.dkp['Molten Core'].entries,
                deleted = self.dkp['Molten Core'].deleted,
            }
        },
    }
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
        self.dkp = gmember.dkp
    else
        print('Falling back to defaults for ', self.name)
    end
end