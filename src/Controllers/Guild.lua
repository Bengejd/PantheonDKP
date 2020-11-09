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
local DKP_Entry = core.DKP_Entry;
local Settings = core.Settings;

local GuildDB = PDKP.guildDB;

local IsInGuild, GetNumGuildMembers, GuildRoster, GuildRosterSetOfficerNote, GetGuildInfo = IsInGuild, GetNumGuildMembers, GuildRoster, GuildRosterSetOfficerNote, GetGuildInfo -- Global Guild Functions
local strsplit, tonumber, tostring, pairs, type, next = strsplit, tonumber, tostring, pairs, type, next -- Global lua functions.
local insert, sort = table.insert, table.sort

Guild.initiated = false;
Guild.updateCalled = false;
Guild.sortDir = nil;
Guild.sortBy = nil;
Guild.currentRaid = 'Molten Core';

Guild.bank = nil;

-- Init the Databse.
local function initDB()
    GuildDB = PDKP.guildDB
    return GuildDB
end

function Guild:HasMembers()
    local guild_member_count = GetNumGuildMembers(true)
    return guild_member_count > 0
end

-- Init the Guild object.
function Guild:new()
    if (IsInGuild() == false or Guild.initiated) then
        return
    end

    Guild.db = initDB()
    Guild.db.members = PDKP.guildDB.members;

    Guild.officers = {};
    Guild.members = {};
    Guild.classLeaders = {};
    Guild.bankIndex = nil;
    Guild.memberNames = {};
    Guild.online, Guild.members = Guild:GetMembers()
    Guild.initiated = true;

    DKP:DeleteOldEntries()

    return Guild
end

function Guild:IsNewMemberObject(name)
    if tContains(Guild.memberNames, name) then
        return false
    else
        return true
    end
end

function Guild:UpdateNumOfMembers(num)
    GuildDB.numOfMembers = num
end

function Guild:GetMembers()

    GuildRoster()
    Guild.classLeaders, Guild.officers = {}, {};
    Guild.online = {};
    Guild.numOfMembers, _, _ = GetNumGuildMembers();

    if Guild.numOfMembers > 0 then Guild:UpdateNumOfMembers(Guild.numOfMembers) else Guild.numOfMembers = GuildDB.numOfMembers; end
    for i=1, Guild.numOfMembers do
        local member = Member:new(i)
        local isNew = Guild:IsNewMemberObject(member['name'])

        if member.lvl >= 55 or member.canEdit or member.isOfficer then
            if member.name == nil then member.name = '' end;
            if member.isBank then Guild:InitBankInfo(i, member) end -- Init bank info.
            if member.isOfficer then Guild.officers[member.name]=member end -- Init Officers
            if member.isClassLeader then insert(Guild.classLeaders, member) end; -- Init class classLeaders
            if isNew then
                table.insert(Guild.members, member)
                Guild.members[member.name] = member;
                Guild.memberNames[#Guild.memberNames + 1] = member.name
            end

            if member.online then Guild.online[member.name] = member end
        end
    end

    return Guild.online, Guild.members; -- Always return, even if it's empty.
end

function Guild:UpdateOnlineStatus()
    GuildRoster()
    local onlineTable = {};
    Guild.numOfMembers, _, _ = GetNumGuildMembers();
    if Guild.numOfMembers > 0 then Guild:UpdateNumOfMembers(Guild.numOfMembers) else Guild.numOfMembers = GuildDB.numOfMembers; end
    for i=1, Guild.numOfMembers do
        local name, _, _, _, _, _, _, _, online, _, _ = GetGuildRosterInfo(i)
        if online then
            name = strsplit('-', name)
            table.insert(onlineTable, name)
        end
    end
    return onlineTable
end

function Guild:InitBankInfo(index, member)
    Guild.bankIndex = index
    Guild.bank = member;
    Guild:GetSyncStatus()
end

function Guild:GetSyncStatus()
    if Guild.bank == nil or Guild.bank.name ~= Defaults.bank_name then
        Util:Debug("Error getting Sync Status from bank info", Guild.bank, Guild.bank.name);
        return
    end
    DKP.bankLastEdit, DKP.bankLastSync = Guild.bank:GetGuildBankSync()
end

function Guild:GetMemberByName(name)
    if tContains(Guild.memberNames, name) then return Guild.members[name]
    else return nil
    end
end

function Guild:UpdateBankNote(lastEdit, lastSync)
    if not Settings:CanEdit() then return end
    Guild:GetMembers()
    local gbankLastEdit, gbankLastSync = Guild.bank:GetGuildBankSync()
    lastEdit = lastEdit or gbankLastEdit;
    lastSync = lastSync or gbankLastSync;
    GuildRosterSetOfficerNote(Guild.bank.guildIndex, tostring(lastEdit) .. ',' .. tostring(lastSync))
    Guild:GetMembers()

end

--- Merging Functions

function PDKP_Merge_Old_Guild_Data()
    return Guild:MergeOldData()
end

function Guild:MergeOldData()
    local old_guild_db = core.PDKP.old_guild_db
    local old_guild_members =  old_guild_db['members']

    --- Member data
    Util:Debug("Merging Old Member data")
    for name, old_mem in pairs(old_guild_members) do
        local new_mem = Guild:GetMemberByName(name)
        if new_mem ~= nil then
            local dkp = old_mem['dkp'];
            new_mem:OverwriteDKP(dkp)
        end
    end

    local old_dkp_db = core.PDKP.old_dkp_db
    local old_history = old_dkp_db['history']
    local old_deleted = old_history['deleted']
    local old_all = old_history['all']

    local currentDB = core.PDKP.dkpDB
    local current_history = currentDB['history']
    local current_deleted = current_history['deleted']
    local current_all = current_history['all']

    --- Deleted History
    Util:Debug("Merging Old Deleted Entries")
    for _, ID in pairs(old_deleted) do
        if not tContains(current_deleted, ID) then
            table.insert(current_deleted, ID)
        end
    end

    --- All History
    Util:Debug("Merging Old Entries")
    for ID, old_entry in pairs(old_all) do
        local current_entry = current_all[ID]
        if current_entry == nil then
            local new_entry = DKP_Entry:New(old_entry)
            new_entry:Save()
        end
    end

    --- Last Edit
    if old_dkp_db['lastEdit'] then
        core.PDKP.dkpDB['lastEdit'] = old_dkp_db['lastEdit']
    end

    Settings.db['mergedOld'] = true
    GUI:RefreshTables()
end