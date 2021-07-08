local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local GuildBankGUI = {}

function GuildBankGUI:Initialize()
    if Utils:GetMyName() ~= "Neekio" then return end
end

GUI.GuildBankGUI = GuildBankGUI