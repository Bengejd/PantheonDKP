local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Import = core.import;
local Setup = core.Setup;

GUI.countdownTimer = nil;
GUI.statusbar = nil;
GUI.reasonDropdown = nil;
GUI.shown = false;
GUI.sortBy = nil;
GUI.sortDir = 'ASC';
GUI.pdkp_frame = nil;
GUI.lastEntryClicked = nil;
GUI.lastEntryNameClicked = nil;
GUI.sliderVal = 0;
GUI.hasTimer = false;
GUI.adjustDropdowns = nil;
GUI.raidDropdown = nil;

local AceGUI = LibStub("AceGUI-3.0")

local PlaySound = PlaySound

GUI.pdkp_dropdown_enables_submit = false;
GUI.pdkp_dkp_amount_box = nil
GUI.pdkp_submit_button = nil

GUI.HistoryTItle = Util:FormatFontTextColor('FFBA49', 'Recent History')
GUI.HistoryShown = false

GUI.adjustmentReasons = {
    "On Time Bonus",
    "Completion Bonus",
    "Benched",
    "Boss Kill",
    "Unexcused Absence",
    "Item Win",
    "Other"
}

GUI.adjustDropdowns = {}


-----------------------------
--     MISC FUNCTIONS    --
-----------------------------

function GUI:CheckOutOfDate()
    local outOfDateText = Util:FormatFontTextColor('E71D36', 'Your DKP is out of date')
    local lastEdit = DKP.dkpDB.lastEdit
    local lastEditID;
    if DKP.bankID == nil then
--       Util:Debug('no bankID')
    else
--        Util:Debug(lastEdit['id'])
    end
end

function GUI:UpdateSelectedEntriesLabel()
    local label = _G['pdkp_selected_entries_label'];
    local displayCount = GUI:GetDisplayDataCount();
    local selectCount = #GUI.selected;

    local text = displayCount .. " Entries Shown | " .. selectCount .. " Selected"
    label:SetText(text);
end

function GUI:HideAdjustmentReasons()
    for i=1, 3 do
        local d = GUI.adjustDropdowns[i]
        d.frame:Hide()
        d:SetText('')
        d:SetValue(nil)
    end
end

-- Hides the PDKP UI
function GUI:Hide()
    if not GUI.shown then return end -- Don't open more than one instance of PDKP

    PlaySound(851)

    PDKP:Print("Hiding PDKP")

    GUI.pdkp_frame:Hide()
    GUI.shown = false;
    GUI.HistoryCheck.frame:Hide()

    GUI.HistoryFrame:Hide()

    -- Hide the item link as well.
    local itemLinkButton = GUI:GetItemButton();
    itemLinkButton:Hide();
    Item:ClearLinked()

    if GUI.adjustDropdowns then
        for i = 1, #GUI.adjustDropdowns do
            GUI.adjustDropdowns[i].frame:Hide();
            if i == 1 then GUI.adjustDropdowns[i]:SetValue(''); end
        end
    end
end

function GUI:ToggleAllClasses(checked)
    for i=1, #Defaults.classes do
        local cb = _G['pdkp_'..Defaults.classes[i]..'_checkbox']
        cb:SetChecked(true)
        _G['pdkp_all_classes']:SetChecked(true)
        GUI:pdkp_dkp_table_filter_class(cb:GetName(), true)
    end
end

function GUI:dkpSliderValueChanged(val)
    GUI.sliderVal = val;
    pdkp_dkp_table_filter()
end

function GUI:UpdateDKPSliderMax()
    local slider = getglobal('pdkp_filter_dkp_slider')
    local max = DKP:GetHighestDKP();
    slider:SetMinMaxValues(0.0, max)
    slider.textHigh:SetText(max);
end

---------------------------
-- View Functions     --
---------------------------
function GUI:pdkp_change_view(view)
    GUI.selected = {};
    PDKP:Print("View changed to", view);
end

function GUI:ShowBossKillPopup()
end

---------------------------
-- Entry Click Functions --
---------------------------

-- Handles control click of an entry
function GUI:EntryControlClicked(charObj, clickType, bName)
    GUI.lastEntryClicked = bName;
    GUI.lastEntryNameClicked = charObj['name']
    charObj.bName = bName; -- we'll need this later to remove the custom textures if selected filter is checked.
    if GUI.selected[charObj.name] then
        GUI:RemoveFromSelected(charObj);
    else GUI:AddToSelected(charObj);
    end
end

