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
local Comms = core.Comms;

local AceGUI = LibStub("AceGUI-3.0")
local PlaySound = PlaySound

-- Parent function to create all of the UI elements we need.
function Setup:MainUI()
    if GUI.pdkp_frame then -- We have initialized the frame already.
        -- Grab the global pdkpCoreFrame object that was previously created
        GUI.pdkp_frame = _G['pdkpCoreFrame']
    else -- We haven't initialized the frame yet.
        -- Create frame args: frameType, frameName, parentFrame, inheritsFrame

        -----------------------------
        --        Main Frame       --
        -----------------------------

        GUI.pdkp_frame = CreateFrame("Frame", "pdkpCoreFrame", UIParent, "pdkp_core_frame");
        GUI.pdkp_frame:SetPoint("TOP", 0, 0)

        GUI.pdkp_dkp_amount_box = _G['pdkp_dkp_amount_box'];
        GUI.pdkp_submit_button = _G['pdkp_dkp_submit'];

        -----------------------------
        --     Class Checkboxes    --
        -----------------------------

        Setup:ClassFilterCheckboxes()
        Setup:DkpSlideFilter()

        -- GUI:CreateTestMenuDropdown()
        Setup:AdjustmentDropdowns()

        GUI:SelectedEntriesUpdated()

        Setup:RaidDkpDropdown()
        Setup:HistoryFrame()
        Setup:dkpPushButton()

        GUI:CheckOutOfDate()
    end
end

-----------------------------
--     CREATE FUNCTIONS    --
-----------------------------

function Setup:dkpPushButton()
    local b = CreateFrame("Button", "pdkpPushButton", pdkpCoreFrame, 'UIPanelButtonTemplate')
    b:SetPoint("TOPLEFT", 20, -5)
    b:SetHeight(55);
    b:SetWidth(55);
    b:SetAlpha(0);
    b:SetScript("OnClick", function()
        PlaySound(856)
        Comms:RequestOfficersLastEdit()
    end)
    GUI.pushButton = b

    local pf = CreateFrame("Frame", "pdkpPushFrame", UIParent, nil)
    pf:SetPoint("TOPLEFT", 0, -100)
    pf:SetHeight(300);
    pf:SetWidth(300);
    pf:SetBackdrop({
        edgeFile = nil,
        tile = false,
        tileEdge = true,
        tileSize = 0,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
        backdropBorderColor = { r = 0.7, g = 1, b = 0.7, a = 1 },
        backdropColor = { r = 0.7, g = 1, b = 0.7, a = 1 },
    });
    pf:EnableMouse(true)
    pf:SetFrameStrata('FULLSCREEN');
    pf:RegisterForDrag("LeftButton")
    pf:SetMovable(true)
    pf:SetScript("OnDragStart", pf.StartMoving)
    pf:SetScript("OnDragStop", pf.StopMovingOrSizing)

    local cb = CreateFrame("Button", 'pdkpPushCloseButton', pf, 'UIPanelCloseButton')
    cb:SetPoint("TOPRIGHT", pf, "TOPRIGHT", 45, 10)
    cb:SetHeight(35);
    cb:SetWidth(35);
    cb:SetScript("OnClick", function()
        pf:Hide()
    end)

    local scrollcontainer = AceGUI:Create("InlineGroup")
    scrollcontainer:SetFullWidth(false)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetHeight(300)
    scrollcontainer:SetWidth(300)
    scrollcontainer:SetLayout("Fill")

    local font = "AchievementPointsFont"
    local title = pf:CreateFontString('pdkp_push_title', "ARTWORK", font);
    title:SetText('DKP Push Request Portal')
    title:SetPoint("TOP", 25, -30);
    pf.pushTitle = title;

    scrollcontainer:SetParent(pf)
    scrollcontainer.frame:SetFrameStrata('HIGH');
    scrollcontainer:SetPoint("CENTER", pf, "CENTER", 25, -15);

    pf:SetScript("OnShow", function()
        scrollcontainer.frame:Show()
        cb:Show()
    end)
    pf:SetScript("OnHide", function()
        scrollcontainer.frame:Hide()
        cb:Hide()
    end)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)

    pf.scroll = scroll

    pf:Hide()
    scrollcontainer.frame:Hide()
    GUI.pushFrame = pf;
end

