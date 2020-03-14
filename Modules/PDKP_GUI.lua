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

local pdkp_dropdown_enables_submit = false;
local pdkp_dkp_amount_box;
local pdkp_submit_button;

GUI.HistoryTItle = Util:FormatFontTextColor('FFBA49', 'Recent History')

GUI.adjustmentReasons = {
    "On Time Bonus",
    "Signup Bonus",
    "Benched",
    "Boss Kill",
    "Unexcused Absence",
    "Item Win",
    "Other"
}

---------------------------
--  GUI Setup Functions  --
---------------------------

function GUI:CreateMainFrame()
    if GUI.pdkp_frame == nil then -- We haven't initialized the frame yet.
        -- Create frame args: frameType, frameName, parentFrame, inheritsFrame
        GUI.pdkp_frame = CreateFrame("Frame", "pdkpCoreFrame", UIParent, "pdkp_core_frame");
        GUI.pdkp_frame:SetPoint("TOPLEFT", 0, 0)
        GUI:setupClassCheckboxes()
        GUI:SetupDKPFilterSlider()
        GUI:CreateAdjustDropdown()
        GUI:SelectedEntriesUpdated()
        GUI:CreateRaidDkpDropdown()
        GUI:CreateHistoryFrame()

        pdkp_dkp_amount_box = _G['pdkp_dkp_amount_box'];
        pdkp_submit_button =  _G['pdkp_dkp_submit'];


    else -- We have initialized the frame already.
        -- Grab the global pdkpCoreFrame object that was previously created
        GUI.pdkp_frame = getglobal("pdkpCoreFrame");

    end
end

function GUI:CreatePushButton()

end

function GUI:CreateAdjustDropdown()
    local reasonDropdown = AceGUI:Create("Dropdown")
    local secondaryDropdown = AceGUI:Create("Dropdown")
    local thirdDropdown = AceGUI:Create("Dropdown")

    local dropdowns = {reasonDropdown, secondaryDropdown, thirdDropdown }
    local dropdownWidths = {150, 120, 100};
    local dropdownX = {-25, 100, 200 }
    local dropdownNames = {'first', 'second', 'third'}

