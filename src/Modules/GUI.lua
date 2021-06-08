local _G = _G;
local AddonName, core = ...;

local PDKP = core.PDKP
local GUI, Util, Defaults, Character, Setup = PDKP:GetInst('GUI', 'Util', 'Defaults', 'Character', 'Setup')
local GUI, Util, Defaults, Character, Setup, Dev = PDKP:GetInst('GUI', 'Util', 'Defaults', 'Character', 'Setup', 'Dev')

--local DKP = core.DKP;
--local Raid = core.Raid;
--local Comms = core.Comms;
--local Setup = core.Setup;
--local Guild = core.Guild;
--local Settings = core.Settings;
--local Export = core.Export;

GUI.pdkp_frame = nil;
GUI.sortBy = 'name';
GUI.sortDir = 'ASC';
GUI.memberTable = nil;
GUI.adjustment_frame = nil; -- The DKP Adjustments Frame
GUI.adjustmentDropdowns = {} -- -- The DKP Adjustment Dropdown Menus names
GUI.adjustmentDropdowns_names = {}; -- The DKP Adjustment Dropdown Menus names
GUI.editBoxes = {}; -- The DKP Adjustment Edit Boxes
GUI.adjustment_submit_button = nil; -- The Submit Button
GUI.adjustment_entry = {}; -- The Entry info we are creating when hitting submit
GUI.adjust_buttons = {} -- The Adjustment Buttons
GUI.boss_loot_frame = nil; -- The DKP Adjustments Boss Loot Frame
GUI.recent_boss_kill = {}; -- The Info regarding our most recent Boss Kill
GUI.filter_frame = nil; -- The Member Table Filter Frame
GUI.history_frame = nil; -- The DKP History Frame
GUI.history_table = nil; -- The DKP History Table
GUI.raid_frame = nil; -- The PDKP Raid Tools frame.
GUI.popup_entry = nil; -- The popup entry that we are editing/deleting.
GUI.sync_frame = nil;

GUI.shroud_box = nil;

function GUI:Init()
    Dev:Print('Initializing GUI')
    GUI.pdkp_frame = Setup:MainUI()
    GUI.pdkp_frame:Hide()

    --GUI:UpdateEasyStats()

    if Defaults.development then
        Dev:Print('Development Mode Active')
        GUI.pdkp_frame:Show()
    end
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