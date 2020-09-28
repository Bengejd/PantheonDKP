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
local Settings = core.Settings;

GUI.pdkp_frame = nil;
GUI.sortBy = 'name';
GUI.sortDir = 'ASC';
GUI.memberTable = nil;

GUI.adjustmentDropdowns = {}
GUI.adjustmentDropdowns_names = {};
GUI.editBoxes = {};
GUI.submit_entry = nil;
GUI.adjustment_entry = {};
GUI.adjust_buttons = {}

GUI.boss_loot_frame = nil;
GUI.recent_boss_kill = {};

GUI.filter_frame = nil;
GUI.adjustment_frame = nil;
GUI.history_frame = nil;
GUI.raid_frame = nil;

function GUI:Init()
    Util:Debug('Initializing GUI')
    GUI.pdkp_frame = Setup:MainUI()

    GUI:UpdateEasyStats()

    Shroud:Setup()

    if Settings:IsDebug() then
        Util:Debug('Debugging Mode Active')
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

function GUI:UpdateEasyStats()
    local char_name = Character:GetMyName()
    local member = Guild:GetMemberByName(char_name)

    local char_info_text;

    if member == nil and not Settings:IsDebug() then return end

    if member == nil and Settings:IsDebug() then
        char_info_text = 'Pamplemousse' .. ' | ' .. '9999 DKP'
    elseif Settings:IsDebug() then
        char_info_text = char_name .. ' | ' .. '99999 DKP'
    else
        char_info_text = char_name .. ' | ' .. '99999 DKP'
    end

    local pdkp_frame = _G['pdkp_frame']
    --local easy_frame, easy_text = pdkp_frame.easy_stats, pdkp_frame.easy_stats.text
    local easy_text = pdkp_frame.easy_stats.text

    easy_text:SetText(char_info_text)
    --local text_len = string.len(char_info_text)
    --local border_widths = {[21]=250, [22]=260, [23]=270} -- changes based on characters being displayed.
    --local borderX = border_widths[text_len] or 240
    --
    --easy_frame:SetSize(borderX, 72);

end