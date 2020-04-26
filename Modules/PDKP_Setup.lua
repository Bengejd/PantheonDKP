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
local Shroud = core.Shroud;
local Raid = core.Raid;

local AceGUI = LibStub("AceGUI-3.0")
local PlaySound = PlaySound

-- Parent function to create all of the UI elements we need.
function Setup:MainUI()
    if GUI.pdkp_frame then -- We have initialized the frame already.
        -- Grab the global pdkpCoreFrame object that was previously created
        GUI.pdkp_frame = _G['pdkpCoreFrame']
    else -- We haven't initialized the frame yet.
        -- Create frame args: frameType, frameName, parentFrame, inheritsFrame

        Setup:OfficerWindow()


        -----------------------------
        --        Main Frame       --
        -----------------------------

        GUI.pdkp_frame = CreateFrame("Frame", "pdkpCoreFrame", UIParent, "pdkp_core_frame");
        GUI.pdkp_frame:SetPoint("TOP", 0, 0)
        GUI.pdkp_frame:SetScale(1) -- Just incase. This might fix the scaling issue that Sparkle has?

        GUI.pdkp_dkp_amount_box = _G['pdkp_dkp_amount_box'];
        GUI.pdkp_submit_button = _G['pdkp_dkp_submit'];
        GUI.pdkp_version = _G['pdkp_version_label'];
        GUI.pdkp_version:SetText('V' .. core.defaults.addon_version)

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
        Setup:ShroudingWindow()
        Setup:PrioList()

        Setup:PushTimer()

        GUI:CheckOutOfDate()

        Setup:ShroudingWindow()
    end
end

-----------------------------
--     CREATE FUNCTIONS    --
-----------------------------
function Setup:PushTimer()
    if GUI.pushbar == nil then
        GUI.pushbar = CreateFrame("StatusBar", 'pdkp_pushbar', UIParent)
        local statusbar = GUI.pushbar;

        statusbar:RegisterForDrag("LeftButton")
        statusbar:SetFrameStrata("HIGH")
        statusbar:EnableMouse(true);
        statusbar:SetMovable(true)

        statusbar:SetScript("OnDragStart", statusbar.StartMoving)
        statusbar:SetScript("OnDragStop", statusbar.StopMovingOrSizing)

        statusbar:SetPoint("TOP", UIParent, "TOP", 0, -10)
        statusbar:SetWidth(200)
        statusbar:SetHeight(20)
        statusbar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
        statusbar:GetStatusBarTexture():SetHorizTile(true)
        statusbar:GetStatusBarTexture():SetVertTile(false)
        statusbar:SetStatusBarColor(0, 0.65, 0)

        statusbar.bg = statusbar:CreateTexture(nil, "BACKGROUND")
        statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-TargetingFrame-BarFill")
        statusbar.bg:SetAllPoints(true)
        statusbar.bg:SetVertexColor(0, 0.35, 0)

        statusbar.value = statusbar:CreateFontString(nil, "OVERLAY")
        statusbar.value:SetPoint("CENTER", statusbar, "CENTER", 0, 0)
        statusbar.value:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        statusbar.value:SetJustifyH("LEFT")
        statusbar.value:SetShadowOffset(1, -1)
        statusbar.value:SetTextColor(0, 1, 0)
    end;
    local statusbar = GUI.pushbar;
    statusbar.value:SetText("0%")

    statusbar.isLocked = false;

    local timerCount = 0
    statusbar:SetMinMaxValues(0, 100)

    statusbar:Hide()
end

