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
local ScrollTable = core.ScrollTable;
local Settings = core.Settings;

local AceGUI = LibStub("AceGUI-3.0")
local pdkp_frame = nil
local PlaySound = PlaySound

local CLOSE_BUTTON_TEXT = "|TInterface\\Buttons\\UI-StopButton:0|t"
local TRANSPARENT_BACKGROUND = "Interface\\TutorialFrame\\TutorialFrameBackground"
local PDKP_TEXTURE_BASE = "Interface\\Addons\\PantheonDKP\\Media\\Main_UI\\PDKPFrame-"
local SHROUD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
local HIGHLIGHT_TEXTURE = 'Interface\\QuestFrame\\UI-QuestTitleHighlight'
local SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
local ARROW_TEXTURE = 'Interface\\MONEYFRAME\\Arrow-Left-Up'
local ROW_SEPARATOR = 'Interface\\Artifacts\\_Artifacts-DependencyBar-BG'

local filterButtons = {};

--------------------------
-- Local      Functions --
--------------------------

local function setMovable(f)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag('LeftButton')
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

local function createCloseButton(f, mini)
    local template = mini and 'pdkp_miniButton' or 'UIPanelButtonTemplate'
    local b = CreateFrame("Button", '$parentCloseButton',  f, template)
    b:SetText(CLOSE_BUTTON_TEXT)
    b:SetParent(f)
    b:SetScript("OnClick", function(self) self:GetParent():Hide() end)
    return b
end

local function createCheckButton(parent, point, x, y, displayText, uniqueName, center, frame)
    uniqueName = uniqueName or nil;
    center = center or false;
    frame = frame or nil;
    local cb = CreateFrame("CheckButton", 'pdkp_filter_' ..uniqueName, parent, "ChatConfigCheckButtonTemplate")
    _G[cb:GetName() .. 'Text']:SetText(displayText)

    if center and frame then
        local cbtw = _G[cb:GetName() .. 'Text']:GetWidth();
        cb:SetPoint('TOPRIGHT', frame, 'CENTER', x - cbtw *0.25, y);
    else
        cb:SetPoint(point, x, y);
    end


    cb.filterOn = uniqueName;
    return cb;
end

