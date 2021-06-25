local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local RaidTools = {}

local RaidManager, Media, Constants;

local RaidFrame = RaidFrame
local CreateFrame, unpack, GameTooltip = CreateFrame, unpack, GameTooltip
local strupper = string.upper
local tinsert = table.insert

function RaidTools:Initialize()
    RaidManager = MODULES.RaidManager
    Media = MODULES.Media
    Constants = MODULES.Constants

    local f = CreateFrame("Frame", 'pdkp_raid_frame', RaidFrame, 'BasicFrameTemplateWithInset')
    f:SetSize(300, 425)
    f:SetPoint("LEFT", RaidFrame, "RIGHT", 0, 0)
    f.title = f:CreateFontString(nil, "OVERLAY")
    f.title:SetFontObject("GameFontHighlight")
    f.title:SetPoint("CENTER", f.TitleBg, "CENTER", 11, 0)
    f.title:SetText("PDKP Raid Tools")
    f:SetFrameStrata("HIGH")
    f:SetFrameLevel(1)
    f:SetToplevel(true)

    f.content = CreateFrame("Frame", '$parent_content', f)
    f.content:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -28)
    f.content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)
    f.content:SetSize(f:GetWidth(), f:GetHeight())

    local b = CreateFrame("Button", 'pdkp_raid_frame_button', RaidFrame, 'UIPanelButtonTemplate')
    b:SetHeight(30)
    b:SetWidth(80)
    b:SetText("Raid Tools")
    b:SetPoint("TOPRIGHT", RaidFrame, "TOPRIGHT", 80, 0)
    b:SetScript("OnClick", function()
        if f:IsVisible() then
            f:Hide()
        else
            f:Show()
        end
    end)

    ----- SimpleScrollFrame
    local scroll = PDKP.SimpleScrollFrame:new(f.content)
    local scrollFrame = scroll.scrollFrame
    local scrollContent = scrollFrame.content;

    -- Create all of the Backdrop groups.
    --local GROUPS = {
    --    { ['name'] = 'class_group', ['title'] = 'Raid Breakdown', ['height'] = 170, ['sub_func'] = self._CreateGroupIcons, ['sub_args'] = 'self' },
    --    {
    --        ['name'] = 'promote_group', ['title'] = 'Raid Breakdown',
    --        ['args'] = { nil, scrollContent, 'Raid Control' },
    --        ['height'] = 170,
    --        ['desc'] = "This will give all Officers & Class Leaders in the raid the 'Assist' role."
    --    },
    --    {
    --        ['init'] = GUtils.createBackdropFrame,
    --        ['args'] = { nil, scrollContent, "Raid Breakdown" },
    --        ['height'] = 170,
    --    },
    --}
    --local loot_threshold_group = GUtils:createBackdropFrame(nil, scrollContent, 'Loot Threshold')
    --loot_threshold_group:SetHeight(125)
    --scrollContent:AddChild(loot_threshold_group)
    --local loot_warning = Utils:FormatTextColor('Note:', 'E71D36')
    --loot_threshold_group.desc:SetText("This will set the loot threshold to 'Common'. \n\n" .. loot_warning .. ' This action becomes undone if Loot Master is changed.')

    --- Class Group Section
    local class_group = GUtils:createBackdropFrame(nil, scrollContent, 'Raid Breakdown')
    class_group:SetHeight(170)
    scrollContent:AddChild(class_group)

    self:_CreateGroupIcons(class_group)

    local promote_group = GUtils:createBackdropFrame(nil, scrollContent, 'Raid Control')
    promote_group:SetHeight(100)
    scrollContent:AddChild(promote_group)
    promote_group.desc:SetText("This will give all Officers & Class Leaders in the raid the 'Assist' role.")

    --- Promote Leadership section.
    local promote_button = CreateFrame("Button", nil, promote_group.content, "UIPanelButtonTemplate")
    promote_button:SetText("Promote Leadership")
    promote_button:SetScript("OnClick", RaidManager.PromoteLeadership)
    promote_button:SetPoint("TOPLEFT")
    promote_button:SetSize(promote_button:GetTextWidth() + 20, 30)

    --- Loot Threshold Group
    --local loot_threshold_group = GUtils:createBackdropFrame(nil, scrollContent, 'Loot Threshold')
    --loot_threshold_group:SetHeight(125)
    --scrollContent:AddChild(loot_threshold_group)
    --local loot_warning = Utils:FormatTextColor('Note:', 'E71D36')
    --loot_threshold_group.desc:SetText("This will set the loot threshold to 'Common'. \n\n" .. loot_warning .. ' This action becomes undone if Loot Master is changed.')

    local threshold_button = CreateFrame("Button", nil, loot_threshold_group.content, 'UIPanelButtonTemplate')
    threshold_button:SetText("Set Loot Common")
    threshold_button:SetScript("OnClick", RaidManager.SetLootCommon)
    threshold_button:SetPoint("TOPLEFT")
    threshold_button:SetSize(threshold_button:GetTextWidth() + 20, 30)

    --- Invite Control Group
    local inv_control_group = GUtils:createBackdropFrame(nil, scrollContent, 'Invite Control')
    inv_control_group:SetHeight(360)
    scrollContent:AddChild(inv_control_group)

    local spam_button_desc; -- Define this early so we can detect how far it is from the bottom in the resize.

    -- Automatically resizes the Inv_control_group based on the editBoxes size.
    inv_control_group.resize = function(diff)
        if diff < -10 then
            inv_control_group:SetHeight(350 - diff)
        else
            inv_control_group:SetHeight(350)
        end
        scrollContent.Resize()
    end

    local invite_command_opts = {
        ['name'] = 'invite_commands',
        ['parent'] = inv_control_group.content,
        ['title'] = 'Auto Invite Commands',
        ['max_chars'] = 225,
        ['smallTitle'] = true,
        ['textValidFunc'] = self._TextValidFunc,
        ['description'] = 'You will auto-invite when whispered one of the words or phrases listed above.'
    }

    local inv_edit_box = GUtils:createEditBox(invite_command_opts)
    inv_edit_box:SetPoint("TOPLEFT", inv_control_group.content, "TOPLEFT", 12, -8)
    inv_edit_box:SetPoint("TOPRIGHT", inv_control_group.content, "TOPRIGHT", 12, 8)
    inv_edit_box:SetText("inv, invite")

    local disallow_opts = {
        ['name'] = 'disallow_invite',
        ['parent'] = inv_control_group.content,
        ['title'] = 'Ignore Invite Requests from',
        ['multi'] = true,
        ['max_chars'] = 225,
        ['smallTitle'] = true,
        ['max_lines'] = 4,
        ['numeric'] = false,
        ['textValidFunc'] = self._TextValidFunc,
        ['description'] = "This will prevent the above members from abusing the automatic raid invite feature."
    }
    local disallow_edit = GUtils:createEditBox(disallow_opts)
    disallow_edit:SetPoint("TOPLEFT", inv_edit_box.desc, "BOTTOMLEFT", 8, -32)
    disallow_edit:SetPoint("TOPRIGHT", inv_edit_box.desc, "BOTTOMRIGHT", -10, 32)

    local ignore_from = Settings:UpdateIgnoreFrom({}, true) or {};
    if #ignore_from >= 1 then
        local names = { unpack(ignore_from) }
        local ignore_text = ''
        for k, n in pairs(names) do
            n = strlower(n)
            if k == #names then
                ignore_text = ignore_text .. n
            else
                ignore_text = ignore_text .. n .. ', '
            end
        end
        disallow_edit:SetText(ignore_text)
    end

    disallow_edit:HookScript("OnEditFocusLost", function()
        disallow_edit:SetText(strlower(disallow_edit:GetText()))
    end)

    disallow_edit.start_height = disallow_edit:GetHeight() -- Set our starting height for resize purposes.

    --@debug@
    ToggleFriendsFrame(4)
    --@end-debug@
