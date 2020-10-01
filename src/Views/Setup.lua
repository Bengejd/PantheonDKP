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
local Loot = core.Loot;
local HistoryTable = core.HistoryTable;
local SimpleScrollFrame = core.SimpleScrollFrame;

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
local CHAR_INFO_TEXTURE = 'Interface\\CastingBar\\UI-CastingBar-Border-Small'

local adoon_version_hex = '0059c5'

local PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local paneColor = {0.1, 0.1, 0.1, 0.5}
local paneBorderColor = {0.4, 0.4, 0.4}

local filterButtons = {};

local pi = math.pi

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

    if title then title_text:SetText(title) end

    local border = CreateFrame("Frame", nil, f)
    border:SetPoint("TOPLEFT", 0, -17)
    border:SetPoint("BOTTOMRIGHT", -1, 3)

    border:SetBackdrop(PaneBackdrop)
    border:SetBackdropColor(unpack(paneColor))
    border:SetBackdropBorderColor(unpack(paneBorderColor))

    local content = CreateFrame("Frame", nil, border)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    f.border = border
    f.content = content
    return f
end

local function createIcon(parent, label_text)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(30, 30)
    local l = f:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
    l:SetPoint("BOTTOM", 0, -15)

    if label_text then l:SetText(label_text) end

    local icon = f:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(25, 25)
    icon:SetAllPoints(f)

    f.icon = icon
    f.label = l

    return f
end

local function createCloseButton(f, mini)
    local template = mini and 'pdkp_miniButton' or 'UIPanelButtonTemplate'
    local b = CreateFrame("Button", '$parentCloseButton',  f, template)
    b:SetText(CLOSE_BUTTON_TEXT)
    b:SetParent(f)
    b:SetScript("OnClick", function(self) self:GetParent():Hide() end)
    return b
end

function Setup:CreateCloseButton(f, mini)
    return createCloseButton(f, mini)
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
    local showFunc = opts['showFunc'] or function() end
    local hideFunc = opts['hideFunc'] or function() end
    local change_func = opts['changeFunc'] or function (dropdown_val) end


    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    dropdown.uniqueID = opts['name']
    dropdown.showOnValue = opts['showOnValue'] or 'Always'
    local dropdown_width = 0;
    dropdown.initialized = false

    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
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

    if hide then dropdown:Hide() end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()

        for key, val in pairs(menu_items) do
            info.text = val;
            info.checked = false
            info.menuList= key
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

    if opts['dropdownTable'] then opts['dropdownTable'][opts['name']]=dropdown end

    return dropdown
end