-- Handles regular click of an entry
function GUI:EntryClicked(charObj, clickType, bName)
    if GUI:IsNotSelected(charObj.name) == false then
        _G[bName].customTexture:Hide();
        if GUI:GetSelectedCount() == 0 then GUI:ShowSelectedHistory(nil) end
        GUI:ClearSelected();
        return;
    end

    GUI:ClearSelected() -- clear all previous selections
    GUI.lastEntryClicked = bName;
    GUI.lastEntryNameClicked = charObj['name']
    charObj.bName = bName; -- we'll need this later to remove the custom textures if selected filter is checked.
    GUI:AddToSelected(charObj);
    GameTooltip:Hide();
end

-- Handles the shift click of an entry
function GUI:EntryShiftClicked(charObj, clickType, bName)
    if bName == GUI.lastEntryClicked then return end; -- No need to do anyhting if you're clicking the same entry.
    -- No previous entry to reference.
    if GUI:GetSelectedCount() == 0 then return GUI:EntryControlClicked(charObj, clickType, bName) end

    local prevClick = Util:RemoveNonNumerics(GUI.lastEntryClicked);
    local currClick = Util:RemoveNonNumerics(bName);

    local prevNum = tonumber(prevClick); -- Previously clicked entry
    local currNum = tonumber(currClick) -- Most recent clicked entry

    local startIndex; -- the entry we're starting at.
    local endIndex; -- the entry we're ending at.

    if prevNum < currNum then startIndex = prevNum else startIndex = currNum end
    if currNum > prevNum then endIndex = currNum else endIndex = prevNum end

    local startIndex; -- the entry we're starting at.
    local endIndex; -- the entry we're ending at.

    local displayData = GUI:GetTableDisplayData(true);

    local charObjStop = getglobal("pdkp_dkp_entry" .. currNum)
    charObjStop = charObjStop.char;

    local dataIndex = {}
    for k, v in pairs(displayData) do dataIndex[v['name']] = k end

    local charStop = dataIndex[charObjStop['name']]
    local charStart = dataIndex[GUI.lastEntryNameClicked]

    if charStart < charStop then startIndex = charStart else startIndex = charStop end
    if charStop > charStart then endIndex = charStop else endIndex = charStart end

    for i = startIndex, endIndex do
        local charObj = displayData[i]
        GUI:AddToSelected(charObj);
    end

    GUI.lastEntryClicked = bName;
    GUI.lastEntryNameClicked = charObj['name'];
end

---------------------------
-- Selected Functions   --
---------------------------

-- Returns the selected entries count.
function GUI:GetSelectedCount()
    return table.getn(GUI.selected);
end

-- changes the view to the selected entries only.
function GUI:pdkp_toggle_selected()
    if table.getn(GUI.selected) == 0 then Util:Debug('Nothing to display!') end;
    GUI:GetTableDisplayData()
    pdkp_dkp_table_filter()
end

-- Returns the "Selected" filter checkbox status.
function GUI:GetSelectedFilterStatus()
    return getglobal('pdkp_selected_checkbox'):GetChecked();
end

function GUI:IsNotSelected(name)
    return GUI.selected[name] == nil
end

-- Adds an entry to the selected array.
function GUI:AddToSelected(charObj)
    -- Don't add selections that are already in the list.
    if GUI:IsNotSelected(charObj.name) == false then return end;

    table.insert(GUI.selected, charObj.name)
    GUI.selected[charObj.name] = charObj;
    --    entryButton.customTexture:Show();
    pdkp_dkp_scrollbar_Update()
    GUI:SelectedEntriesUpdated()

    if GUI:GetSelectedCount() == 1 then GUI:ShowSelectedHistory(charObj) end
end

-- Removes the entry from the selected array.
function GUI:RemoveFromSelected(charObj)
    _G[charObj.bName].customTexture:Hide();
    GUI.selected[charObj.name] = nil;

    table.remove(GUI.selected, Util:FindTableIndex(GUI.selected, charObj.name));
    GUI:SelectedEntriesUpdated()

    if GUI:GetSelectedCount() == 0 then GUI:ShowSelectedHistory(nil) end
end

