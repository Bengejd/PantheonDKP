local _, core = ...;
local _G = _G;
local L = core.L;

local IsInGuild, GetNumGuildMembers, GuildRoster, GuildRosterSetOfficerNote, GetGuildInfo = IsInGuild, GetNumGuildMembers, GuildRoster, GuildRosterSetOfficerNote, GetGuildInfo -- Global Guild Functions
local strsplit, tonumber, tostring, pairs, type = strsplit, tonumber, tostring, pairs, type -- Global lua functions.

local Guild = core.Guild;
Guild.__index = Guild; -- Set the __index parameter to reference Character

function Guild:new(guildIndex)
    if IsInGuild() == false then return end;

    local self = {};
    setmetatable(self, Guild); -- Set the metatable so we used Members's __index

    self.officers = {};
    self.members = {};
    self.classLeaders = {};



    -- Variables / Attributes.

    return self
end

-- Events: