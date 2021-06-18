local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local tinsert, tContains, pairs, next = table.insert, tContains, pairs, next;

local Adjust = {}
local tabName = 'view_adjust_button';

Adjust.dropdowns = {}
Adjust.editBoxes = {}

function Adjust:Initialize()
    if not PDKP.canEdit then return end

    local tabNames = GUI.TabController.tab_names

    -- To prevent tab controller not being ready yet.
    if tabNames == nil then
        return C_Timer.After(0.1, function()
            Adjust:Initialize()
        end)
    end

    local tf = tabNames[tabName].frame;

    --- Entry Preview Section
    local entry_preview = self:CreateEntryPreview(tf)

    --- Entry Details section
    local entry_details = GUtils:createBackdropFrame('entry_details', tf, 'Entry Details');
    entry_details:SetPoint("TOPLEFT", entry_preview, "BOTTOMLEFT", 0, 0)
    entry_details:SetPoint("BOTTOMRIGHT", tf, "BOTTOMRIGHT", 0, 0);

    local mainDD, raidDD, amount_box, other_box, item_box;

    --- Reason Section
    local reason_opts = {
        ['name'] = 'reason',
        ['parent'] = entry_details.content,
        ['title'] = 'Adjustment Reason',
        ['items'] = { 'Completion Bonus', 'Boss Kill', 'Item Win', 'Other' },
        ['defaultVal'] = '',
        ['changeFunc'] = self.DropdownChanged
    }

    mainDD = GUtils:createDropdown(reason_opts)
    mainDD:SetPoint("TOPLEFT", entry_details, "TOPLEFT", -3, -50)
    tinsert(self.dropdowns, mainDD)
    tinsert(entry_details.children, mainDD)

    local raid_items = {}
    for raid_name, raid_table in pairs(MODULES.Constants.RAID_BOSSES) do
        raid_items[raid_name] = raid_table['boss_names']
    end

    --- Raid Section
    local raid_opts = {
        ['name'] = 'raid_boss',
        ['parent'] = mainDD,
        ['title'] = 'Raid Boss',
        ['hide'] = true,
        ['dropdownTable'] = mainDD,
        ['showOnValue'] = 'Boss Kill',
        ['changeFunc'] = self.DropdownChanged,
        ['items'] = raid_items
    }

    raidDD = GUtils:createNestedDropdown(raid_opts)
    raidDD:SetPoint("LEFT", mainDD, "RIGHT", -20, 0)
    tinsert(self.dropdowns, raidDD)
    tinsert(entry_details.children, raidDD)

    --- Amount section
    local amount_opts = {
        ['name']='amount',
        ['parent']=mainDD,
        ['title']='Amount',
        ['multi']=false,
        ['max_chars']=7,
        ['numeric']=true,
        ['dropdownTable'] = mainDD,
        ['showOnValue'] = 'Always',
        ['textValidFunc']=self.DropdownChanged
    }
    amount_box = GUtils:createEditBox(amount_opts)
    amount_box.frame:SetWidth(75)
    amount_box:SetWidth(60)
    amount_box:SetPoint("TOPLEFT", mainDD, "BOTTOMLEFT", 25, -20)
    tinsert(self.editBoxes, amount_box)
    tinsert(entry_details.children, amount_box)

    --- Item Name Box Section
    local item_opts = {
        ['name']= 'item',
        ['parent']= mainDD,
        ['title']='Item Name',
        ['multi']=true,
        ['numeric']=false,
        ['dropdownTable'] = mainDD,
        ['showOnValue'] = 'Item Win',
        ['textValidFunc']=self.DropdownChanged
    }
    item_box = GUtils:createEditBox(item_opts)
    item_box:SetPoint("LEFT", mainDD, "RIGHT", 20, 0)
    item_box:Hide()
    tinsert(self.editBoxes, item_box)
    tinsert(entry_details.children, item_box)

    --- Other Edit Box Section
    local other_opts = {
        ['name']= 'other',
        ['parent']= mainDD,
        ['title']='Other',
        ['multi']=true,
        ['numeric']=false,
        ['dropdownTable'] = mainDD,
        ['showOnValue'] = 'Other',
        ['textValidFunc']=self.DropdownChanged
    }
    other_box = GUtils:createEditBox(other_opts)
    other_box:SetPoint("LEFT", mainDD, "RIGHT", 20, 0)
    other_box:Hide()
    tinsert(self.editBoxes, other_box)
    tinsert(entry_details.children, other_box)

    --- Submit Section
    local sb = CreateFrame("Button", "$parent_submit", tf, "UIPanelButtonTemplate")
    sb:SetSize(80, 22) -- width, height
    sb:SetText("Submit")
    sb:SetPoint("BOTTOMRIGHT", tf, "BOTTOMRIGHT", 4, -22)
    sb:SetScript("OnClick", function()
        -- TODO: Hook up submit logic.
    end)
    sb:Disable()

    self.entry_details = entry_details;
