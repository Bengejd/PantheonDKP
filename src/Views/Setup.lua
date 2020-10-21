local _, core = ...;
local _G = _G;
--local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
--local Item = core.Item;
local PDKP = core.PDKP;
local Raid = core.Raid;
local Util = core.Util;
local Comms = core.Comms;
local Setup = core.Setup;
local Guild = core.Guild;
local Shroud = core.Shroud;
--local Member = core.Member;
--local Officer = core.Officer;
--local Invites = core.Invites;
--local Minimap = core.Minimap;
--local Import = core.Import;

--local AceGUI = LibStub("AceGUI-3.0")
local Defaults = core.Defaults;
local ScrollTable = core.ScrollTable;
local Settings = core.Settings;
local Loot = core.Loot;
local HistoryTable = core.HistoryTable;
local SimpleScrollFrame = core.SimpleScrollFrame;

local Export = core.Export;

local pdkp_frame;

local CreateFrame, strlower = CreateFrame, strlower
local GameFontNormalSmall = GameFontNormalSmall

local floor = math.floor

local CLOSE_BUTTON_TEXT = "|TInterface\\Buttons\\UI-StopButton:0|t"
local TRANSPARENT_BACKGROUND = "Interface\\TutorialFrame\\TutorialFrameBackground"
local PDKP_TEXTURE_BASE = "Interface\\Addons\\PantheonDKP\\Media\\Main_UI\\PDKPFrame-"
local SHROUD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
local SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
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
    local change_func = opts['changeFunc'] or function () end


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

    UIDropDownMenu_Initialize(dropdown, function()
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

    box:SetScript("OnEditFocusGained", function() box.touched = true end)

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
        box_frame:SetPoint("TOPRIGHT", box, "TOPRIGHT", -10, 0)
        box_frame:SetHeight(30)
    end

    box_frame:SetFrameLevel(box:GetFrameLevel() - 4)

    local title_font = 'GameFontNormal'

    if small_title then title_font = 'GameFontNormalSmall' end

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

    GUI.editBoxes[name]=box

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
        --['reload']=function()
        --    ReloadUI()
        --end,
        --['show']=function()
        --    GUI:Show()
        --end,
        --['hide']=function()
        --    GUI:Hide()
        --end,
        ['reset DKP']=function()
            DKP:ResetDKP(true)
        end,
        ['boss kill']=function()
            local boss_info = Raid:TestBossKill()
            print(boss_info['name'], boss_info['id'], boss_info['raid'])
        end,
        ['memory']=function()
            Util:ReportMemory()
        end,
        ['merge_guild_old']=function()
            Guild:MergeOldData()
        end,
        ['Overwrite Push']=function()
            Export:New('push-overwrite')
        end,
        ['Merge Push']=function()
            Export:New('push-merge')
        end,
        ['AQ-Quest Report']=function()
            Loot:TestGetAQLoots()
        end,
    }

    local button_counter = 1
    for name, func in pairs(buttons) do
        local db = CreateFrame("Button", nil, f, "UiPanelButtonTemplate")

        db:SetHeight(22)
        db:SetText(name)

        local width = db:GetTextWidth() + 10
        if width < 80 then width = 80 end

        db:SetWidth(width)

        db:SetScript("OnClick", function()
            print('Debug Function:', name)
            func()
        end)

        local pos_x = 10
        local pos_y = -25

        pos_y = pos_y * button_counter

        db:SetPoint("TOPLEFT", f, "TOPLEFT", pos_x, pos_y)

        button_counter = button_counter + 1
    end

    if not Settings:IsDebug() then f:Hide() end
end

