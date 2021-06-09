local _G = _G;
local PDKP = _G.PDKP

local Setup, Media, Raid, DKP, Util, Comms, Guild, Defaults, ScrollTable = PDKP:GetInst('Setup', 'Media', 'Raid', 'DKP', 'Util', 'Comms', 'Guild', 'Defaults', 'ScrollTable')
local GUI, Settings, Loot, HistoryTable, SimpleScrollFrame, Shroud, Dev = PDKP:GetInst('GUI', 'Settings', 'Loot', 'HistoryTable', 'SimpleScrollFrame', 'Shroud', 'Dev')

local pdkp_frame;

local CreateFrame, strlower, unpack = CreateFrame, strlower, unpack
local GameFontNormalSmall = GameFontNormalSmall
local BackdropTemplateMixin = BackdropTemplateMixin
local floor, pairs = math.floor, pairs
local tinsert = tinsert

local UIParent, UISpecialFrames = UIParent, UISpecialFrames

local UIDropDownMenu_GetSelectedValue, UIDropDownMenu_SetWidth, UIDropDownMenu_SetText, UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo,
UIDropDownMenu_SetSelectedValue, UIDropDownMenu_AddButton = UIDropDownMenu_GetSelectedValue, UIDropDownMenu_SetWidth,
UIDropDownMenu_SetText, UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo, UIDropDownMenu_SetSelectedValue, UIDropDownMenu_AddButton

Setup.FilterButtons = {}

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

local function createBackdropFrame(name, parent, title)
    local f = CreateFrame("Frame", name, parent)

    local title_text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title_text:SetPoint("TOPLEFT", 14, 0)
    title_text:SetPoint("TOPRIGHT", -14, 0)
    title_text:SetJustifyH("LEFT")
    title_text:SetHeight(18)

    if title then
        title_text:SetText(title)
    end

    local border = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate")
    border:SetPoint("TOPLEFT", 0, -17)
    border:SetPoint("BOTTOMRIGHT", -1, 3)

    border:SetBackdrop(Media.PaneBackdrop)
    border:SetBackdropColor(unpack(Media.paneColor))
    border:SetBackdropBorderColor(unpack(Media.paneBorderColor))

    local content = CreateFrame("Frame", nil, border)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local content_desc = content:CreateFontString(content, "OVERLAY", "GameFontHighlightSmall")
    content_desc:SetPoint("BOTTOMLEFT")
    content_desc:SetPoint("BOTTOMRIGHT")
    content_desc:SetJustifyH("LEFT")

    f.desc = content_desc
    f.border = border
    f.content = content
    f.title = title_text;
    return f
end

local function createIcon(parent, label_text)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(30, 30)
    local l = f:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
    l:SetPoint("BOTTOM", 0, -15)

    if label_text then
        l:SetText(label_text)
    end

    local icon = f:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(25, 25)
    icon:SetAllPoints(f)

    f.icon = icon
    f.label = l

    return f
end

local function createCloseButton(f, mini)
    local template = mini and 'pdkp_miniButton' or 'UIPanelButtonTemplate'
    local b = CreateFrame("Button", '$parentCloseButton', f, template)
    b:SetText(Media.CLOSE_BUTTON_TEXT)
    b:SetParent(f)
    b:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)
    return b
end

function Setup:CreateCloseButton(f, mini)
    return createCloseButton(f, mini)
end

local function createCheckButton(parent, point, x, y, displayText, uniqueName, center, enabled, frame)
    uniqueName = uniqueName or nil;
    center = center or false;
    frame = frame or nil;
    local cb = CreateFrame("CheckButton", 'pdkp_filter_' .. uniqueName, parent, "ChatConfigCheckButtonTemplate")
    _G[cb:GetName() .. 'Text']:SetText(displayText)

    if center and frame then
        local cbtw = _G[cb:GetName() .. 'Text']:GetWidth();
        cb:SetPoint('TOPRIGHT', frame, 'CENTER', x - cbtw * 0.25, y);
    else
        cb:SetPoint(point, x, y);
    end

    if enabled and enabled == true then
        cb:SetChecked(true);
    end

    cb.filterOn = uniqueName;
    return cb;