end

function Adjust:CreateEntryPreview(tf)
    local f = GUtils:createBackdropFrame('entry_preview', tf, 'Entry Preview');
    f:SetPoint("TOPLEFT", tf, "TOPLEFT", 10, -20)
    f:SetPoint("TOPRIGHT", tf, "TOPRIGHT", -10, -20)
    f:SetSize(340, 250);

    local PREVIEW_HEADERS = {'Officer', 'Reason', 'Amount', 'Members'}

    for i=1, #PREVIEW_HEADERS do
        local head = PREVIEW_HEADERS[i]
        local label = f.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
        local value = f.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')

        label:SetText(head .. ':')

        if i == 1 then
            label:SetPoint("TOPLEFT", f.content, "TOPLEFT", 5, -5)
        else
            label:SetPoint("TOPLEFT", f.children[i -1], "BOTTOMLEFT", 0, -2)
        end

        value:SetPoint("LEFT", label, "RIGHT", 0, 0)
        value:SetText("None")

        label.value = value;

        table.insert(f.children, label)
    end

    f.desc:SetText(Utils:FormatTextColor("Entry is invalid", 'E71D36'));

    return f;
end

function Adjust:UpdatePreview(isValid)

end

-- Just helps break up everything, gathering all of the data into one place before shipping it off.
function Adjust:DropdownChanged()
    --- There will always be either 2 or 3 valid adjustments.
    local valid_adjustments = {}
    local children = Adjust.entry_details.children

    local mainDD = children[1]
    local amount_box = children[3]

    if mainDD.selectedValue == 'Boss Kill' and amount_box:getValue() ~= 10 then
        amount_box:SetEnabled(false)
        return amount_box:SetText(10)
    else
        amount_box:SetEnabled(true)
    end

    local tbl_len = 0
    for _, dd in pairs(children) do
        if dd.dropdownTable ~= nil and dd.showOnValue ~= "Always" then
            local ddParent = dd.dropdownTable;
            if ddParent.selectedValue == dd.showOnValue and ddParent:IsVisible() then
                dd:Show()
            else
                dd:Hide()
            end
        end
        if dd.isValid() then
            valid_adjustments[dd.uniqueID] = dd.selectedValue
            tbl_len = tbl_len + 1
        end
    end

    if next(valid_adjustments) ~= nil and tbl_len >= 2 then
        MODULES.Adjustment:Update(valid_adjustments)
    end
end

function PDKP_ToggleAdjustmentDropdown()
    if tEmpty(GUI.adjustmentDropdowns) then
        return
    end

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

    entry_details['raid'] = raid_val
    entry_details['reason'] = reason_val

    local function toggleFrameVisiblity(frame, show)
        if show then
            frame:Show()
        else
            frame:Hide()
        end
    end

    for _, b_dd in pairs({ bwlDD, mcDD, aqDD, naxxDD }) do
        toggleFrameVisiblity(b_dd, reason_val == 'Boss Kill' and b_dd.uniqueID == 'boss_' .. raid_val)
    end
    toggleFrameVisiblity(other_box, reason_val == 'Other')

    local adjust_amount_setting = Defaults.adjustment_amounts[raid_val][reason_val]
    if adjust_amount_setting ~= nil then
        amount_box:SetText(adjust_amount_setting)
    end

    GUI.adjustment_entry['dkp_change'] = amount_box:getValue()
    GUI.adjustment_entry['other_text'] = other_box:GetText()

    local selected = #PDKP.memberTable.selected

    if reason_val == 'Unexcused Absence' and selected == 1 then
        local unexcused_amount = DKP:CalculateButton('Unexcused Absence')
        amount_box:SetText("-" .. unexcused_amount)
        GUI.adjustment_entry['dkp_change'] = amount_box:getValue()
    end

    for _, b_dd in pairs({ bwlDD, mcDD, aqDD, naxxDD }) do
        if b_dd:IsVisible() then
            GUI.adjustment_entry['boss'] = UIDropDownMenu_GetSelectedValue(b_dd)
        end
    end

    local can_submit = true

    local entry_frames = { reasonDD, raidDD, bwlDD, mcDD, aqDD, naxxDD, other_box, amount_box }

    --- Validate every frame.
    for _, frame in pairs(entry_frames) do
        can_submit = can_submit and frame.isValid()
    end

    if reason_val == 'Unexcused Absence' and selected ~= 1 then
        can_submit = false
    end

    --- Selection check
    can_submit = can_submit and selected > 0

    if reason_val == 'Item Win' then
        GUI.adjustment_entry['shouldHaveItem'] = true
        can_submit = can_submit and selected == 1
        Loot.frame:Show()
    else
        Loot.frame:Hide()
    end

    GUI.adjustment_entry['names'] = PDKP.memberTable.selected
    GUI.adjustment_entry['item'] = nil;

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

GUI.Adjustment = Adjust