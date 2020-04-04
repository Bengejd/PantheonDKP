local _, core = ...;
local _G = _G;
local L = core.L;

local next = next

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Invites = core.Invites;
local Raid = core.Raid;
local Comms = core.Comms;
local Setup = core.Setup;
local Import = core.Import;
local item = core.Item;

local Member = core.Member;
Member.__index = Member;    -- Set the __index parameter to reference Character

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

    if DKP.dkpDB.members[self.name] ~= nil then -- we need to migrate the data.
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
    end
    self:GetDkpValues()
    --        self:UpdateGuildDB()
    return self
end

-- Returns whether the user can edit the databases on their own.
function Member:CanEdit()
    return self.canEdit;
end

function Member:UpdateGuildDB()
    if self.lvl < 55 and not self.canEdit then return end

    local db = Guild.db.members
    db[self.name] = {
        name=self.name,
        rankIndex=self.rankIndex,
        class=self.class,
        canEdit = self.canEdit,
        formattedname = self.formattedName,
        guildTest = 'The test worked!',
        dkp = {
            ['Blackwing Lair'] = {
                previousTotal = self.dkp['Blackwing Lair'].previousTotal,
                total = self.dkp['Blackwing Lair'].total,
                entries = self.dkp['Blackwing Lair'].entries,
                deleted = self.dkp['Blackwing Lair'].deleted
            },
            ['Molten Core'] = {
                previousTotal = self.dkp['Molten Core'].previousTotal,
                total = self.dkp['Blackwing Lair'].total,
                entries = self.dkp['Blackwing Lair'].entries,
                deleted = self.dkp['Blackwing Lair'].deleted,
            }
        },
    }
end

function Member:GetDkpValues()
    local db = DKP.dkpDB.members
    local hist = DKP.dkpDB.history;
    local dkp = self.dkp

    if db[self.name] ~= nil then -- We have some data to migrate
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
                                dkp['Molten Core'].entries[entryId] = true
                            elseif entryRaid == 'Blackwing Lair' then
                                dkp['Blackwing Lair'].entries[entryId] = true
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
    end
end