local _, PDKP = ...
local _G = _G
PDKP.GUtils = {}
local unpack, CreateFrame = unpack, CreateFrame
local GameFontHighlightSmall = GameFontHighlightSmall

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;

local GUtils = PDKP.GUtils

function GUtils:setMovable(f)
    if f == nil then
        return
    end
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag('LeftButton')
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

function GUtils:createCloseButton(f, mini)
    mini = mini or false

    local template = mini and 'pdkp_miniButton' or 'UIPanelButtonTemplate'
    local b = CreateFrame("Button", '$parentCloseButton', f, template)
    b:SetText(MODULES.Media.CLOSE_BUTTON_TEXT)
    b:SetParent(f)
    b:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)
    return b
end

function GUtils:createCheckButton(opts)
    local uniqueName = opts['uniqueName'] or ''
    local center = opts['center'] or false
    local frame = opts['frame'] or nil
    local pointX = opts['x'] or 0
    local pointY = opts['y'] or 0
    local point = opts['point'] or 'TOPRIGHT'
    local displayText = opts['text'] or ''
    local enabled = opts['enabled'] or false
    local parent = opts['parent']

    local cb = CreateFrame("CheckButton", 'pdkp_filter_' .. uniqueName, parent, "ChatConfigCheckButtonTemplate")
    local cbText = _G[cb:GetName() .. 'Text']
    cbText:SetText(displayText)

    -- To center the text and the check box.
    cbText:SetPoint("TOPLEFT", cb, "TOPRIGHT", 0, 0)
    cbText:SetPoint("BOTTOMLEFT", cb, "BOTTOMRIGHT", 0, 0)

    if center and frame then
        local cbtw = cbText:GetWidth()
        cb:SetPoint("TOPRIGHT", frame, "CENTER", pointX - cbtw * 0.25, pointY)
    else
        cb:SetPoint(point, pointX, pointY)
    end

    --- BUG FIX: HitInset should be set to avoid overlapping other content with check box's click frame.
    --- Defaults to (l,r,t,b) = 0, -145, 0, 0
    cb:SetHitRectInsets(0, cbText:GetWidth() * -1, 0, 0)

    cb:SetChecked(enabled)

    cb.text = cbText
    cb.displayText = displayText
    cb.filterOn = uniqueName
    return cb;
end

function GUtils:createBackdropFrame(name, parent, title)
    if parent == nil then
        return
    end
    title = title or ''
    name = name or nil

    local f = CreateFrame("Frame", name, parent)

    local title_text = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    title_text:SetPoint("TOPLEFT", 14, 0)
    title_text:SetPoint("TOPRIGHT", -14, 0)
    title_text:SetJustifyH("LEFT")
    title_text:SetHeight(18)
    title_text:SetText(title)

    local border = CreateFrame("Frame", nil, f, MODULES.Media.BackdropTemplate)
    border:SetPoint("TOPLEFT", 0, -17)
    border:SetPoint("BOTTOMRIGHT", -1, 3)

    border:SetBackdrop(MODULES.Media.PaneBackdrop)
    border:SetBackdropColor(unpack(MODULES.Media.PaneColor))
    border:SetBackdropBorderColor(unpack(MODULES.Media.PaneBorderColor))

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
    f.children = {};
    return f
end

function GUtils:createIcon(parent, label_text)
    if parent == nil then
        return
    end
    label_text = label_text or ''

    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(30, 30)
    local l = f:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
    l:SetPoint("BOTTOM", 0, -15)

    l:SetText(label_text)

    local icon = f:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(25, 25)
    icon:SetAllPoints(f)

    f.icon = icon
    f.label = l

    return f
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
function GUtils:createDropdown(opts)
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = opts['title'] or ''
    local default_val = opts['defaultVal'] or ''
    local hide = opts['hide'] or false

    local showFunc = opts['showFunc'] or function()
    end
    local hideFunc = opts['hideFunc'] or function()
    end
    local changeFunc = opts['changeFunc'] or function()
    end

    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    dropdown.uniqueID = opts['name']
    dropdown.showOnValue = opts['showOnValue'] or 'Always'
    dropdown.initialized = false -- Used later on, in initialization
    dropdown.children = opts['children'] or {}

    --- BUG FIX Start: Menu Width
    --- Menu width doesn't dynamically change, at least not easily. To get around this, we find the longest string, pop
    --- it into the dd_title font string, calculate the width with some padding, and set that as our dropdown width.

    -- ShallowCopy the menu_items so we don't accidentally sort the original table.
    local itemsCopy = PDKP.Utils.ShallowCopy(menu_items)

    -- Sort the items table by length
    table.sort(itemsCopy, function(a, b)
        return string.len(a) > string.len(b)
    end)

    -- Grab the longest string from the sorted table
    local longest_item = itemsCopy[1]

    dd_title:SetText(longest_item);

    local title_padding = 20;
    local dropdown_width = dd_title:GetStringWidth() + title_padding

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    dd_title:SetText(title_text)

    --- End BUG FIX: Menu Width

    -- Dropdown Functions
    dropdown:SetScript("OnShow", showFunc)
    dropdown:SetScript("OnHide", hideFunc)
    dropdown.isValid = function()
        local box_text = UIDropDownMenu_GetSelectedValue(dropdown)
        return dropdown:IsVisible() and box_text ~= nil and box_text ~= "" and box_text ~= 0;
    end

    if hide then
        dropdown:Hide()
    end

    -- We need to define the initialize function via blizzard's method.
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
                changeFunc(dropdown, dropdown, b)
            end
            UIDropDownMenu_AddButton(info)
        end

        if not dropdown.initialized and default_val and default_val ~= '' then
            dropdown.initialized = true;
            UIDropDownMenu_SetSelectedValue(dropdown, default_val, default_val)
            UIDropDownMenu_SetText(dropdown, default_val)
        end
    end)

    -- Attaches this to a global object, if provided.
    if opts['dropdownTable'] then
        dropdown.dropdownTable = opts['dropdownTable']
    end

    return dropdown