--[[
--  On Time Bonus -> Raid (Ony, MC, BWL)
--  Signup Bonus -> Raid (Ony, MC, BWL)
--  Boss Kill -> Boss Name (Recently killed bosses)
--  Item Win -> Item Name
--
 ]]

    reasonDropdown:SetList(GUI.adjustmentReasons)
    secondaryDropdown:SetList(core.raids);

    reasonDropdown:SetValue('Other')
    thirdDropdown:SetText('Other');
    reasonDropdown:SetLabel('Reason');

    local otherBox = getglobal('pdkp_other_entry_box')

    local function DropdownValueChanged(this, event, index)
        local submitButton = pdkp_submit_button
        local amountBox = getglobal('pdkp_dkp_amount_box')

        this.value = index
        local adjustAmount;
        local bossKillBonus = 10;
        local updateAmountBox = false;
        -- First Dropdown Logic

        if this.name == 'first' then
            for i=2, #dropdowns do
                if i ~= 4 then
                    local d = dropdowns[i];
                    d:SetValue('')
                    d.frame:Hide()
                    d:SetLabel('');
                    amountBox:SetText('');
                    submitButton:SetEnabled(false);
                end
            end

            -- On time, Signup, Boss kill, Unexcused Absence.
            if index <= 5 then
                secondaryDropdown.frame:Show()
                secondaryDropdown:SetLabel('Raid');
                otherBox:Hide();
            end

            if index == 6 then
                local buttonText = getglobal('pdkp_item_link_text')
                if Util:IsEmpty(buttonText:GetText()) then submitButton:SetEnabled(false);
                else pdkp_dropdown_enables_submit = true;
                end
            end

            if index == 7 then
                otherBox:Show();
                pdkp_dropdown_enables_submit = false;

                otherBox:SetScript("OnTextChanged", function(self)
                    local isEmpty = Util:IsEmpty(self:GetText());
                    if isEmpty then
                        pdkp_dropdown_enables_submit = false;
                    else
                        pdkp_dropdown_enables_submit = true;
                    end
                end)
            end

        -- Second Dropdown Logic
        elseif this.name == 'second' then
            thirdDropdown.frame:Hide() -- Hide it by default
            local d1 = dropdowns[1];

            if d1.value >= 1 and d1.value <= 5 then
                local raid = core.raids[index];
                if raid == core.raids[1] then adjustAmount = 5 else adjustAmount = 10 end;

                if d1.value >= 1 and d1.value <= 3 then  -- Ontime / Signup bonus
                    updateAmountBox = true

                    if d1.value == 3 then -- benched
                        bossKillBonus = (bossKillBonus * #core.raidBosses[raid]);
                        adjustAmount = (bossKillBonus + (adjustAmount * 2)) / 2;
                    end
                end


                if d1.value == 4 then -- boss kill
                    local bosses = core.raidBosses[raid]

                    thirdDropdown:SetList(bosses)
                    thirdDropdown:SetLabel('Boss Kill')

                    if bosses ~= nil then
                        thirdDropdown:SetValue(bosses[1])
                        thirdDropdown:SetText(bosses[1]);
                        thirdDropdown.frame:Show()
                        updateAmountBox = true;
                        adjustAmount = 10;
                    end
                end
                pdkp_dropdown_enables_submit = true;
            end

        -- Third Dropdown Logic

        elseif this.name == 'third' then
            pdkp_dropdown_enables_submit = true;
        end

        if updateAmountBox then

            amountBox:SetText(adjustAmount);
        end

        GUI:ToggleSubmitButton()
    end

    for i=1, #dropdowns do
        local d = dropdowns[i]
        d:ClearAllPoints();
        d:SetParent(GUI.pdkp_frame);
        d.frame:SetFrameStrata('HIGH')
        d:SetWidth(dropdownWidths[i])
        d:SetPoint("BOTTOMRIGHT", GUI.pdkp_frame, "BOTTOMRIGHT", dropdownX[i], -150)
        d.name = dropdownNames[i];
        d:SetCallback("OnValueChanged", DropdownValueChanged)
        if i > 1 then d.frame:Hide(); end
    end

    GUI.adjustDropdowns = dropdowns;
    GUI.reasonDropdown = reasonDropdown;
end

function GUI:CreateRaidDkpDropdown()
    local currentRaid = DKP.dkpDB.currentDB;

    local rd = AceGUI:Create("Dropdown")
    rd:ClearAllPoints();
    rd:SetList(core.raids);
    rd:SetValue(currentRaid);
    rd:SetLabel('Raid Selection');
    rd:SetText(currentRaid);

    rd:SetParent(GUI.pdkp_frame);
    rd.frame:SetFrameStrata('HIGH');
    rd:SetWidth(120);
    rd:SetPoint("TOPRIGHT", GUI.pdkp_frame, "TOPRIGHT", 200, -25);

    rd.label:SetHeight(22)

    rd:SetCallback("OnValueChanged", function(this, event, index)
        DKP:ChangeDKPSheets(core.raids[index])
        GUI:UpdateEasyStats();
        pdkp_dkp_table_filter();

        if GUI.HistoryObj ~= nil then
            GUI:ShowSelectedHistory(GUI.HistoryObj)
        end
    end)

    GUI.raidDropdown = rd;
    table.insert(GUI.adjustDropdowns, rd);
end

function GUI:UpdateSelectedEntriesLabel()
    local label = getglobal('pdkp_selected_entries_label');

    local displayCount = GUI:GetDisplayDataCount();
    local selectCount = #GUI.selected;

    label:SetText(displayCount .. " Entries Shown | " .. selectCount .. " Selected");

end

function GUI:CreateHistoryFrame()

    local check = AceGUI:Create("CheckBox")
    check:SetValue(false)
    check:SetParent(pdkpCoreFrame)
    check.frame:SetFrameStrata('HIGH');
    check:SetImage('Interface\\Buttons\\UI-GuildButton-OfficerNote-Up.blp')
    check:SetPoint("TOP", pdkpCoreFrame, "TOP", -32, -43)
    check.checkbg:SetAlpha(0.0)
    check.highlight:SetAlpha(0.0)
    check.check:SetAlpha(0.0)
    check:SetWidth(50)
    check:SetHeight(50)
    check.frame:Show()

    GUI.HistoryCheck = check

    local function showHistoryFrame(checked, buttonCall)
        if checked then GUI.HistoryFrame:Show() else GUI.HistoryFrame:Hide() end
        -- Workaround for check button not firing when using the easyStats to toggle.
        if not buttonCall and checked then PlaySound(856) elseif not buttonCall then PlaySound(857) end
    end

    check:SetCallback("OnValueChanged", function(self, _, checked)
        showHistoryFrame(checked, true)
    end)

    local b = CreateFrame("Button", "pdkpHistoryButton", pdkpCoreFrame, 'UIPanelButtonTemplate')
    b:SetPoint("TOPLEFT", 95, -50)
    b:SetHeight(25);
    b:SetWidth(210);
    b:SetAlpha(0);
    b:SetScript("OnClick", function()
        check:ToggleChecked()
        showHistoryFrame(check:GetValue(), false)
    end)
    GUI.historyButton = b

    local hf = CreateFrame("Frame", "pdkpHistoryFrame", pdkpCoreFrame, nil)
    hf:SetPoint("TOPRIGHT", 235,-75)
    hf:SetHeight(575);
    hf:SetWidth(450);
    hf:SetBackdrop( {
        bgFile = "Interface\\AddOns\\PantheonDKP\\Media\\PDKPFrame-Middle",
        edgeFile = nil, tile = false, tileEdge = true, tileSize = 0, edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
        backdropBorderColor = { r=0.7, g=1, b=0.7, a=1 },
        backdropColor = { r=0.7, g=1, b=0.7, a=1 },
    });
    hf:EnableMouse(true)
    hf:SetFrameStrata('FULLSCREEN');
    hf:RegisterForDrag("LeftButton")

    local scrollcontainer = AceGUI:Create("InlineGroup")
    scrollcontainer:SetFullWidth(false)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetHeight(475)
    scrollcontainer:SetWidth(350)
    scrollcontainer:SetLayout("Fill")

    local font="GameFontHighlightLarge"
    local title = hf:CreateFontString('pdkp_history_label', "ARTWORK", font);
    title:SetText('')
    title:SetPoint("TOP", 20, -20);
    hf.historyTitle = title;

    scrollcontainer:SetParent(hf)
    scrollcontainer.frame:SetFrameStrata('HIGH');
    scrollcontainer:SetPoint("CENTER", hf, "CENTER", 25, -15);

    hf:SetScript("OnShow", function()
        scrollcontainer.frame:Show()
        GUI.reasonDropdown.frame:Hide()
    end)
    hf:SetScript("OnHide", function()
        scrollcontainer.frame:Hide()
        GUI.reasonDropdown.frame:Show()
    end)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)

    hf.scroll = scroll

    hf:Hide()
    scrollcontainer.frame:Hide()
    GUI.HistoryFrame = hf

    GUI.HistoryFrame.historyTitle:SetText(GUI.HistoryTItle)
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
       for i=1, #GUI.adjustDropdowns do
           GUI.adjustDropdowns[i].frame:Hide();
           if i == 1 then GUI.adjustDropdowns[i]:SetValue(''); end
       end
    end