local function createEditBox(opts)
    local name = opts['name'] or 'edit_box'
    local parent = opts['parent'] or pdkp_frame
    local box_label_text = opts['title'] or ''
    local multi_line = opts['multi']
    local max_chars = opts['max_chars'] or 225
    local textValidFunc = opts['textValidFunc'] or function() end
    local numeric = opts['numeric'] or false

    local box = CreateFrame("EditBox", "$parent_" .. name, parent)
    box:SetHeight(30)
    box:SetWidth(150)
    box:SetFrameStrata("DIALOG")
    box:SetMaxLetters(max_chars)
    box:SetAutoFocus(false)
    box:SetFontObject(GameFontHighlightSmall)
    box:SetMultiLine(multi_line)

    box.isValid = function()
        if box:IsVisible() then
            local box_text = box:GetText()
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

    box:SetScript("OnEscapePressed", function() box:ClearFocus() end)
    box:SetScript("OnTextChanged", function()
        if box.isValid() then textValidFunc(box) end
    end)

    local box_frame = CreateFrame("Frame", '$parent_edit_frame', box)
    box_frame:SetBackdrop( {
        bgFile = TRANSPARENT_BACKGROUND,
        edgeFile = SHROUD_BORDER, tile = true, tileSize = 17, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    });
    box_frame:SetWidth(170)

    if multi_line then
        box_frame:SetPoint("TOPLEFT", box, "TOPLEFT", -10, 10)
        box_frame:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", 10, -15)
        box_frame:SetHeight(50)
    else
        box_frame:SetPoint("TOPLEFT", box, "TOPLEFT", -10, 0)
        box_frame:SetHeight(30)
    end

    box_frame:SetFrameLevel(box:GetFrameLevel() - 4)

    -- label
    local el = box:CreateFontString(box_frame, "OVERLAY", 'GameFontNormal')
    el:SetText(box_label_text)
    el:SetPoint("TOPLEFT", box_frame, "TOPLEFT", 5, 10)

    GUI.editBoxes[name]=box

    box.frame = box_frame
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

    --- Close button

    local b = createCloseButton(f, false)
    b:SetSize(22, 25) -- width, height
    b:SetPoint("TOPRIGHT", -2, -10)

    local addon_title = f:CreateFontString(f, "Overlay", "BossEmoteNormalHuge")
    addon_title:SetText("PantheonDKP")
    addon_title:SetSize(200, 25)
    addon_title:SetPoint("CENTER", f, "TOP", 0, -25)

    --- Addon Version
    local addon_version = f:CreateFontString(f, "Overlay", "GameFontNormalSmall")
    addon_version:SetSize(50, 14)
    addon_version:SetText(Util:FormatFontTextColor(adoon_version_hex, "v" .. Settings:GetAddonVersion()))
    addon_version:SetPoint("RIGHT", b, "LEFT", 0, -3)

    local easy_stats = f:CreateTexture('pdkp_easy_stats', 'OVERLAY')
    easy_stats:SetTexture(CHAR_INFO_TEXTURE)
    easy_stats:SetSize(240, 72)
    easy_stats:SetPoint("TOPLEFT", f, "TOPLEFT", 65, -25)
    easy_stats:SetTexCoord(0, 1, 1, 0)

    local easy_stats_text = f:CreateFontString(f, "OVERLAY", "GameFontNormalLeftYellow")
    easy_stats_text:SetSize(175, 20)
    easy_stats_text:SetPoint("LEFT", easy_stats, "LEFT", 35, 0)

    f.easy_stats = easy_stats
    f.easy_stats.text = easy_stats_text
    f.addon_title = addon_title
    f.addon_version = addon_version

    pdkp_frame = f

    tinsert(UISpecialFrames,f:GetName())

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

    local buttons = {
        ['reload']=function()
            ReloadUI()
        end,
        ['show']=function()
            GUI:Show()
        end,
        ['hide']=function()
            GUI:Hide()
        end,
        ['debug']=function()
            Settings:ToggleDebugging()
        end,
        ['shroud']=function()
            DKP:TestShroud()
        end,
        ['roll']=function()
            DKP:TestShroud()
        end,
        ['reset DKP']=function()
            DKP:ResetDKP()
        end,
        ['compressString']=function()
            local testTime = 1600749114
            local encoded_time, compressed_time, serialized_time = Comms:DataEncoder(testTime)
            print(testTime)
            print(encoded_time)
            print(compressed_time)
            print(serialized_time)
        end,
        ['boss kill']=function()
            local boss_info = Raid:TestBossKill()
            print(boss_info['name'], boss_info['id'], boss_info['raid'])
        end,
        ['memory']=function()
            Util:ReportMemory()
        end
    }
    local button_counter_x = 1
    local button_counter_y = 1
    local button_counter = 1
    for name, func in pairs(buttons) do
        local db = CreateFrame("Button", nil, f, "UiPanelButtonTemplate")

        db:SetHeight(22)
        db:SetText(name)

        local width = db:GetTextWidth() + 10
        if width < 80 then width = 80 end

        db:SetWidth(width)

        db:SetScript("OnClick", func)

        pos_x = 10
        pos_y = -25

        pos_y = pos_y * button_counter

        db:SetPoint("TOPLEFT", f, "TOPLEFT", pos_x, pos_y)

        button_counter = button_counter + 1
    end

    if not Settings:IsDebug() then f:Hide() end
