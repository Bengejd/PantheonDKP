local _, core = ...;
local _G = _G;
local L = core.L;

local Defaults = core.Defaults;
local Settings = core.Settings;

local IsInRaid, GetRaidRosterInfo = IsInRaid, GetRaidRosterInfo
local GetInstanceInfo, GetNumSavedInstances, GetSavedInstanceInfo = GetInstanceInfo, GetNumSavedInstances, GetSavedInstanceInfo
local GetNumLootItems, GetLootSlotInfo = GetNumLootItems, GetLootSlotInfo
local LoggingCombat, SendChatMessage = LoggingCombat, SendChatMessage
local StaticPopupDialogs, StaticPopup_Show = StaticPopupDialogs, StaticPopup_Show
local tostring, print, setmetatable, pairs = tostring, print, setmetatable, pairs
local canEdit, bossIDS = core.canEdit, core.bossIDS;

local currentRaid = nil;

local Raid = core.Raid;
Raid.__index = Raid; -- Set the __index parameter to reference Raid

function Raid:new()
    local self = {};
    setmetatable(self, Raid); -- Set the metatable so we used Members's __index

    -- Variables / Attributes.
    self.ClassInfo = {};
    self.MasterLooter = nil;
    self.dkpOfficer = nil;
    self.members = {};
    self.CurrentRaid = nil;

    return self
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

-- Events: PLAYER_ENTERING_WORLD, ZONE_CHANGED_NEW_AREA, GROUP_ROSTER_UPDATE,
-- -- CHAT_MSG_ADDON -- This might allow us to unregister from non-wanted events when in raid?