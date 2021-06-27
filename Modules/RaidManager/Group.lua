local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Group = {}

local IsInRaid = IsInRaid

local tinsert = table.insert

function Group:Initialize()
    setmetatable(self, Group); -- Set the metatable so we used Group's __index

    self.classes = {};

    local CLASSES = MODULES.Constants.CLASSES
    for i=1, #CLASSES do
        self.classes[CLASSES[i]] = {}
    end

    self.members = {};

    self.player = {}

    self.leadership = {
        assist = {},
        masterLoot = nil,
        dkpOfficer = nil,
        leader = nil,
    }

    self:RegisterEvents();
end

function Group:Refresh()

    local numGroupMembers = GetNumGroupMembers()

    for i=1, numGroupMembers do
        local name, rank, _, _, class, _, _, _, _, _, isML, _ = GetRaidRosterInfo(i);
        tinsert(self.classes[class], name)

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
            self.player = {
                name = name,
                class = class,
                isML = isML ~= nil,
                isLeader = rank == 2,
                isAssist = rank == 1,
                isDKP = name == self.leadership.dkpOfficer
            }
        end

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


    --function Raid:InviteName(name)
    --    name = strlower(name)
    --    local ignore_from = GUI.invite_control['ignore_from']
    --    if contains(ignore_from, name) then
    --        return print("Invite request from", name, "has been ignored")
    --    end
    --
    --    if Raid:InRaid() then
    --        if not (Raid.raid.leader == Char:GetMyName() or tContains(Raid.raid.assistants, Char:GetMyName())) then
    --            SendChatMessage("Whisper " .. Raid.raid.leader .. " for invite, I don\'t have assist", "WHISPER", nil, name)
    --            return
    --        end
    --    else
    --        ConvertToRaid()
    --    end
    --    InviteUnit(name)
    --end

end

function Group:InvitePlayer(name)
    if self:CanInvite() then
        return InviteUnit(name)
    end
end

function Group:CanInvite()
    local inRaid = IsInRaid()
    local numGroupMembers = GetNumGroupMembers()
    local isGroupLeader = UnitIsGroupLeader("PLAYER")

    if (not inRaid and numGroupMembers == 0) or isGroupLeader then
        return true
    elseif not isGroupLeader and inRaid then
        self:Refresh()
        if self.isAssist then
            return true
        end
    end
    return false
end

function Group:RegisterEvents()
    local events = {'GROUP_ROSTER_UPDATE', 'BOSS_KILL', 'ZONE_CHANGE_NEW_AREA'};


    --local raid_group_events = {
    --    ['GROUP_ROSTER_UPDATE']=function(_, _)
    --        if not GetRaidRosterInfo(raid_size) then return end
    --        Raid.raid:Init()
    --        GUI:UpdateInRaidFilter()
    --    end,
    --    ['BOSS_KILL']=function(arg1, arg2)
    --        local bossID, bossName = arg1, arg2
    --        Raid:BossKill(bossID, bossName)
    --    end,
    --    ['ZONE_CHANGED_NEW_AREA']=function()
    --        if not UnitIsDeadOrGhost("player") then
    --            Raid:CheckCombatLogging()
    --        end
    --    end
    --}
end

MODULES.GroupManager = Group