end

function Setup:RandomStuff()
    --Setup:ShroudingBox()
    Setup:Debugging()

    Setup:ScrollTable()
    Setup:Filters()
    Setup:DKPAdjustments()
    Setup:RaidDropdown()
    --Setup:BossKillLoot()
    --Setup:TabView()
    Setup:DKPHistory()
    Setup:RaidTools()
    local scroll_frame = Setup:HistoryTable()

    -- TODO: Use Interface\Buttons\UI-TotemBar and texCoords for the expand / collapse buttons.
end

function Setup:RaidTools()
    local f = CreateFrame("Frame", 'pdkp_raid_frame', RaidFrame, 'BasicFrameTemplateWithInset')
    f:SetSize(300, 425)
    f:SetPoint("LEFT", RaidFrame, "RIGHT", 0, 0)
    f.title = f:CreateFontString(nil, "OVERLAY")
    f.title:SetFontObject("GameFontHighlight")
    f.title:SetPoint("CENTER", f.TitleBg, "CENTER", 11, 0)
    f.title:SetText("PDKP Raid Interface")
    f:SetFrameStrata("HIGH")
    f:SetFrameLevel(1)
    f:SetToplevel(true)

    local b = CreateFrame("Button", 'pdkp_raid_frame_button', RaidFrame, 'UIPanelButtonTemplate')
    b:SetHeight(30)
    b:SetWidth(80)
    b:SetText("Raid Tools")
    b:SetPoint("TOPRIGHT", RaidFrame, "TOPRIGHT", 80, 0)
    b:SetScript("OnClick", function()
        if f:IsVisible() then f:Hide() else f:Show() end

        --if Raid.spamText == nil and raidSpamTime ~= nil then
        --    raidSpamTime:SetText("[TIME] [RAID] invites going out. Pst for invite")
        --    Raid.spamText = raidSpamTime:GetText()
        --end
    end)

    f.content = CreateFrame("Frame", '$parent_content', f)
    f.content:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -28)
    f.content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)
    f.content:SetSize(f:GetWidth(), f:GetHeight())

    ----- SimpleScrollFrame
    local scroll = SimpleScrollFrame:new(f.content)
    local scrollFrame = scroll.scrollFrame
    local scrollContent = scrollFrame.content;


    --- Class Group Section

    local class_group = createBackdropFrame(nil, scrollContent, 'Raid Breakdown')
    class_group:SetHeight(170)
    scrollContent:AddChild(class_group)

    local classTexture = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"

    -- TODO: Attach Dead Counter to CompactRaidFrameContainerBorderFrame using Interface\ICONS\INV_Misc_Bone_HumanSkull_01 or Interface\Durability\DeathRecap with TexCoords?
    -- TODO: Create MasterLooter using Interface\ICONS\INV_Crate_05 as ICONS or Interface\ICONS\INV_Box_03
    -- TODO: Create DKP Officer using Interface\ICONS\INV_MISC_Coin_01 as ICONS

    class_group.class_icons = {}
    local icon_classes = {'Total','Tank', unpack(Defaults.classes)}
    for key, class in pairs(icon_classes) do
        local i_frame = createIcon(class_group.content, '0')
        i_frame.class = class

        local previous_frame;
        if key > 1 then
            previous_frame = class_group.class_icons[icon_classes[key-1]]
        elseif key > 7 then
            previous_frame = class_group.class_icons[icon_classes[key-6]]
        end

        if class == 'Tank' then
            i_frame.icon:SetTexture('Interface\\ICONS\\Ability_Defend')
        elseif class == 'Total' then
            i_frame.icon:SetTexture('Interface\\ICONS\\Achievement_GuildPerk_EverybodysFriend')
        else
            local coords = CLASS_ICON_TCOORDS[strupper(class)]; -- The Coords for the class icon via the global object.
            i_frame.icon:SetTexture(classTexture)
            i_frame.icon:SetTexCoord(unpack(coords))
        end

        if key == 1 then
            i_frame:SetPoint("TOP", -20, 0)
            i_frame:SetPoint("CENTER", -20, 0)
        elseif key == 2 then
            i_frame:SetPoint("LEFT", previous_frame, "RIGHT", 10, 0)
        elseif key == 3 then
            i_frame:SetPoint("TOPRIGHT", class_group.class_icons[icon_classes[key-2]], "BOTTOMLEFT", -10, -15)
        elseif key > 3 and key < 7 then
            i_frame:SetPoint("LEFT", previous_frame, "RIGHT", 10, 0)
        elseif key >= 7 then
            i_frame:SetPoint("TOPLEFT", class_group.class_icons[icon_classes[key - 4]], "BOTTOMLEFT", 0, -15)
        end

        i_frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(i_frame, "ANCHOR_BOTTOM")
        GameTooltip:ClearLines()
            local names = {}
            if not tEmpty(Raid.raid) then
                names = Raid.raid['classes'][self.class]
            end
            local tip_text = '';

            for name_key, name in pairs({unpack(names)}) do
                tip_text = tip_text .. name
                if name_key < #names then tip_text = tip_text .. '\n' end
            end

            GameTooltip:AddLine(tip_text)
            GameTooltip:Show()
        end)

        -- We don't care about the total hover.
        if class == 'Total' then i_frame:SetScript("OnEnter", function() end) end

        i_frame:SetScript("OnLeave", function()
        GameTooltip:ClearLines()
        GameTooltip:Hide()
        end)

        class_group.class_icons[class]=i_frame
    end

    --- Promote Leadership section.
    local promote_group = createBackdropFrame(nil, scrollContent, 'Promote Leadership')
    promote_group:SetHeight(100)
    scrollContent:AddChild(promote_group)


    --- Invite Group Commands
    local invite_group = createBackdropFrame(nil, scrollContent, 'Invite Commands')
    invite_group:SetHeight(100)
    scrollContent:AddChild(invite_group)

    --- Disallow Invite From
    local disallow_group = createBackdropFrame(nil, scrollContent, 'Disallow Invites')
    disallow_group:SetHeight(100)
    scrollContent:AddChild(disallow_group)

    --- Auto Invite Spam
    local invite_spam_group = createBackdropFrame(nil, scrollContent, 'Invite Spam')
    invite_spam_group:SetHeight(100)
    scrollContent:AddChild(invite_spam_group)

    f.class_groups = class_group

    GUI.raid_frame = f

    FriendsFrameTab4:Click()
    pdkp_frame:Hide()
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

    GUI.filter_frame = f;