function Setup:EasyStats()
    local f = pdkp_frame
    local table_frame = GUI.memberTable.frame
    local easy_stats_frame = CreateFrame("Frame", 'pdkp_easy_stats', f)
    easy_stats_frame:SetPoint("BOTTOM", table_frame, "TOP", 0, -2)
    easy_stats_frame:SetPoint("CENTER", table_frame, "CENTER", -40, 0)
    easy_stats_frame:SetSize(240, 25)


    local easy_stats = easy_stats_frame:CreateTexture('pdkp_easy_stats_border', 'OVERLAY')
    easy_stats:SetTexture(CHAR_INFO_TEXTURE)
    easy_stats:SetSize(240, 72)
    easy_stats:SetPoint("CENTER")
    easy_stats:SetTexCoord(0, 1, 1, 0)

    local easy_stats_text = easy_stats_frame:CreateFontString(easy_stats_frame, "OVERLAY", "GameFontNormalLeftYellow")
    easy_stats_text:SetPoint("CENTER")
    easy_stats_text:SetHeight(20)

    f.easy_stats = easy_stats
    f.easy_stats.text = easy_stats_text
end

function Setup:HistoryButton()

end

function Setup:RandomStuff()
    Setup:ShroudingBox()
    Setup:Debugging()

    Setup:ScrollTable()
    Setup:EasyStats()
    Setup:Filters()
    Setup:DKPAdjustments()
    Setup:RaidDropdown()
    --Setup:BossKillLoot()
    Setup:DKPHistory()
    Setup:RaidTools()
    Setup:InterfaceOptions()
    Setup:PushProgressBar()
    Setup:HistoryTable()
    Setup:DKPOfficer()
    Setup:SyncStatus()

    --- For debugging purposes.
    if Settings:IsDebug() then
        pdkp_frame:Show()
    end
end

