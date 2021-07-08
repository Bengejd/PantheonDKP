local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;

local Member;

local tContains = tContains

local GetServerTime = GetServerTime

local IsInGuild, GetNumGuildMembers, GuildRoster = IsInGuild, GetNumGuildMembers, GuildRoster
local _, _ = GuildRosterSetOfficerNote, GetGuildInfo

local GuildManager = {}

function GuildManager:Initialize()
    self.initiated = false

    self.bankIndex = nil
    self.officers = {}
    self.classLeaders = {}
    self.online = {}
    self.members = {}
    self.memberNames = {}
    self.guildies = {}
    self.numOfMembers, self.numOnlineMembers = 0, 0

    PDKP.player = {}
    self.playerName = Utils:GetMyName()

    if not IsInGuild() then
        return
    end

    self:_GetLeadershipRanks()

    Member = MODULES.Member
    self.GuildDB = MODULES.Database:Guild()

    self:GetMembers()

    self.initiated = true
end

function GuildManager:IsNewMemberObject(name)
    return not tContains(self.memberNames, name)
end

function GuildManager:IsMemberInDatabase(name)
    return self.GuildDB[name] ~= nil
end

function GuildManager:IsGuildMember(name)
    return tContains(self.guildies, name)
end

function GuildManager:GetMembers()
    GuildRoster()
    self.classLeaders, self.officers, self.online = {}, {}, {}

    self.numOfMembers, self.numOnlineMembers, _ = GetNumGuildMembers()

    local server_time = GetServerTime()

    for i = 1, self.numOfMembers do
        local member = Member:new(i, server_time, { self.officerRank, self.classLeadRank })
        local isNew = self:IsNewMemberObject(member.name)

        if member.name ~= nil then
            self.guildies[#self.guildies + 1] = member.name;
        end

        if member.name == self.playerName then
            PDKP.canEdit = member.canEdit
        end

        if member:IsRaidReady() then
            if member.name == nil then
                member.name = ''
            end
            if member.isOfficer then
                self.officers[member.name] = member
            end
            if member.isClassLeader then
                self.classLeaders[member.name] = member
            end

            if isNew then
                self.members[member.name] = member;
                self.memberNames[#self.memberNames + 1] = member.name
            end

            if member.online then
                self.online[member.name] = member
            elseif self.online[member.name] ~= nil then
                self.online[member.name] = nil
            end
        end
    end
    return self.online, self.members -- Always return, even if it's empty for edge cases.
end

function GuildManager:GetMemberByName(name)
    if tContains(self.memberNames, name) then
        return self.members[name]
    end
    return nil
end

function GuildManager:IsMemberOfficer(name)
    local member = self:GetMemberByName(name)

    if member == nil then
        return false
    end

    return member.isOfficer
end

function GuildManager:GetOnlineNames()
    local onlineMembers, _ = self:GetMembers()
    local onlineNames = {}
    for name, val in pairs(onlineMembers) do
        if val ~= nil then
            tinsert(onlineNames, name)
        end
    end
    return onlineNames
end

function GuildManager:_GetLeadershipRanks()
    local numRanks = GuildControlGetNumRanks()
    for i = 2, numRanks do
        local perm = C_GuildInfo.GuildControlGetRankFlags(i)
        local listen, speak, promote, demote, invite, kick, o_note = perm[3], perm[4], perm[5], perm[6], perm[7], perm[8], perm[12]
        if listen and speak and promote and demote and invite and kick and o_note and i ~= 1 then
            self.officerRank = i
        elseif invite and kick and promote and demote then
            self.classLeadRank = i
        end
    end
end

MODULES.GuildManager = GuildManager