end

--- Opts:
---     name (string): Name of the dropdown (lowercase)
---     parent (Frame): Parent frame of the dropdown.
---     items (Table): String table of the dropdown options.
---     defaultVal (String): String value for the dropdown to default to (empty otherwise).
---     hide (Boolean): A boolean value for whether the dropdown should start hidden.
---     dropdownTable (table): A table of dropdowns for this to be inserted into.
---     showOnValue (string): A custom value for when the table should be shown.
---     changeFunc (Function): A custom function to be called, after selecting a dropdown option.
---     showFunc (Function): A custom function to be called, when the dropdown shows.
---     hideFunc (Function): A custom function to be called, when the dropdown hides.
local function createDropdown(opts)
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = opts['title'] or ''
    local default_val = opts['defaultVal'] or ''
    local hide = opts['hide'] or false
    local showFunc = opts['showFunc'] or function()
    end
    local hideFunc = opts['hideFunc'] or function()
    end
    local change_func = opts['changeFunc'] or function()
    end

    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    dropdown.uniqueID = opts['name']
    dropdown.showOnValue = opts['showOnValue'] or 'Always'
    local dropdown_width = 0;
    dropdown.initialized = false

    for _, item in pairs(menu_items) do
        -- Sets the dropdown width to the largest item string width.
        dd_title:SetText(item)
        local text_width = dd_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    dropdown:SetScript("OnShow", showFunc)
    dropdown:SetScript("OnHide", hideFunc)

    dropdown.isValid = function()
        if dropdown:IsVisible() then
            local box_text = UIDropDownMenu_GetSelectedValue(dropdown)
            if box_text and box_text ~= "" and box_text ~= 0 then
                return true
            else
                return false
            end
        else
            return true
        end
    end

    if hide then
        dropdown:Hide()
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function()
        local info = UIDropDownMenu_CreateInfo()

        for key, val in pairs(menu_items) do
            info.text = val;
            info.checked = false
            info.menuList = key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end

        if not dropdown.initialized and default_val and default_val ~= '' then
            dropdown.initialized = true;
            UIDropDownMenu_SetSelectedValue(dropdown, default_val, default_val)
        end
    end)

    if opts['dropdownTable'] then
        opts['dropdownTable'][opts['name']] = dropdown
    end

    return dropdown
end

