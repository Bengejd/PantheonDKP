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
local Member = core.Member;

local GuildDB;

local Player = nil;

Guild.online = {};

Guild.officers = {};
Guild.bankIndex = 0;
Guild.members = {};
Guild.classLeaders = {}


local guildDBDefaults = {
    profile = {
        name = nil,
        numOfMembers = 0,
        members = {},
        officers = {},
        migrated = false,
    }
}

-- Creates and assigns the Guild Database.
function Guild:InitGuildDB()
    Util:Debug('GuildDB init');

    core.Guild.db = LibStub("AceDB-3.0"):New("pdkp_guildDB", guildDBDefaults, true);
    GuildDB = core.Guild.db.profile;
    Guild.db = GuildDB;
end

-- Gets & Sets the guildDB's data.
function Guild:GetGuildData(onlineOnly)
    if IsInGuild() == false then return end;

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
    Guild.officers = {}; -- Clear out the old array, just incase.
    local gMemberCount, _, _ = GetNumGuildMembers();
    if gMemberCount > 0 then GuildDB.numOfMembers = gMemberCount else gMemberCount = GuildDB.numOfMembers; end
    for i=1, gMemberCount do
        local member = Member:new(i)
        if member.lvl >= 55 or member.canEdit or member.isOfficer then
            if member.online then Guild.online[member.name]=member;  end
            if member.isBank then
                Guild.bankIndex = i
                DKP.bankID, DKP.lastSync = Guild:GetBankData(member.officerNote)
            end
            if member.isOfficer then table.insert(Guild.officers, member) end
            member.isDkpOfficer = false

            if member.isClassLeader then table.insert(Guild.classLeaders, member) end

            if member.name == nil then
                member.name = ''
            else
                member:MigrateAndLocate()
                member:Save()
                Guild.members[member.name] = member;
            end
        end
    end

    Guild:VerifyGuildData()
    return Guild.online, Guild.members; -- Always return, even if it's empty.
end

function Guild:GetMemberByName(name)
    local tempMember = Guild.members[name]
    if tempMember == nil then
        return GuildDB.members[name]
    end
    return tempMember
end

function Guild:VerifyGuildData()
    for key, member in pairs(GuildDB.members) do
       if type(key) == type(1) then GuildDB.members[key] = nil end
    end
end

-- Needs reworked
function Guild:GetMyGuildInfo()
    if IsInGuild() then
        local guildName, guildRankName, guildRankIndex, realmName = GetGuildInfo("player");
        return guildName, guildRankName, guildRankIndex, realmName;
    end
end

-- Needs reworked
function Guild:IsMember(name, rankIndex)
    for _,v in pairs(GuildDB.members) do
        if v['name'] == name then
            if rankIndex and v['name'] then v['rankIndex'] = rankIndex; end
            return true;
        end
    end
    return false;
end

-- Needs reworked
function Guild:CanEdit()
    return core.canEdit;
end

function Guild:CanMemberEdit(name)
    local member = Guild.members[name]

    if member then
        return member.canEdit
    else
        for _, v in pairs(GuildDB.members) do
            if v['name'] == name then
                return v['canEdit'];
            end
        end
    end
    return false; -- Member was not found in the Guild Roster.
end

function Guild:GetMyMemberObject()
    local myName = Util:GetMyName()
    local myMemberObject = Guild:GetMemberByName(myName)
    return myMemberObject
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
    if Guild.members == nil or #Guild.members == 0 then
       return GuildDB.members;
    end
    return Guild.members
end

---------------------------
--    BANK FUNCTIONS     --
---------------------------

function Guild:GetBankMember()
    return Guild.members['Pantheonbank']
end

-- bank note is the lastEdit, lastSync
function Guild:GetBankData(officerNote)
    local lastEdit, lastSync = strsplit(',', officerNote)
    return tonumber(lastEdit), tonumber(lastSync)
end

function Guild:UpdateLastSync(lastSync)
    if not core.canEdit then return end; -- We can't edit the note anyway.
    Guild:GetGuildData() -- Re-get the guild info just incase.
    local bank = Guild:GetBankMember()
    if bank then -- We found the bank object.
        local bankNote = bank.officerNote
        local _, bankLastSync = Guild:GetBankData(bankNote)
        if bankLastSync and lastSync > bankLastSync then -- we have the right to update the lastSync.
            Guild:UpdateBankNote(nil, lastSync)
        else
            Util:Debug('Skipping update LastSync because bankLastSync is greater')
        end
    end
end

function Guild:UpdateBankLastEdit(lastEdit)
    return Guild:UpdateBankNote(lastEdit)
end

function Guild:FormatNewBankNote(lastEdit, lastSync)
    return tostring(lastEdit) .. ',' .. tostring(lastSync)
end

function Guild:UpdateBankNote(lastEdit, lastSync)
    if not core.canEdit then return end; -- We can't edit the note anyway.
    Guild:GetGuildData() -- retrieve the bank info.
    if Util:GetMyName() == 'Karenbaskins' then return end  -- Disabled changes from Karenbaskins as well.
    lastEdit = lastEdit or DKP.dkpDB.lastEdit;
    lastSync = lastSync or DKP.lastSync
    GuildRosterSetOfficerNote(Guild.bankIndex, Guild:FormatNewBankNote(lastEdit, lastSync))
end