local _G = _G;
local PDKP = _G.PDKP

local Setup, Media, Raid, DKP, Util, Comms, Guild, Defaults, ScrollTable, Char = PDKP:GetInst('Setup', 'Media', 'Raid', 'DKP', 'Util', 'Comms', 'Guild', 'Defaults', 'ScrollTable', 'Character')
local GUI, Settings, Loot, HistoryTable, SimpleScrollFrame, Shroud, Dev, Bid = PDKP:GetInst('GUI', 'Settings', 'Loot', 'HistoryTable', 'SimpleScrollFrame', 'Shroud', 'Dev', 'Bid')

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
    border:SetBackdropColor(unpack(Media.PaneColor))
    border:SetBackdropBorderColor(unpack(Media.PaneBorderColor))

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

--- Opts:
---     name (string)
---     parent (Frame)
---     title (string)
---     multi_line (boolean)
---     max_chars (boolean)
---     textValidFunc (Function)
---     numeric (int)
---     small_title (boolean)
---
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
    box:SetNumeric(numeric)
    box.uniqueID = name

    box.touched = false

    box.isValid = function()
        if not box:IsVisible() then return false end
        if name == 'other' then return true end

        if box:IsNumeric() then
            return box:GetNumber() > 0
        else
            return box:GetText() and box:GetText() ~= ''
        end
        return false
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
        else
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

    GUI.editBoxes[name] = box

    box.frame = box_frame
    box.desc = ed
    box.title = el
    return box
end

local function createItemLink(parent)
    local fs = parent:CreateFontString(parent, 'OVERLAY', 'GameFontNormalSmall')
    fs:SetNonSpaceWrap(false)
    fs:SetWordWrap(false)
    fs:SetJustifyH('LEFT')

    local f = CreateFrame('Button', nil, parent)
    f:SetAllPoints(fs)

    f:SetScript("OnClick", function()
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
        local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(itemIdentifier)
        local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, _, _, itemStackCount, _, itemTexture,
        itemSellPrice = GetItemInfo(itemIdentifier)

        if not itemLink then return end

        fs:SetText(itemLink)
        fs.iLink = itemLink
        if fs.icon then
            fs.icon:SetTexture(itemTexture)
        end

        return fs.iLink, itemTexture
    end

    return fs
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

    for _, t in pairs(textures) do createTextures(t) end

    f:SetPoint("TOP", 0, 0)

    setMovable(f)

    --- Close button
    local b = createCloseButton(f, false)
    b:SetSize(22, 25) -- width, height
    b:SetPoint("TOPRIGHT", -2, -10)

    local addon_title = f:CreateFontString(f, "Overlay", "BossEmoteNormalHuge")
    addon_title:SetText(Util:FormatTextColor('PantheonDKP', Defaults.addon_hex))
    addon_title:SetSize(200, 25)
    addon_title:SetPoint("CENTER", f, "TOP", 0, -28)
    addon_title:SetScale(0.9)

    --- Addon Version
    local addon_version = f:CreateFontString(f, "Overlay", "GameFontNormalSmall")
    addon_version:SetSize(50, 14)
    addon_version:SetText(Util:FormatTextColor("v" .. Defaults.addon_version, Media.addon_version_hex))
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
        Setup.Options,
        Setup.DKPAdjustments,
        Setup.PDKPTabs,
        Setup.BidBox,

        --- Unfinished Functions
        Setup.Debugging, Setup.EasyStats,
        Setup.RaidDropdown, Setup.DKPHistory, Setup.RaidTools, Setup.InterfaceOptions, Setup.PushProgressbar,
        Setup.HistoryTable, Setup.DKPOfficer, Setup.SyncStatus
    }

    for i, func in ipairs(randomFuncs) do
        if func then
            func()
        end
    end
end