end

-- Creates the class filter checkboxes progmatically, saving XML space.
function GUI:setupClassCheckboxes()
    local templateName = "pdkp_class_checkboxTemplate"
    for i=1, #Defaults.classes do
        local cbName = "pdkp_" .. Defaults.classes[i] .. "_checkbox";

        local cb = CreateFrame("CheckButton", cbName, pdkpCoreFrame, templateName);
        getglobal(cbName .. "Text"):SetText(Defaults.classes[i]);
        cb:SetFrameLevel(i + 1);

        local relPointX = -150;
        local relPointY = -300;
        local relativeTo = pdkpCoreFrame
        local point = "TOPRIGHT"
        local relativePoint = "TOPRIGHT"

        if i > 1 then
            relativeTo = getglobal("pdkp_" .. Defaults.classes[i-1] .. "_checkbox");
            point = 'RIGHT';
            relativePoint = 'RIGHT'
            relPointX = 80;
            relPointY = 0;
            if i > 4 then
                relativeTo = getglobal("pdkp_" .. Defaults.classes[i-4] .. "_checkbox");
                relPointX = 0;
                relPointY = -35;
            end
        end
        cb:SetPoint(point, relativeTo, relativePoint, relPointX, relPointY);
    end
end

function GUI:dkpSliderValueChanged(val)
    GUI.sliderVal = val;
    pdkp_dkp_table_filter()