end

function Setup:DKPAdjustments()
    local f = CreateFrame("Frame", "$parent_adjustment_frame", pdkp_frame)

    f:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetHeight(225)
    f:SetPoint("BOTTOMLEFT", PDKP.memberTable.frame, "BOTTOMRIGHT", -3, 0)
    f:SetPoint("BOTTOMRIGHT", pdkp_frame, "BOTTOMRIGHT", -10,0)

    local adjustHeader = f:CreateFontString(f, "OVERLAY", 'GameFontNormal')
    adjustHeader:SetText("DKP Adjustments")
    adjustHeader:SetPoint("TOPLEFT", 5, -5)

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

    for raid, _ in pairs(Defaults.raidBosses) do
        local boss_opts = {
            ['name']='boss_' .. raid,
            ['parent']=mainDD,
            ['title']='Boss',
            ['hide']=true,
            ['dropdownTable']=GUI.adjustmentDropdowns,
            ['showOnValue']=raid,
            ['changeFunc']=PDKP_ToggleAdjustmentDropdown,
            ['items']=Defaults.raidBosses[raid],
        }
        local bossDD = createDropdown(boss_opts)
        bossDD:SetPoint("LEFT", mainDD, "RIGHT", -20, 0)
    end

    --- Amount section
    local amount_opts = {
        ['name']='amount',
        ['parent']=mainDD,
        ['title']='Amount',
        ['multi']=false,
        ['max_chars']=7,
        ['numeric']=true,
        ['textValidFunc']=function(box)
            PDKP_ToggleAdjustmentDropdown()
        end
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
        ['textValidFunc']=function(box)
            PDKP_ToggleAdjustmentDropdown()
        end
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
        DKP:Submit()
        other_box:SetText("")
        amount_box:SetText("")
        other_box:ClearFocus()
        amount_box:ClearFocus()

        PDKP_ToggleAdjustmentDropdown()
    end)
    sb.canSubmit = false
    sb.toggle = function()
        if sb.canSubmit then sb:Enable() else sb:Disable() end
    end
    sb:Disable()

    GUI.adjustment_submit_button = sb

    --- Shroud / Roll buttons
    local shroud = CreateFrame("Button", "$parent_shroud", f, "UIPanelButtonTemplate")
    shroud:SetSize(75, 25)
    shroud:SetText("Shroud")
    shroud:SetPoint("TOPLEFT", amount_box, "BOTTOMLEFT", -10, -10)
    shroud:SetScript("OnClick", function()
        local amount = DKP:CalculateButton('Shroud')
        amount_box:SetText("-" .. amount)
    end)

    local roll = CreateFrame("Button", "$parent_roll", f, "UIPanelButtonTemplate")
    roll:SetSize(75, 25)
    roll:SetText("Roll")
    roll:SetPoint("LEFT", shroud, "RIGHT", 0, 0)
    roll:SetScript("OnClick", function()
        local amount = DKP:CalculateButton('Roll')
        amount_box:SetText("-" .. amount)
    end)

    GUI.adjust_buttons = {shroud, roll}

    mainDD:Show()


    --- Boss Loot Section
    local boss_loot_frame = Loot:CreateBossLoot(f)

    local loot_close = createCloseButton(boss_loot_frame, true)
    loot_close:SetPoint('TOPRIGHT', boss_loot_frame, 'TOPRIGHT', 0, -1)

    --boss_loot_frame:Hide()

    GUI.boss_loot_frame = boss_loot_frame;

    if not Settings:CanEdit() then f:Hide() end

    GUI.adjustment_frame = f;

