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

GUI.popup_entry = nil;

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

---------------------------
---  GLOBAL POP UPS     ---
---------------------------

PDKP_POPUP_DIALOG_SETTINGS = {
    ['PDKP_Placeholder']={
        text = "This method is under construction",
        button1 = "OK",
        OnAccept = function()
        end,
        OnCancel = function()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    },
    ["PDKP_RAID_BOSS_KILL"]={
        text = "", -- set by the calling function.
        button1 = "Award DKP",
        button2 = "Cancel",
        bossID = nil,
        bossName = nil,
        OnAccept = function()
            pdkp_template_function_call('pdkp_boss_kill_dkp', StaticPopupDialogs["PDKP_RAID_BOSS_KILL"].bossInfo);
            StaticPopup_Hide('PDKP_RAID_BOSS_KILL')
        end,
        OnCancel = function() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    },
    ['PDKP_CONFIRM_DKP_CHANGE'] = {
        text = "",
        button1 = "Confirm",
        button2 = "Cancel",
        OnAccept = function()
            DKP:UpdateEntries()
        end,
        OnCancel = function()
            StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].text = ''
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    },

    ['PDKP_DKP_ENTRY_POPUP']={
        text = "What would you like to do to this entry?",
        button1 = "Edit",
        button3 = 'Cancel',
        button2 = "Delete",
        OnAccept = function(self) -- Edit
            print('Edit Clicked')
        end,
        OnCancel = function(self) -- Delete
            StaticPopup_Show('PDKP_CONFIRM_DKP_ENTRY_DELETE')

            --StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_CONFIRM'].text = 'Are you sure you want to DELETE this entry?'
            --local entry = StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_POPUP'].entry
            --StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_CONFIRM'].entry = entry;
            --StaticPopup_Show('PDKP_EDIT_DKP_ENTRY_CONFIRM')
        end,
        OnAlt = function(self) -- Cancel
            print('Cancel clicked')
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    },
    ['PDKP_CONFIRM_DKP_ENTRY_DELETE']={
        text = "Are you sure you want to DELETE this entry?",
        button1 = "Confirm",
        button2 = "Cancel",
        OnAccept = function(self) -- Confirm
            DKP:DeleteEntry()
        end,
        OnCancel = function() -- Cancel
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    },
    ['PDKP_CONFIRM_DKP_ENTRY_POPUP']={

    },
    ['PDKP_OFFICER_PUSH_CONFIRM'] = {
        text = "WARNING THIS IS GUILD WIDE \n Overwrite is permanent and cannot be reversed. Merge is a safer option.",
        button1 = "Overwrite",
        button3 = 'Cancel',
        button2 = "Merge",
        OnAccept = function(...) -- First (Overwrite)
            Comms:SendGuildPush(true)
        end,
        OnCancel = function(...) -- Second (Merge)
            local _, _, clickType = ...
            -- Because creating another instance of the popup calls onCancel with 'override' instead of 'clicked'.
            -- This ensures that we actually clicked the cancel button. When hideOnEscape is enabled, this also is set as
            -- 'clicked' so this can't be enabled when we are using 3 buttons, as ALT is the one that we're using for
            -- cancel, for UX purposes.
            if clickType == 'clicked' then
                Comms:SendGuildPush(false)
            end
        end,
        OnAlt = function(...) -- Third (Cancel)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    },
    ['PDKP_RELOAD_UI'] = {
        text = "You are on a fresh version of PantheonDKP. Please Reload to continue.",
        button1 = "Reload",
        button2 = "Cancel",
        OnAccept = function(self) -- Confirm
            ReloadUI()
        end,
        OnCancel = function() -- Cancel
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    },
}

for popupName, value in pairs(PDKP_POPUP_DIALOG_SETTINGS) do
    StaticPopupDialogs[popupName] = value
end