function Setup:Options()

    local test = false

    local option_types = {
        'group', 'toggle',
    }


    local options = {
        {
            ['name'] = 'notifications',
            ['title'] = '1. Notifications',
            ['type'] = 'toggle',
            ['desc'] = 'Enables / Disables all messages from the addon.',
            ['value'] = true,
        },
        {
            ['name'] = 'sync',
            ['title'] = '2. Allow DKP syncs to occur in:',
            ['desc'] = 'These options only control when a DKP merge-push is allowed to occur. This will not affect DKP updates that occur during a raid.',
            ['type'] = 'group',
            ['values'] = {
                ['pvp'] = {
                    ['name']='Battlegrounds',
                    ['desc'] = 'Enable / Disable sync while in Battlegrounds',
                    ['type'] = 'toggle',
                    ['value'] = true,
                },
                ['raids'] = {
                    ['name'] = 'Raids',
                    ['desc'] = 'Enable / Disable sync while in Raid Instances',
                    ['type'] = 'toggle',
                    ['value'] = true,
                },
                ['dungeons'] = {
                    ['name'] = 'Dungeons',
                    ['desc'] = 'Enable / Disable sync while in Dungeon Instances',
                    ['type'] = 'toggle',
                    ['value'] = true,
                },
            }
        },
        {
            ['name'] = 'admin',
            ['title'] = '3. Addon Debugging',
            ['type'] = 'toggle',
            ['desc'] = 'Enables / Disables addon debugging messages. Pretty much only use this if Neekio tells you to.',
            ['value'] = false,
        }
    }

    local f = CreateFrame("Frame", "$parentOptionsFrame", pdkp_frame, BackdropTemplateMixin and "BackdropTemplate")

    f:SetHeight(400)
    f:SetWidth(300)

    f:SetPoint("TOPLEFT", PDKP.memberTable.frame, "TOPRIGHT", 0, 0)
    f:SetPoint("BOTTOMLEFT", GUI.filter_frame, "BOTTOMRIGHT", 0, 0)

    local opt_frames = {}

    local function generate_option_check(opt, optFrame)
        local cb_parent = optFrame.content
        local cb_name = optFrame:GetName() .. 'CheckButton_' .. opt['name']
        local cb_point = "TOPLEFT"
        local cb_display_text = 'Enable ' .. opt['name']

        local val = opt['value']

        local cb = createCheckButton(cb_parent, cb_point, 0, 0, cb_display_text, cb_name, false, val)

        local cb_desc = cb:CreateFontString(cb, 'OVERLAY', 'GameFontHighlightSmall')
        cb_desc:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 5, 0)
        cb_desc:SetPoint("TOPRIGHT", cb_parent, "RIGHT", 0, 0)
        cb_desc:SetJustifyH("LEFT")

        cb_desc:SetText(opt['desc'])

        cb.desc = cb_desc

        table.insert(optFrame.buttons, cb)

        return cb
    end

    for index, opt in pairs(options) do
        local opt_name = "$parentOption" .. opt['name']

        -- name, parent, title
        local optFrame = createBackdropFrame(opt_name, f, opt['title'])
        optFrame:SetHeight(200)
        optFrame:SetWidth(200)

        optFrame.buttons = {}

        -- Set the first index position, based on the frame, and subsequent ones based on previous indexes.
        if index == 1 then
            optFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -15)
            optFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
        else
            optFrame:SetPoint("TOPLEFT", opt_frames[index -1], "BOTTOMLEFT", 0, 0)
            optFrame:SetPoint("TOPRIGHT", opt_frames[index -1], "BOTTOMRIGHT", 0, 0)
        end

        if opt['type'] == 'group' and opt['values'] ~= nil then
            local opt_val_index = 1
            for _, opt_val in pairs(opt['values']) do
                local cb_btn = generate_option_check(opt_val, optFrame)

                if opt_val_index > 1 then
                    local opt_btn = optFrame.buttons[opt_val_index]
                    local prev_btn = optFrame.buttons[opt_val_index - 1]
                    opt_btn:SetPoint("TOPLEFT", prev_btn.desc, "BOTTOMLEFT", -5, -10)
                end

                local cb_title = _G[optFrame.buttons[#optFrame.buttons]:GetName() .. 'Text']
                cb_title:SetPoint('LEFT', cb_btn, 'RIGHT', 0, 0)

                opt_val_index = opt_val_index + 1
            end
        elseif opt['type'] == 'toggle' then
            generate_option_check(opt, optFrame)
        end

        if #optFrame.buttons >= 1 then
            local top = optFrame:GetTop()
            local last_btn = optFrame.buttons[#optFrame.buttons]
            local bot = last_btn.desc:GetBottom()
            local padding = 15

            local diff = top - bot

            optFrame:SetHeight(diff + padding)
        end

        if not PDKP.canEdit and index == 3 then
            _G[optFrame:GetName()] = nil
            optFrame:Hide()
        else
            opt_frames[index] = optFrame
        end

    end

    if test then
        if Settings:CanEdit() then
            options.args.adminGroup = {
                name='3. Officer',
                type="group",
                inline= true,
                args = {
                    debugging = {
                        name = "Addon Debugging",
                        type = "toggle",
                        desc="Enables / Disables addon debugging messages. Pretty much only use this if Neekio tells you to.",
                        set = function(_,val) return Settings:GetSetInterface('set', 'debug', val) end,
                        get = function() return Settings:GetSetInterface('get', 'debug', nil) end

                    },
                }
            }
        end
    end


    GUI.optionsFrame = f
end

--------------------------
-- Random     Functions --
--------------------------

function Setup:BidBox()
    local title_str = Util:FormatTextColor('PDKP Active Bids', Defaults.addon_hex)

    local f = CreateFrame("Frame", "pdkp_bid_frame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    f:SetWidth(256)
    f:SetHeight(256)
    f:SetPoint("CENTER")
    setMovable(f)

    f:SetScript("OnShow", function()
        f.dkp_title:SetText('Total DKP: ' .. Char:GetMyDKP())
    end)

    local sourceWidth, sourceHeight = 256, 512
    local startX, startY, width, height = 0, 0, 216, 277

    local texCoords = {
        startX / sourceWidth,
        (startX + width) / sourceWidth,
        startY / sourceHeight,
        (startY+height) / sourceHeight
    }

    local tex = f:CreateTexture(nil, 'BACKGROUND')
    tex:SetTexture(Media.BID_FRAME)

    tex:SetTexCoord(unpack(texCoords))
    tex:SetAllPoints(f)

    local title = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    title:SetText(title_str)
    title:SetPoint("CENTER", f, "TOP", 25, -22)

    local dkp_title = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    dkp_title:SetPoint("TOP", title, "BOTTOM", -5, -25)

    local bid_counter_frame = CreateFrame('Frame', nil, f)
    local bid_tex = bid_counter_frame:CreateTexture(nil, 'BACKGROUND')
    bid_counter_frame:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, 0)
    bid_counter_frame:SetSize(78, 64)

    --- To visualize the frame's position, uncomment this.
    --bid_counter_frame:SetAlpha(0.5)
    --bid_tex:SetTexture(Media.PDKP_BG)
    --bid_tex:SetAllPoints(bid_counter_frame)

    local bid_counter = bid_counter_frame:CreateFontString(bid_counter_frame, 'OVERLAY', 'BossEmoteNormalHuge')
    bid_counter:SetText("0")
    bid_counter:SetPoint("CENTER", bid_counter_frame, "CENTER")
    bid_counter:SetPoint("TOP", bid_counter_frame, "CENTER", 0, 10)

    local close_btn = createCloseButton(f, true)
    close_btn:SetSize(24, 22)
    close_btn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -10)

    local sb = CreateFrame("Button", "$parent_submit", f, "UIPanelButtonTemplate")
    sb:SetSize(80, 22) -- width, height
    sb:SetText("Submit Bid")
    sb:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 10)
    sb:SetScript("OnClick", function()
        local bid_amt = f.bid_box.getValue()
        f.current_bid:SetText(bid_amt)

        --TODO: Submit this to the Bid Manager/Comms
    end)
    sb:SetEnabled(false)

    local cb = CreateFrame("Button", "$parent_submit", f, "UIPanelButtonTemplate")
    cb:SetSize(80, 22) -- width, height
    cb:SetText("Cancel Bid")
    cb:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 28, 10)
    cb:Hide()
    cb:SetEnabled(false)
    cb:SetScript("OnClick", function()
        -- TODO: Setup Cancel logic
        Dev:Print("Cancel this shit yo")
        f.current_bid:SetText("")
        f.cancel_btn:SetEnabled(false)
        f.cancel_btn:Hide()
    end)
    cb:SetScript("OnShow", function()
        if f.current_bid.getValue() > 0 then
            f.submit_btn:SetText("Update Bid")
        else
            f.submit_btn:SetText("Submit Bid")
        end
    end)
    cb:SetScript("OnHide", function()
        f.submit_btn:SetText("Submit Bid")
    end)

    local item_icon = f:CreateTexture(nil, 'OVERLAY')
    item_icon:SetSize(46, 35)
    item_icon:SetPoint("LEFT", f, "LEFT", 32, 21)

    local item_link = createItemLink(f)
    item_link:SetPoint("LEFT", item_icon, "RIGHT", 5, 0)
    item_link:SetWidth(150)

    item_link.icon = item_icon

    -- TODO: Cleanup this dev stuff.
    --local ateish = 22589
    --local kingsfall = 22802
    --local blade = 17780
    --local edge = 14551
    --local test_item_id = kingsfall

    local bid_box_opts = {
        ['name'] = 'bid_input',
        ['parent'] = f,
        ['title'] = 'Bid Amount',
        ['multi_line'] = false,
        ['max_chars'] = 5,
        ['textValidFunc'] = function(box)
            local box_val = box.getValue()
            local curr_bid_val = f.current_bid.getValue()
            if box_val and box_val < Char:GetMyDKP() and box_val > 0 and box_val ~= curr_bid_val then
                return sb:SetEnabled(true)
            end
            return sb:SetEnabled(false)
        end,
        ['numeric'] = true,
        ['small_title'] = false,
    }
    local bid_box = createEditBox(bid_box_opts)
    bid_box:SetWidth(80)
    bid_box:SetPoint("LEFT", f, "LEFT", 45, -35)
    bid_box.frame:SetFrameLevel(bid_box:GetFrameLevel() - 2)
    bid_box:SetScript("OnTextSet", function()
        local val = bid_box.getValue()
        f.submit_btn.isEnabled = val > 0
        f.submit_btn:SetEnabled(f.submit_btn.isEnabled)
    end)

    local current_bid_opts = {
        ['name'] = 'display_bid',
        ['parent'] = f,
        ['title'] = 'Pending Bid',
        ['multi_line'] = false,
        ['max_chars'] = 5,
        ['textValidFunc'] = nil,
        ['numeric'] = true,
        ['small_title'] = false,
    }
    local current_bid = createEditBox(current_bid_opts)
    current_bid:SetWidth(80)
    current_bid:SetPoint("LEFT", bid_box, "RIGHT", 15, 0)
    current_bid.frame:SetFrameLevel(current_bid:GetFrameLevel() - 2)
    current_bid:SetEnabled(false)
    current_bid.frame:SetBackdrop(nil)
    current_bid:SetScript("OnTextSet", function()
        local val = current_bid.getValue()
        f.cancel_btn.isEnabled = val > 0
        f.cancel_btn:SetEnabled(f.cancel_btn.isEnabled)
        f.bid_box:SetText(0)

        if f.cancel_btn.isEnabled then
            f.cancel_btn:Show()
        else
            f.cancel_btn:Hide()
        end
    end)

    tinsert(UISpecialFrames, f:GetName())

    f.current_bid = current_bid
    f.bid_box = bid_box
    f.item_link = item_link
    f.submit_btn = sb
    f.cancel_btn = cb
    f.bid_counter = bid_counter
    f.dkp_title = dkp_title

    GUI.bid_frame = f

    f:Hide()


    --local item_title = f.content:CreateFontString(f.content, "OVERLAY", 'GameFontNormal')
    --item_title:SetPoint("TOPLEFT")
    --
    --local test_bid_item = '|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r'
    --
    --local bid_title = Util:FormatTextColor('Item: ', Defaults.addon_hex)
    --
    --print(bid_title)
    --
    --item_title:SetText(bid_title .. ' ' .. test_bid_item)
    --
    --local scroll = SimpleScrollFrame:new(f.content)
    --local scrollFrame = scroll.scrollFrame
    --local scrollContent = scrollFrame.content;
    --
    --local cb = createCloseButton(f, true)
    --cb:SetPoint("TOPRIGHT")
    --
    --cb:SetScript("OnClick", function()
    --    f:Hide()
    --    -- TODO: Hook this up
    --    --if Raid:IsDkpOfficer() then Comms:SendCommsMessage('pdkpClearShrouds', {}, 'RAID', nil, nil, nil) end
    --end)
    --
    --f.scrollContent = scrollContent;
    --f.scroll = scroll;
    --f.scrollFrame = scrollFrame;

    --local shroud_events = {'CHAT_MSG_RAID', 'CHAT_MSG_RAID_LEADER'}
    --for _, eventName in pairs(shroud_events) do f:RegisterEvent(eventName) end
    --f:SetScript("OnEvent", PDKP_Shroud_OnEvent)

    Bid.frame = f;