end

function PDKP_ToggleAdjustmentDropdown()
    if tEmpty(GUI.adjustmentDropdowns) then return end

    local gui_dds = GUI.adjustmentDropdowns;

    wipe(GUI.adjustment_entry) -- Wipe the old entry details.

    local entry_details = GUI.adjustment_entry

    --- Submit Button
    local sb = GUI.adjustment_submit_button

    local reasonDD, raidDD, bwlDD, mcDD, aqDD, naxxDD = gui_dds['reasons'], gui_dds['raid'], gui_dds['boss_Blackwing Lair'],
    gui_dds['boss_Molten Core'], gui_dds['boss_Ahn\'Qiraj'], gui_dds['boss_Naxxramas']

    local other_box = GUI.editBoxes['other']
    local amount_box = GUI.editBoxes['amount']

    local reason_val = UIDropDownMenu_GetSelectedValue(reasonDD)
    local raid_val = UIDropDownMenu_GetSelectedValue(raidDD)

    entry_details['raid']=raid_val
    entry_details['reason']=reason_val

    local function toggleFrameVisiblity(frame, show)
        if show then
            frame:Show()
        else
            frame:Hide()
        end
    end

    for _, b_dd in pairs({bwlDD, mcDD, aqDD, naxxDD} ) do
        toggleFrameVisiblity(b_dd, reason_val == 'Boss Kill' and b_dd.uniqueID == 'boss_' .. raid_val)
    end
    toggleFrameVisiblity(other_box, reason_val == 'Other')

    local adjust_amount_setting = Defaults.adjustment_amounts[raid_val][reason_val]
    if adjust_amount_setting ~= nil then amount_box:SetText(adjust_amount_setting) end

    GUI.adjustment_entry['dkp_change']=amount_box:getValue()
    GUI.adjustment_entry['other_text']=other_box:getValue()

    for _, b_dd in pairs({bwlDD, mcDD, aqDD, naxxDD}) do
        if b_dd:IsVisible() then
            GUI.adjustment_entry['boss']=UIDropDownMenu_GetSelectedValue(b_dd)
        end
    end

    local can_submit = true

    local entry_frames = {reasonDD, raidDD, bwlDD, mcDD, aqDD, naxxDD, other_box, amount_box}

    --- Validate every frame.
    for _, frame in pairs(entry_frames) do
        can_submit = can_submit and frame.isValid()
    end

    local selected = #PDKP.memberTable.selected

    --- Selection check
    can_submit = can_submit and selected > 0

    if reason_val == 'Item Win' then
        can_submit = can_submit and selected == 1
        GUI.boss_loot_frame:Show()
    else
        GUI.boss_loot_frame:Hide()
    end

    GUI.adjustment_entry['names']=PDKP.memberTable.selected

    for _, button in pairs(GUI.adjust_buttons) do
        if selected == 1 then
            button:Enable()
        else
            button:Disable()
        end
    end

    sb.canSubmit = can_submit
    sb.canSubmit = can_submit

    sb.toggle()
