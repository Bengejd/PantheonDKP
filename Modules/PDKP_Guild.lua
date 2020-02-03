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
local DKPDB = core.dkpDB;

local Player = nil;

local guildDBDefaults = {
    char = {
        name = nil,
        numOfMembers = nil,
        members = {}
    }
}

-- Creates and assigns the Guild Database.
function Guild:InitGuildDB()
    Util:Debug('GuildDB init');

    core.Guild.db = LibStub("AceDB-3.0"):New("pdkp_guildDB", guildDBDefaults);
    GuildDB = Guild:GetDB();
end

-- Sets the guildDB's data.
function Guild:GetGuildData()
    -- Guild:ResetGuildData(); -- Reset the guild data on a fresh start.

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
    GetGuildRosterShowOffline()

    local gMemberCount = GetNumGuildMembers();
    if gMemberCount > 0 then GuildDB.numOfMembers = gMemberCount; end

    for i=1, GuildDB.numOfMembers do
        local name, rank, rankIndex, lvl, class, __, __, __, online, __, __ = GetGuildRosterInfo(i)
        name = Util:RemoveServerName(name)
        table.insert(GuildDB.members, {
            ["name"]=name,
            ['rank']=rank,
            ['rankIndex']=rankIndex,
            ["class"]=class,
            ['online']=online,
            ['lvl']=lvl,
            ["class_color"]=core.defaults.class_colors[class], -- so we can display the class later.
        });

        if name == Util:GetMyName() then
            print(name);
            core.canEdit = rankIndex <= 4;
            Util:Debug("Can Edit: " .. tostring(core.canEdit));
        end
    end
    Util:Debug("Total Guild Members: " .. GuildDB.numOfMembers)
end

function Guild:GetOnlineMembers()
    GuildRoster()
    GetGuildRosterShowOffline()

    local onlineMembers = {};
    for i=1, GuildDB.numOfMembers do
        local name, _, _, _, _, __, __, __, online, __, __ = GetGuildRosterInfo(i)
        name = Util:RemoveServerName(name)

        if online then
            table.insert(onlineMembers, {
                ["name"]=name,
                ['online']=online,
            });
        end
    end
    Util:Debug("Online Members Total: " .. #onlineMembers)
    return onlineMembers;
end

function Guild:GetBankIndex()
    GuildRoster()
    GetGuildRosterShowOffline()
end

function Guild:IsMember(name)
    for _,v in pairs(GuildDB.members) do
        if v['name'] == name then return true; end
    end
    return false;
end

function Guild:CanEdit()
    return core.canEdit;
end

function Guild:GetClassBreakdown()
    local classes={
        ['Druid']= 0,
        ['Hunter']=0,
        ['Mage']=0,
        ['Paladin']=0,
        ['Priest']=0,
        ['Rogue']=0,
        ['Warlock']=0,
        ['Warrior']=0,
    };
    for key, charObj in pairs(GuildDB.members) do
        if charObj.name then
            if charObj.lvl >= 60 then
               classes[charObj.class] = classes[charObj.class] + 1;
            end
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
    return core.Guild.db.char;
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