end

function GUI:SetupDKPFilterSlider()
    local name = "pdkp_filter_dkp_slider"
    local slider = CreateFrame("Slider", name, pdkpCoreFrame, "OptionsSliderTemplate")
    slider:SetWidth(300)
    slider:SetHeight(25)
    slider:SetOrientation('HORIZONTAL')
    slider.tooltipText = 'This is the Tooltip hint' --Creates a tooltip on mouseover.
    slider:SetPoint("BOTTOMLEFT", pdkpCoreFrame, "BOTTOMLEFT", 500, 15);

    slider.textLow = _G[name.."Low"]
    slider.textHigh = _G[name.."High"]
    slider.text = _G[name.."Text"]
    slider:SetMinMaxValues(0.0, DKP:GetHighestDKP())
    slider.minValue, slider.maxValue = slider:GetMinMaxValues()
    slider.textLow:SetText(slider.minValue)
    slider.textHigh:SetText(slider.maxValue)
    slider:SetValue(GUI.sliderVal)
    slider:SetValueStep(1);
    slider:SetStepsPerPage(5);
    slider.textBase = 'Hide DKP < '
    slider.text:SetText(slider.textBase .. slider:GetValue());
    slider:SetScript("OnValueChanged", function(self,event,arg1)
        if event == nil then return end;
        local val = event + 0.5 - (event + 0.5) % 1;
        self.text:SetText(self.textBase .. tostring(val));
        GUI:dkpSliderValueChanged(val);
    end)
end

function GUI:UpdateDKPSliderMax()
    local slider = getglobal('pdkp_filter_dkp_slider')
    local max = DKP:GetHighestDKP();
    slider:SetMinMaxValues(0.0, max)
    slider.textHigh:SetText(max);
end

---------------------------
--    View Functions     --
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
    charObj.bName = bName;  -- we'll need this later to remove the custom textures if selected filter is checked.
    if GUI.selected[charObj.name] then
        GUI:RemoveFromSelected(charObj);
    else GUI:AddToSelected(charObj);
    end
end

-- Handles regular click of an entry
function GUI:EntryClicked(charObj, clickType, bName)
    if GUI:IsNotSelected(charObj.name) == false then
        _G[bName].customTexture:Hide();
       GUI:ClearSelected();
        return;
    end

    GUI:ClearSelected() -- clear all previous selections
    GUI.lastEntryClicked = bName;
    GUI.lastEntryNameClicked = charObj['name']
    charObj.bName = bName;  -- we'll need this later to remove the custom textures if selected filter is checked.
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

    local dataIndex={}
    for k,v in pairs(displayData) do dataIndex[v['name']]=k end

    local charStop = dataIndex[charObjStop['name']]
    local charStart = dataIndex[GUI.lastEntryNameClicked]

    if charStart < charStop then startIndex = charStart else startIndex = charStop end
    if charStop > charStart then endIndex = charStop else endIndex = charStart end

    for i=startIndex, endIndex do
        local charObj = displayData[i]
        GUI:AddToSelected(charObj);
    end

    GUI.lastEntryClicked = bName;
    GUI.lastEntryNameClicked = charObj['name'];
