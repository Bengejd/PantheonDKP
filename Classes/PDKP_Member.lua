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
    setmetatable(self, Member); -- Set the metatable so we used Character's __index

    self.name, self.rank, self.rankIndex, self.lvl, self.class, self.zone,
    self.note, self.officerNote, self.online, self.status, self.classFileName = GetGuildRosterInfo(guildIndex)
    self.name = Util:RemoveServerName(self.name) -- Remove the server name from the member's name.
    self.formattedName = Util:GetClassColoredName(self.name, self.class) -- Get their colored name.
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

-- Returns whether the user can edit the databases on their own.
function Member:CanEdit()
    return self.canEdit;
end

function Member:UpdateDkpDB()
--    local dkpDB = DKP.dkpDB

    -- This should find the entries from each of the respective raids as well, and reorganize them.
end

function Member:UpdateGuildDB()
    if self.lvl < 55 and not self.canEdit then return end

    local db = Guild.db
    db[self.name] = {
        name=self.name,
        rankIndex=self.rankIndex,
        class=self.class,
        canEdit = self.canEdit,
        formattedname = self.formattedName,
        guildTest = 'The test worked!',
        dkp = {
            ['Blackwing Lair'] = {
                previousTotal = self.dkp['Blackwing Lair'].previousTotal or 0,
                total = self.dkp['Blackwing Lair'].total or 0,
                entries = self.dkp['Blackwing Lair'].entries or {},
                deleted = self.dkp['Blackwing Lair'].deleted or {}
            },
            ['Molten Core'] = {
                previousTotal = self.dkp['Molten Core'].previousTotal or 0,
                total = self.dkp['Blackwing Lair'].total or 0,
                entries = self.dkp['Blackwing Lair'].entries or {},
                deleted = self.dkp['Blackwing Lair'].deleted or {},
            }
        },
    }
end

function Member:GetDkpValues()
    local db = DKP.dkpDB.members
    local dkp = self.dkp
    if db[self.name] ~= nil then
        local dkpObj = db[self.name];

    else
        print(self.name, ' found in dkp db')
    end
end



