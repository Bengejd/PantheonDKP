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

local officerOldScript = {};

-- Parent function to create all of the UI elements we need.
function Setup:MainUI()
    if GUI.pdkp_frame then -- We have initialized the frame already.
        -- Grab the global pdkpCoreFrame object that was previously created
        GUI.pdkp_frame = _G['pdkpCoreFrame']
    else -- We haven't initialized the frame yet.
        -- Create frame args: frameType, frameName, parentFrame, inheritsFrame

        --        Setup:OfficerWindow()


        -----------------------------
        -- Main Frame       --
        -----------------------------

        GUI.pdkp_frame = CreateFrame("Frame", "pdkpCoreFrame", UIParent, "pdkp_core_frame");
        GUI.pdkp_frame:SetPoint("TOP", 0, 0)
        GUI.pdkp_frame:SetScale(1) -- Just incase. This might fix the scaling issue that Sparkle has?

        GUI.pdkp_dkp_amount_box = _G['pdkp_dkp_amount_box'];
        GUI.pdkp_submit_button = _G['pdkp_dkp_submit'];
        GUI.pdkp_version = _G['pdkp_version_label'];
        GUI.pdkp_version:SetText('V' .. core.defaults.addon_version)

        -----------------------------
        -- Class Checkboxes    --
        -----------------------------

        Setup:ClassFilterCheckboxes()
        Setup:DkpSlideFilter()

        -- GUI:CreateTestMenuDropdown()
        Setup:AdjustmentDropdowns()

        GUI:SelectedEntriesUpdated()

        Setup:RaidDkpDropdown()
        Setup:HistoryFrame()
        Setup:ShroudingWindow()
        Setup:PrioList()

        Setup:PushTimer()

        GUI:CheckOutOfDate()

        Setup:ShroudingWindow()
    end
end

-----------------------------
-- CREATE FUNCTIONS    --
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

    sf:SetScale(1) -- Just incase. This might fix the scaling issue that Mozz has?

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
        scrollcontainer.frame:Show()
    end)
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
        scrollcontainer.frame:Show()
    end)
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
                for i = 1, #core.raids do
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
        d.frame:SetFrameStrata("DIALOG")
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
    rd.frame:SetFrameStrata("DIALOG");
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
        if checked then
            GUI.HistoryFrame:SetFrameStrata('DIALOG')
            GUI.HistoryFrame.scroll.frame:SetFrameStrata('DIALOG')
            GUI.HistoryFrame:Show() else GUI.HistoryFrame:Hide() end
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
    hf:SetFrameStrata('HIGH');
    hf:Raise()
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
    scrollcontainer.frame:SetFrameStrata('DIALOG');
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

    local function compare(a, b)
        return a < b;
    end

    table.sort(memberNames, compare)

    for i = 1, #memberNames do
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

    dropdownList:HookScript('OnShow', function()
        local charName = strtrim(_G['DropDownList1Button1']:GetText())

        if charName and Raid:MemberIsInRaid(charName) and Raid:IsAssist() and Guild:CanMemberEdit(charName) then

            local isDkpOfficer = charName == Raid.dkpOfficer
            local dkpOfficerText

            if isDkpOfficer then dkpOfficerText = 'Demote from DKP Officer' else
               dkpOfficerText = 'Promote to DKP Officer'
            end

            _G['UIDropDownMenu_AddSeparator'](1)
            _G['UIDropDownMenu_AddButton']({
                hasArrow = false;
                text = 'PDKP',
                isTitle = true;
                isUninteractable = true;
                notCheckable = true;
                iconOnly = false;
                tCoordLeft = 0;
                tCoordRight = 1;
                tCoordTop = 0;
                tCoordBottom = 1;
                tSizeX = 0;
                tSizeY = 8;
                tFitDropDownSizeX = true;
            }, 1) -- Title
            _G['UIDropDownMenu_AddButton']({ -- Actual button
                hasArrow = false;
                text = dkpOfficerText,
                isTitle = false;
                isUninteractable = false;
                notCheckable = true;
                iconOnly = false;
                keepShownOnClick=false,
                tCoordLeft = 0;
                tCoordRight = 1;
                tCoordTop = 0;
                tCoordBottom = 1;
                tSizeX = 0;
                tSizeY = 8;
                tFitDropDownSizeX = true;
                func=function(...)
                    if isDkpOfficer then
                        Raid.dkpOfficer = nil
                        PDKP:Print(charName .. ' is no longer the DKP Officer')
                    else
                        Raid.dkpOfficer = charName;
                        PDKP:Print(charName .. ' is now the DKP Officer')
--                        self:SetText('Demote from DKP Officer')
                    end
                    Comms:SendCommsMessage('pdkpDkpOfficer', Raid.dkpOfficer, 'RAID', nil, 'BULK', nil)
                end
            }, 1)
            _G['UIDropDownMenu_AddSeparator'](1)
        end
    end)
end

