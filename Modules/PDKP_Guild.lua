local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;

local GuildDB;


local Player = nil;
Guild.officers = {};
Guild.bankIndex = 0;

local guildDBDefaults = {
    profile = {
        name = nil,
        numOfMembers = 0,
        serialized = false,
        members = {}
    }
}

-- Creates and assigns the Guild Database.
function Guild:InitGuildDB()
    Util:Debug('GuildDB init');

    core.Guild.db = LibStub("AceDB-3.0"):New("pdkp_guildDB", guildDBDefaults, true);
    GuildDB = core.Guild.db.profile;
    Guild.db = GuildDB;
end

-- Sets the guildDB's data.
function Guild:GetGuildData(onlineOnly)
    --	name—Name of the member (string)
    --	rank—Name of the member’s rank (string)
    --	rankIndex—Numeric rank of the member (0 = guild leader; higher numbers
    --	for lower ranks) (number)
    --	level—Character level of the member (number)
    --	class—Localized name of the member’s class (string)
    --	zone—Zone in which the member was last seen (string)
    --	note—Public note text for the member (string)
    --	officernote—Officer note text for the member, or the empty string
    --  if the player is not allowed to view officer notes (string)
    --	online—1 if the member is currently online; otherwise nil (1nil)
    --	status—Status text for the member (string)
    --		<AFK>—Is away from keyboard
    --		<DND>—Does not want to be disturbed
    --  classFileName—Non-localized token representing the member’s class
    --		(string)

    GuildRoster()
    local gMemberCount, _, _ = GetNumGuildMembers();
    if gMemberCount > 0 then GuildDB.numOfMembers = gMemberCount else ReloadUI() end
    local onlineMembers = {}
    Guild.officers = {};

    for i=1, GuildDB.numOfMembers do
        local name, _, rankIndex, lvl, class, __, __, officerNote, online, __, __ = GetGuildRosterInfo(i)
        name = Util:RemoveServerName(name)
        local formattedName;
        if name then formattedName = Util:GetClassColoredName(name, class) end

        local canEdit = rankIndex <= 3;

        if onlineOnly then
            table.insert(onlineMembers, {
                ["name"]=name,
                ['online']=online,
            });
        else
            if lvl >= 55 or canEdit then
                if not Guild:IsMember(name, rankIndex) then
                    table.insert(GuildDB.members, {
                        ["name"]=name,
                        ['rankIndex']=rankIndex,
                        ["class"]=class,
                        ['online']=online,
                        ['canEdit']=canEdit,
                        ['formattedName']=formattedName,
                    });
                end
            end
        end

        if canEdit then
           table.insert(Guild.officers, {
               ['name']=name,
               ['rankIndex']=rankIndex,
               ['online']=online,
               ['canEdit']= canEdit,
               ['formattedName']=formattedName,
               ['lastEdit']=-1,
           })
        end

        if name == Util:GetMyName() then
            core.canEdit = canEdit;

            Util:Debug("Can Edit: " .. tostring(core.canEdit));
        end
    end

    if onlineOnly then Util:Debug("Online Members Total: " .. #onlineMembers) end
    Guild:VerifyGuildData()
    Guild:GetBankInfo()

    return onlineMembers; -- Always return, even if it's empty.
end

function Guild:GetBankInfo()
    for i = 1, Guild:GetMemberCount() do
        local name, _, rankIndex, lvl, class, __, __, officerNote, online, __, __ = GetGuildRosterInfo(i)
        name = Util:RemoveServerName(name)
        if name == 'Pantheonbank' then
            Guild.bankIndex = i;
            DKP.bankID = officerNote;
            Util:Debug('Found BankIndex '.. i .. ' officerNote: ' .. officerNote)
            return
        end
    end
end

function Guild:VerifyGuildData()
    for i=1, #GuildDB.members do
        local member = GuildDB.members[i]
        if member['name'] == nil then
            table.remove(GuildDB.members, i)
            GuildDB.numOfMembers = GuildDB.numOfMembers - 1;
        end
    end
end

function Guild:GetMyGuildInfo()
    if IsInGuild() then
        local guildName, guildRankName, guildRankIndex, realmName = GetGuildInfo("player");
        return guildName, guildRankName, guildRankIndex, realmName;
    end
end

function Guild:IsMember(name, rankIndex)
    for _,v in pairs(GuildDB.members) do
        if v['name'] == name then
            if rankIndex and v['name'] then v['rankIndex'] = rankIndex; end
            return true;
        end
    end
    return false;
end

function Guild:CanEdit()
    return core.canEdit;
end

function Guild:CanMemberEdit(name)
    for _, v in pairs(GuildDB.members) do
        if v['name'] == name then
            return v['canEdit'];
        end
    end
    return false; -- Member was not found in the Guild Roster.
end

function Guild:GetClassBreakdown()
    local classes={
        ['Druid']= 0, ['Hunter']=0, ['Mage']=0, ['Paladin']=0,
        ['Priest']=0, ['Rogue']=0, ['Warlock']=0, ['Warrior']=0,
    }
    for _, charObj in pairs(GuildDB.members) do
        if charObj.name and charObj.lvl >= 60 then
            classes[charObj.class] = classes[charObj.class] + 1;
        end
    end

    Util:PrintTable(classes, 1);
end

-- Resets the GuildDB to empty values.
function Guild:ResetGuildDataData()
    GuildDB.members = {};
    GuildDB.numOfMembers = 0;
end

-- Simple method to return the guild's database for methods outside this file.
function Guild:GetDB()
    return core.Guild.db.profile;
end

-- Returns the total members count from the database.
function Guild:GetMemberCount()
    return GuildDB.numOfMembers;
end

-- Returns the Guild's name from the DB
function Guild:GetGuildName()
    return GuildDB.name;
end

-- returns the members table from the database.
function Guild:GetMembers()
    return GuildDB.members;
end

function Guild:UpdateBankNote(id)
    Guild:GetBankInfo()
    GuildRosterSetOfficerNote(Guild.bankIndex, id)
end