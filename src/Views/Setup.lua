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

function Setup:RandomStuff()

    local randomFuncs = {
        --Setup.ScrollTable,
        --Setup.Filters,
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