end

--- Opts:
---     name (string): Name of the dropdown (lowercase)
---     parent (Frame): Parent frame of the dropdown.
---     items (Table): table of the dropdown options & their sub-menus.
---     defaultVal (String): String value for the dropdown to default to (empty otherwise).
---     hide (Boolean): A boolean value for whether the dropdown should start hidden.
---     dropdownTable (table): A table of dropdowns for this to be inserted into.
---     showOnValue (string): A custom value for when the table should be shown.
---     changeFunc (Function): A custom function to be called, after selecting a dropdown option.
---     showFunc (Function): A custom function to be called, when the dropdown shows.
---     hideFunc (Function): A custom function to be called, when the dropdown hides.
function GUtils:createNestedDropdown(opts)
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = opts['title'] or ''
    local default_val = opts['defaultVal'] or ''
    local hide = opts['hide'] or false

    local showFunc = opts['showFunc'] or function()
    end
    local hideFunc = opts['hideFunc'] or function()
    end
    local changeFunc = opts['changeFunc'] or function()
    end

    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')

    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    dropdown.uniqueID = opts['name']
    dropdown.showOnValue = opts['showOnValue'] or 'Always'
    dropdown.initialized = false -- Used later on, in initialization
    dropdown.children = opts['children'] or {}

    --- BUG FIX Start: Menu Width
    --- Menu width doesn't dynamically change, at least not easily. To get around this, we find the longest string, pop
    --- it into the dd_title font string, calculate the width with some padding, and set that as our dropdown width.

    -- ShallowCopy the menu_items so we don't accidentally sort the original table.
    local itemsCopy = PDKP.Utils.ShallowCopy(menu_items)

    local table_keys = {} -- We use a header vs button for separation.
    for key, v in pairs(itemsCopy) do
        table.insert(table_keys, key)
    end

    -- Sort the items table by length
    table.sort(table_keys, function(a, b)
        return string.len(a) > string.len(b)
    end)

    -- Grab the longest string from the sorted table
    local longest_item = table_keys[1]

    dd_title:SetText(longest_item);

    local title_padding = 20;
    local dropdown_width = dd_title:GetStringWidth() + title_padding

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    --- End BUG FIX: Menu Width

    -- Dropdown Functions
    dropdown:SetScript("OnShow", showFunc)
    dropdown:SetScript("OnHide", hideFunc)
    dropdown.isValid = function()
        local box_text = UIDropDownMenu_GetSelectedValue(dropdown)
        return dropdown:IsVisible() and box_text ~= nil and box_text ~= "" and box_text ~= 0;
    end

    -- We need to define the initialize function via blizzard's method.
    function PDKP_DropDown_Initialize(self, level)
        level = level or 1;

        if level == 1 then
            for key, _ in pairs(menu_items) do
                local info = UIDropDownMenu_CreateInfo();
                info.hasArrow = true; -- creates submenu
                info.notCheckable = true;
                info.keepShownOnClick = false;
                info.text = key;
                info.value = {
                    ["Level1_Key"] = key;
                };
                UIDropDownMenu_AddButton(info, level);
            end
        end

        if level == 2 then
            -- getting values of first menu
            local Level1_Key = UIDROPDOWNMENU_MENU_VALUE["Level1_Key"];
            local subarray = menu_items[Level1_Key];
            for _, boss_name in pairs(subarray) do
                local info = UIDropDownMenu_CreateInfo();
                info.hasArrow = false; -- no submenues this time
                info.notCheckable = false;
                info.text = boss_name
                info.keepShownOnClick = false;
                info.value = boss_name;
                info.func = function(b)
                    UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                    UIDropDownMenu_SetText(dropdown, b.value)
                    ToggleDropDownMenu(1, nil, dropdown)
                    b.checked = true
                    changeFunc(dropdown, dropdown, b)
                end
                UIDropDownMenu_AddButton(info, level);
            end
        end

        if not dropdown.initialized and default_val and default_val ~= '' then
            dropdown.initialized = true;
            UIDropDownMenu_SetSelectedValue(dropdown, default_val, default_val)
        end
    end

    UIDropDownMenu_Initialize(dropdown, PDKP_DropDown_Initialize, nil);

    -- Attaches this to a global object, if provided.
    if opts['dropdownTable'] then
        dropdown.dropdownTable = opts['dropdownTable']
    end

    return dropdown
