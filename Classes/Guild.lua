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
local insert = table.insert

Guild.initiated = false;
Guild.sortDir = nil;
Guild.sortBy = nil;
Guild.currentRaid = 'Molten Core';

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
    GuildDB = db.profile;
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

function Guild:Sort(sortBy)
    local newSortDir, newSortBy = nil, nil;

    local function toggleSort()

    end

    local function compare(a, b)
        if a == 0 and b == 0 then return end

    end


    local function compare(a,b)
        if a == 0 and b == 0 then return end;
        if sortDir == 'ASC' then return a[sortBy] > b[sortBy] end
        return a[sortBy] < b[sortBy];
    end

    local function compareDKP(a,b)
        if sortDir == 'DES' then return a.dkp['Molten Core'].total > b.dkp['Molten Core'].total end
        return a.dkp['Molten Core'].total < b.dkp['Molten Core'].total
    end
end

function Guild:IsNewMemberObject(member)
    local tableObj = Guild.members[member.name];

    return true;
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
--                member:MigrateAndLocate()
--                member:Save()
                table.insert(Guild.members, member)
                Guild.members[member.name] = member;
            end

            if member.online then Guild.online[member.name] = member end
        end
    end

    return Guild.online, Guild.members; -- Always return, even if it's empty.
end

function Guild:InitBankInfo(index, member)
    Guild.bankIndex = index
    DKP.bankID, DKP.lastSync = Guild:GetBankData(member.officerNote)
end

--['PLAYER_ENTERING_WORLD']=function()
--    Guild:GetMembers();
--    PDKP:Print(#Guild.members .. ' members found')
--    Setup:MainInterface()
--end

local function Guild_OnEvent(self, event, arg1, ...)
    local ADDON_EVENTS = {
        ['PLAYER_ENTERING_WORLD']=function() Guild:GetMembers() end
    }

    if ADDON_EVENTS[event] then
--        print('Guild Event!')
        return ADDON_EVENTS[event]()
    end

end

--local events = CreateFrame("Frame", "PDKP_GuildEventsFrame");
--local eventNames = { 'GUILD_ROSTER_UPDATE', 'PLAYER_ENTERING_WORLD', 'CHAT_MSG_GUILD' }
--for _, event in pairs(eventNames) do
--   events:RegisterEvent(event)
--end
--events:SetScript("OnEvent", Guild_OnEvent)

--
--local eventNames = {
--    "ADDON_LOADED", "GUILD_ROSTER_UPDATE", "GROUP_ROSTER_UPDATE", "ENCOUNTER_START",
--    "COMBAT_LOG_EVENT_UNFILTERED", "LOOT_OPENED", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_WHISPER",
--    "CHAT_MSG_GUILD", "CHAT_MSG_LOOT", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA","BOSS_KILL", "CHAT_MSG_SYSTEM"
--}
--
--for _, eventName in pairs(eventNames) do
--    events:RegisterEvent(eventName);
--end
--
--events:SetScript("OnEvent", PDKP_OnEvent); -- calls the above MonDKP_OnEvent function to determine what to do with the event