end

function Setup:DKPHistory()
    local f = CreateFrame("Frame", "$parent_history_frame", pdkp_frame)

    f:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetPoint("TOPLEFT", PDKP.memberTable.frame, "TOPRIGHT", -3, 0)
    f:SetPoint("BOTTOMRIGHT", pdkp_frame, "BOTTOMRIGHT", -10,35)

    local history_button = CreateFrame("Button", "$parent_history_button", pdkp_frame, 'UIPanelButtonTemplate')
    history_button:SetSize(80, 30)
    history_button:SetPoint("CENTER", pdkp_frame, "TOP", 0, -50)
    history_button:SetScript("OnClick", function()
        if GUI.history_frame:IsVisible() then
            GUI.history_frame:Hide()
            GUI.filter_frame:Show()
            GUI.adjustment_frame:Show()
        else
            GUI.history_frame:Show()
            GUI.filter_frame:Hide()
            GUI.adjustment_frame:Hide()
        end
    end)
    history_button:SetText("History")

    f:Hide()

    GUI.history_frame = f;

    local ob = CreateFrame("Button", "$parent_options", f, "UIPanelButtonTemplate")
    ob:SetSize(80, 22) -- width, height
    ob:SetText("Options")
    ob:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 4, -22)
    ob:SetScript("OnClick", function()
        print('Opening History Options')
        -- TODO: Hookup the options button frame.
    end)

    history_button:Click()
end

function Setup:RaidDropdown()

    local parent_frame = _G['pdkp_frameFilterFrame']

    local raid_opts = {
        ['name']='raid',
        ['parent']=pdkp_frame,
        ['title']='Raid Selection',
        ['items']= Defaults.dkp_raids,
        ['defaultVal']=Settings.current_raid,
        ['dropdownTable']=GUI.adjustmentDropdowns,
        ['changeFunc']=function(dropdown, dropdown_val)
            Settings:ChangeCurrentRaid(dropdown_val);
            GUI:RefreshTables()
            PDKP_ToggleAdjustmentDropdown()
        end
    }
    local raid_dd = createDropdown(raid_opts)

    raid_dd:SetPoint("TOPRIGHT", parent_frame, "TOPRIGHT", 15, 25);
end