end

function Setup:DKPAdjustments()
    local f = CreateFrame("Frame", "$parent_adjustment_frame", pdkp_frame, BackdropTemplateMixin and "BackdropTemplate")

    -- todo: TBC UPDATE CHANGE REQUIRED
    --f:SetBackdrop({
    --    tile = true, tileSize = 0,
    --    edgeFile = Media.SCROLL_BORDER, edgeSize = 8,
    --    insets = { left = 4, right = 4, top = 4, bottom = 4 },
    --})
    f:SetHeight(225)
    f:SetPoint("TOPLEFT", PDKP.memberTable.frame, "TOPRIGHT", -3, -10)
    f:SetPoint("BOTTOMRIGHT", pdkp_frame, "BOTTOMRIGHT", -10,-50)

    local adjustHeader = f:CreateFontString(f, "OVERLAY", 'GameFontNormalLarge')
    adjustHeader:SetText("DKP Adjustments")
    adjustHeader:SetPoint("CENTER", f, "TOP", 0, -5)

    local mainDD, amount_box, other_box;

    --- Main Dropdown

    local reason_opts = {
        ['name']='reasons',
        ['parent']=f,
        ['title']='Reason',
        ['items']= {'On Time Bonus', 'Completion Bonus', 'Boss Kill', 'Unexcused Absence', 'Item Win', 'Other'},
        ['defaultVal']='',
        ['dropdownTable']=GUI.adjustmentDropdowns,
        ['changeFunc']=PDKP_ToggleAdjustmentDropdown
    }

    mainDD = createDropdown(reason_opts)
    mainDD:SetPoint("TOPLEFT", f, "TOPLEFT", -3, -50)


    --- Bosses section

    --for raid, _ in pairs(Defaults.raidBosses) do
    --    local boss_opts = {
    --        ['name']='boss_' .. raid,
    --        ['parent']=mainDD,
    --        ['title']='Boss',
    --        ['hide']=true,
    --        ['dropdownTable']=GUI.adjustmentDropdowns,
    --        ['showOnValue']=raid,
    --        ['changeFunc']=PDKP_ToggleAdjustmentDropdown,
    --        ['items']=Defaults.raidBosses[raid],
    --    }
    --    local bossDD = createDropdown(boss_opts)
    --    bossDD:SetPoint("LEFT", mainDD, "RIGHT", -20, 0)
    --end

    --- Amount section
    local amount_opts = {
        ['name']='amount',
        ['parent']=mainDD,
        ['title']='Amount',
        ['multi']=false,
        ['max_chars']=7,
        ['numeric']=true,
        ['textValidFunc']=PDKP_ToggleAdjustmentDropdown
    }
    amount_box = createEditBox(amount_opts)

    amount_box.frame:SetWidth(75)
    amount_box:SetWidth(60)
    amount_box:SetPoint("TOPLEFT", mainDD, "BOTTOMLEFT", 25, -20)

    --- Other Edit Box Section

    local other_opts = {
        ['name']= 'other',
        ['parent']= mainDD,
        ['title']='Other',
        ['multi']=true,
        ['numeric']=false,
        ['textValidFunc']=PDKP_ToggleAdjustmentDropdown
    }
    other_box = createEditBox(other_opts)
    other_box:SetPoint("LEFT", mainDD, "RIGHT", 20, 0)
    other_box:Hide()

    --- Submit button
    local sb = CreateFrame("Button", "$parent_submit", f, "UIPanelButtonTemplate")
    sb:SetSize(80, 22) -- width, height
    sb:SetText("Submit")
    sb:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 4, -22)
    sb:SetScript("OnClick", function()
        if GUI.adjustment_entry['shouldHaveItem'] then
            local item_frame = Loot.frame:getChecked()
            if item_frame then
                if item_frame['item_info'] ~= nil then
                    GUI.adjustment_entry['item'] = item_frame.item_info['link']
                    item_frame.deleted = true
                    item_frame:Hide()
                end
            end
        end

        DKP:Submit()
        other_box:SetText("")
        amount_box:SetText("")
        other_box:ClearFocus()
        amount_box:ClearFocus()

        --PDKP_ToggleAdjustmentDropdown()
    end)
    sb.canSubmit = false
    sb.toggle = function()
        if sb.canSubmit then sb:Enable() else sb:Disable() end
    end
    sb:Disable()

    GUI.adjustment_submit_button = sb

    --- Minimum Bid button
    local minimum_bid = CreateFrame("Button", "$parent_shroud", f, "UIPanelButtonTemplate")
    minimum_bid:SetSize(75, 25)
    minimum_bid:SetText("Min Bid")
    minimum_bid:SetPoint("TOPLEFT", amount_box, "BOTTOMLEFT", -10, -10)
    minimum_bid:SetScript("OnClick", function()
        local amount = 1
        amount_box:SetText("-" .. amount)
    end)

    GUI.adjust_buttons = {shroud, roll}

    mainDD:Show()

    --- Boss Loot Section
    --Setup:LootFrame(f)

    if not PDKP.canEdit then f:Hide() end

    GUI.adjustment_frame = f;