function Setup:PushProgressBar()
    local pb
    if GUI.pushbar == nil then
        pb = CreateFrame("StatusBar", 'pdkp_pushbar', UIParent)
        setMovable(pb)
        pb:SetFrameStrata("HIGH")
        pb:SetPoint("TOP")
        pb:SetWidth(300)
        pb:SetHeight(20)
        pb:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
        pb:GetStatusBarTexture():SetHorizTile(true)
        pb:GetStatusBarTexture():SetVertTile(false)
        pb:SetStatusBarColor(0, 0.65, 0)
        pb.bg = pb:CreateTexture(nil, "BACKGROUND")
        pb.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-TargetingFrame-BarFill")
        pb.bg:SetAllPoints(true)
        pb.bg:SetVertexColor(0, 0.35, 0)

        pb.value = pb:CreateFontString(nil, "OVERLAY")
        pb.value:SetPoint("CENTER")
        pb.value:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        pb.value:SetJustifyH("LEFT")
        pb.value:SetShadowOffset(1, -1)
        pb.value:SetTextColor(0, 1, 0)
        GUI.pushbar = pb;
    end
    if pb == nil then pb = GUI.pushbar end
    pb.value:SetText("0%")
    pb.isLocked = false;
    pb:SetMinMaxValues(0, 100)
    pb:Hide()
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
    local promote_group = createBackdropFrame(nil, scrollContent, 'Raid Control')
    promote_group:SetHeight(100)
    scrollContent:AddChild(promote_group)

    promote_group.desc:SetText("This will give all Officers & Class Leaders in the raid the 'Assist' role.")

    local promote_button = CreateFrame("Button", nil, promote_group.content, "UIPanelButtonTemplate")
    promote_button:SetText("Promote Leadership")
    promote_button:SetScript("OnClick", function() Raid:PromoteLeadership() end)
    promote_button:SetPoint("TOPLEFT")
    promote_button:SetSize(promote_button:GetTextWidth() + 20, 30)

    --- Loot Threshold Group
    local loot_threshold_group = createBackdropFrame(nil, scrollContent, 'AQ40 Loot Threshold')
    loot_threshold_group:SetHeight(125)
    scrollContent:AddChild(loot_threshold_group)

    local loot_warning = Util:FormatFontTextColor('E71D36', 'Note:')
    loot_threshold_group.desc:SetText("This will set the loot threshold to 'Common' for AQ40 keys. \n\n" .. loot_warning .. ' This action becomes undone if Loot Master is changed.')

    local threshold_button = CreateFrame("Button", nil, loot_threshold_group.content, 'UIPanelButtonTemplate')
    threshold_button:SetText("Set Loot Common")
    threshold_button:SetScript("OnClick", function() Raid:SetLootCommon() end)
    threshold_button:SetPoint("TOPLEFT")
    threshold_button:SetSize(threshold_button:GetTextWidth() + 20, 30)


    --- Invite Control Group
    local inv_control_group = createBackdropFrame(nil, scrollContent, 'Invite Control')
    inv_control_group:SetHeight(360)
    scrollContent:AddChild(inv_control_group)

    local spam_button_desc; -- Define this early so we can detect how far it is from the bottom in the resize.

    -- Automatically resizes the Inv_control_group based on the editBoxes size.
    inv_control_group.resize = function(diff)
        if diff < -10 then inv_control_group:SetHeight(350 - diff) else inv_control_group:SetHeight(350) end
        scrollContent.Resize()
    end

    -- Sets the GUI.invite_control values based on which box it is.
    local function textValidFunc(box)
        if not box.touched and box.init then return end
        box.init = true

        local box_id = box.uniqueID

        local bt = box:GetText()

        local box_funcs = {
            ['invite_spam']=function()
                GUI.invite_control['text']=bt
            end,
            ['disallow_invite']=function()
                local text_arr = Util:SplitString(bt, ',')
                GUI.invite_control['ignore_from']=text_arr
                Settings:UpdateIgnoreFrom(text_arr)
            end,
            ['invite_commands']=function()
                local text_arr = Util:SplitString(bt, ',')
                GUI.invite_control['commands']=text_arr
            end,
        }

        if box_funcs[box_id] then box_funcs[box_id]()
        else
            Util:Debug("GUI.Invite_Control box func", box_id, 'was not found!')
        end
    end

    local invite_command_opts = {
        ['name']='invite_commands',
        ['parent']=inv_control_group.content,
        ['title']='Auto Invite Commands',
        ['multi']=false,
        ['max_chars']=225,
        ['smallTitle']=true,
        ['numeric']=false,
        ['textValidFunc']=textValidFunc
    }

    local inv_edit_box = createEditBox(invite_command_opts)
    inv_edit_box:SetPoint("TOPLEFT", inv_control_group.content, "TOPLEFT", 12, -8)
    inv_edit_box:SetPoint("TOPRIGHT", inv_control_group.content, "TOPRIGHT", 12, 8)
    inv_edit_box.desc:SetText("You will auto-invite when whispered one of the words or phrases listed above.")
    inv_edit_box:SetText("inv, invite")

    local disallow_opts = {
        ['name']='disallow_invite',
        ['parent']=inv_control_group.content,
        ['title']='Ignore Invite Requests from',
        ['multi']=true,
        ['max_chars']=225,
        ['smallTitle']=true,
        ['max_lines']=4,
        ['numeric']=false,
        ['textValidFunc']=textValidFunc
    }
    local disallow_edit = createEditBox(disallow_opts)
    disallow_edit:SetPoint("TOPLEFT", inv_edit_box.desc, "BOTTOMLEFT", 8, -32)
    disallow_edit:SetPoint("TOPRIGHT", inv_edit_box.desc, "BOTTOMRIGHT", -10, 32)

    local ignore_from = Settings:UpdateIgnoreFrom({}, true) or {};
    if #ignore_from >= 1 then
        local names = {unpack(ignore_from)}
        local ignore_text = ''
        for k, n in pairs(names) do
            n = strlower(n)
            if k == #names then ignore_text = ignore_text .. n else ignore_text = ignore_text .. n .. ', ' end
        end
        disallow_edit:SetText(ignore_text)
    end

    disallow_edit:HookScript("OnEditFocusLost", function()
        disallow_edit:SetText(strlower(disallow_edit:GetText()))
    end)

    disallow_edit.desc:SetText("This will prevent the above members from abusing the automatic raid invite feature.")

    disallow_edit.start_height = disallow_edit:GetHeight() -- Set our starting height for resize purposes.

    local invite_spam_opts = {
        ['name']='invite_spam',
        ['parent']=inv_control_group.content,
        ['title']='Guild Invite Spam text',
        ['multi']=true,
        ['max_chars']=225,
        ['smallTitle']=true,
        ['max_lines']=5,
        ['numeric']=false,
        ['textValidFunc']=textValidFunc
    }
    local invite_spam_box = createEditBox(invite_spam_opts)
    invite_spam_box:SetPoint("TOPLEFT", disallow_edit.desc, "BOTTOMLEFT", 8, -32)
    invite_spam_box:SetPoint("TOPRIGHT", disallow_edit.desc, "BOTTOMRIGHT", -10, 32)
    invite_spam_box:SetText("[TIME] [RAID] invites going out. Pst for Invite")
    invite_spam_box.desc:SetText("This is the message that will be sent when 'Start Raid Inv Spam' is clicked.")

    local spam_button = CreateFrame("Button", nil, inv_control_group.content, "UIPanelButtonTemplate")
    spam_button:SetText("Start Raid Inv Spam")
    spam_button:SetScript("OnClick", function()
        GUI.invite_control['running'] = not GUI.invite_control['running']
        local running = GUI.invite_control['running']

        local b_text = ''

        if running then b_text = 'Stop Raid Inv Spam' else b_text = 'Start Raid Inv Spam' end
        spam_button:SetText(b_text)

        GUI:ToggleRaidInviteSpam()

        -- TODO: See if there is an easy way to change this color to something more like ElvUI's Black buttons.
    end)
    spam_button:SetPoint("TOPLEFT", invite_spam_box.desc, "BOTTOMLEFT", 0, -8)
    spam_button:SetPoint("TOPRIGHT", invite_spam_box.desc, "BOTTOMRIGHT", 0, 8)

    spam_button_desc = spam_button:CreateFontString(spam_button, "OVERLAY", "GameFontHighlightSmall")
    spam_button_desc:SetPoint("TOPLEFT", spam_button, "BOTTOMLEFT", 0, -8)
    spam_button_desc:SetPoint("TOPRIGHT", spam_button, "BOTTOMRIGHT", 0, 8)
    spam_button_desc:SetText("This will send your message to Guild chat every 90 seconds for 15 minutes or until the raid is full. Click again to stop the message spam.")
    spam_button_desc:SetJustifyH("LEFT")

    invite_spam_box.start_height = invite_spam_box:GetHeight() -- Set our starting height for resize purposes.

    -- Resizes the Inv_control_group frame, based on the size of the edit boxes.
    local function editBoxResized(edit_frame, _, _)
        if not edit_frame.touched then return end
        local _, button_bottom, _, _ = spam_button_desc:GetRect()
        local bottom = floor(button_bottom)
        local diff = floor(bottom) - floor(360)
        local singles = math.fmod(diff, 10) -- We only care about intervals of 10.
        diff = diff - singles
        inv_control_group.resize(diff)
    end

    disallow_edit:SetScript("OnSizeChanged", editBoxResized)
    invite_spam_box:SetScript("OnSizeChanged", editBoxResized)

    f.class_groups = class_group

    GUI.raid_frame = f
    GUI.invite_control['spamButton']=spam_button

    --- This is to ensure that the commands get registered initially.
    f:Show()
    f:Hide()
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
        ['textValidFunc']=function()
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
        ['textValidFunc']=function()
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
    Setup:LootFrame(f)

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
        GUI.adjustment_entry['shouldHaveItem'] = true
        can_submit = can_submit and selected == 1
        Loot.frame:Show()
    else
        Loot.frame:Hide()
    end

    GUI.adjustment_entry['names']=PDKP.memberTable.selected
    GUI.adjustment_entry['item']=nil;

    for _, button in pairs(GUI.adjust_buttons) do
        if (reason_val == 'Other' or reason_val == 'Item Win') and selected == 1 then
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

    local filter_frame = _G['pdkp_frameFilterFrame']

    local buttons = {
        ['view_history_button']={
            ['parent']=filter_frame,
            ['shows']={f},
            ['hides']={GUI.filter_frame, GUI.adjustment_frame},
            ['text']='Open History'
        },
        ['view_filters_button']={
          ['parent']=f,
          ['shows']={GUI.filter_frame, GUI.adjustment_frame},
          ['hides']={f},
          ['text']='Close History'
        },
    }

    for name, btn in pairs(buttons) do
        local b = CreateFrame("Button", "$parent_" .. name, btn['parent'])
        b:SetSize(120, 30)
        b.hides = btn['hides']
        b.shows = btn['shows']
        b:SetPoint("BOTTOMLEFT", btn['parent'], "TOPLEFT", 0, 0)
        b:SetNormalTexture("Interface\\CHATFRAME\\ChatFrameTab")
        b:SetScript("OnClick", function()
            for _, frame in pairs(b.hides) do frame:Hide() end
            for _, frame in pairs(b.shows) do frame:Show() end
        end)

        local b_text = b:CreateFontString(b, 'OVERLAY', 'GameFontNormalLeft')
        b_text:SetPoint("CENTER", 0, -5)
        b_text:SetText(btn['text'])
        GUI[name] = b
    end

    f:Hide()

    GUI.history_frame = f;

    local ob = CreateFrame("Button", "$parent_options", f, "UIPanelButtonTemplate")
    ob:SetSize(80, 22) -- width, height
    ob:SetText("Options")
    ob:Disable()
    ob:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 4, -22)
    ob:SetScript("OnClick", function()
        print('Opening History Options')
        -- TODO: Hookup the options button frame.
    end)
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
        ['changeFunc']=function(_, dropdown_val)
            Settings:ChangeCurrentRaid(dropdown_val);
            GUI:RefreshTables()
            PDKP_ToggleAdjustmentDropdown()
            GUI:UpdateEasyStats()
            if GUI.shroud_box:IsVisible() then
                Shroud:NewShrouder(nil)
            end
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

        local rotate_180 = (pi / 180) * 180

        for _, tex in pairs(textures) do _G[t:GetName() .. tex]:SetRotation(rotate_180) end

        _G[t:GetName() .. 'Left']:SetTexCoord(0, 0.84375, 1, 0)

        PanelTemplates_TabResize(t, 0, nil, 36, 60);

        local tab_text = _G[t:GetName() .. 'Text']
        tab_text:SetAllPoints(t)

        return t
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
    local f = createBackdropFrame('sync_status', GUI.filter_frame, 'DKP Sync Status')
    f:SetPoint("TOPLEFT", GUI.filter_frame, "BOTTOMLEFT")
    f:SetPoint("BOTTOMRIGHT", GUI.adjustment_frame, "TOPRIGHT")

    GUI.sync_frame = f;
    f.children = {};

    local function createSyncLabel(label_text)
        local label = f.content:CreateFontString('OVERLAY', nil, 'GameFontNormalLeft')
        label:SetText(label_text)
        local sync_text = f.content:CreateFontString('OVERLAY', nil, 'GameFontHighlightSmall')
        sync_text:SetPoint("LEFT", label, 'RIGHT', 5, 0)
        label.desc = sync_text;

        if #f.children == 0 then
            label:SetPoint("TOPLEFT", 0, -2);
        else
            label:SetPoint("TOPLEFT", f.children[#f.children], "BOTTOMLEFT", 0, -10)
        end
        table.insert(f.children, label)
        return label
    end
    local syncStatus = createSyncLabel('Sync Status:')
    local guildPush = createSyncLabel('Last DKP Edit:');
    local lastPush = createSyncLabel('Last Push Received:');
    local guildSync = createSyncLabel('Last Sync Request:');
    --local timeSinceSync = createSyncLabel('Time Since Latest Sync:')

    f.syncStatus = syncStatus;
    f.guildSync = guildSync;
    f.guildPush = guildPush;
    f.lastPush = lastPush;
    --f.timeSinceSync = timeSinceSync;

    pdkp_frame:HookScript("OnShow", function()
        GUI:UpdateSyncStatus()
    end)
end

function Setup:InterfaceOptions()

    --local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")

    --name (string|function) - Display name for the option
    --desc (string|function) - description for the option (or nil for a self-describing name)
    --descStyle (string) - "inline" if you want the description to show below the option in a GUI (rather than as a tooltip). Currently only supported by AceGUI "Toggle".
    --validate (methodname|function|false) - validate the input/value before setting it. return a string (error message) to indicate error.
    --confirm (methodname|function|boolean) - prompt for confirmation before changing a value
    --true - display "name - desc", or contents of .confirmText
    --function - return a string (prompt to display) or true (as above), or false to skip the confirmation step
    --order (number|methodname|function) - relative position of item (default = 100, 0=first, -1=last)
    --disabled (methodname|function|boolean) - disabled but visible
    --hidden (methodname|function|boolean) - hidden (but usable if you can get to it, i.e. via commandline)
    --guiHidden (boolean) - hide this from graphical UIs (dialog, dropdown)
    --dialogHidden (boolean) - hide this from dialog UIs
    --dropdownHidden (boolean) - hide this from dropdown UIs
    --cmdHidden (boolean)- hide this from commandline
    --Note that only hidden can be a function, the specialized hidden cases cannot.
    --icon (string|function) - path to icon texture
    --iconCoords (table|methodname|function) - arguments to pass to SetTexCoord, e.g. {0.1,0.9,0.1,0.9}.
    --handler (table) - object on which getter/setter functions are called if they are declared as strings rather than function references
    --type (string) - "execute", "input", "group", etc; see below
    --width (string) - "double", "half", "full", "normal", or numeric, in a GUI provide a hint for how wide this option needs to be. (optional support in implementations)
    --default is nil (not set)
    --double, half - increase / decrease the size of the option
    --full - make the option the full width of the window
    --normal - use the default widget width defined for the implementation (useful to overwrite widgets that default to "full")
    --any number - multiplier of the default width, ie. 0.5 equals "half", 2.0 equals "double"

    if Settings.db['sync'] == nil then
        Settings.db['sync'] = {
            ['pvp']=true,
            ['raids']=true,
            ['dungeons']=true
        }
    end

    local options = {
        type = "group",
        args = {
            notificationGroup= {
                name="1. Notifications",
                type="group",
                inline= true,
                args = {
                    Silent = {
                        name = "Enabled",
                        type = "toggle",
                        desc="Enables / Disables all messages from the addon.",
                        set = function(_,val) return Settings:GetSetInterface('set', 'silent', val) end,
                        get = function() return not Settings:GetSetInterface('get', 'silent', nil) end
                    },
                }
            },
            SyncGroup= {
                name="2. Allow DKP syncs to occur in:",
                type="group",
                desc='This only controls merge / overwrite syncing. This will not affect DKP updates that occur during a raid.',
                descStyle='inline',
                inline= true,
                args = {
                    syncInPvP = {
                        name = "Battlegrounds",
                        desc = "Enable / Disable sync while in Battlegrounds",
                        type = "toggle",
                        set = function(_,val) return Settings:GetSetInterface('set', 'pvp', val) end,
                        get = function() return Settings:GetSetInterface('get', 'pvp', nil) end
                    },
                    syncInRaid = {
                        name = "Raids",
                        desc = "Enable / Disable sync while in Raid Instances",
                        type = "toggle",
                        set = function(_,val) return Settings:GetSetInterface('set', 'raids', val) end,
                        get = function() return Settings:GetSetInterface('get', 'raids', nil) end
                    },
                    syncInDungeons = {
                        name = "Dungeons",
                        desc = "Enable / Disable sync while in Dungeon Instances",
                        type = "toggle",
                        set = function(_,val) return Settings:GetSetInterface('set', 'dungeons', val) end,
                        get = function() return Settings:GetSetInterface('get', 'dungeons', nil) end
                    },
                    syncDesc = {
                        name="These options only control when a DKP merge-push is allowed to occur. This will not affect DKP updates that occur during a raid.",
                        type='description',
                        fontSize ='medium'
                    }
                }
            },
            adminGroup = nil,
        }
    }

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

    LibStub('AceConfigRegistry-3.0'):RegisterOptionsTable("PantheonDKP", options)
    AceConfigDialog:AddToBlizOptions('PantheonDKP')
end

function Setup:LootFrame(parent)
    local f = createBackdropFrame("pdkp_loot_frame", parent, 'Loot Table')
    f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    f:SetHeight(200)
    f:SetWidth(200)

    local scroll = SimpleScrollFrame:new(f.content)
    local scrollFrame = scroll.scrollFrame;
    local scrollContent = scrollFrame.content;

    local cb = createCloseButton(f, true)
    cb:SetFrameLevel(f:GetFrameLevel() + 4)
    cb:SetFrameStrata("DIALOG")

    cb:SetScript("OnClick", function(self)
        self:GetParent():Hide()
        Loot:ClearLootFrame()
    end)

    cb:SetPoint("TOPRIGHT", -5, 0)

    f.scroll = scroll;
    f.scrollFrame  = scrollFrame;
    f.scrollContent = scrollContent;

    scrollFrame.scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 8, -20)
    scrollFrame.scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -8, 18)

    f.getChecked = function()
        local sc = f.scrollContent;
        for i=1, #sc.children do
            local child = sc.children[i]
            if child:IsVisible() and child.checked then
                return child
            end
        end
        return 'None Linked'
    end

    f.checkUnique = function(item_info)
        for i=1, #scrollContent.children do
            local child = scrollContent.children[i];
            if child.item_info == item_info then return false end
        end
        return true
    end

    f.addLootItem = function(_, item_info)

        if not f.checkUnique(item_info) then
            Util:Debug("Duplicate Item Info Found")
            return
        end

        local loot_frame = CreateFrame("Frame", nil, scrollContent, nil)
        loot_frame:SetSize(scrollContent:GetWidth(), 18)

        local item_link_string = loot_frame:CreateFontString(loot_frame, 'OVERLAY', 'GameFontHighlightLeft')

        -- TODO: GameTooltip should dispaly here.
        item_link_string:SetText(item_info['name'])
        item_link_string:SetPoint("LEFT")
        item_link_string:SetWidth(loot_frame:GetWidth() - 40)
        item_link_string:SetHeight(loot_frame:GetHeight())

        loot_frame.item_info = item_info

        loot_frame.checked = false

        local lcb = Setup:CreateCloseButton(loot_frame, true)
        lcb:SetSize(15, 15);
        lcb:SetPoint("LEFT", loot_frame, "RIGHT", 0, 0)
        lcb:SetFrameLevel(loot_frame:GetFrameLevel() + 4)
        lcb:SetScript("OnClick", function()
            local lcb_parent = lcb:GetParent()
            lcb_parent.deleted = true
            lcb_parent:Hide()
        end)

        local check = CreateFrame("CheckButton", nil, loot_frame, 'ChatConfigCheckButtonTemplate')
        check:SetPoint("RIGHT", lcb, "LEFT", -5, 0)

        -- We can only have 1 checked at a time.
        local function toggleChecked(ignore_child)
            for i=1, #scrollContent.children do
                local child = scrollContent.children[i]
                if child ~= ignore_child then
                    child.check_box:SetChecked(false)
                    child.checked = false
                end
            end
        end

        check:SetScript("OnClick", function(_, buttonType)
            if buttonType == 'LeftButton' then
                toggleChecked(loot_frame)
                loot_frame.checked = check:GetChecked()
            end
        end)


        loot_frame:SetScript("OnHide", function()
            if loot_frame.deleted then
                Loot:LootDeleted(loot_frame.item_info)
                scrollContent.Resize()
                loot_frame.checked = false
            else
                --- Do something here? Re-position the siblings, Remove this item from the loot list?
            end
        end)

        scrollContent.AddChild(scrollContent, loot_frame)

        if #scrollContent.children == 1 then
            loot_frame:ClearAllPoints()
            loot_frame:SetPoint("TOPLEFT", 2, 0)
            loot_frame:SetPoint("TOPRIGHT", -15, 0)
        end

        loot_frame.check_box = check
    end

    local loot_events = {'CHAT_MSG_LOOT', 'OPEN_MASTER_LOOT_LIST', 'UPDATE_MASTER_LOOT_LIST', 'LOOT_SLOT_CHANGED',
                         'LOOT_OPENED', 'LOOT_SLOT_CLEARED'}

    for _, eventName in pairs(loot_events) do f:RegisterEvent(eventName) end

    f:SetScript("OnEvent", PDKP_OnLootEvent)

    Loot.frame = f

    f:Hide()

    return f