function GUI:ShowSelectedHistory(charObj)
    if GUI.HistoryShown == false then return end; -- No need to do anything if history isn't being shown.

    local b, member, dkpHistory, charName, title, entries, historyKeys;

    GUI.HistoryFrame.scroll:ReleaseChildren() -- Clear the previous entries.

    local function getDkpHistoryKeys(historyObject, all)
        local keys = {};
        if historyObject == nil then return {}; end
        for key, obj in pairs(historyObject) do
            if all then table.insert(keys, key) -- For everyone.
            else table.insert(keys, obj)
            end
        end
        return keys;
    end

    if charObj ~= nil then -- We actually have a character we're checking out.
        b = _G[charObj['bName']]
--        Util:Debug('Showing history for '.. charObj['name'])
        member = DKP.dkpDB.members[charObj['name']]
        historyKeys = getDkpHistoryKeys(member['entries'], false)
        charName = Util:FormatFontTextColor(Util:GetClassColor(b.char.class), b.char.name)
        title = Util:FormatFontTextColor('FFBA49', 'Recent History for ') .. charName
        GUI.HistoryFrame.historyTitle:SetText(title) -- Set the title.
    else
        Util:Debug('Showing history for everyone')
        historyKeys = getDkpHistoryKeys(DKP.dkpDB.history['all'], true)
    end

    if historyKeys == nil or #historyKeys == 0 then -- there is no dkp history to show, hide the frame and end function.
        local scroll = GUI.HistoryFrame.scroll
        local empty = 'No historical data found'
        empty = Util:FormatFontTextColor('E71D36', empty)
        local label = AceGUI:Create("Label")
        label:SetText(empty)
        scroll:AddChild(label)
        return
    end

    local function compare(a,b)
        return a > b
    end
    table.sort(historyKeys, compare)

    for i=1, #historyKeys do
        local key = historyKeys[i]
        local entry = DKP.dkpDB.history.all[key]
        local raid = entry['raid'];
        if raid == 'Onyxia\'s Lair' then raid = 'Molten Core'; end -- Set the default since MC & Ony are combined.

        local dkpChangeText = entry['dkpChangeText']
        local lineText = entry['text']

        if raid and raid == DKP.dkpDB.currentDB then -- Only show history relevent to this raid.
            local scroll = GUI.HistoryFrame.scroll

            local dkpChangeLabel = AceGUI:Create("Label")
            dkpChangeLabel:SetWidth(50)

            local reasonLabel = AceGUI:Create("InteractiveLabel")
            reasonLabel:SetWidth(250)
            local officerLabel = AceGUI:Create("Label")

            officerLabel:SetText('Officer: ' ..entry['officer'])
            reasonLabel:SetText('Reason: '..lineText)
            dkpChangeLabel:SetText(string.trim(dkpChangeText))

            local labels = {officerLabel, reasonLabel, dkpChangeLabel }

            local function labelCallback(self, _, buttonType)
                if buttonType == 'RightButton' and Guild:CanEdit() then
                    StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_POPUP'].entry = self.entry;
                    StaticPopup_Show('PDKP_EDIT_DKP_ENTRY_POPUP')
                end
            end

            for i=1, #labels do
                local label = labels[i];
                label.entry = entry;
                label:SetCallback("OnClick", labelCallback)
            end

            if entry['item'] ~= nil then
               reasonLabel:SetCallback("OnEnter", function(self)
                    GameTooltip:SetOwner(reasonLabel.frame, "ANCHOR_RIGHT")
                    local tiptext = entry['item']
                    GameTooltip:SetHyperlink(tiptext);
               end)
                reasonLabel:SetCallback("OnLeave", function(self)
                    GameTooltip:Hide()
                end)
            end

            reasonLabel:SetFullWidth(false)
            dkpChangeLabel:SetFullWidth(false)

            local ig = AceGUI:Create("InlineGroup")

            local formattedDate = Util:Format12HrDateTime(entry['datetime'])
            local title = formattedDate

            if entry['raid'] then
                title = entry['raid'] .. ' | ' .. formattedDate
            end

            ig:SetTitle(title)
            ig:SetLayout("Flow")
            ig:SetFullWidth(true)

            local officerGroup = AceGUI:Create("SimpleGroup")
            local textGroup = AceGUI:Create("SimpleGroup")
            local dkpGroup = AceGUI:Create("SimpleGroup")

            officerGroup:SetFullWidth(true)
            textGroup:SetFullWidth(false)
            dkpGroup:SetFullWidth(false)

            officerGroup:AddChild(officerLabel)
            textGroup:AddChild(reasonLabel)
            dkpGroup:AddChild(dkpChangeLabel)

            textGroup:SetWidth(275)
            dkpGroup:SetWidth(30)

            ig:AddChild(officerGroup)
            ig:AddChild(textGroup)
            ig:AddChild(dkpGroup)

            if charObj == nil then -- List all entries, with the people affected.
                local names = entry['names'];
                local sg3 = AceGUI:Create("SimpleGroup")
                local namesLabel = AceGUI:Create("Label")
                namesLabel:SetText('Members: '..names)
                sg3:AddChild(namesLabel)
                sg3:SetFullWidth(true)
                sg3:SetWidth(300)
                namesLabel:SetWidth(325)
                ig:AddChild(sg3)
            end

            scroll:AddChild(ig)
        end
    end

    GUI.HistoryObj = charObj