end

function RaidTools:_TextValidFunc()

    --if not box.touched and box.init then
    --    return
    --end
    --box.init = true
    --
    --local box_id = box.uniqueID
    --
    --local bt = box:GetText()
    --
    --local box_funcs = {
    --    ['invite_spam'] = function()
    --        --RaidTools.invite_control['text'] = bt
    --    end,
    --    ['disallow_invite'] = function()
    --        --local text_arr = Util:SplitString(bt, ',')
    --        --RaidTools.invite_control['ignore_from'] = text_arr
    --        --Settings:UpdateIgnoreFrom(text_arr)
    --    end,
    --    ['invite_commands'] = function()
    --        --local text_arr = Util:SplitString(bt, ',')
    --        --RaidTools.invite_control['commands'] = text_arr
    --    end,
    --}
    --
    --if box_funcs[box_id] then
    --    box_funcs[box_id]()
    --end
end

function RaidTools:CreateOldRaidTools()


    local invite_spam_opts = {
        ['name'] = 'invite_spam',
        ['parent'] = inv_control_group.content,
        ['title'] = 'Guild Invite Spam text',
        ['multi'] = true,
        ['max_chars'] = 225,
        ['smallTitle'] = true,
        ['max_lines'] = 5,
        ['numeric'] = false,
        ['textValidFunc'] = textValidFunc
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

        if running then
            b_text = 'Stop Raid Inv Spam'
        else
            b_text = 'Start Raid Inv Spam'
        end
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
        if not edit_frame.touched then
            return
        end
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
    GUI.invite_control['spamButton'] = spam_button

    --- This is to ensure that the commands get registered initially.
    f:Show()
    f:Hide()
end

function RaidTools:_CreateGroupIcons(class_group)
    class_group.class_icons = {}

    local classTexture = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"

    local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

    -- TODO: Attach Dead Counter to CompactRaidFrameContainerBorderFrame using Interface\ICONS\INV_Misc_Bone_HumanSkull_01 or Interface\Durability\DeathRecap with TexCoords?
    -- TODO: Create MasterLooter using Interface\ICONS\INV_Crate_05 as ICONS or Interface\ICONS\INV_Box_03
    -- TODO: Create DKP Officer using Interface\ICONS\INV_MISC_Coin_01 as ICONS

    local ICONS = { 'Total', 'Tank', unpack(Constants.CLASSES) }
    local ICON_PATHS = { ['Total'] = Media.TANK_ICON, ['Tank'] = Media.TOTAL_ICON }
    for i = 1, #Constants.CLASSES do
        ICON_PATHS[Constants.CLASSES[i]] = classTexture
    end

    for key, class in pairs(ICONS) do
        local i_frame = GUtils:createIcon(class_group.content, "0")
        i_frame.class = class

        i_frame.icon:SetTexture(ICON_PATHS[class])

        -- Set up the text coords for the class icons
        if key > 2 then
            i_frame.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]))
        end

        -- Set up the previous frames.
        local previous_frame;
        if key > 1 then
            local prev_key = Utils:ternaryAssign(key <= 7, 1, 6)
            previous_frame = class_group.class_icons[ICONS[key - prev_key]]
        end

        local BASE_POINTS = {
            [key == 1] = { { "TOP", -20, 0 }, { "CENTER", -20, 0 } }, -- Total
            [key == 2] = { "LEFT", previous_frame, "RIGHT", 10, 0 }, -- Tanks
            [key == 3] = { "TOPRIGHT", class_group.class_icons[ICONS[key - 2]], "BOTTOMLEFT", -10, -15 },
            [key > 3 and key <= 6] = { "LEFT", previous_frame, "RIGHT", 10, 0 },
            [key == 7] = { "TOPLEFT", class_group.class_icons[ICONS[key - 4]], "BOTTOMLEFT", -20, -15 },
            [key > 7] = { "LEFT", class_group.class_icons[ICONS[key - 1]], "RIGHT", 10, 0 }
        }

        local points = BASE_POINTS[true]

        if points then
            for i = 1, #points do
                if type(points[1]) == "table" then
                    i_frame:SetPoint(unpack(points[i]))
                else
                    i_frame:SetPoint(unpack(points))
                end
            end
        end

        if class ~= 'Total' then
            i_frame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(i_frame, "ANCHOR_BOTTOM")
                GameTooltip:ClearLines()
                local tip_text = ''
                local names = MODULES.RaidManager:GetClassMemberNames(class)
                for name_key, name in pairs({ unpack(names) }) do
                    tip_text = tip_text .. Utils:ternaryAssign(name_key < #names, name .. '\n', name)
                end

                GameTooltip:AddLine(tip_text)
                GameTooltip:Show()
            end)

            i_frame:SetScript("OnLeave", function()
                GameTooltip:ClearLines()
                GameTooltip:Hide()
            end)
        end

        class_group.class_icons[class] = i_frame
    end
end

GUI.RaidTools = RaidTools