local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Member;

local tContains = tContains

local GetServerTime = GetServerTime

local IsInGuild, GetNumGuildMembers, GuildRoster = IsInGuild, GetNumGuildMembers, GuildRoster
local GuildRosterSetOfficerNote, GetGuildInfo = GuildRosterSetOfficerNote, GetGuildInfo


local GuildManager = {}

function GuildManager:Initialize()
    self.bankIndex = nil
    self.officers = {}
    self.classLeaders = {}
    self.online = {}
    self.members = {}
    self.memberNames = {}
    self.numOfMembers, self.numOnlineMembers = 0, 0

    Member = MODULES.Member
    self.GuildDB = MODULES.Database:Guild()

    if not IsInGuild() then return end

    self:GetMembers()

    self.initiated = true
end

function GuildManager:IsNewMemberObject(name)
    return not tContains(self.memberNames, name)
end

function GuildManager:IsMemberInDatabase(name)
    return self.GuildDB[name] ~= nil
end

function GuildManager:GetMembers()
    GuildRoster()
    self.classLeaders, self.officers, self.online = {}, {}, {}

    self.numOfMembers, self.numOnlineMembers, _ = GetNumGuildMembers()

    local server_time = GetServerTime()

    for i=1, self.numOfMembers do
        local member = Member:new(i, server_time)
        local isNew = self:IsNewMemberObject(member.name)
        local inDatabase = self:IsMemberInDatabase(member.name);

        if member:IsRaidReady() then
            if member.name == nil then member.name = '' end
            --if member.isBank then Guild:initBankInfo(i, member) end
            if member.isOfficer then self.officers[member.name] = member end
            if member.isClassLeader then self.classLeaders[member.name] = member end

            if isNew then
                self.members[member.name] = member;
                self.memberNames[#self.memberNames + 1] = member.name
            end

            --if not inDatabase and PDKP.canEdit then
            --    member:Initialize(server_time)
            --end

            if member.online then self.online[member.name] = member end
        end
    end
    return self.online, self.members -- Always return, even if it's empty for edge cases.
end

function GuildManager:GetMemberByName(name)
    if tContains(self.memberNames, name) then return self.members[name] end
    return nil
end

MODULES.GuildManager = GuildManager