end

-- Hides the custom textures for entries in the selected table, and then empties the table completely.
function GUI:ClearSelected()
    for key, charObj in pairs(GUI.selected) do
        if charObj.name then
            GUI.selected[charObj.name] = nil;
        end
    end
    GUI.selected = {};
    GUI.lastEntryClicked = nil;
    GUI.lastEntryNameClicked = nil;
    pdkp_dkp_scrollbar_Update()
    GUI:ToggleSubmitButton()

    GUI.HistoryFrame.historyTitle:SetText(GUI.HistoryTItle)
    GUI:ShowSelectedHistory(nil)
    if not GUI.lastEntryClicked then return end;
end

-- Disalbes / Enables the shrouding & roll buttons if more than 1 person is selected.
function GUI:SelectedEntriesUpdated()
    local selectedCount = GUI:GetSelectedCount()
    local shroudButton = getglobal('pdkp_dkp_quick_shroud');
    local rollButton = getglobal('pdkp_dkp_quick_roll')

    local enabled = false;

    if selectedCount > 0 and selectedCount < 2 then enabled = true end
    shroudButton:SetEnabled(enabled);
    rollButton:SetEnabled(enabled);
    GUI:ToggleSubmitButton()

    GUI:UpdateSelectedEntriesLabel()
end

function GUI:ToggleSubmitButton()
    if GUI.pdkp_dkp_amount_box == nil then return end;
    -- Someone is selected
    -- Amount is in the box
    -- Reason is selected (sub-sections are selected)
    local hasSelected = GUI.GetSelectedCount() >= 1;

    local isEmpty = Util:IsEmpty(GUI.pdkp_dkp_amount_box:GetText());
    local isEnabled = GUI.pdkp_dropdown_enables_submit and hasSelected and not isEmpty and core.canEdit;

    GUI.pdkp_submit_button:SetEnabled(isEnabled);
end

---------------------------
-- MISC GUI Functions  --
---------------------------

-- Type can be 'shroud' or 'roll'
function GUI:QuickCalculate(type)
    local charObj = GUI.selected[GUI.selected[1]]; -- Ugly way of doing this...
    local percent = 0.1;
    local amount;
    if type == 'shroud' then percent = 0.5 end;

    amount = math.ceil(charObj.dkpTotal * percent);
    GUI.pdkp_dkp_amount_box:SetText('-' .. amount);
end

-- Update personal DKP text at the top
function GUI:UpdateEasyStats()
    local charName = PDKP:GetCharName();
    local char_dkp = DKP:GetPlayerDKP(charName);

    local charInfoText = charName .. " | " .. char_dkp .. " DKP"

    if (core.defaults.debug) then charInfoText = "Pamplemousse" .. " | " .. '9999' .. " DKP" end

    getglobal("pdkp_charInfo"):SetText(charInfoText);

    local textLen = string.len(charInfoText);
    local borderWidths = { [21] = 250, [22] = 260, [23] = 270 } -- changes based on characters being displayed.
    local borderX = borderWidths[textLen] or 240;

    _G['pdkp_easy_stats_border']:SetSize(borderX, 72);
end

---------------------------
-- Hide GUI Functions  --
---------------------------
function GUI:HideAdjustmentGUI(hide)
    local shroudButton = getglobal('pdkp_dkp_quick_shroud');
    local itemLink = getglobal('pdkp_item_link');

    local elements = { shroudButton, GUI.pdkp_submit_button, GUI.pdkp_dkp_amount_box, itemLink };

    for k, element in pairs(elements) do
        if hide then element:Hide(); else element:Show(); end
    end
end

---------------------------
-- LINKED ITEM Functions --
---------------------------
function GUI:UpdateShroudItemLink(itemLink)
    Item:UpdateLinked(itemLink);
    local buttonText = _G['pdkp_item_link_text']
    buttonText:SetText(itemLink);
    local button = GUI:GetItemButton();
    button:Show();

    Util:Debug(itemLink);


    -- THIS SHOULD ALSO CHANGE DROPDOWN TO ITEM-WIN IF NECESSARY.