function Setup:OfficerWindow()
    if core.canEdit == false or not Raid:IsInRaid() or not Raid:IsAssist() then
        return Util:Debug(
            'Not creating officer window:' ..
            ' Edit: ' .. tostring(core.canEdit) ..
            ' InRaid: ' .. tostring(Raid:IsInRaid()) ..
            ' IsAssist: ' .. tostring(Raid:IsAssist())
        )
    end

    if _G['pdkpOfficerFrame'] then return end;

    if not GUI.pdkp_frame then -- We haven't initialized the frame yet.

        PDKP:Show()
        GUI:Hide()
    end

    local mainFrame = CreateFrame("Frame", "pdkpOfficerFrame", RaidFrame, "BasicFrameTemplateWithInset")
    mainFrame:SetSize(300, 425) -- Width, Height
    mainFrame:SetPoint("RIGHT", RaidFrame, "RIGHT", 300, 0) -- Point, relativeFrame, relativePoint, xOffset, yOffset
    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY")
    mainFrame.title:SetFontObject("GameFontHighlight")
    mainFrame.title:SetPoint("CENTER", mainFrame.TitleBg, "CENTER", 11, 0)
    mainFrame.title:SetText('PDKP Officer Interface')
    mainFrame:SetFrameStrata('FULLSCREEN');
    mainFrame:SetFrameLevel(1);
    mainFrame:SetToplevel(true)

    local closeButton = mainFrame.CloseButton
    closeButton:SetEnabled(false)

    GUI.OfficerFrame = mainFrame

    mainFrame:Show()

    local mainFrameKids = {}

    local scrollcontainer = AceGUI:Create("SimpleGroup")
    scrollcontainer:SetFullWidth(false)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetHeight(350)
    scrollcontainer:SetWidth(250)
    scrollcontainer:SetLayout("Fill")

    scrollcontainer:SetParent(mainFrame)
    scrollcontainer.frame:SetFrameStrata('HIGH');
    scrollcontainer:SetPoint("CENTER", mainFrame, "CENTER", 0, -10);

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)

    local promoteOfficer = AceGUI:Create("Button")
    promoteOfficer:SetText("Promote Officers")
    promoteOfficer:SetWidth(140)
    promoteOfficer:SetCallback('OnClick', function()
        if Raid:isRaidLeader() then
            local raidRoster = Raid:GetRaidInfo()
            for key, rMember in pairs(raidRoster) do
                for _, officer in pairs(Guild.officers) do
                    if officer.name == rMember.name then PromoteToAssistant('raid' .. key) end
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

                if Raid:IsInRaid() then
                    SendChatMessage(Raid.spamText, "GUILD", nil, nil);
                else -- Something happened, we're not in the raid anymore, so cancel the callback.
                    return guildInviteSpam()
                end

                if inviteSpamCount >= 10 then
                    guildInviteSpam()
                end
                PDKP:Print('Raid Invite Spam count: ' .. tostring(inviteSpamCount))
            end

            Raid.SpamTimer = PDKP:ScheduleRepeatingTimer(TimerFeedback, 90); -- Posts it every 90 seconds for 15 minutes.
            SendChatMessage(Raid.spamText, "GUILD", nil, nil);
        end
    end

    whisperCommand:SetText("Start Raid Inv Spam")
    whisperCommand:SetDisabled(true)
    whisperCommand:SetCallback('OnClick', function()
        guildInviteSpam()
    end)

    local raidSpamTime = AceGUI:Create("MultiLineEditBox")
    raidSpamTime:SetLabel('Guild Invite Spam text')
    raidSpamTime:SetHeight(100)
    raidSpamTime:SetWidth(200)
    raidSpamTime:DisableButton(true)
    raidSpamTime:SetText("[TIME] [RAID] invites going out. Pst for invite")
    raidSpamTime:SetCallback('OnTextChanged', function()
        Raid.spamText = raidSpamTime:GetText()

        if Util:IsEmpty(Raid.spamText) then
            whisperCommand:SetDisabled(true)
        else
            whisperCommand:SetDisabled(false)
        end
    end)

    local raidGroup = AceGUI:Create("InlineGroup")
    raidGroup:SetTitle('Raid Control')
    raidGroup:SetParent(scroll)
    raidGroup.frame:SetFrameStrata('HIGH');

    local label = AceGUI:Create("Label")
    label:SetText("This will give all officers in the raid the 'Assist' role.")
    raidGroup:AddChild(promoteOfficer)
    raidGroup:AddChild(label)

    raidGroup.frame:Hide()

    scroll:AddChild(raidGroup)

    mainFrame.raidControlGroup = raidGroup

    local inviteControl = AceGUI:Create("InlineGroup")
    inviteControl:SetTitle('Invite Control')
    inviteControl:SetParent(scroll)
    inviteControl.frame:SetFrameStrata('HIGH');

    local inviteLabel = AceGUI:Create("Label")
    inviteLabel:SetText("You will auto-invite when whispered one of the words or phrases listed above.")
    inviteControl:AddChild(inviteBox)
    inviteControl:AddChild(inviteLabel)

    local raidSpamLabel = AceGUI:Create("Label")
    raidSpamLabel:SetText("This is the message that will be sent when 'Start Raid Inv Spam' is clicked.")
    inviteControl:AddChild(raidSpamTime)
    inviteControl:AddChild(raidSpamLabel)

    local emptyLabel = AceGUI:Create("Label") -- To create space between Guild invite spam text and the button.
    emptyLabel:SetText("     ")

    inviteControl:AddChild(emptyLabel)

    local whisperLabel = AceGUI:Create("Label")
    whisperLabel:SetText("This will send your message to Guild chat every 90 seconds for 15 minutes. Click again to stop the message spam.")
    inviteControl:AddChild(whisperCommand)
    inviteControl:AddChild(whisperLabel)

    inviteControl.frame:Hide()

    scroll:AddChild(inviteControl)

    mainFrame.inviteControlGroup = inviteControl

    scroll.frame:SetFrameLevel(1);
    table.insert(mainFrameKids, scrollcontainer)

    local function toggleKids(show)
        for _, child in pairs(mainFrameKids) do
            if show then child.frame:Show() else child.frame:Hide() end
        end
    end

    mainFrame:SetScript('OnHide', function() toggleKids(false) end)
    mainFrame:SetScript('OnShow', function() toggleKids(true) end)

    GUI.officerInterfaceFrame = mainFrame;
end