local function createDropdown(name, parent, options, defaultVal)
    defaultVal = defaultVal or '';
    local dropdown = CreateFrame("FRAME", '$parentDropdown_' .. name, parent, 'UIDropDownMenuTemplate');
    dropdown:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 15, 75);
    dropdown.SetWidth = UIDropDownMenu_SetWidth;
    dropdown.Init = UIDropDownMenu_Initialize;
    dropdown.CreateInfo = UIDropDownMenu_CreateInfo;
    dropdown.SetValue = UIDropDownMenu_SetSelectedValue;
    dropdown.SetText = UIDropDownMenu_SetText;
    dropdown.buttons = {};

    dropdown:SetWidth(dropdown, 100);
    dropdown:Init(dropdown, function()
        local info = dropdown:CreateInfo();
        for key, option in pairs(options) do
            info.text = option;
            info.checked = false;
            info.menuList = key
            info.hasArrow = false;
            info.func = function(b)
                Setup:DropdownValueChanged(dropdown, b)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedValue(dropdown, defaultVal, defaultVal);
    return dropdown;
end

local function createEditBox(name, parent, options)
    local opts = {
        ['name'] = name or '$parent_editbox',
        ['parent'] = parent or 'pdkp_frame',
        ['posx']= options['x'] or 0,
        ['posy']=options['y'] or 0,
        ['relative']=options['relative'] or 'BOTTOMLEFT',
        ['callback']=options['callback'] or nil,
    }

    -- edit frame
    local ef = CreateFrame("Frame", "$parent_edit_frame", pdkp_frame)
    --ef:SetBackdrop( {
    --    bgFile = TRANSPARENT_BACKGROUND,
    --    edgeFile = SHROUD_BORDER, tile = true, tileSize = 17, edgeSize = 16,
    --    insets = { left = 5, right = 5, top = 5, bottom = 5 }
    --});
    ef:SetHeight(25)
    ef:SetWidth(165)
    ef:SetPoint('BOTTOMLEFT', pdkp_frame, "BOTTOMLEFT", 10, 10)

    -- edit label
    local sl = ef:CreateFontString(ef, 'OVERLAY', 'GameFontNormalSmall')
    sl:SetText("Search:")
    sl:SetPoint("LEFT", ef, "LEFT", -12, 0)
    sl:SetWidth(80)

    -- edit clear button
    local clearButton = CreateFrame("Button", "$parent_clear_button", ef, "UIPanelButtonTemplate")
    clearButton:SetText("Clear")
    clearButton:SetSize(45, 15)
    clearButton:SetPoint("RIGHT", ef, "RIGHT", -2, 0)
    clearButton:SetScript("OnClick", function()
        print("Clear Edit Box!")
    end)

    -- edit box
    local eb = CreateFrame("EditBox", "$parent_editBox", pdkp_frame)
    eb:SetWidth(90)
    eb:SetHeight(50)
    eb:SetPoint("LEFT", ef, "LEFT", 5, 0)
    eb:SetFontObject(GameFontNormalSmall)
    eb:SetFrameStrata("DIALOG")
    eb:SetMaxLetters(12)
    eb:SetAutoFocus(false)

    local function resetSearch()
        eb:ClearFocus()
        local text = eb:GetText()
        if text == nil or text == "" then
            sl:Show()
            clearButton:Hide()
        end
    end

    local function clearSearch()
        eb:SetText("")
        resetSearch()
    end

    eb:SetScript("OnEscapePressed", function() resetSearch() end)
    eb:SetScript("OnEnterPressed", function() resetSearch() end)
    eb:SetScript("OnTextChanged", function()
        local text = eb:GetText()
        if text == nil and text == "" then
            sl:Show()
        else
            sl:Hide()
            clearButton:Show()
        end
    end)
    eb:SetScript("OnEditFocusLost", function()
        _G["pdkp_frame_edit_frame_clear_button"]:Hide()
        print('hiding button')
    end)
    eb:SetScript("OnEditFocusGained", function()

    end)

    _G["pdkp_frame_edit_frame_clear_button"]:Hide()

    return frame

end

--------------------------
-- Setup      Functions --
--------------------------

function Setup:DropdownValueChanged(dropdown, b)
    b.selected = true;
    UIDropdownMenu_SetSelectedValue(dropdown, b.value, b.value);
    UIDropdownMenu_SetText(dropdown, b.value);
end


function Setup:MainUI()
    local f = CreateFrame("Frame", "pdkp_frame", UIParent)
    f:SetFrameStrata("HIGH");
    f:SetClampedToScreen(true);

    f:SetWidth(742) -- Set these to whatever height/width is needed
    f:SetHeight(682) -- for your Texture

    local function createTextures(tex)
        local x = tex['x'] or 0
        local y = tex['y'] or 0

        local t = f:CreateTexture(nil, "BACKGROUND")
        t:SetTexture(PDKP_TEXTURE_BASE .. tex['file'])
        t:SetPoint(tex['dir'], f, x, y)
        f.texture = t
    end

    local textures = {
        { ['dir'] = 'BOTTOMLEFT', ['file'] = 'BotLeft.tga', },
        { ['dir'] = 'BOTTOM', ['file'] = 'BotMid.tga', ['y']=1.5},
        { ['dir'] = 'BOTTOMRIGHT', ['file'] = 'BotRight.tga', },
        { ['dir'] = 'CENTER', ['file'] = 'Middle.tga', },
        { ['dir'] = 'LEFT', ['file'] = 'MidLeft.tga', ['y']=-42},
        { ['dir'] = 'RIGHT', ['file'] = 'MidRight.tga', ['x']=2.35},
        { ['dir'] = 'TOPLEFT', ['file'] = 'TopLeft.tga', ['x']=-8},
        { ['dir'] = 'TOP', ['file'] = 'Top.blp', },
        { ['dir'] = 'TOPRIGHT', ['file'] = 'TopRight.blp', },
    }

    for _, t in pairs(textures) do createTextures(t) end

    f:SetPoint("TOP",0,0)
    f:Show()

    setMovable(f)

    -- Close button

    local b = createCloseButton(f, false)
    b:SetSize(22, 25) -- width, height
    b:SetPoint("TOPRIGHT", -2, -10)

    -- Submit Button

    local sb = CreateFrame("Button", "MyButton", f, "UIPanelButtonTemplate")
    sb:SetSize(80 ,22) -- width, height
    sb:SetText("Submit")
    sb:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -6, 12)
    sb:SetScript("OnClick", function()
        local st = PDKP.memberTable

        if #st.selected >= 1 then
            for _, name in pairs(st.selected) do
                local _, rowIndex = tfind(st.rows, name, 'name')
                if rowIndex then
                    local row = st.rows[rowIndex]
                    if row.dataObj['name'] == name then
                        local member = Guild:GetMemberByName(name)
                        member:UpdateDKP(nil, nil)
                        row:UpdateRowValues()
                    end
                end
            end
        end
    end)

    pdkp_frame = f

    Setup:RandomStuff()

    return pdkp_frame
