local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local PDKP = core.PDKP;
local Raid = core.Raid;
local Util = core.Util;
local Comms = core.Comms;
local Setup = core.Setup;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Member = core.Member;
local Import = core.Import;
local Officer = core.Officer;
local Invites = core.Invites;
local Minimap = core.Minimap;
local Defaults = core.Defaults;

local GuildDB;

local IsInGuild, GetNumGuildMembers, GuildRoster, GuildRosterSetOfficerNote, GetGuildInfo = IsInGuild, GetNumGuildMembers, GuildRoster, GuildRosterSetOfficerNote, GetGuildInfo -- Global Guild Functions
local strsplit, tonumber, tostring, pairs, type, next = strsplit, tonumber, tostring, pairs, type, next -- Global lua functions.
local insert = setmetatable, table.insert

Guild.initiated = false;

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
    if (IsInGuild() == false) or (Guild.initiated) then return end

    Guild.db = initDB()

    Guild.officers = {};
    Guild.members = {};
    Guild.classLeaders = {};
    Guild.bankIndex = nil;
    Guild.online = {};
    Guild.numOfMembers = nil;

    Guild.initiated = true;

    PDKP:Print('Guild Initiated')

    return Guild
end

function Guild:IsNewMemberObject(member)
    return next(Guild.members[member.name]) == nil
end

function Guild:GetMembers()
    GuildRoster()
    Guild.classLeaders, Guild.officers = {}, {};
    Guild.online = {};
    Guild.numOfMembers, _, _ = GetNumGuildMembers();
    if Guild.numOfMembers > 0 then GuildDB.numOfMembers = Guild.numOfMembers else Guild.numOfMembers = GuildDB.numOfMembers; end
    for i=1, Guild.numOfMembers do
        local member = Member:new(i)
        local isNew = Guild:IsNewMemberObject(member)

        if member.lvl >= 55 or member.canEdit or member.isOfficer then
            if member.name == nil then member.name = '' end;
            if member.isBank then Guild:InitBankInfo(i, member) end -- Init bank info.
            if member.isOfficer then insert(Guild.officers, member) end -- Init Officers
            if member.isClassLeader then insert(Guild.classLeaders, member) end; -- Init class classLeaders
            -- Add member to the table only if it's new, to allow object persistence.
            if isNew then
                member:MigrateAndLocate()
                member:Save()
                Guild.members[member.name] = member;
            end

            if member.online then Guild.online[member.name] = member end
        end
    end
    return Guild.online, Guild.members; -- Always return, even if it's empty.
end

function Guild:InitBankInfo(index, member)
    Guild.bankIndex = i
    DKP.bankID, DKP.lastSync = Guild:GetBankData(member.officerNote)
end