function Setup:TabView()

    local tc = CreateFrame("Frame", 'myTabContainerFrame', UIParent, nil)
    tc:SetSize(200, 200);
    tc:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    tc:SetMovable(true)
    tc:EnableMouse(true)
    tc:SetParent(UIParent)

    tc:SetBackdrop({
        tile = true, tileSize = 32,
        edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border', edgeSize = 32,
        bgFile= 'Interface\\DialogFrame\\UI-DialogBox-Background',
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })

    local header = tc:CreateFontString(tc, 'OVERLAY', 'GameFontNormal')
    header:SetSize(356, 64)
    header:SetPoint("TOP", 0, 12)
    header:SetText("My Frame")

    local tab_pages = {}
    local tab_buttons = {}

    local tab_page_opts = {
        [1]={
            ['name']='Filter',
            ['text']='Filter Page',
            ['title']='Filter',
            ['points']={
                ['side']='TOPLEFT',
                ['rel']='TOPLEFT',
            },
        },
        [2]={
            ['name']='History',
            ['text']='History Page',
            ['title']='History',
            ['points']={
                ['side']='TOPRIGHT',
                ['rel']='TOPRIGHT',
            },

        },
    }

    local function createTabButton(opts, page)
        local t = CreateFrame("Button", page:GetName() .. '_Tab', tc, "CharacterFrameTabButtonTemplate")
        t:SetText(opts['text'])
        t:SetSize(t:GetTextWidth() + 30, 30)
        t:SetPoint(opts['points']['side'], "$parent", opts['points']['rel'], 0, 30)
        t:SetFrameLevel(tc:GetFrameLevel() + 4)

        local textures = {'LeftDisabled', 'MiddleDisabled', 'RightDisabled', 'Left', 'Middle', 'Right'}

        local text_down = {'LeftDisabled', 'Left'}
        local text_left = {'MiddleDisabled', 'Middle'}
        local text_up = {'RightDisabled', 'Right'}

        local rotate_270 = (pi / 180) * 270
        local rotate_90 = (pi / 180) * 90
        local rotate_360 = (pi / 180) * 360
        local rotate_180 = (pi / 180) * 180

        for _, tex in pairs(textures) do
            _G[t:GetName() .. tex]:SetRotation(rotate_180)
        end

        --_G[t:GetName() .. 'LeftDisabled']:SetTexCoord(0, 0.15625, 0, 0.546875)
        _G[t:GetName() .. 'Left']:SetTexCoord(0, 0.84375, 1, 0)
        --_G[t:GetName() .. 'MiddleDisabled']:SetTexCoord(0.15625, 0.84375, 0, 0.546875)
        --_G[t:GetName() .. 'Middle']:SetTexCoord(0.15625, 0.84375, 0, 1.0)
        --_G[t:GetName() .. 'RightDisabled']:SetTexCoord(0.84375, 1.0, 0, 0.546875)
        --_G[t:GetName() .. 'Right']:SetTexCoord(0.84375, 1.0, 0, 1.0)

        --local midTex = _G[t:GetName() .. 'Middle']:SetRotation()
        --midTex:SetRotation(rotate_left)

        PanelTemplates_TabResize(t, 0, nil, 36, 60);

        local tab_text = _G[t:GetName() .. 'Text']
        tab_text:SetAllPoints(t)

        return t
    end

    local function rotateTab(tab)
        --rotate_down
    end

    local function toggleTab(t)
        for _, page in pairs(tab_pages) do
            if page.tab:GetName() == t:GetName() then
                page:Show()
            else
                page:Hide()
            end
        end
    end

    local function createTabPage(opts)
        local page = CreateFrame("Frame", '$parent_' .. opts['name'] .. '_Page', tc, nil)
        page:SetPoint("TOPLEFT", tc)
        page:SetPoint("BOTTOMRIGHT", tc)

        local page_text = page:CreateFontString(page, "OVERLAY", 'GameFontNormal')
        page_text:SetText(opts['text'])
        page_text:SetPoint("TOPLEFT", page)
        page_text:SetPoint("BOTTOMRIGHT", page)
        page_text:SetSize(20, 30)

        page.text = page_text

        page.tab = createTabButton(opts, page)

        page.tab:SetScript("OnClick", function()
            toggleTab(page.tab)
        end)

        return page
    end

    for key, page_opts in pairs(tab_page_opts) do
        local page = createTabPage(page_opts)
        table.insert(tab_pages, page)
        if key ~= 1 then page:Hide() end

        local tab = page.tab
        tab:SetScript("OnClick", function()
            toggleTab(tab)
        end)
    end
    tc:Show()
