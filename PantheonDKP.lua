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
local Guild = core.Guild; -- Uppercase is the file
local guild = core.guild; -- Lowercase is the object
local Shroud = core.Shroud;
local Member = core.Member;
local Import = core.Import;
local Officer = core.Officer;
local Invites = core.Invites;
local Minimap = core.Minimap;
local Defaults = core.Defaults;

core.firstLogin = nil;

local function PDKP_OnEvent(self, event, arg1, ...)

    local arg2 = ...

    local ADDON_EVENTS = {
        ['ADDON_LOADED']=PDKP:OnInitialize(event, arg1),
        ['PLAYER_ENTERING_WORLD']=function()
            local initialLogin, uiReload = arg1, arg2
            core.firstLogin = initialLogin;
            if uiReload then
                Guild:new();
                GUI:Init()
            end
        end,
        ['ZONE_CHANGED_NEW_AREA']=function()
            if core.firstLogin then
                Guild:new();
                GUI:Init()
            end
        end
    }

    if ADDON_EVENTS[event] then ADDON_EVENTS[event]() end
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