function Setup:ShroudingWindow()
    local sf = getglobal('pdkp_shrouding_window');
    sf:SetPoint('BOTTOMLEFT', 0, 0);

    sf:SetWidth(200);
    sf:SetHeight(200);

    local scrollcontainer = AceGUI:Create("SimpleGroup")
    scrollcontainer:SetFullWidth(false)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetHeight(130)
    scrollcontainer:SetWidth(150)
    scrollcontainer:SetLayout("Fill")

    scrollcontainer:SetParent(sf)
    scrollcontainer.frame:SetFrameStrata('HIGH');
    scrollcontainer:SetPoint("CENTER", sf, "CENTER", 0, -10);

    sf:SetScript("OnShow", function()
        Shroud.window.open = true
        scrollcontainer.frame:Show() end)
    sf:SetScript("OnHide", function()
        scrollcontainer.frame:Hide()
        Shroud:ClearShrouders()
        Shroud.window.open = false
    end)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)

    sf.scroll = scroll

    sf:Hide()
    scrollcontainer.frame:Hide()
    Shroud.window = sf;
    Shroud.window.scroll = scroll;
end

function Setup:PrioList()
    local lf = getglobal('pdkp_prio_window');
    lf:SetPoint('BOTTOMLEFT', 0, 200);

    lf:SetWidth(200);
    lf:SetHeight(200);

    local scrollcontainer = AceGUI:Create("SimpleGroup")
    scrollcontainer:SetFullWidth(false)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetHeight(130)
    scrollcontainer:SetWidth(150)
    scrollcontainer:SetLayout("Fill")

    scrollcontainer:SetParent(lf)
    scrollcontainer.frame:SetFrameStrata('HIGH');
    scrollcontainer:SetPoint("CENTER", lf, "CENTER", 0, -10);

    lf:SetScript("OnShow", function()
        scrollcontainer.frame:Show() end)
    lf:SetScript("OnHide", function()
        scrollcontainer.frame:Hide()
    end)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)

    scrollcontainer.frame:Hide()
    lf:Hide()

    lf.scroll = scroll
    GUI.prio = lf;
    GUI.prio.scroll = scroll;
    GUI.prio.scrollcontainer = scrollcontainer

--    GUI:UpdateLootList(nil)
end

