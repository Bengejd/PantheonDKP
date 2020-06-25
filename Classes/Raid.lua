local _, core = ...;
local _G = _G;
local L = core.L;

local IsInRaid, GetRaidRosterInfo = IsInRaid, GetRaidRosterInfo
local GetInstanceInfo, GetNumSavedInstances, GetSavedInstanceInfo = GetInstanceInfo, GetNumSavedInstances, GetSavedInstanceInfo
local GetNumLootItems, GetLootSlotInfo = GetNumLootItems, GetLootSlotInfo
local LoggingCombat, SendChatMessage = LoggingCombat, SendChatMessage
local StaticPopupDialogs, StaticPopup_Show = StaticPopupDialogs, StaticPopup_Show
local tostring, print = tostring, print

local Raid = core.Raid;
Raid.__index = Raid; -- Set the __index parameter to reference Character

function Raid:new(guildIndex)
    local self = {};
    setmetatable(self, Raid); -- Set the metatable so we used Members's __index

    -- Variables / Attributes.
    self.ClassInfo = {};
    self.MasterLooter = nil;
    self.dkpOfficer = nil;


    return self
end

-- Events: PLAYER_ENTERING_WORLD, ZONE_CHANGED_NEW_AREA, GROUP_ROSTER_UPDATE,
-- -- CHAT_MSG_ADDON -- This might allow us to unregister from non-wanted events when in raid?