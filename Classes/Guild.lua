local _, core = ...;
local _G = _G;
local L = core.L;

local Guild = core.Classes.Guild;
local GuildDB;
local Member = core.Member;

local IsInGuild, GetNumGuildMembers, GuildRoster, GuildRosterSetOfficerNote, GetGuildInfo = IsInGuild, GetNumGuildMembers, GuildRoster, GuildRosterSetOfficerNote, GetGuildInfo -- Global Guild Functions
local strsplit, tonumber, tostring, pairs, type, next = strsplit, tonumber, tostring, pairs, type, next -- Global lua functions.
local setmetatable, insert = setmetatable, table.insert

Guild.__index = Guild; -- Set the __index parameter to reference Character

-- Init the Databse.
local function initDB()
    local guildDBDefaults = {
        profile = {
            name = nil,
            numOfMembers = 0,
            members = {},
            officers = {},
        }
    }
    local db = LibStub("AceDB-3.0"):New("pdkp_guildDB", guildDBDefaults, true);
    return db.profile;
end

-- Init the Guild object.
function Guild:new()
    if IsInGuild() == false then return end

    local self = {};
    setmetatable(self, Guild); -- Set the metatable so we used Members's __index

    self.db = initDB()

    self.officers = {};
    self.members = {};
    self.classLeaders = {};
    self.bankIndex = nil;
    self.online = {};
    self.numOfMembers = nil;

    -- Variables / Attributes.

    return self
end

function Guild:IsNewMemberObject(member)
    return next(Guild.members[member.name]) == nil
end

function Guild:GetMembers()
    GuildRoster()
    self.classLeaders, self.officers = {}, {};
    self.online = {};
    self.numOfMembers, _, _ = GetNumGuildMembers();
    if self.numOfMembers > 0 then GuildDB.numOfMembers = self.numOfMembers else self.numOfMembers = GuildDB.numOfMembers; end
    for i=1, self.numOfMembers do
        local member = Member:new(i)
        local isNew = Guild:IsNewMemberObject(member)

        if member.lvl >= 55 or member.canEdit or member.isOfficer then
            if member.name == nil then member.name = '' end;
            if member.isBank then self:InitBankInfo(i, member) end -- Init bank info.
            if member.isOfficer then insert(self.officers, member) end -- Init Officers
            if member.isClassLeader then insert(self.classLeaders, member) end; -- Init class classLeaders
            -- Add member to the table only if it's new, to allow object persistence.
            if isNew then
                member:MigrateAndLocate()
                member:Save()
                self.members[member.name] = member;
            end

            if member.online then self.online[member.name] = member end
        end
    end
    return self.online, self.members; -- Always return, even if it's empty.
end

function Guild:InitBankInfo(index, member)
    self.bankIndex = i
    DKP.bankID, DKP.lastSync = Guild:GetBankData(member.officerNote)
end