end

function GUI:GetItemButton()
    return _G['pdkp_item_link'];
end

---------------------------
-- TIMER Functions    --
---------------------------
function GUI:CreateTimer(timerCount)

    if timerCount == nil then timerCount = 20 end -- Default timer count.
    if GUI.countdownTimer then GUI:CancelTimer() end
    if GUI.statusbar == nil then GUI.statusbar = CreateFrame("StatusBar", 'pdkp_statusbar', UIParent) end;

    local statusbar = GUI.statusbar;

    statusbar:RegisterForDrag("LeftButton")
    statusbar:SetFrameStrata("HIGH")
    statusbar:EnableMouse(true);

    statusbar:SetScript("OnDragStart", statusbar.StartMoving)
    statusbar:SetScript("OnDragStop", statusbar.StopMovingOrSizing)

    statusbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    statusbar:SetWidth(200)
    statusbar:SetHeight(20)
    statusbar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    statusbar:GetStatusBarTexture():SetHorizTile(false)
    statusbar:GetStatusBarTexture():SetVertTile(false)
    statusbar:SetStatusBarColor(0, 0.65, 0)

    statusbar.bg = statusbar:CreateTexture(nil, "BACKGROUND")
    statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    statusbar.bg:SetAllPoints(true)
    statusbar.bg:SetVertexColor(0, 0.35, 0)

    statusbar.value = statusbar:CreateFontString(nil, "OVERLAY")
    statusbar.value:SetPoint("LEFT", statusbar, "LEFT", 4, 0)
    statusbar.value:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    statusbar.value:SetJustifyH("LEFT")
    statusbar.value:SetShadowOffset(1, -1)
    statusbar.value:SetTextColor(0, 1, 0)
    statusbar.value:SetText("20")

    statusbar.isLocked = false;

    statusbar:Show()

    local function TimerFeedback()
        timerCount = timerCount - 1;
        GUI:UpdateTimer(statusbar, timerCount);
    end

    GUI.countdownTimer = PDKP:ScheduleRepeatingTimer(TimerFeedback, 1)
end

function GUI:UpdateTimer(statusbar, timerCount)
    statusbar.value:SetText(timerCount);

    local width = statusbar:GetWidth()
    statusbar:SetWidth(width - 10);

    if timerCount == 0 then
        statusbar:Hide();
        GUI:CancelTimer()
    end
end

function GUI:CancelTimer()
    if GUI.countdownTimer then
        PDKP:CancelTimer(GUI.countdownTimer);
        GUI.countdownTimer = nil;
        GUI.statusbar:Hide();
        GUI.statusbar = nil;
    end
end

---------------------------
-- GLOBAL POP UPS     --
---------------------------

StaticPopupDialogs["PDKP_Placeholder"] = {
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
}

StaticPopupDialogs["PDKP_RAID_BOSS_KILL"] = {
    text = "", -- set by the calling function.
    button1 = "Award DKP",
    button2 = "Cancel",
    bossID = nil,
    bossName = nil,
    OnAccept = function()
        pdkp_template_function_call('pdkp_boss_kill_dkp', StaticPopupDialogs["PDKP_RAID_BOSS_KILL"].bossID);
        StaticPopup_Hide('PDKP_RAID_BOSS_KILL')
    end,
    OnCancel = function() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'] = {
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
}

StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_POPUP'] = {
    text = "What would you like to do to this entry?",
    button1 = "Edit",
    button3 = 'Cancel',
    button2 = "Delete",
    OnAccept = function(self) -- Edit
        end,
    OnCancel = function() -- Delete
        StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_CONFIRM'].text = 'Are you sure you want to DELETE this entry?'
        local entry = StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_POPUP'].entry
        StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_CONFIRM'].entry = entry;
        StaticPopup_Show('PDKP_EDIT_DKP_ENTRY_CONFIRM')
    end,
    OnAlt = function() -- Cancel
        print('Cancel clicked')
    end,
timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_CONFIRM'] = {
    text = "Are you sure you want to",
    button1 = "Confirm",
    button2 = "Cancel",
    OnAccept = function(self) -- Confirm
        local entry = StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_CONFIRM'].entry
        DKP:DeleteEntry(entry)
    end,
    OnCancel = function() -- Cancel
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}