function Setup:dkpPushButton()
    local b = CreateFrame("Button", "pdkpPushButton", pdkpCoreFrame, 'UIPanelButtonTemplate')
    b:SetPoint("TOPLEFT", 20, -5)
    b:SetHeight(55);
    b:SetWidth(55);
    b:SetAlpha(0);
    b:SetScript("OnClick", function()
        Util:Debug("Push button clicked")
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
    pf:EnableMouse(false)
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
    scrollcontainer.frame:EnableMouse(false)

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
    scroll.frame:EnableMouse(true)
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

    local otherBox = _G['pdkp_other_entry_box']

    otherBox:SetHyperlinksEnabled(true)

    local function DropdownValueChanged(this, event, index)
        local currentRaid = DKP.dkpDB.currentDB
        local dropdownName = this.name
        local bossKillBonus = 10;
        local updateAmountBox = false;
        local adjustAmount;

        local function secondLogic()
            thirdDropdown.frame:Hide() -- Hide it by default
            local d1 = dropdowns[1];
            local d2 = secondaryDropdown


            if d1.value >= 1 and d1.value <= 5 then
                local raid = core.raids[d2.value];
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
        end
        local function firstLogic()
            for i=2, #dropdowns do
                if i ~= 4 then
                    local d = dropdowns[i];
                    d:SetValue('')
                    d.frame:Hide()
                    d:SetLabel('');
                    GUI.pdkp_dkp_amount_box:SetText('');
                    GUI.pdkp_submit_button:SetEnabled(false);
                end
            end

            if index <= 5 then -- On time, Signup, Boss kill, Unexcused Absence.
                secondaryDropdown.frame:Show()
                secondaryDropdown:SetLabel('Raid');
                otherBox:Hide();
            elseif index == 6 then
                local itemButtonText = _G['pdkp_item_link_text'];
                if Util:IsEmpty(itemButtonText:GetText()) then
                    otherBox:Show();
                    GUI.pdkp_submit_button:SetEnabled(false);
                else
                    GUI.pdkp_dropdown_enables_submit = true;
                end
            elseif index == 7 then -- other
                otherBox:Show();
                GUI.pdkp_dropdown_enables_submit = false;
                otherBox:SetScript("OnTextChanged", function(self)
                    local isEmpty = Util:IsEmpty(otherBox:GetText());
                    if isEmpty then
                        GUI.pdkp_dropdown_enables_submit = false;
                    else
                        GUI.pdkp_dropdown_enables_submit = true;
                    end
                    GUI:ToggleSubmitButton()
                end)
            end

            if index <= 5 then
                for i=1, #core.raids do
                    local raid = core.raids[i]
                    if raid == currentRaid then
                        secondaryDropdown:SetValue(i)
                        secondaryDropdown:SetText(currentRaid)
                        secondLogic()
                    end
                end
            end
        end

        if this.name == 'first' then firstLogic()
        elseif this.name == 'second' then secondLogic()
        elseif this.name == 'third' then GUI.pdkp_dropdown_enables_submit = true;
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
    hf:SetHeight(570);
    hf:SetWidth(450);
    hf:SetBackdrop({
        bgFile = "Interface\\AddOns\\PantheonDKP\\Media\\Main_UI\\PDKPFrame-Middle",
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

function Setup:dkpExport()
    local frame = AceGUI:Create('Frame')
    local eb = AceGUI:Create("EditBox")

    frame:SetHeight(500)
    frame:SetWidth(500)
    frame:SetLayout("Fill")

    frame:AddChild(eb)

    eb.frame:SetHeight(400)
    eb.frame:SetWidth(400)

    local text = '';

    local members = Guild.members
    local memberNames = {}
    for key, member in pairs(members) do
        table.insert(memberNames, key)
    end

    local function compare(a,b)
        return a < b;
    end

    table.sort(memberNames, compare)

    for i=1, #memberNames do
        local member = members[memberNames[i]];
        local dkp = member:GetDKP('Blackwing Lair', 'total')
        if dkp > 0 then
            text = text .. member.name .. ':' .. dkp .. ', '
        end
    end

    eb:SetText(text)

    eb.frame:Show()
    frame:Show()
end

function Setup:dkpOfficer()
    local dropdownList = _G['DropDownList1']
    dropdownList:SetScript('OnShow', function()
        local charName = _G['DropDownList1Button1']:GetText()
        for i=1, 13 do -- There are 13 "buttons" on the dropdown list menu in the raid frames.
            local b = _G['DropDownList1Button'..i]
            if b and b:GetText() == 'Promote to Main Assist' then
                b:SetText('Promote to DKP Officer')
                b:SetScript('OnClick', function()
                    PDKP:Print(charName .. ' is now the DKP Officer')
                    Raid.dkpOfficer = charName;
                    Comms:SendCommsMessage('pdkpDkpOfficer', Raid.dkpOfficer, 'RAID', nil, 'BULK', nil)
                end)
            end
        end
    end)
end

function Setup:OfficerWindow()
    if core.canEdit == false or not Raid:IsInRaid() then
        return Util:Debug('Cant edit, not creating officer window')
    end

    local mainFrame = CreateFrame("Frame", "pdkpOfficerFrame", RaidFrame, "BasicFrameTemplateWithInset")
    mainFrame:SetSize(300, 425) -- Width, Height
    mainFrame:SetPoint("RIGHT", RaidFrame, "RIGHT", 300, 0) -- Point, relativeFrame, relativePoint, xOffset, yOffset
    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY")
    mainFrame.title:SetFontObject("GameFontHighlight")
    mainFrame.title:SetPoint("CENTER", mainFrame.TitleBg, "CENTER", 11, 0)
    mainFrame.title:SetText('PDKP Officer Interface')
    mainFrame:SetFrameStrata('MEDIUM')

    GUI.OfficerFrame = mainFrame

    mainFrame:Show()

    local mainFrameKids = {}

    local raidGroup = AceGUI:Create("InlineGroup")
    raidGroup:SetTitle('Raid Control')

    raidGroup:SetFullWidth(false)
    raidGroup:SetFullHeight(true)
    raidGroup:SetHeight(50)
    raidGroup:SetWidth(250)
    raidGroup:SetLayout("Flow")

    raidGroup:SetParent(mainFrame)
    raidGroup.frame:SetFrameStrata('HIGH');
    raidGroup:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -25);

    local promoteOfficer = AceGUI:Create("Button")
    promoteOfficer:SetText("Promote Officers")
    promoteOfficer:SetWidth(140)
    promoteOfficer:SetCallback('OnClick', function()
        if Raid:isRaidLeader() then
            local raidRoster = Raid:GetRaidInfo()
            for key, rMember in pairs(raidRoster) do
                for _, officer in pairs(Guild.officers) do
                    if officer.name == rMember.name then PromoteToAssistant('raid'..key) end
                end
            end
        end
    end)

    local inviteBox = AceGUI:Create("EditBox")
    inviteBox:SetLabel('Auto Invite Commands')
    inviteBox:SetText("inv, invite")
    inviteBox:SetCallback('OnEnterPressed', function()
        local text = inviteBox:GetText()
        local textTable = { strsplit(',', text) }
        core.inviteTextCommands = {}; -- Reset the inv list.
        for key, text in pairs(textTable) do
            core.inviteTextCommands[strtrim(string.lower(text))] = true
        end
    end)
    local whisperCommand = AceGUI:Create("Button")

    local inviteSpamCount = 0;

    local function guildInviteSpam()
        if Raid.SpamTimer then
            print('Canceling Invite Spam')
            PDKP:CancelTimer(Raid.SpamTimer)
            inviteSpamCount = 0;
            Raid.SpamTimer = nil
            whisperCommand:SetText("Start Raid Inv Spam")
            return;
        else
            if Raid.spamText == nil then return end
            whisperCommand:SetText('Stop Raid Inv Spam')

            local function TimerFeedback()
                inviteSpamCount = inviteSpamCount + 1
                SendChatMessage(Raid.spamText.. ' '.. inviteSpamCount ,"GUILD" ,nil, nil);
                if inviteSpamCount >= 10 then
                    guildInviteSpam()
                end
            end
            Raid.SpamTimer = PDKP:ScheduleRepeatingTimer(TimerFeedback, 90); -- Posts it every 90 seconds for 15 minutes.
            SendChatMessage(Raid.spamText.. ' '.. inviteSpamCount ,"GUILD" ,nil, nil);
        end
    end

    whisperCommand:SetText("Start Raid Inv Spam (15 mins)")
    whisperCommand:SetWidth(160)
    whisperCommand:SetDisabled(true)
    whisperCommand:SetCallback('OnClick', function()
        guildInviteSpam()
    end)

    local raidSpamTime = AceGUI:Create("MultiLineEditBox")
    raidSpamTime:SetLabel('Guild Invite Spam text')
    raidSpamTime:SetHeight(100)
    raidSpamTime:SetText("[TIME] [RAID] invites starting. Pst for invite")
    raidSpamTime:SetCallback('OnEnterPressed', function()
        Raid.spamText = raidSpamTime:GetText()
        whisperCommand:SetDisabled(false)
    end)

    if Raid:isRaidLeader() then
        raidGroup:AddChild(promoteOfficer)
    end

    raidGroup:AddChild(inviteBox)
    raidGroup:AddChild(raidSpamTime)
    raidGroup:AddChild(whisperCommand)

    table.insert(mainFrameKids, raidGroup)



    local function toggleKids(show)
        for _, child in pairs(mainFrameKids) do
            if show then child.frame:Show() else child.frame:Hide() end
        end
    end

    mainFrame:SetScript('OnHide', function() toggleKids(false) end)
    mainFrame:SetScript('OnShow', function() toggleKids(true) end)
end