end

function Setup:SyncStatus()


    --Util:Format12HrDateTime(self.id)
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
            ['rel_point_y']=-70,
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
                ['compareFunc']=compare,
                ['colored']=true,
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
        ['showHighlight']=true,
        ['indexOn']=col_settings['headers'][1]['label'], -- Helps us keep track of what is selected, if it is filtered.
    }

    st = ScrollTable:newHybrid(table_settings, col_settings, row_settings)
    st.cols[1]:Click()

    PDKP.memberTable = st;
    GUI.memberTable = st;

    st.searchFrame = Setup:TableSearch()

    -- Entries label
    -- 0 Entries shown | 0 selected
    local label = st.searchFrame:CreateFontString(st.searchFrame, 'OVERLAY', 'GameFontNormalLeftYellow')
    label:SetSize(200, 14)
    label:SetPoint("LEFT", st.searchFrame.clearButton, "LEFT", 60, 0)
    label:SetText("0 Players shown | 0 selected")

    st.entryLabel = label

end

function Setup:HistoryTable()

    local ht = {};

    local table_settings = {
        ['name']= 'ScrollTable',
        ['parent']=GUI.history_frame,
        ['height']=GUI.history_frame:GetHeight() - 40,
        ['width']=GUI.history_frame:GetWidth(),
        ['movable']=true,
        ['enableMouse']=true,
        ['retrieveDataFunc']=function()
            local keys, entries = DKP:GetEntries(true, nil)
            return keys
        end,
        ['retrieveDisplayDataFunc']=function(self, id)
            return DKP:GetEntries(false, id)
        end,
        ['anchor']={
            ['point']='TOPLEFT',
            ['rel_point_x']=0,
            ['rel_point_y']=-40,
        }

    }
    local col_settings = {
        ['height']=0,
        ['width']=200,
        ['firstSort']=1, -- Denotes the header we want to sort by originally.
        ['stacked']=true,
        ['headers'] = {
            [1] = {
                ['label']='formattedOfficer',
                ['sortable']=false,
                ['displayName']='Officer',
                ['point']='LEFT',
                ['showSortDirection'] = false,
                ['display']=false,
            },
            [2] = {
                ['label']='historyText',
                ['sortable']=false,
                ['point']='LEFT',
                ['displayName']='Reason',
                ['showSortDirection'] = false,
                ['display']=false,
                ['onClickFunc']=function(row, buttonType)
                    if buttonType == 'RightButton' then
                        GUI.popup_entry = row.dataObj
                        StaticPopup_Show('PDKP_DKP_ENTRY_POPUP')
                    end
                end
            },
            [4] = {
                ['label']='formattedNames',
                ['sortable']=false,
                ['point']='LEFT',
                ['displayName']='Members',
                ['showSortDirection'] = false,
                ['display']=false,
            },
            [3] = {
                ['label']='change_text',
                ['sortable']=false,
                ['point']='LEFT',
                ['displayName']='Amount',
                ['showSortDirection'] = false,
                ['display']=false,
            },
        }
    }
    local row_settings = {
        ['height']=100,
        ['width']=350,
        ['max_values'] = 1000,
        ['showbackdrop']=true,
        ['indexOn']=col_settings['headers'][1]['label'], -- Helps us keep track of what is selected, if it is filtered.
    }

    ht = HistoryTable:newHybrid(table_settings, col_settings, row_settings)

    GUI.history_table = ht
end


