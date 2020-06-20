local _, core = ...;
local _G = _G;
local L = core.L;

local PDKP = core.PDKP;

local function PDKP_OnEvent(self, event, arg1, ...)

end

function PDKP:OnInitialize(event, name)
    if (name ~= "PantheonDKP") then return end

end

function UnregisterEvent(self, event)
    self:UnregisterEvent(event);
end

local events = CreateFrame("Frame", "EventsFrame");

local eventNames = {
    "ADDON_LOADED", "GUILD_ROSTER_UPDATE", "GROUP_ROSTER_UPDATE", "ENCOUNTER_START",
    "COMBAT_LOG_EVENT_UNFILTERED", "LOOT_OPENED", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_WHISPER",
    "CHAT_MSG_GUILD", "CHAT_MSG_LOOT", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA","BOSS_KILL", "CHAT_MSG_SYSTEM"
}

for _, eventName in pairs(eventNames) do
    events:RegisterEvent(eventName);
end
events:SetScript("OnEvent", PDKP_OnEvent); -- calls the above MonDKP_OnEvent function to determine what to do with the event


