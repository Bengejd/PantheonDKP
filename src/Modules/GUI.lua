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

local SendChatMessage = SendChatMessage

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

GUI.shroud_box = nil;

GUI.invite_control = {
    ['commands']={},
    ['ignore_from']={},
    ['text']='',
    ['running']=false,
    ['counter']=0,
    ['timer']=nil,
    ['spamButton']=nil,
}


function GUI:Init()
    Util:Debug('Initializing GUI')
    GUI.pdkp_frame = Setup:MainUI()

    GUI:UpdateEasyStats()

    Shroud:Setup()

    if Settings:IsDebug() then
        Util:Debug('Debugging Mode Active')
    end
end

function GUI:TogglePDKP()
    if GUI.pdkp_frame and GUI.pdkp_frame:IsVisible() then
        GUI.pdkp_frame:Hide()
    elseif GUI.pdkp_frame and not GUI.pdkp_frame:IsVisible() then
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

function GUI:UpdateEasyStats()
    local char_name = Character:GetMyName()
    local member = Guild:GetMemberByName(char_name)

    local char_info_text = char_name .. ' | ';
    local dkp_total = '0'

    if member ~= nil then dkp_total = member:GetDKP(nil, 'total') end

    if Settings:IsDebug() and member == nil then dkp_total = '9999' end

    char_info_text = char_info_text .. dkp_total .. ' DKP'

    local easy_frame = _G['pdkp_frame'].easy_stats
    local easy_text = easy_frame.text
    easy_text:SetText(char_info_text)
    local padding = 65 -- 20 for the string, 45 for the texture.
    local stats_width = easy_text:GetStringWidth() + padding
    easy_frame:SetWidth(stats_width)

    --easy_frame:SetSize(str_width + 45, 72)
    --local border_widths = {[21]=250, [22]=260, [23]=270} -- changes based on characters being displayed.
    --local borderX = border_widths[text_len] or 240
    --
    --easy_frame:SetSize(borderX, 72);

end

function GUI:UpdateRaidClassGroups()
    if Raid.raid == nil or GUI.raid_frame == nil or GUI.raid_frame.class_groups == nil then return end

    local raid_class_names = {'Tank', unpack(Defaults.classes)}
    local class_icons = GUI.raid_frame.class_groups.class_icons
    local raid_classes = Raid.raid['classes']


    for key, class in pairs(raid_class_names) do
        local class_icon = class_icons[class]
        class_icon.label:SetText(#Raid:GetClassNames(class))
    end
    -- Set total members

    if tEmpty(Raid.raid.members) then return end
    class_icons['Total'].label:SetText(#Raid.raid.members)


end

function GUI:RefreshTables()
    GUI.memberTable:ClearSelected()
    GUI.memberTable:ClearAll()
    GUI.memberTable:RaidChanged()

    if GUI.history_table.frame:IsVisible() then
        GUI.history_table:HistoryUpdated()
    else
        GUI.history_table.updateNextOpen = true
    end

    wipe(GUI.memberTable.selected)
end

function GUI:ToggleRaidInviteSpam()
    local invite_control = GUI.invite_control
    local text = invite_control['text']
    local timer =  invite_control['timer']
    local interval = 90

    local spam_channel = 'GUILD'
    local spam_char = nil

    if Settings:IsDebug() then
        Util:Debug("Setting Spam Count Interval to 2 for debugging")
        interval = 2
        spam_char = 'Lariese'
        spam_channel = 'WHISPER'
    end

    if timer then
        print('Stopping Invite Spam')
        PDKP:CancelTimer(timer)
        GUI.invite_control['count']=0;
        GUI.invite_control['timer']=nil;
        GUI.invite_control['spamButton']:SetText('Start Raid Inv Spam')
        return
    end

    if Util:IsEmpty(text) then return end -- Stop here if the text is empty.

    print("Starting Invite Spam")

    local function sendMsg()
        SendChatMessage(text, spam_channel, nil, spam_char) -- SendChatMesage(text, 'GUILD', nil, nil);
    end

    local function timerFeedback()
        GUI.invite_control['counter'] = GUI.invite_control['counter'] + 1
        print("Raid Invite Spam Count: " .. tostring(GUI.invite_control['counter']))
        sendMsg()
        if  GUI.invite_control['counter'] >= 10 then Comms:ToggleRaidInviteSpam() end
        if Raid:GetRaidSize() == 40 then Comms:ToggleRaidInviteSpam() end
    end

    sendMsg()
    GUI.invite_control['timer'] = PDKP:ScheduleRepeatingTimer(timerFeedback, interval) -- Posts it every 90 seconds for 15 mins.
end

function UpdatePushBar(percent, elapsed)
    if GUI.pushbar == nil then
        Setup:PushTimer()
    end

    local remaining = 100 - percent
    local pps = percent / elapsed -- Percent per second
    local eta = (elapsed / percent) * remaining
    eta = math.floor(eta)

    hours = string.format("%02.f", math.floor(eta/3600));
    mins = string.format("%02.f", math.floor(eta/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(eta - hours*3600 - mins *60));

    --print('percent: ', percent, 'elapsed:', elapsed, 'hours', hours, 'mins', mins, 'secs', secs)

    local etatext = mins .. ':' .. secs

    local statusText = 'PDKP Push: ' .. percent .. '%' .. ' ETA: ' .. etatext

    GUI.pushbar:Show()

    local statusbar = GUI.pushbar
    local currVal = statusbar:GetValue()

    if currVal == nil then currVal = 0 end
    if currVal < percent and percent <= 100 then
        statusbar.value:SetText(statusText);
        statusbar:SetValue(percent)
    end

    if percent >= 100 then
        statusbar:Hide();
        PDKP:CancelTimer(GUI.pushbar)
        statusbar:SetValue(0)
    end
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