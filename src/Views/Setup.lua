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
    f:SetFrameStrata("LOW")

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
end

function Setup:RandomStuff()
    --Setup:ShroudingBox()

    Setup:ScrollTable()
    Setup:Filters()
    Setup:RaidDropdown()
    --Setup:BossKillLoot()
    --Setup:TabView()
end

function Setup:Filters()
    local f = CreateFrame("Frame", "$parentFilterFrame", pdkp_frame)
    f:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetHeight(300)
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
            { ['x']=0, ['y']=70, ['displayText']='All Classes', ['filterOn']='Class_All',
              ['center']=true,
            },
        },
        {}, -- First Class Row
        {}, -- Second Class Row
    }

    for key, class in pairs(Defaults.classes) do
        local classBtn = { ['point']='TOPLEFT', ['x']=60, ['y']=0, ['displayText']=class, ['filterOn']='Class_'..class}

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
                        cb:SetPoint("LEFT", f, "LEFT", 20, 30);
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
    f:SetHeight(300)
    f:SetPoint("BOTTOMLEFT", PDKP.memberTable.frame, "BOTTOMRIGHT", -3, 0)
    f:SetPoint("BOTTOMRIGHT", pdkp_frame, "RIGHT", -10,0)
    f:Show()

    GUI.adjustmentReasons = {
        "On Time Bonus",
        "Completion Bonus",
        "Benched",
        "Boss Kill",
        "Unexcused Absence",
        "Item Win",
        "Other"
    }

    local favoriteNumber = 42 -- A user-configurable setting

    -- Create the dropdown, and configure its appearance
    local dropDown = CreateFrame("FRAME", "WPDemoDropDown", UIParent, "UIDropDownMenuTemplate")
    dropDown:SetPoint("CENTER")
    UIDropDownMenu_SetWidth(dropDown, 200)
    UIDropDownMenu_SetText(dropDown, "Favorite number: " .. favoriteNumber)

    -- Create and bind the initialization function to the dropdown menu
    UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        if (level or 1) == 1 then
            -- Display the 0-9, 10-19, ... groups
            for i=0,4 do
                info.text, info.checked = i*10 .. " - " .. (i*10+9), favoriteNumber >= i*10 and favoriteNumber <= (i*10+9)
                info.menuList, info.hasArrow = i, true
                UIDropDownMenu_AddButton(info)
            end

        else
            -- Display a nested group of 10 favorite number options
            info.func = self.SetValue
            for i=menuList*10, menuList*10+9 do
                info.text, info.arg1, info.checked = i, i, i == favoriteNumber
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    -- Implement the function to change the favoriteNumber
    function dropDown:SetValue(newValue)
        favoriteNumber = newValue
        -- Update the text; if we merely wanted it to display newValue, we would not need to do this
        UIDropDownMenu_SetText(dropDown, "Favorite number: " .. favoriteNumber)
        -- Because this is called from a sub-menu, only that menu level is closed by default.
        -- Close the entire menu with this next call
        CloseDropDownMenus()
    end


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
    local f = CreateFrame("Frame", "pdkp_bossLoot_frame", PDKP.memberTable.frame)
    f:SetFrameStrata("HIGH")
    f:SetPoint("BOTTOMRIGHT", PDKP.memberTable.frame, "BOTTOMRIGHT")
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


