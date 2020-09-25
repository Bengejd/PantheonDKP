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
local Guild = core.Guild;
local Shroud = core.Shroud;
local Member = core.Member;
local Import = core.Import;
local Officer = core.Officer;
local Invites = core.Invites;
local Minimap = core.Minimap;
local Defaults = core.Defaults;
local Character = core.Character;

GUI.pdkp_frame = nil;
GUI.sortBy = 'name';
GUI.sortDir = 'ASC';
GUI.memberTable = nil;

GUI.adjustmentDropdowns = {}
GUI.adjustmentDropdowns_names = {};
GUI.editBoxes = {};
GUI.submit_entry = nil;
GUI.adjustment_entry = {};

function GUI:Init()
    Util:Debug('Initializing GUI')
    GUI.pdkp_frame = Setup:MainUI()
    Shroud:Setup()
end

function GUI:Show()
    if GUI.pdkp_frame then
        GUI.pdkp_frame:Show()
    end
end

function GUI:Hide()
    if GUI.pdkp_frame then
        GUI.pdkp_frame:Hide()
    end
end