local function createEditBox(opts)
    local name = opts['name'] or 'edit_box'
    local parent = opts['parent'] or pdkp_frame
    local box_label_text = opts['title'] or ''
    local multi_line = opts['multi'] or false
    local max_chars = opts['max_chars'] or 225
    local textValidFunc = opts['textValidFunc'] or function()
    end
    local numeric = opts['numeric'] or false
    local small_title = opts['smallTitle'] or false

    local box = CreateFrame("EditBox", "$parent_" .. name, parent)
    box:SetHeight(30)
    box:SetWidth(150)
    box:SetFrameStrata("DIALOG")
    box:SetMaxLetters(max_chars)
    box:SetAutoFocus(false)
    box:SetFontObject(GameFontHighlightSmall)
    box:SetMultiLine(multi_line)
    box.uniqueID = name

    box.touched = false

    box.isValid = function()
        if box:IsVisible() then
            local box_text = box:GetText()
            if name == 'other' then
                return true
            end
            if box_text and box_text ~= "" and box_text ~= 0 then
                return true
            else
                return false
            end
        else
            return true
        end
    end

    box.getValue = function()
        if numeric then
            return box:GetNumber()
        else
            return box:GetText()
        end
    end

    box:SetScript("OnEscapePressed", function()
        box:ClearFocus()
    end)
    box:SetScript("OnTextChanged", function()
        if box.isValid() then
            textValidFunc(box)
        end
    end)

    box:SetScript("OnEditFocusGained", function()
        box.touched = true
    end)

    local box_frame = CreateFrame("Frame", '$parent_edit_frame', box, BackdropTemplateMixin and "BackdropTemplate")

    box_frame:SetBackdrop({
        bgFile = Media.TRANSPARENT_BACKGROUND,
        edgeFile = Media.SHROUD_BORDER, tile = true, tileSize = 17, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    });
    box_frame:SetWidth(170)

    if multi_line then
        box_frame:SetPoint("TOPLEFT", box, "TOPLEFT", -10, 10)
        box_frame:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", 10, -15)
        box_frame:SetHeight(50)
    else
        box_frame:SetPoint("TOPLEFT", box, "TOPLEFT", -10, 0)
        box_frame:SetPoint("TOPRIGHT", box, "TOPRIGHT", -10, 0)
        box_frame:SetHeight(30)
    end

    box_frame:SetFrameLevel(box:GetFrameLevel() - 4)

    local title_font = 'GameFontNormal'

    if small_title then
        title_font = 'GameFontNormalSmall'
    end

    -- label
    local el = box:CreateFontString(box_frame, "OVERLAY", title_font)
    el:SetText(box_label_text)
    el:SetPoint("TOPLEFT", box_frame, "TOPLEFT", 5, 10)

    -- Description below the edit box.
    local ed = box:CreateFontString(box_frame, "OVERLAY", "GameFontHighlightSmall")
    ed:SetText("")
    ed:SetPoint("TOPLEFT", box_frame, "BOTTOMLEFT", 2, 0)
    ed:SetPoint("TOPRIGHT", box_frame, "BOTTOMRIGHT", 0, 0)
    ed:SetJustifyH("LEFT")

    box.init = false;

    GUI.editBoxes[name] = box

    box.frame = box_frame
    box.desc = ed
    box.title = el
    return box
end

--------------------------
-- Setup      Functions --
--------------------------


function Setup:MainUI()
    local f = CreateFrame("Frame", "pdkp_frame", UIParent)
    f:SetFrameStrata("HIGH");
    f:SetClampedToScreen(true);

    f:SetWidth(742) -- Set these to whatever height/width is needed
    f:SetHeight(632) -- for your Texture

    local function createTextures(tex)
        local x = tex['x'] or 0
        local y = tex['y'] or 0

        local t = f:CreateTexture(nil, "BACKGROUND")
        t:SetTexture(Media.PDKP_TEXTURE_BASE .. tex['file'])

        if tex['file'] == 'BG.tga' then
            t:SetDrawLayer("Background", -8)
            t:SetPoint('TOPLEFT', f, 5, -15)
            t:SetPoint('BOTTOMRIGHT', f, -5, 15)
            t:SetAlpha(0.8)
        else
            t:SetPoint(tex['dir'], f, x, y)
        end

        f.texture = t
    end

    local textures = {
        { ['dir'] = 'BOTTOMLEFT', ['file'] = 'BotLeft.tga', },
        { ['dir'] = 'BOTTOM', ['file'] = 'BotMid.tga', ['y'] = 1.5 },
        { ['dir'] = 'BOTTOMRIGHT', ['file'] = 'BotRight.tga', },
        { ['dir'] = 'CENTER', ['file'] = 'Middle.tga', },
        { ['dir'] = 'LEFT', ['file'] = 'MidLeft.tga', ['y'] = -42 },
        { ['dir'] = 'RIGHT', ['file'] = 'MidRight.tga', ['x'] = 2.35 },
        { ['dir'] = 'TOPLEFT', ['file'] = 'TopLeft.tga', ['x'] = -8 },
        { ['dir'] = 'TOP', ['file'] = 'Top.tga', },
        { ['dir'] = 'TOPRIGHT', ['file'] = 'TopRight.tga', },
        { ['dir'] = 'TOPLEFT', ['file'] = 'BG.tga', }
    }

    for _, t in pairs(textures) do
        createTextures(t)
    end

    f:SetPoint("TOP", 0, 0)
    f:Show()

    setMovable(f)

    --- Close button
    local b = createCloseButton(f, false)
    b:SetSize(22, 25) -- width, height
    b:SetPoint("TOPRIGHT", -2, -10)

    local addon_title = f:CreateFontString(f, "Overlay", "BossEmoteNormalHuge")
    addon_title:SetText("PantheonDKP")
    addon_title:SetSize(200, 25)
    addon_title:SetPoint("CENTER", f, "TOP", 0, -28)
    addon_title:SetScale(0.8)

    --- Addon Version
    local addon_version = f:CreateFontString(f, "Overlay", "GameFontNormalSmall")
    addon_version:SetSize(50, 14)
    addon_version:SetText(Util:FormatFontTextColor(Media.addon_version_hex, "v" .. Defaults.addon_version))
    addon_version:SetPoint("RIGHT", b, "LEFT", 0, -3)

    --- Addon Author
    local addon_author = f:CreateFontString(f, "Overlay", "Game11Font")
    addon_author:SetSize(200, 20)
    addon_author:SetText("Author: Neekio-Blaumeux")
    addon_author:SetPoint("TOPLEFT", f, "TOPLEFT", 40, -15)

    f.addon_title = addon_title
    f.addon_version = addon_version

    pdkp_frame = f

    tinsert(UISpecialFrames, f:GetName())

    Setup:RandomStuff()

    return pdkp_frame