end

---------------------------
--  Selected Functions   --
---------------------------

-- Returns the selected entries count.
function GUI:GetSelectedCount()
    return table.getn(GUI.selected);
end

-- changes the view to the selected entries only.
function GUI:pdkp_toggle_selected()
    if table.getn(GUI.selected) == 0 then print('Nothing to display!') end;
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

    GUI:ShowSelectedHistory(charObj)
end

-- Removes the entry from the selected array.
function GUI:RemoveFromSelected(charObj)
    _G[charObj.bName].customTexture:Hide();
    GUI.selected[charObj.name] = nil;

    table.remove(GUI.selected, Util:FindTableIndex(GUI.selected, charObj.name));

    GUI:SelectedEntriesUpdated()
end

function GUI:ShowSelectedHistory(charObj)

    local b = _G[charObj['bName']]
    local dkpHistory = DKP.dkpDB.history[charObj['name']]

    local charName = Util:FormatFontTextColor(Util:GetClassColor(b.char.class), b.char.name)
    local title = Util:FormatFontTextColor('FFBA49', 'Recent History for ') .. charName

    GUI.HistoryFrame.historyTitle:SetText(title) -- Set the title.
    GUI.HistoryFrame.scroll:ReleaseChildren() -- Clear the previous entries.

    if dkpHistory == nil or #dkpHistory == 0 then -- there is no dkp history to show, hide the frame and end function.
        return
    end


    local font = "GameFontNormalLarge"

    for i = #dkpHistory, 1, -1 do
        local raid = dkpHistory[i]['raid'];
        if raid == 'Onyxia\'s Lair' then raid = 'Molten Core'; end -- Set the default since MC & Ony are combined.

        local dkpChangeText = dkpHistory[i]['dkpChangeText']
        local lineText = dkpHistory[i]['text']

        if raid and raid == DKP.dkpDB.currentDB then -- Only show history relevent to this raid.
            local scroll = GUI.HistoryFrame.scroll

            local dkpChangeLabel = AceGUI:Create("Label")
            local dkpTextLabel = AceGUI:Create("Label")

            dkpTextLabel:SetText(lineText)
            dkpChangeLabel:SetText(dkpChangeText)

            dkpTextLabel:SetFullWidth(false)
            dkpChangeLabel:SetFullWidth(false)

            local ig = AceGUI:Create("InlineGroup")

            local formattedDate = Util:Format12HrDateTime(dkpHistory[i]['datetime'])
            local title = formattedDate

            if dkpHistory[i]['raid'] then
                title = dkpHistory[i]['raid'] .. ' | ' .. formattedDate
            end

            ig:SetTitle(title)
            ig:SetLayout("Flow")

            local sg1 = AceGUI:Create("SimpleGroup")
            local sg2 = AceGUI:Create("SimpleGroup")

            ig:SetFullWidth(true)

            sg1:SetFullWidth(false)
            sg2:SetFullWidth(false)

            sg1:AddChild(dkpTextLabel)
            sg2:AddChild(dkpChangeLabel)

            sg1:SetWidth(238)
            sg2:SetWidth(50)

            ig:AddChild(sg1)
            ig:AddChild(sg2)

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

function GUI:HideElements()
    for i=1, #Defaults.classes do
        local cbName = "pdkp_" .. Defaults.classes[i] .. "_checkbox";
    end
end

function GUI:ToggleSubmitButton()
    if pdkp_dkp_amount_box == nil then return end;
    -- Someone is selected
    -- Amount is in the box
    -- Reason is selected (sub-sections are selected)
    local hasSelected = GUI.GetSelectedCount() >= 1;

    local isEmpty = Util:IsEmpty(pdkp_dkp_amount_box:GetText());
    local submitButton = pdkp_submit_button
    local isEnabled = pdkp_dropdown_enables_submit and hasSelected and not isEmpty and core.canEdit;

    submitButton:SetEnabled(isEnabled);
end