end

--- Opts:
---     name (string)
---     parent (Frame)
---     title (string)
---     multi_line (boolean)
---     max_chars (boolean)
---     textValidFunc (Function)
---     numeric (int)
---     small_title (boolean)
---     showOnValue (string)
---     dropdownTable (table)
---
function GUtils:createEditBox(opts)
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
    box:SetParent(parent)
    box:SetHeight(30)
    box:SetWidth(150)
    box:SetFrameStrata("DIALOG")
    box:SetMaxLetters(max_chars)
    box:SetAutoFocus(false)
    box:SetFontObject(GameFontHighlightSmall)
    box:SetMultiLine(multi_line)
    box:SetNumeric(numeric)
    box.uniqueID = name
    box.selectedValue = nil --- Ease of use for combining in dropdowns.

    box.touched = false

    if opts['showOnValue'] then
        box.showOnValue = opts['showOnValue']
    end
    if opts['dropdownTable'] then
        box.dropdownTable = opts['dropdownTable']
    end

    box.isValid = function()
        return box:IsVisible()
                and (name == 'other'
                or (box:IsNumeric() and box:GetNumber() > 0)
                or (not box:IsNumeric() and box:GetText() and box:GetText() ~= ""))
    end
    box.getValue = function()
        if numeric then
            return box:GetNumber()
        end
        return box:GetText()
    end

    box:SetScript("OnEscapePressed", function()
        box:ClearFocus()
    end)
    box:SetScript("OnTextChanged", function()
        box.selectedValue = box.getValue()
        textValidFunc()
    end)
    box:SetScript("OnEditFocusGained", function()
        box.touched = true
    end)

    local box_frame = CreateFrame("Frame", '$parent_edit_frame', box, MODULES.Media.BackdropTemplate)

    box_frame:SetBackdrop({
        bgFile = MODULES.Media.TRANSPARENT_BACKGROUND,
        edgeFile = MODULES.Media.SHROUD_BORDER, tile = true, tileSize = 17, edgeSize = 16,
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

    if box:GetFrameLevel() > 4 then
        box_frame:SetFrameLevel(box:GetFrameLevel() - 4)
    end

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

    -- TODO: Might need to reimplement this later on...
    --GUI.editBoxes[name] = box

    box.frame = box_frame
    box.desc = ed
    box.title = el
    return box
end

--- Opts
---     parent (Frame) - This relies on the caller to set the item in SetItemLink()
function GUtils:createItemLink(parent)
    local fs = parent:CreateFontString(parent, 'OVERLAY', 'GameFontNormalSmall')
    fs:SetNonSpaceWrap(false)
    fs:SetWordWrap(false)
    fs:SetJustifyH('LEFT')

    local f = CreateFrame('Button', nil, parent)
    f:SetAllPoints(fs)

    f:SetScript("OnClick", function()
        -- Calling SetHyperLink on an existing link with the same item, will hide it. Which is a stupid way to handle
        -- hiding it...
        if GameTooltip:GetItem() then
            GameTooltip:SetHyperlink(fs.iLink)
        else
            GameTooltip:SetOwner(fs, "ANCHOR_NONE");
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetPoint("TOP", fs, "BOTTOM", 0, -20);
            GameTooltip:SetHyperlink(fs.iLink)
        end
    end)

    -- ItemID, ItemName or ItemLink
    fs.SetItemLink = function(itemIdentifier)
        -- TODO: Find out if we need all of this, or if it can be nullified.

        -- Call instant first, since it assures that we'll get the item info.
        local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(itemIdentifier)

        -- Then call the actual item info, so we can get the texture, and link.
        local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, _, _, itemStackCount, _, itemTexture,
        itemSellPrice = GetItemInfo(itemIdentifier)

        if not itemLink then
            return
        end

        fs:SetText(itemLink)
        fs.iLink = itemLink
        if fs.icon then
            fs.icon:SetTexture(itemTexture)
        end

        return fs.iLink, itemTexture
    end

    return fs
end