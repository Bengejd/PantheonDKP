local _, core = ...;
local _G = _G;
local L = core.L;

local Defaults = core.Defaults;
local Settings = core.Settings;
local Util = core.Util;
local GUI = core.GUI;

local IsInRaid, GetRaidRosterInfo = IsInRaid, GetRaidRosterInfo
local GetInstanceInfo, GetNumSavedInstances, GetSavedInstanceInfo = GetInstanceInfo, GetNumSavedInstances, GetSavedInstanceInfo
local GetNumLootItems, GetLootSlotInfo = GetNumLootItems, GetLootSlotInfo
local LoggingCombat, SendChatMessage = LoggingCombat, SendChatMessage
local StaticPopupDialogs, StaticPopup_Show = StaticPopupDialogs, StaticPopup_Show
local tostring, print, setmetatable, pairs = tostring, print, setmetatable, pairs
local canEdit, bossIDS = core.canEdit, core.bossIDS;

local Raid = core.Raid;

Raid.raid = nil;
Raid.events_frame = nil;

Raid.recent_boss_kill = {};

Raid.__index = Raid; -- Set the __index parameter to reference Raid

local raid_events = {'GROUP_ROSTER_UPDATE'}

function Raid:new()
    local self = {};
    setmetatable(self, Raid); -- Set the metatable so we used Members's __index

    Raid.raid = self

    -- Variables / Attributes.
    self.classes = {};
    self.MasterLooter = nil;
    self.dkpOfficer = nil;
    self.members = {};

    self:RegisterEvents();
    self:Init()

    return self
end

function Raid:Init()
    local raid_info = self:GetRaidInfo()
    self.members = raid_info['names']
    self.classes = raid_info['classes']
    self.MasterLooter = raid_info['ML']
    GUI:UpdateRaidClassGroups()
end

function PDKP_Raid_OnEvent(self, event, arg1, ...)
    if not Raid:InRaid() then return Util:Debug("Not In Raid, Ignoring event") end
    local raid_size = GetNumGroupMembers()

    local raid_group_events = {
        ['GROUP_ROSTER_UPDATE']=function()
            if not GetRaidRosterInfo(raid_size) then return end
            Raid.raid:Init()
        end,
    }

    if raid_group_events[event] then raid_group_events[event]() end

end

function Raid:GetClassNames(class)
    local raid_roster = Raid:GetRaidInfo()
    return raid_roster['classes'][class]
end

function Raid:InRaid()
    return UnitInRaid("player") ~= nil
end

function Raid:NewBossKill()
    --return Raid:BossKill(669, 'Sulfuron Harbinger');
end

function Raid:GetRaidInfo()
    if not Raid:InRaid() then return end

    local raidRoster = {
        ['names']={},
        ['classes']={},
        ['ML']=nil,
        ['dkpOfficer']=nil,
        ['dead']={},
    }

    for key, class in pairs(Defaults.classes) do raidRoster['classes'][class] = {} end
    raidRoster['classes']['Tank'] = {}

    for i=1, 40 do
        local name, rank, subgroup, level, class, fileName,
        zone, online, isDead, role, isML = GetRaidRosterInfo(i);
        if name ~= nil then
            table.insert(raidRoster['names'], name)
            if role ~= nil and role == 'MAINTANK' then
                table.insert(raidRoster['classes']['Tank'], name)
            else
                table.insert(raidRoster['classes'][class], name)
            end

            if isMl then raidRoster['ML']=name end
            if isDead then table.insert(raidRoster['dead'], name) end
        end
    end
    return raidRoster
end

function Raid:BossKill()
    if not canEdit then return end; -- If you can't edit, then you shoudln't be here.

    local bk
    for raidName, raidObj in pairs(bossIDS) do
        if bk == nil then
            for pdkpBossID, pdkpBossName in pairs(raidObj) do
                if pdkpBossID == bossID or pdkpBossName == bossName then
                    bk = {
                        name=pdkpBossName,
                        id=pdkpBossID,
                        raid=raidName,
                    }
                    break
                end
            end
        else
            break
        end
    end

    if bk == nil then return end; -- We should have found the boss kill by now.

    -- You are the DKP Officer
    -- There is no dkp Officer, but you're the master looter

    local dkpOfficer = Raid.dkpOfficer

    if ( ( dkpOfficer and Raid:IsDkpOfficer() ) or ( not dkpOfficer and RaidIsMasterLooter() ) ) then
        Util:Debug('You are not the master looter, and not dkpOffcier.')
        return
    end

    local popup = StaticPopupDialogs["PDKP_RAID_BOSS_KILL"];
    popup.text = bk.name .. ' was killed! Award 10 DKP?'
    popup.bossInfo = bk;
    StaticPopup_Show('PDKP_RAID_BOSS_KILL')
end

function Raid:GetCurrentRaid()
    name, instance_type, difficultyIndex, difficultyName, maxPlayers,
    dynamicDifficulty, isDynamic, instanceMapId, lfgID = GetInstanceInfo()
    if tContains(Defaults.raids, name) then
        return name
    elseif currentRaid ~= nil and tContains(Defaults.raids, currentRaid) then
        return currentRaid
    else
        return Settings.current_raid;
    end
end

function Raid:GetInstanceInfo()
    name, instance_type, difficultyIndex, difficultyName, maxPlayers,
    dynamicDifficulty, isDynamic, instanceMapId, lfgID = GetInstanceInfo()
end

function Raid:RegisterEvents()
    if Raid.events_frame ~= nil then
        Util:Debug('Setting up raid events')
        for _, eventName in pairs(raid_events) do Raid.events_frame:UnregisterEvent(eventName) end
        Raid.events_frame = nil
    end

    Raid.events_frame = CreateFrame("Frame", nil, UIParent)
    for _, eventName in pairs(raid_events) do Raid.events_frame:RegisterEvent(eventName) end
    Raid.events_frame:SetScript("OnEvent", PDKP_Raid_OnEvent)
end

--- Debug funcs
function Raid:TestBossKill()
    local raids = Defaults.bossIDS
    local raid_bosses = raids[Settings.current_raid]
    for id, name in pairs(raid_bosses) do
        return {
            ['name']=name,
            ['id']=id,
            ['raid']=Settings.current_raid
        }
    end
end

-- Events: PLAYER_ENTERING_WORLD, ZONE_CHANGED_NEW_AREA, GROUP_ROSTER_UPDATE,
-- CHAT_MSG_ADDON -- This might allow us to unregister from non-wanted events when in raid