---------------------------
--   MISC GUI Functions  --
---------------------------

-- Type can be 'shroud' or 'roll'
function GUI:QuickCalculate(type)
    local charObj = GUI.selected[GUI.selected[1]]; -- Ugly way of doing this...
    local percent = 0.1;
    local amount;
    if type == 'shroud' then percent = 0.5 end;

    amount = math.ceil(charObj.dkpTotal * percent);
    pdkp_dkp_amount_box:SetText('-' .. amount);
end

-- Update personal DKP text at the top
function GUI:UpdateEasyStats()
    local charName = PDKP:GetCharName();
    local char_dkp = DKP:GetPlayerDKP(charName);

    local charInfoText = charName .. " | " .. char_dkp .. " DKP"

    if(core.defaults) then charInfoText = "Pamplemousse" .. " | " .. '9999' .. " DKP" end

    getglobal("pdkp_charInfo"):SetText(charInfoText);

    local textLen = string.len(charInfoText);
    local borderWidths = { [21]=250,  [22]=260,  [23]=270 } -- changes based on characters being displayed.
    local borderX = borderWidths[textLen] or 240;

    _G['pdkp_easy_stats_border']:SetSize(borderX, 72);
end

---------------------------
--   Hide GUI Functions  --
---------------------------

function GUI:HideAdjustmentGUI(hide)
    local shroudButton = getglobal('pdkp_dkp_quick_shroud');
    local submitButton = pdkp_submit_button
    local amountBox = pdkp_dkp_amount_box
    local itemLink = getglobal('pdkp_item_link');

    local elements = {shroudButton, submitButton, amountBox, itemLink};

    for k, element in pairs(elements) do
       if hide then element:Hide(); else element:Show(); end
    end
end

---------------------------
-- LINKED ITEM Functions --
---------------------------

function GUI:UpdateShroudItemLink(itemLink)
    Item:UpdateLinked(itemLink);
    local buttonText = getglobal('pdkp_item_link_text')
    buttonText:SetText(itemLink);
    local button = GUI:GetItemButton();
    button:Show();

    print(itemLink);


    -- THIS SHOULD ALSO CHANGE DROPDOWN TO ITEM-WIN IF NECESSARY.
end

function GUI:GetItemButton()
    return getglobal('pdkp_item_link');
end

---------------------------
-- GUI Settings Functions--
---------------------------

function GUI:GetGUISettings()
    local name = "pdkp_filter_dkp_slider"
end

function GUI:SetGUISettings()

end

---------------------------
--    TIMER Functions    --
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

local dkp_reason_menu = {
    { text = "Select an Option", isTitle = true},
    { text = "Option 1", func = function() print("You've chosen option 1"); end },
    { text = "Option 2", func = function() print("You've chosen option 2"); end },
    { text = "More Options", hasArrow = true,
        menuList = {
            { text = "Option 3", func = function() print("You've chosen option 3"); end }
        }
    }
}

function GUI:ReasonDropdown()
    local dkp_reason_menu_frame = CreateFrame("Frame", "pdkp_reason_menu_dropdown", UIParent, "UIDropDownMenuTemplate")

    -- Make the menu appear at the cursor:
    EasyMenu(dkp_reason_menu, dkp_reason_menu_frame, "cursor", 0 , 0, "MENU");
    -- Or make the menu appear at the frame:
    menuFrame:SetPoint("Center", UIParent, "Center")
    EasyMenu(dkp_reason_menu, dkp_reason_menu_frame, dkp_reason_menu_frame, 0 , 0, "MENU");
end

---------------------------
--    GLOBAL POP UPS     --
---------------------------

StaticPopupDialogs["PDKP_CHANGE_VIEW_POPUP"] = {
    text = "Change Table View",
    button1 = "Raid",
    button2 = "Guild",
    OnAccept = function()
        pdkp_template_function_call('pdkp_change_table_view', 'Raid')
    end,
    OnCancel = function()
        pdkp_template_function_call('pdkp_change_table_view', 'Guild')
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

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
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
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
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}