end

function Setup:RandomStuff()

    local randomFuncs = {
        Setup.ScrollTable,
        Setup.Filters,

        --- Unfinished Functions
        Setup.ShroudingBox, Setup.Debugging, Setup.EasyStats, Setup.DKPAdjustments,
        Setup.RaidDropdown, Setup.DKPHistory, Setup.RaidTools, Setup.InterfaceOptions, Setup.PushProgressbar,
        Setup.HistoryTable, Setup.DKPOfficer, Setup.SyncStatus
    }

    for i, func in ipairs(randomFuncs) do
        if func then
            func()
        end
    end

    --- For debugging purposes.
    if Defaults.development then
        pdkp_frame:Show()
    end
end

function Setup:Filters()
    local f = CreateFrame("Frame", "$parentFilterFrame", pdkp_frame, BackdropTemplateMixin and "BackdropTemplate")

    f:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = Media.SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetHeight(150)
    f:SetPoint("TOPLEFT", PDKP.memberTable.frame, "BOTTOMLEFT", 0, 0)
    f:SetPoint("TOPRIGHT", PDKP.memberTable.frame, "BOTTOMRIGHT", 0, 0)

    f:Show()

    local rows = { -- Our filter rows
        { -- Row 1
            { ['point'] = 'TOPLEFT', ['x'] = 15, ['y'] = -20, ['displayText'] = 'Selected', ['filterOn'] = 'selected', ['enabled'] = false },
            { ['point'] = 'TOPLEFT', ['x'] = 30, ['y'] = 0, ['displayText'] = 'Online', ['filterOn'] = 'online', ['enabled'] = false },
            { ['point'] = 'TOPLEFT', ['x'] = 30, ['y'] = 0, ['displayText'] = 'In Raid', ['filterOn'] = 'raid', ['enabled'] = false },
            { ['point'] = 'TOPLEFT', ['x'] = 30, ['y'] = 0, ['displayText'] = 'Select All', ['filterOn'] = 'Select_All', ['enabled'] = false },
        },
        { -- Row 2
            { ['point']='TOPLEFT', ['x'] = 0, ['y'] = 0, ['displayText'] = 'All Classes', ['filterOn'] = 'Class_All',
              ['center'] = true, ['enabled'] = true
            },
        },
        {}, -- First Class Row
        {}, -- Second Class Row
        {}, -- Third Class Row
    }

    local class_row = 3

    for key, class in pairs(Defaults.classes) do
        local classBtn = {
            ['point'] = 'TOPLEFT', ['x'] = 80, ['y'] = 70, ['displayText'] = class,
            ['filterOn'] = 'Class_' .. class, ['center'] = true, ['enabled'] = true
        }
        if key >= 4 and key <= 6 then class_row = 4 elseif key >= 7 then class_row = 5 end
        table.insert(rows[class_row], classBtn)
    end

    for rowKey, row in pairs(rows) do
        for fKey, filter in pairs(row) do
            local parent = f -- Default parent.
            table.insert(Setup.FilterButtons, {})

            if fKey > 1 or rowKey > 1 then
                local pcb = Setup.FilterButtons[#Setup.FilterButtons - 1];
                local pcbt = _G[pcb:GetName() .. 'Text']
                parent = pcb;
                if #row > 1 then
                    -- To better space out the buttons.
                    filter['x'] = filter['x'] + pcbt:GetWidth();
                end
            end

            local cb = createCheckButton(parent, filter['point'], filter['x'], filter['y'], filter['displayText'],
                    filter['filterOn'], filter['center'], filter['enabled'], f)

            --- Clear all points, to reassign their points to the previous section's checkbutton.
            if rowKey >= 2 then cb:ClearAllPoints(); end

            if rowKey == 2 then
                cb:SetPoint("LEFT", Setup.FilterButtons[#Setup.FilterButtons - 4], "LEFT", 0, -30);
            elseif rowKey == 3 then
                if fKey == 1 then
                    cb:SetPoint("LEFT", Setup.FilterButtons[#Setup.FilterButtons - 1], "LEFT", 0, -30);
                else
                    cb:SetPoint("TOPRIGHT", Setup.FilterButtons[#Setup.FilterButtons - 1], "TOPRIGHT", filter['x'], 0);
                end
            elseif rowKey >= 4 then
                cb:SetPoint("TOPLEFT", Setup.FilterButtons[#Setup.FilterButtons - 3], "TOPLEFT", 0, -20);
            end

            cb:SetScript("OnClick", function(b)
                local function loop_all_class(setStatus)
                    local all_checked = true;
                    for i = 1, #Defaults.classes do
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
                if rowKey == 2 then
                    loop_all_class(b:GetChecked());
                elseif rowKey >= 3 then
                    local all_checked = loop_all_class();
                    _G['pdkp_filter_Class_All']:SetChecked(all_checked);
                end

                local st = PDKP.memberTable;
                st:ApplyFilter(b.filterOn, b:GetChecked());
            end)
            Setup.FilterButtons[#Setup.FilterButtons] = cb;
        end
    end

    local st = PDKP.memberTable;
    for _, b in pairs(Setup.FilterButtons) do
        st:ApplyFilter(b.filterOn, b:GetChecked());
    end

    GUI.filter_frame = f;
end

function Setup:ScrollTable()
    local st = {};

    local function compare(a, b)
        local sortDir = st.sortDir;
        local sortBy = st.sortBy;
        -- Set the data object explicitly here
        -- Since this is pointing to a row
        -- Not a member object.
        a = a.dataObj;
        b = b.dataObj;

        if sortBy == 'name' then
            a, b = a['name'], b['name']
        elseif sortBy == 'class' then
            if a['class'] == b['class'] then
                return a['name'] < b['name']
            end
            a, b = a['class'], b['class']
        elseif sortBy == 'dkp' then
            a, b = a:GetDKP(nil, 'total'), b:GetDKP(nil, 'total')
        end

        if sortDir == 'ASC' then
            return a > b
        else
            return a < b
        end
    end

    local table_settings = {
        ['name'] = 'ScrollTable',
        ['parent'] = pdkp_frame,
        ['height'] = 350,
        ['width'] = 330,
        ['movable'] = true,
        ['enableMouse'] = true,
        ['retrieveDataFunc'] = function()
            Guild:GetMembers()
            return Guild.memberNames
        end,
        ['retrieveDisplayDataFunc'] = function(_, name)
            return Guild:GetMemberByName(name)
        end,
        ['anchor'] = {
            ['point'] = 'TOPLEFT',
            ['rel_point_x'] = 8,
            ['rel_point_y'] = -70,
        }
    }
    local col_settings = {
        ['height'] = 14,
        ['width'] = 90,
        ['firstSort'] = 1, -- Denotes the header we want to sort by originally.
        ['headers'] = {
            [1] = {
                ['label'] = 'name',
                ['sortable'] = true,
                ['point'] = 'LEFT',
                ['showSortDirection'] = true,
                ['compareFunc'] = compare
            },
            [2] = {
                ['label'] = 'class',
                ['sortable'] = true,
                ['point'] = 'CENTER',
                ['showSortDirection'] = true,
                ['compareFunc'] = compare,
                ['colored'] = true,
            },
            [3] = {
                ['label'] = 'dkp',
                ['sortable'] = true,
                ['point'] = 'RIGHT',
                ['showSortDirection'] = true,
                ['compareFunc'] = compare,
                ['getValueFunc'] = function(member)
                    return member:GetDKP(nil, 'total')
                end,
            },
        }
    }
    local row_settings = {
        ['height'] = 20,
        ['width'] = 285,
        ['max_values'] = 425,
        ['showHighlight'] = true,
        ['indexOn'] = col_settings['headers'][1]['label'], -- Helps us keep track of what is selected, if it is filtered.
    }

    st = ScrollTable:newHybrid(table_settings, col_settings, row_settings)
    st.cols[1]:Click()

    PDKP.memberTable = st;
    GUI.memberTable = st;

    st.searchFrame = Setup:TableSearch()
    --
    ---- Entries label
    ---- 0 Entries shown | 0 selected
    local label = st.searchFrame:CreateFontString(st.searchFrame, 'OVERLAY', 'GameFontNormalLeftYellow')
    label:SetSize(200, 15)
    label:SetPoint("LEFT", st.searchFrame.clearButton, "LEFT", 60, -1)
    label:SetText("0 Players shown | 0 selected")

    st.entryLabel = label
end

function Setup:TableSearch()
    -- edit frame
    local ef = CreateFrame("Frame", "$parent_edit_frame", pdkp_frame)
    ef:SetHeight(25)
    ef:SetWidth(165)
    ef:SetPoint('BOTTOMLEFT', pdkp_frame, "BOTTOMLEFT", 10, 10)

    -- search label
    local sl = ef:CreateFontString(ef, 'OVERLAY', 'GameFontNormalSmall')
    sl:SetText("Search:")
    sl:SetPoint("LEFT", ef, "LEFT", -12, 0)
    sl:SetWidth(80)

    -- edit clear button
    local clearButton = CreateFrame("Button", "$parent_clear_button", ef, "UIPanelButtonTemplate")
    clearButton:SetText("Clear")
    clearButton:SetSize(45, 15)
    clearButton:SetPoint("RIGHT", ef, "RIGHT", -2, 0)

    -- edit box
    local eb = CreateFrame("EditBox", "$parent_editBox", pdkp_frame)
    eb:SetWidth(75)
    eb:SetHeight(50)
    eb:SetPoint("LEFT", ef, "LEFT", 48, 0)
    eb:SetFontObject(GameFontNormalSmall)
    eb:SetFrameStrata("DIALOG")
    eb:SetMaxLetters(11)
    eb:SetAutoFocus(false)

    local function toggleClearButton(text)
        if text == nil or text == "" then
            clearButton:Hide()
        else
            clearButton:Show()
        end
    end

    local function resetSearch()
        eb:ClearFocus()
        toggleClearButton(eb:GetText())
    end

    eb:SetScript("OnEscapePressed", function() resetSearch() end)
    eb:SetScript("OnEnterPressed", function() resetSearch() end)
    eb:SetScript("OnTextChanged", function()
        local text = eb:GetText()
        toggleClearButton(text)
        PDKP.memberTable:SearchChanged(text)
    end)
    eb:SetScript("OnEditFocusLost", function() toggleClearButton(eb:GetText()) end)
    eb:SetScript("OnEditFocusGained", function() toggleClearButton(eb:GetText()) end)

    clearButton:SetScript("OnClick", function()
        eb:SetText("")
        resetSearch()
    end)

    clearButton:Hide()

    ef.editBox = eb
    ef.searchLabel = sl
    ef.clearButton = clearButton

    return ef
end