end

function Setup:ShroudingBox()
    local f = createBackdropFrame('pdkp_shroud_frame', UIParent, 'PDKP Shrouding')
    f:SetPoint("BOTTOMLEFT")
    f:SetHeight(200)
    f:SetWidth(200)
    setMovable(f)

    local scroll = SimpleScrollFrame:new(f.content)
    local scrollFrame = scroll.scrollFrame
    local scrollContent = scrollFrame.content;

    local cb = createCloseButton(f, true)
    cb:SetPoint("TOPRIGHT")

    cb:SetScript("OnClick", function()
        f:Hide()
        if Raid:IsDkpOfficer() then Comms:SendCommsMessage('pdkpClearShrouds', {}, 'RAID', nil, nil, nil) end
    end)

    f.scrollContent = scrollContent;
    f.scroll = scroll;
    f.scrollFrame = scrollFrame;

    local shroud_events = {'CHAT_MSG_RAID', 'CHAT_MSG_RAID_LEADER'}
    for _, eventName in pairs(shroud_events) do f:RegisterEvent(eventName) end
    f:SetScript("OnEvent", PDKP_Shroud_OnEvent)

    f:Hide()

    GUI.shroud_box = f;
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
        ['retrieveDisplayDataFunc']=function(_, name)
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
    local hf = createBackdropFrame('$parent_Table_Frame', GUI.history_frame)
    hf:SetPoint("TOPLEFT", GUI.memberTable.frame, 'TOPRIGHT', 0, -30)
    hf:SetPoint("BOTTOMRIGHT", -7, 0)

    GUI.history_table = HistoryTable:init(hf)
end

function Setup:DKPOfficer()
    if not Settings:CanEdit() then return end
    local dropdownList = _G['DropDownList1']
    dropdownList:HookScript('OnShow', function()
        local charName = strtrim(_G['DropDownList1Button1']:GetText())
        local member = Guild:GetMemberByName(charName)

        if not (member and Raid:MemberIsInRaid(charName) and member.canEdit) then return end

        local dkpOfficer = Raid.raid.dkpOfficer;
        local isDkpOfficer = charName == dkpOfficer

        local dkpOfficerText = tenaryAssign(isDkpOfficer, 'Demote from DKP Officer', 'Promote to DKP Officer')

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
                Raid:SetDkpOfficer(isDkpOfficer, charName);
                Comms:SendCommsMessage('pdkpDkpOfficer', Raid.raid.dkpOfficer, 'RAID', nil, 'BULK', nil)
            end
        }, 1)
        _G['UIDropDownMenu_AddSeparator'](1)
    end)
end