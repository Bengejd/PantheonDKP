local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Group = {}

local IsInRaid = IsInRaid

local tinsert = table.insert
local GetNumGroupMembers, GetRaidRosterInfo = GetNumGroupMembers, GetRaidRosterInfo
local UnitIsGroupLeader = UnitIsGroupLeader
local ConvertToRaid, InviteUnit = ConvertToRaid, InviteUnit

function Group:Initialize()
    setmetatable(self, Group); -- Set the metatable so we used Group's __index

    self.classes = {};
    self.available = true

    self:_RefreshClasses()

    self.memberNames = {};

    self.player = {}

    self.leadership = {
        assist = {},
        masterLoot = nil,
        dkpOfficer = nil,
        leader = nil,
    }

    self:RegisterEvents();

    self:Refresh()

    if PDKP:IsDev() then

    end
end

function Group:Refresh()
    if not self.available then return end
    self.available = false

    local numGroupMembers = GetNumGroupMembers()

    self:_RefreshLeadership()
    self:_RefreshClasses()
    self:_RefreshMembers()

    for i=1, numGroupMembers do
        local name, rank, _, _, class, _, _, _, _, _, isML, _ = GetRaidRosterInfo(i);
        tinsert(self.classes[class], name)
        tinsert(self.memberNames, name)

        -- leadership
        if rank > 0 then
            tinsert(self.leadership.assist, name)
            if rank == 2 then
                self.leadership.leader = name
            end
        end

        if isML then
            self.leadership.masterLoot = name
        end

        if name == PDKP.player.name then
            self.isML = isML ~= nil
            self.isLeader = rank == 2
            self.isAssist = rank >= 1
            self.isDKP = name == self.leadership.dkpOfficer
        end
    end

    if PDKP.raid_frame ~= nil then
        PDKP.raid_frame:updateClassGroups()
    end

    --if not Raid:InRaid() then return Util:Debug("Not In Raid, Ignoring event") end
    --local raid_size = GetNumGroupMembers()
    --    --local raid_group_events = {
    --    --    ['GROUP_ROSTER_UPDATE']=function(_, _)
    --    --        if not GetRaidRosterInfo(raid_size) then return end
    --    --        Raid.raid:Init()
    --    --        GUI:UpdateInRaidFilter()
    --    --    end,
    --    --    ['BOSS_KILL']=function(arg1, arg2)
    --    --        local bossID, bossName = arg1, arg2
    --    --        Raid:BossKill(bossID, bossName)
    --    --    end,
    --    --    ['ZONE_CHANGED_NEW_AREA']=function()
    --    --        if not UnitIsDeadOrGhost("player") then
    --    --            Raid:CheckCombatLogging()
    --    --        end
    --    --    end
    --    --}
    --    else
    --        ConvertToRaid()
    --    end
    --    InviteUnit(name)
    --end

    self.available = true
end

function Group:InvitePlayer(name)
    if self:CanInvite(name) then
        return InviteUnit(name)
    elseif GetNumGroupMembers() == 5 and self.isLeader then
        ConvertToRaid()
        return self:InvitePlayer(name)
    end
end

function Group:CanInvite(name)
    local ignore_pugs = MODULES.RaidManager.ignore_pugs
    if ignore_pugs and not MODULES.GuildManager:IsGuildMember(name) then
        return false
    end

    self:Refresh()

    return not self:IsInRaid() or self:IsLeader() or self:IsAssist()
end

function Group:RegisterEvents()
    local events = {'GROUP_ROSTER_UPDATE', 'BOSS_KILL' };
    local f = CreateFrame("Frame", "PDKP_Group_EventsFrame");

    for _, eventName in pairs(events) do
        f:RegisterEvent(eventName)
    end
    f:SetScript("OnEvent", function(self, event, arg1, ...)
        Group:_HandleEvent(event, arg1, ...)
    end)
end

function Group:IsInRaid()
    --local isAlone = (not IsInRaid() and GetNumGroupMembers() == 0)
    return IsInRaid() and GetNumGroupMembers() >= 1
end

function Group:IsDKPOfficer()
    return self.isDKP
end

function Group:IsAssist()
    return self.isAssist or false
end

function Group:IsLeader()
    return self.isLeader or UnitIsGroupLeader("PLAYER")
end

function Group:IsMasterLoot()
    return self.isML
end

function Group:HasDKPOfficer()
    return self.leadership.dkpOfficer ~= nil
end

function Group:GetNumClass(class)
    if self.classes[class] then
        return #self.classes[class]
    end
    return 0
end

function Group:_RefreshClasses()
    local CLASSES = MODULES.Constants.CLASSES
    for i=1, #CLASSES do
        if type(self.classes[CLASSES[i]]) == "table" then
            wipe(self.classes[CLASSES[i]])
        end
        self.classes[CLASSES[i]] = {}
    end
end

function Group:_RefreshLeadership()
    for key, val in pairs(self.leadership) do
        if type(val) == "table" then
            wipe(self.leadership[key])
        else
            self.leadership[key] = nil
        end
    end
end

function Group:_RefreshMembers()
    wipe(self.memberNames)
    if type(self.memberNames) ~= "table" then
        self.memberNames = {}
    end
end

function Group:_HandleEvent(event, arg1, ...)
    self:Refresh()

    if not self.available then
        print('Restarting handle event');
        return C_Timer.After(1.5, self:_HandleEvent(event, arg1, ...))
    end

    if event == 'GROUP_ROSTER_UPDATE' then
        if not self:IsInRaid() then return end
        -- TODO: Update GUI Filter?
    elseif event == 'BOSS_KILL' then
        local isDKP = self:HasDKPOfficer() and self:IsDKPOfficer()
        local isMLNoDKP = not self:HasDKPOfficer() and self:IsMasterLoot()
        if isDKP or isMLNoDKP then
            MODULES.DKPManager:BossKillDetected(arg1, ...)
        end
    end

    --local raid_group_events = {
    --    ['ZONE_CHANGED_NEW_AREA']=function()
    --        if not UnitIsDeadOrGhost("player") then
    --            Raid:CheckCombatLogging()
    --        end
    --    end
    --}
end

MODULES.GroupManager = Group