end

function Setup:Debugging()
    local f = CreateFrame("Frame", "pdkp_debug_frame", UIParent)
    f:SetFrameStrata("HIGH")
    f:SetPoint("BOTTOMLEFT")
    f:SetHeight(500)
    f:SetWidth(200)

    f:SetBackdrop( {
        bgFile = TRANSPARENT_BACKGROUND,
        edgeFile = SHROUD_BORDER, tile = true, tileSize = 64, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    });

    setMovable(f)

    -- mini close button
    local b = createCloseButton(f, true)
    b:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -6, -6)

    -- title
    local t = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    t:SetPoint("TOPLEFT", 5, -10)
    t:SetPoint("TOPRIGHT", -10, -30)
    t:SetText("PDKP Debugging")
    t:SetParent(f)

    --local sb = CreateFrame("Button", "MyButton", f, "UIPanelButtonTemplate")
    --sb:SetSize(80 ,22) -- width, height
    --sb:SetText("Submit")
    --sb:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -6, 12)
    --sb:SetScript("OnClick", function()
    --    local st = PDKP.memberTable
    --
    --    if #st.selected >= 1 then
    --        for _, name in pairs(st.selected) do
    --            local _, rowIndex = tfind(st.rows, name, 'name')
    --            if rowIndex then
    --                local row = st.rows[rowIndex]
    --                if row.dataObj['name'] == name then
    --                    local member = Guild:GetMemberByName(name)
    --                    member:UpdateDKP(nil, nil)
    --                    row:UpdateRowValues()
    --                end
    --            end
    --        end
    --    end
    --end)

    local buttons = {
        ['show']=function()
            print('Showing PDKP')
        end,
        ['hide']=function()
            print('Hiding PDKP')
        end,

    }
    local button_counter_x = 1
    local button_counter_y = 1
    local button_counter = 1
    for name, func in pairs(buttons) do
        local db = CreateFrame("Button", nil, f, "UiPanelButtonTemplate")
        db:SetSize(80, 22)
        db:SetText(name)

        db:SetScript("OnClick", func)

        pos_x = 10
        pos_y = -25

        pos_y = pos_y * button_counter

        db:SetPoint("TOPLEFT", f, "TOPLEFT", pos_x, pos_y)

        button_counter = button_counter + 1
    end
end

function Setup:RandomStuff()
    --Setup:ShroudingBox()
    Setup:Debugging()

    Setup:ScrollTable()
    Setup:Filters()
    Setup:RaidDropdown()
    Setup:RaidReasons()
    Setup:TableSearch()
    --Setup:BossKillLoot()
    --Setup:TabView()
end

function Setup:TableSearch()
    createEditBox('pdkp_search', GUI.pdkp_frame, {})