function Setup:AdjustmentDropdowns()

    local reasonDropdown = AceGUI:Create("Dropdown")
    local secondaryDropdown = AceGUI:Create("Dropdown")
    local thirdDropdown = AceGUI:Create("Dropdown")
    local t = AceGUI:Create("Dropdown-Item-Menu")

    local dropdowns = { reasonDropdown, secondaryDropdown, thirdDropdown }
    local dropdownWidths = { 150, 120, 100 };
    local dropdownX = { -25, 100, 200 };
    local dropdownNames = { 'first', 'second', 'third' }

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

        this.value = index
        local adjustAmount;
        local bossKillBonus = 10;
        local updateAmountBox = false;
        -- First Dropdown Logic

        if this.name == 'first' then
            for i = 2, #dropdowns do
                if i ~= 4 then
                    local d = dropdowns[i];
                    d:SetValue('')
                    d.frame:Hide()
                    d:SetLabel('');
                    GUI.pdkp_dkp_amount_box:SetText('');
                    GUI.pdkp_submit_button:SetEnabled(false);
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
                if Util:IsEmpty(buttonText:GetText()) then GUI.pdkp_submit_button:SetEnabled(false);
                else GUI.pdkp_dropdown_enables_submit = true;
                end
            end

            if index == 7 then
                otherBox:Show();
                GUI.pdkp_dropdown_enables_submit = false;

                otherBox:SetScript("OnTextChanged", function(self)
                    local isEmpty = Util:IsEmpty(self:GetText());
                    if isEmpty then
                        GUI.pdkp_dropdown_enables_submit = false;
                    else
                        GUI.pdkp_dropdown_enables_submit = true;
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

                if d1.value >= 1 and d1.value <= 3 then -- Ontime / Signup bonus
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
                GUI.pdkp_dropdown_enables_submit = true;
            end

            -- Third Dropdown Logic

        elseif this.name == 'third' then
            GUI.pdkp_dropdown_enables_submit = true;
        end

        if updateAmountBox then

            GUI.pdkp_dkp_amount_box:SetText(adjustAmount);
        end

        GUI:ToggleSubmitButton()
    end

    for i = 1, #dropdowns do
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

function Setup:RaidDkpDropdown()
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

function Setup:HistoryFrame()
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
    check:SetHeight(20)
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
    hf:SetPoint("TOPRIGHT", 235, -75)
    hf:SetHeight(575);
    hf:SetWidth(450);
    hf:SetBackdrop({
        bgFile = "Interface\\AddOns\\PantheonDKP\\Media\\PDKPFrame-Middle",
        edgeFile = nil,
        tile = false,
        tileEdge = true,
        tileSize = 0,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
        backdropBorderColor = { r = 0.7, g = 1, b = 0.7, a = 1 },
        backdropColor = { r = 0.7, g = 1, b = 0.7, a = 1 },
    });
    hf:EnableMouse(true)
    hf:SetFrameStrata('FULLSCREEN_DIALOG');
    hf:RegisterForDrag("LeftButton")

    local scrollcontainer = AceGUI:Create("InlineGroup")
    scrollcontainer:SetFullWidth(false)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetHeight(475)
    scrollcontainer:SetWidth(350)
    scrollcontainer:SetLayout("Fill")

    local font = "GameFontHighlightLarge"
    local title = hf:CreateFontString('pdkp_history_label', "ARTWORK", font);
    title:SetText('')
    title:SetPoint("TOP", 20, -20);
    hf.historyTitle = title;

    scrollcontainer:SetParent(hf)
    scrollcontainer.frame:SetFrameStrata('HIGH');
    scrollcontainer:SetPoint("CENTER", hf, "CENTER", 25, -15);

    hf:SetScript("OnShow", function()
        scrollcontainer.frame:Show()
        GUI.HistoryShown = true
        GUI:HideAdjustmentReasons()
        GUI:ShowSelectedHistory(nil)
    end)
    hf:SetScript("OnHide", function()
        scrollcontainer.frame:Hide()
        GUI.reasonDropdown.frame:Show()
        GUI.HistoryShown = false
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

function Setup:DkpSlideFilter()
    local name = "pdkp_filter_dkp_slider"
    local slider = CreateFrame("Slider", name, pdkpCoreFrame, "OptionsSliderTemplate")
    slider:SetWidth(300)
    slider:SetHeight(25)
    slider:SetOrientation('HORIZONTAL')
    slider.tooltipText = 'This is the Tooltip hint' --Creates a tooltip on mouseover.
    slider:SetPoint("BOTTOMLEFT", pdkpCoreFrame, "BOTTOMLEFT", 500, 110);

    slider.textLow = _G[name .. "Low"]
    slider.textHigh = _G[name .. "High"]
    slider.text = _G[name .. "Text"]
    slider:SetMinMaxValues(0.0, DKP:GetHighestDKP())
    slider.minValue, slider.maxValue = slider:GetMinMaxValues()
    slider.textLow:SetText(slider.minValue)
    slider.textHigh:SetText(slider.maxValue)
    slider:SetValue(GUI.sliderVal)
    slider:SetValueStep(1);
    slider:SetStepsPerPage(5);
    slider.textBase = 'Hide DKP < '
    slider.text:SetText(slider.textBase .. slider:GetValue());
    slider:SetScript("OnValueChanged", function(self, event, arg1)
        if event == nil then return end;
        local val = event + 0.5 - (event + 0.5) % 1;
        self.text:SetText(self.textBase .. tostring(val));
        GUI:dkpSliderValueChanged(val);
    end)
end

-- Creates the class filter checkboxes progmatically, saving XML space.
function Setup:ClassFilterCheckboxes()

    local relPointX = -150;
    local relPointY = -200;
    local relativeTo = pdkpCoreFrame
    local point = "TOPRIGHT"
    local relativePoint = "TOPRIGHT"
    local templateName = "pdkp_class_checkboxTemplate"
    for i = 1, #Defaults.classes do
        local cbName = "pdkp_" .. Defaults.classes[i] .. "_checkbox";

        local cb = CreateFrame("CheckButton", cbName, pdkpCoreFrame, templateName);
        getglobal(cbName .. "Text"):SetText(Defaults.classes[i]);
        cb:SetFrameLevel(i + 1);

        if i > 1 then
            relativeTo = getglobal("pdkp_" .. Defaults.classes[i - 1] .. "_checkbox");
            point = 'RIGHT';
            relativePoint = 'RIGHT'
            relPointX = 80;
            relPointY = 0;
            if i > 4 then
                relativeTo = getglobal("pdkp_" .. Defaults.classes[i - 4] .. "_checkbox");
                relPointX = 0;
                relPointY = -35;
            end
        end
        cb:SetPoint(point, relativeTo, relativePoint, relPointX, relPointY);
    end
end

-- Dropdown test between ACE GUI and Custom Solutions. Results inconclusive.
function Setup:CreateTestMenuDropdown()
    -- Create the dropdown, and configure its appearance
    local dropDown = CreateFrame("FRAME", "WPDemoDropDown", pdkpCoreFrame, "UIDropDownMenuTemplate")
    dropDown:SetPoint("BOTTOM", 230, -160)
    UIDropDownMenu_SetWidth(dropDown, 150)
    UIDropDownMenu_SetText(dropDown, 'Reason for change')
    UIDROPDOWNMENU_SHOW_TIME = 2;

    local bossKillMenu = {
        text="Boss Kill",
        sub=true,
        isTitle=true,
        menuList={},
        keepShownOnClick=true
    }

    for raidName, bosses in pairs(core.raidBosses) do
        local subMenu = {};
        subMenu.text, subMenu.sub, subMenu.isTitle, subMenu.menuList, subMenu.notCheckable = raidName, true, true, {}, true
        for i=1, #bosses do
            local b = bosses[i]
            local subItem = {};
            subItem.text, subItem.sub, subItem.isTitle, subItem.menuList = b, false, false, nil
            table.insert(subMenu.menuList, subItem)
        end
        table.insert(bossKillMenu.menuList, subMenu)
    end

    local menus = {
        bossKillMenu,
        {text="On Time Bonus", sub=false},
        {text="Completion Bonus", sub=false},
        {text="Benched", sub=false},
        {text="Unexcused Absence", sub=false},
        {text="Item Win", sub=false},
        {text="Other", sub=false},
    }

    -- Implement the function to change the favoriteNumber
    function dropDown:SetValue(newValue)
        -- validation
        local badValues = {'Boss Kill', 'Onyxia\'s Lair', 'Molten Core', 'Blackwing Lair' }
        for i=1, #badValues do
            if newValue == badValues[i] then return end
        end

        -- Update the text; if we merely wanted it to display newValue, we would not need to do this
        UIDropDownMenu_SetText(dropDown, newValue)
        -- Because this is called from a sub-menu, only that menu level is closed by default.
        -- Close the entire menu with this next call
        CloseDropDownMenus()

    end

    -- Create and bind the initialization function to the dropdown menu
    UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
        local function setupMenu(list)
            for i=1, #list do
                local info = UIDropDownMenu_CreateInfo()
                local m = list[i]
                info.text, info.hasArrow, info.value, info.menuList, info.func = m.text, m.sub, m.text, m.menuList, function(self) dropDown:SetValue(self.value) end
                info.notCheckable = m.menuList ~= nil
                UIDropDownMenu_AddButton(info, level)
            end
        end

        if (level or 1) == 1 then
            setupMenu(menus)
        elseif level == 2 and menuList ~= nil then
            setupMenu(menuList)
        elseif level == 3 and menuList ~= nil then
            setupMenu(menuList)
        end
    end)

    GUI.reasonDropdown = dropDown
end