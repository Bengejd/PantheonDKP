local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local RaidTools = { _initialized = false}

local RaidManager, Media, Constants;

local RaidFrame = RaidFrame
local CreateFrame, unpack, GameTooltip = CreateFrame, unpack, GameTooltip
local floor, fmod = math.floor, math.fmod
local strupper, strlower = string.upper, string.lower
local tinsert = table.insert

function RaidTools:Initialize()
    RaidManager = MODULES.RaidManager
    Media = MODULES.Media
    Constants = MODULES.Constants

    RaidTools.SpamRunning = false

    self.options = {}

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
    local GROUP_OPTS = {
        {
            ['name'] = 'class_group', ['title'] = 'Raid Breakdown', ['height'] = 170,
        },
        {
            ['name'] = 'promote_group', ['title'] = 'Raid Control', ['height'] = 100,
            ['description'] = "This will give all Officers & Class Leaders in the raid the 'Assist' role.",
        },
        {
            ['name'] = 'loot_threshold_group', ['title'] = 'Loot Threshold', ['height'] = 125,
            ['description'] = "This will set the loot threshold to 'Common'. \n\n" .. Utils:FormatTextColor('Note:', 'E71D36') .. ' This action becomes undone if Loot Master is changed.',
        },
        {
            ['name'] = 'inv_control_group', ['title'] = 'Invite Control', ['height'] = 425,
        },
    }
    local GROUPS = {}

    for i = 1, #GROUP_OPTS do
        local opts = GROUP_OPTS[i]
        local frame = GUtils:createBackdropFrame(nil, scrollContent, opts['title'])
        frame:SetHeight(opts['height'])
        if opts['description'] then
            frame.desc:SetText(opts['description'])
        end
        scrollContent:AddChild(frame)
        GROUPS[opts['name']] = frame
    end

    self:_CreateGroupIcons(GROUPS['class_group'])

    local BUTTON_OPTS = {
        {
            ['parent'] = GROUPS['promote_group'],
            ['clickFunc'] = RaidManager.PromoteLeadership,
            ['text'] = 'Promote Leadership',
            ['name'] = 'promote_button'
        },
        {
            ['parent'] = GROUPS['loot_threshold_group'],
            ['clickFunc'] = RaidManager.SetLootCommon,
            ['text'] = 'Set Loot Common',
            ['name'] = 'threshold_button'
        },
    }

    for i = 1, #BUTTON_OPTS do
        local opt = BUTTON_OPTS[i]
        local btn = CreateFrame("Button", nil, opt['parent'].content, 'UIPanelButtonTemplate')
        btn:SetText(opt['text'])
        btn:SetScript("OnClick", opt['clickFunc'])
        btn:SetPoint("TOPLEFT")
        btn:SetSize(btn:GetTextWidth() + 20, 30)
    end

    local spam_button_desc; -- Define this early so we can detect how far it is from the bottom in the resize.

    -- Automatically resizes the Inv_control_group based on the editBoxes size.
    GROUPS['inv_control_group'].resize = function(diff)
        if diff < -10 then
            GROUPS['inv_control_group']:SetHeight(425 - diff)
        else
            GROUPS['inv_control_group']:SetHeight(425)
        end
        scrollContent.Resize()
    end

    local invite_command_opts = {
        ['name'] = 'invite_commands',
        ['parent'] = GROUPS['inv_control_group'].content,
        ['title'] = 'Auto Invite Commands',
        ['smallTitle'] = true,
        ['textValidFunc'] = PDKP_RaidTools_TextValidFunc
    }

    local inv_edit_box = GUtils:createEditBox(invite_command_opts)
    inv_edit_box:SetPoint("TOPLEFT", GROUPS['inv_control_group'].content, "TOPLEFT", 12, -8)
    inv_edit_box:SetPoint("TOPRIGHT", GROUPS['inv_control_group'].content, "TOPRIGHT", 12, 8)
    inv_edit_box.desc:SetText("You will auto-invite when whispered one of the words or phrases listed above.")

    local invite_commands = RaidManager.invite_commands or {'invite', 'inv'}
    local inv_text = strlower(strjoin(", ", tostringall(unpack(invite_commands))))
    inv_edit_box:SetText(inv_text)

    self.options['commands'] = inv_edit_box

    local disallow_opts = {
        ['name'] = 'disallow_invite',
        ['parent'] = GROUPS['inv_control_group'].content,
        ['title'] = 'Ignore Invite Requests from',
        ['multi'] = true,
        ['smallTitle'] = true,
        ['max_lines'] = 4,
        ['textValidFunc'] = PDKP_RaidTools_TextValidFunc
    }
    local disallow_edit = GUtils:createEditBox(disallow_opts)
    disallow_edit:SetPoint("TOPLEFT", inv_edit_box.desc, "BOTTOMLEFT", 8, -32)
    disallow_edit:SetPoint("TOPRIGHT", inv_edit_box.desc, "BOTTOMRIGHT", -10, 32)
    self.options['ignored'] = disallow_edit

    --local ignore_from = Settings:UpdateIgnoreFrom({}, true) or {};
    local ignore_text = strlower(strjoin(", ", tostringall(unpack(RaidManager.ignore_from or {}))))
    disallow_edit:SetText(ignore_text)

    disallow_edit:HookScript("OnEditFocusLost", function()
        disallow_edit:SetText(strlower(disallow_edit:GetText()))
    end)

    disallow_edit.desc:SetText("This will prevent the above comma seperated names from abusing the automatic raid invite feature.")
    disallow_edit.start_height = disallow_edit:GetHeight() -- Set our starting height for resize purposes.

    local guild_only_opts = {
        ['parent'] = disallow_edit,
        ['uniqueName'] = 'guild_only_invites',
        ['text'] = 'Ignore PUGS',
        ['enabled'] = RaidManager.ignore_pugs,
        ['frame'] = f,
    }

    local guild_only = GUtils:createCheckButton(guild_only_opts)
    guild_only.desc:SetText('This will block Invite requests from\nnon-guildies.')
    guild_only:ClearAllPoints()
    guild_only:SetPoint("TOPLEFT", disallow_edit.desc, "BOTTOMLEFT", 0, -5)

    guild_only.desc:SetPoint("RIGHT", GROUPS['inv_control_group'].content, "RIGHT", 0, -5)
    guild_only:SetScript("OnClick", function(b)
        local val = b:GetChecked()
        RaidManager.ignore_pugs = val
        MODULES.Database:UpdateSetting('ignore_pugs', val)
    end)
    self.options['ignore_PUGS'] = guild_only

    local invite_spam_opts = {
        ['name'] = 'invite_spam',
        ['parent'] = GROUPS['inv_control_group'].content,
        ['title'] = 'Guild Invite Spam text',
        ['multi'] = true,
        ['smallTitle'] = true,
        ['max_lines'] = 5,
        ['textValidFunc'] = PDKP_RaidTools_TextValidFunc
    }
    local invite_spam_box = GUtils:createEditBox(invite_spam_opts)
    invite_spam_box:SetPoint("TOPLEFT", guild_only.desc, "BOTTOMLEFT", 8, -32)
    invite_spam_box:SetPoint("TOPRIGHT", guild_only.desc, "BOTTOMRIGHT", -10, 32)
    invite_spam_box:SetText(RaidManager.invite_spam_text)
    invite_spam_box.desc:SetText("This is the message that will be sent when 'Start Raid Inv Spam' is clicked.")
    self.options['spam'] = invite_spam_box

    local spam_button = CreateFrame("Button", nil, GROUPS['inv_control_group'].content, "UIPanelButtonTemplate")
    spam_button:SetText("Start Raid Inv Spam")

    -- TODO: Implement this stuff.
    spam_button:SetScript("OnClick", function()
        RaidTools.SpamRunning = not RaidTools.SpamRunning

        local b_text = ''

        if RaidTools.SpamRunning then
            b_text = 'Stop Raid Inv Spam'
        else
            b_text = 'Start Raid Inv Spam'
        end
        spam_button:SetText(b_text)

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
        GROUPS['inv_control_group'].resize(diff)
    end

    disallow_edit:SetScript("OnSizeChanged", editBoxResized)
    invite_spam_box:SetScript("OnSizeChanged", editBoxResized)

    f.class_groups = GROUPS['class_group']
    f.spam_button = spam_button
    f.GROUPS = GROUPS;

    PDKP.raid_frame = f

    --@debug@
    --ToggleFriendsFrame(4)
    --@end-debug@

    self._initialized = true
end

function PDKP_RaidTools_TextValidFunc(box)
    if (not box.touched) or not RaidTools._initialized then return end
    if not box.touched and not box.init then box.init = true; return end

    local boxID, text = box.uniqueID, box:GetText()
    local text_arr = Utils:SplitString(text, ',')
    local box_funcs = {
        ['invite_spam'] = function()
            MODULES.RaidManager.invite_spam_text = text
        end,
        ['disallow_invite'] = function()
            MODULES.RaidManager.ignore_from = text_arr
            MODULES.Database:UpdateSetting('disallow_invite', text_arr)
        end,
        ['invite_commands'] = function()
            MODULES.RaidManager.invite_commands = text_arr
            MODULES.Database:UpdateSetting('invite_commands', text_arr)
        end,
    }

    print(boxID, text)

    if box_funcs[boxID] then return box_funcs[boxID]() end

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
end

function RaidTools:_CreateGroupIcons(class_group)
    class_group.class_icons = {}

    local classTexture = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"

    local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

    local ICONS = { 'DKP', 'Total', 'Tank', unpack(Constants.CLASSES) }
    local ICON_PATHS = { ['Total'] = Media.TOTAL_ICON, ['Tank'] = Media.TANK_ICON, ['DKP'] = Media.DKP_OFFICER_ICON }
    for i = 1, #Constants.CLASSES do
        ICON_PATHS[Constants.CLASSES[i]] = classTexture
    end

    for key, class in pairs(ICONS) do
        local i_frame = GUtils:createIcon(class_group.content, "0")
        i_frame.class = class

        i_frame.icon:SetTexture(ICON_PATHS[class])

        -- Set up the text coords for the class icons
        if key > 3 then
            i_frame.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]))
        end

        -- Set up the previous frames.
        local previous_frame;
        if key > 1 then
            local prev_key = Utils:ternaryAssign(key <= 8, 1, 6)
            previous_frame = class_group.class_icons[ICONS[key - prev_key]]
        end

        local BASE_POINTS = {
            [key == 1] = { { "TOP", 0, 0 }, { "CENTER", 0, 0 } }, -- DKP
            [key == 2] = { "RIGHT", class_group.class_icons[ICONS[1]], "LEFT", -10, 0 }, -- Total
            [key == 3] = { "LEFT", class_group.class_icons[ICONS[1]], "RIGHT", 10, 0 }, -- Tanks
            [key == 4] = { "TOPRIGHT", class_group.class_icons[ICONS[2]], "BOTTOMLEFT", 9, -15 },
            [key > 4 and key <= 7] = { "LEFT", previous_frame, "RIGHT", 10, 0 },
            [key == 8] = { "TOPLEFT", class_group.class_icons[ICONS[key - 4]], "BOTTOMLEFT", -20, -15 },
            [key > 8] = { "LEFT", class_group.class_icons[ICONS[key - 1]], "RIGHT", 10, 0 }
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

        if key == 3 then
            --i_frame:Hide()
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