end

function Setup:Filters()
    local f = CreateFrame("Frame", "$parentFilterFrame", pdkp_frame)
    f:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetHeight(150)
    f:SetPoint("TOPLEFT", PDKP.memberTable.frame, "TOPRIGHT", -3, 0)
    f:SetPoint("TOPRIGHT", pdkp_frame, "RIGHT", -10,0)

    f:Show()

    local rows = { -- Our filter rows
        { -- Row 1
            { ['point']='TOPLEFT', ['x']=20, ['y']=-20, ['displayText']='Selected', ['filterOn']='selected', },
            { ['point']='TOPLEFT', ['x']=85, ['y']=0, ['displayText']='Online', ['filterOn']='online' },
            { ['point']='TOPLEFT', ['x']=85, ['y']=0, ['displayText']='In Raid', ['filterOn']='raid' },
        },
        { -- Row 2
            { ['point']='TOPLEFT', ['x']=0, ['y']=-30, ['displayText']='Select All', ['filterOn']='Select_All' },
        },
        { -- Row 3
            { ['x']=0, ['y']=0, ['displayText']='All Classes', ['filterOn']='Class_All',
              ['center']=true,
            },
        },
        {}, -- First Class Row
        {}, -- Second Class Row
    }

    for key, class in pairs(Defaults.classes) do
        local classBtn = { ['point']='TOPLEFT', ['x']=60, ['y']=50, ['displayText']=class, ['filterOn']='Class_'..class}

        if key >= 1 and key <= 4 then
            table.insert(rows[4], classBtn);
        else
            table.insert(rows[5], classBtn)
        end
    end

    for rowKey, row in pairs(rows) do
        for fKey, filter in pairs(row) do
            local parent = f -- Default parent.
            table.insert(filterButtons, {});

            if fKey > 1 or rowKey > 1 then
                local pcb = filterButtons[#filterButtons -1];
                local pcbt = _G[pcb:GetName() .. 'Text']
                parent = pcb;
                if #row > 1 then -- To better space out the buttons.
                    filter['x'] = filter['x'] + pcbt:GetWidth();
                end
            end

            local cb = createCheckButton(parent, filter['point'], filter['x'], filter['y'], filter['displayText'],
                    filter['filterOn'], filter['center'], f)

            if rowKey == 4 or rowKey == 5 then
                cb:ClearAllPoints();
                if rowKey == 4 then
                    if fKey == 1 then
                        cb:SetPoint("LEFT", f, "LEFT", 20, -40);
                    else
                        cb:SetPoint("TOPRIGHT", filterButtons[#filterButtons-1], "TOPRIGHT", filter['x'], 0);
                    end
                elseif rowKey == 5 then
                    cb:SetPoint("TOPLEFT", filterButtons[#filterButtons-4], "TOPLEFT", 0, -20);
                end
            end

            if rowKey >= 3 and rowKey <=5 then
                cb:SetChecked(true);
            end

            cb:SetScript("OnClick", function(b)
                local function loop_all_class(setStatus)
                    local all_checked = true;
                    for i=1, #Defaults.classes do
                        local button = _G['pdkp_filter_Class_' .. Defaults.classes[i]];
                        if setStatus ~= nil then
                            button:SetChecked(setStatus);
                        end
                        if not button:GetChecked() then
                            all_checked = false
                        end
                    end
                    return all_checked
                end
                if rowKey == 3 then -- All Classes
                    loop_all_class(b:GetChecked());
                elseif rowKey == 4 or rowKey == 5 then
                    local all_checked = loop_all_class();
                    _G['pdkp_filter_Class_All']:SetChecked(all_checked);
                end

                local st = PDKP.memberTable;
                st:ApplyFilter(b.filterOn, b:GetChecked());
            end)
            filterButtons[#filterButtons] = cb;
        end
    end

    local st = PDKP.memberTable;
    for _, b in pairs(filterButtons) do
        st:ApplyFilter(b.filterOn, b:GetChecked());
    end
end



function Setup:RaidReasons()
    local f = CreateFrame("Frame", "$parentReasonsFrame", pdkp_frame)
    f:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetHeight(225);
    f:SetPoint("BOTTOMLEFT", PDKP.memberTable.frame, "BOTTOMRIGHT", -3, 0)
    f:SetPoint("BOTTOMRIGHT", pdkp_frame, "RIGHT", -10,0)
    f:Show()

    GUI.adjustmentReasons = {
        {
            ['title']='On Time Bonus',
            ['menu']={
                'Molten Core',
                'Blackwing Lair',
                'Ahn\'Qiraj'
            }
        },
        {
            ['title']='Completion Bonus',
            ['menu']={

            }

        },
        {
            ['title']='Benched',
            ['menu']={

            }
        },
        {
            ['title']='Boss Kill',
            ['menu']={

            }
        },
        {
            ['title']='Unexcused Absence',
            ['menu']={

            }
        },
        {
            ['title']='Item Win'
        },
        {
            ['title']='Other'
        },
    }

    local menuList = {
        { text = "Select an Option", isTitle = true},
        { text = "Option 1", func = function() print("You've chosen option 1"); end,
          menuList = {
            { text = "Option 3", func = function() print("You've chosen option 3"); end }
        } },
        { text = "Option 2", func = function() print("You've chosen option 2"); end,
          menuList = {
              { text = "Option 3", func = function() print("You've chosen option 3"); end }
          }
        },
        { text = "More Options", hasArrow = true,
          menuList = {
              { text = "Option 3", func = function() print("You've chosen option 3"); end }
          }
        }
    }
    local menuFrame = CreateFrame("Frame", "Omen_TitleDropDownMenu", f, "UIDropDownMenuTemplate")
    menuFrame.menuList = menuList
    menuFrame:SetParent(f)

    -- Or make the menu appear at the frame:
    menuFrame:SetPoint("Center", f, "Center")
    EasyMenu(menuList, menuFrame, menuFrame, 0, 10, nil)
end

function Setup:RaidDropdown()

    local dropdown = CreateFrame("FRAME", 'pdkp_raid_dropdown', _G['pdkp_frameFilterFrame'], 'UIDropDownMenuTemplate');
    dropdown:SetPoint("TOPRIGHT", _G['pdkp_frameFilterFrame'], "TOPRIGHT", 15, 75);
    UIDropDownMenu_SetWidth(dropdown, 100);
    UIDropDownMenu_SetText(dropdown, Settings.current_raid)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo();
        for key, raid in pairs(Defaults.raids) do
            info.text = raid;
            info.checked = false;
            info.menuList = key;
            info.hasArrow = false;
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value);
                UIDropDownMenu_SetText(dropdown, b.value);
                b.checked = true;

                Settings:ChangeCurrentRaid(b.value);
                PDKP.memberTable:RaidChanged()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetSelectedValue(dropdown, Settings.current_raid, Settings.current_raid);

    -- Implement the function to change the favoriteNumber
    function dropdown:SetValue(self, arg1, arg2, checked)
        raidName = newValue
        print(self, arg1, arg2, checked);
        -- Update the text; if we merely wanted it to display newValue, we would not need to do this
        --UIDropDownMenu_SetText(dropdown, raidName)
        ---- Because this is called from a sub-menu, only that menu level is closed by default.
        ---- Close the entire menu with this next call
        --CloseDropDownMenus()
    end

    Util:WatchVar(dropdown, 'Raid_Dropdown');
end

function Setup:TabView()
    --PanelTemplates_SetNumTabs(myTabContainerFrame, 2);  -- 2 because there are 2 frames total.
    --PanelTemplates_SetTab(myTabContainerFrame, 1);      -- 1 because we want tab 1 selected.
    --myTabPage1:Show();  -- Show page 1.
    --myTabPage2:Hide();  -- Hide all other pages (in this case only one).

end

function Setup:BossKillLoot()
    local f = CreateFrame("Frame", "$parentBossLoot", pdkp_frame)
    f:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetHeight(225);
    f:SetPoint("BOTTOMLEFT", PDKP.memberTable.frame, "BOTTOMRIGHT", -3, 0)
    f:SetPoint("BOTTOMRIGHT", pdkp_frame, "RIGHT", -10,0)
    f:Show()

    -- mini close button
    local b = createCloseButton(f, true)
    b:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -6, -6)

    -- title
    local t = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    t:SetPoint("TOPLEFT", 5, -10)
    t:SetPoint("TOPRIGHT", -10, -30)
    t:SetText("PDKP Shrouding")
    t:SetParent(f)

    f:Show()
end

function Setup:ShroudingBox()
    local f = CreateFrame("Frame", "pdkp_shroud_frame", UIParent)
    f:SetFrameStrata("HIGH")
    f:SetPoint("BOTTOMLEFT")
    f:SetHeight(200)
    f:SetWidth(200)

    f:SetBackdrop( {
        bgFile = TRANSPARENT_BACKGROUND,
        edgeFile = SHROUD_BORDER, tile = true, tileSize = 64, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    });

    setMovable(f)

    -- mini close button
    local b = createCloseButton(f, true)
    b:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -6, -6)

    -- title
    local t = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    t:SetPoint("TOPLEFT", 5, -10)
    t:SetPoint("TOPRIGHT", -10, -30)
    t:SetText("PDKP Shrouding")
    t:SetParent(f)

    f:Show()
end

function Setup:ScrollTable()
    local st = {};

    local function compare(a,b)
        local sortDir = st.sortDir;
        local sortBy = st.sortBy;
        -- Set the data object explicitly here
        -- Since this is pointing to a row
        -- Not a member object.
        a = a.dataObj;
        b = b.dataObj;

        if sortBy == 'name' then
            a = a['name']
            b = b['name']
        elseif sortBy == 'class' then
            if a['class'] == b['class'] then
                return a['name'] < b['name']
            else
                a = a['class']
                b = b['class']
            end
        elseif sortBy == 'dkp' then
            a = a:GetDKP(nil, 'total')
            b = b:GetDKP(nil, 'total')
        end

        if sortDir == 'ASC' then return a > b else return a < b end
    end

    local table_settings = {
        ['name']= 'ScrollTable',
        ['parent']=pdkp_frame,
        ['height']=500,
        ['width']=330,
        ['movable']=true,
        ['enableMouse']=true,
        ['retrieveDataFunc']=function()
            Guild:GetMembers()
            return Guild.memberNames
        end,
        ['retrieveDisplayDataFunc']=function(self, name)
            return Guild:GetMemberByName(name)
        end,
        ['anchor']={
            ['point']='TOPLEFT',
            ['rel_point_x']=12,
            ['rel_point_y']=-120,
        }
    }
    local col_settings = {
        ['height']=14,
        ['width']=90,
        ['firstSort']=1, -- Denotes the header we want to sort by originally.
        ['headers'] = {
            [1] = {
                ['label']='name',
                ['sortable']=true,
                ['point']='LEFT',
                ['showSortDirection'] = true,
                ['compareFunc']=compare
            },
            [2] = {
                ['label']='class',
                ['sortable']=true,
                ['point']='CENTER',
                ['showSortDirection'] = true,
                ['compareFunc']=compare
            },
            [3] = {
                ['label']='dkp',
                ['sortable']=true,
                ['point']='RIGHT',
                ['showSortDirection'] = true,
                ['compareFunc']=compare,
                ['getValueFunc']= function (member)
                    return member:GetDKP(nil, 'total')
                end,
            },
        }
    }
    local row_settings = {
        ['height']=20,
        ['width']=285,
        ['max_values'] = 425,
        ['indexOn']=col_settings['headers'][1]['label'], -- Helps us keep track of what is selected, if it is filtered.
    }

    st = ScrollTable:newHybrid(table_settings, col_settings, row_settings)
    st.cols[1]:Click()

    PDKP.memberTable = st;
end