end

function Setup:PDKPTabs()
    local f = CreateFrame("Frame", "$parentRightFrame", pdkp_frame, BackdropTemplateMixin and "BackdropTemplate")
    f:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = Media.SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    f:SetHeight(500)
    f:SetWidth(395)
    f:SetPoint("TOPLEFT", PDKP.memberTable.frame, "TOPRIGHT", 0, 0)
    f:SetPoint("BOTTOMLEFT", GUI.filter_frame, "BOTTOMRIGHT", 0, 0)

    local tabs = {
        ['adjust_dkp_button'] = {
            ['parent'] = f,
            ['text'] = 'Adjust DKP',
            ['hides'] = { GUI.optionsFrame },
            ['shows'] = {GUI.adjustment_frame},
        },
        ['view_history_button'] = {
            ['parent'] = f,
            ['text'] = 'History',
            ['hides'] = { GUI.adjustment_frame, GUI.optionsFrame },
            ['shows'] = {},
        },
        ['view_loot_button'] = {
            ['parent'] = f,
            ['text'] = 'Loot',
            ['hides'] = { GUI.adjustment_frame, GUI.optionsFrame },
            ['shows'] = {},
        },
        ['view_lockouts_button'] = {
            ['parent'] = f,
            ['text'] = 'Lockouts',
            ['hides'] = { GUI.adjustment_frame },
            ['shows'] = { GUI.optionsFrame },
        },
        ['view_options_button'] = {
            ['parent'] = f,
            ['text'] = 'Options',
            ['hides'] = { GUI.adjustment_frame },
            ['shows'] = { GUI.optionsFrame },
        },
    }

    local tabNames = { 'view_history_button', 'view_loot_button', 'view_options_button' }

    Dev:Print("PDKP.canEdit", PDKP.canEdit)

    if PDKP.canEdit then
        tabNames = {'adjust_dkp_button', unpack(tabNames)}
    end

    local tab_buttons = {}

    for i = 1, #tabNames do
        local name = tabNames[i]
        local btn = tabs[name]

        local b = CreateFrame("Button", "$parent_" .. name, btn['parent'])
        b:SetSize(100, 30)
        b.hides = btn['hides']
        b.shows = btn['shows']

        if i == 1 then
            b:SetPoint("BOTTOMLEFT", btn['parent'], "TOPLEFT", 0, 0)
        else
            b:SetPoint("TOPLEFT", tab_buttons[i - 1], "TOPRIGHT", 0, 0)
            b:SetAlpha(0.5)
        end

        b:SetNormalTexture("Interface\\CHATFRAME\\ChatFrameTab")
        b:SetScript("OnClick", function()

            for _, frame in pairs(b.hides) do
                frame:Hide()
            end
            for _, frame in pairs(b.shows) do
                frame:Show()
            end
        end)

        local b_text = b:CreateFontString(b, 'OVERLAY', 'GameFontNormalLeft')
        b_text:SetPoint("CENTER", 0, -5)
        b_text:SetText(btn['text'])

        b:SetWidth(b_text:GetWidth() + 40)

        GUI[name] = b
        tab_buttons[i] = b
    end

    for key, b in pairs(tab_buttons) do
        b:SetScript("OnClick", function()
            for _, frame in pairs(b.hides) do
                frame:Hide()
            end
            for _, frame in pairs(b.shows) do
                frame:Show()
            end
            for _, tab_button in pairs(tab_buttons) do
                if tab_button ~= b then
                    tab_button:SetAlpha(0.5)
                else
                    tab_button:SetAlpha(1.0)
                end
            end
        end)

        if key == 1 then
            b:Click()
        end
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
            { ['point'] = 'TOPLEFT', ['x'] = 15, ['y'] = -20, ['displayText'] = 'Online', ['filterOn'] = 'online', ['enabled'] = false },
            { ['point'] = 'TOPLEFT', ['x'] = 30, ['y'] = 0, ['displayText'] = 'In Raid', ['filterOn'] = 'raid', ['enabled'] = false },
            { ['point'] = 'TOPLEFT', ['x'] = 30, ['y'] = 0, ['displayText'] = 'Pug', ['filterOn'] = 'isPug', ['enabled'] = false },
            { ['point'] = 'TOPLEFT', ['x'] = 30, ['y'] = 0, ['displayText'] = 'Select All', ['filterOn'] = 'Select_All', ['enabled'] = false },
        },
        { -- Row 2
            { ['point'] = 'TOPLEFT', ['x'] = 0, ['y'] = 0, ['displayText'] = 'All Classes', ['filterOn'] = 'Class_All',
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
        if key >= 4 and key <= 6 then
            class_row = 4
        elseif key >= 7 then
            class_row = 5
        end
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
            if rowKey >= 2 then
                cb:ClearAllPoints();
            end

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

    eb:SetScript("OnEscapePressed", function()
        resetSearch()
    end)
    eb:SetScript("OnEnterPressed", function()
        resetSearch()
    end)
    eb:SetScript("OnTextChanged", function()
        local text = eb:GetText()
        toggleClearButton(text)
        PDKP.memberTable:SearchChanged(text)
    end)
    eb:SetScript("OnEditFocusLost", function()
        toggleClearButton(eb:GetText())
    end)
    eb:SetScript("OnEditFocusGained", function()
        toggleClearButton(eb:GetText())
    end)

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