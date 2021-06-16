local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Adjust = {}
local tabName = 'view_adjust_button';

Adjust.dropdowns = {}

function Adjust:Initialize()
    if not PDKP.canEdit then return end

    local tabNames = GUI.TabController.tab_names

    -- To prevent tab controller not being ready yet.
    if tabNames == nil then return C_Timer.After(0.1, function() Adjust:Initialize() end) end

    local tf = tabNames[tabName].frame;

    local mainDD, amount_box, other_box;

    --- Reason Dropdown
    local reason_opts = {
        ['name']='reasons',
        ['parent']=tf,
        ['title']='Reason',
        ['items'] = {
            ['On Time Bonus'] = {

            }
        },
        ['items']= {'On Time Bonus', 'Completion Bonus', 'Boss Kill', 'Unexcused Absence', 'Item Win', 'Other'},
        ['defaultVal']='',
        ['dropdownTable']=self.dropdowns,
        ['changeFunc']= self.DropdownChanged
    }

    mainDD = GUtils:createDropdown(reason_opts)
    mainDD:SetPoint("TOPLEFT", tf, "TOPLEFT", -3, -50)

    local raid_opts = {
        ['name']='Raid',
        ['parent']=mainDD,
        ['title']='Raid',
        ['hide']=true,
        ['dropdownTable']=mainDD,
        ['showOnValue']='Testing',
        ['changeFunc']= self.DropdownChanged,
        ['items']=MODULES.Constants.RAID_NAMES,
    }

    local raidDD = GUtils:createDropdown(raid_opts)
    raidDD:SetPoint("LEFT", mainDD, "RIGHT", -20, 0)

    --- Raid Section
end

-- Just helps break up everything, gathering all of the data into one place before shipping it off.
function Adjust:DropdownChanged(dropdown, value)
    print(dropdown, value)
end

function Adjust:ReasonChanged()
    print('Adjust!');
end

function Adjust:RaidChanged()
    print('Raid!');
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
    GUI.adjustment_entry['other_text']=other_box:GetText()

    local selected = #PDKP.memberTable.selected

    if reason_val == 'Unexcused Absence' and selected == 1 then
        local unexcused_amount = DKP:CalculateButton('Unexcused Absence')
        amount_box:SetText("-" .. unexcused_amount)
        GUI.adjustment_entry['dkp_change']=amount_box:getValue()
    end

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

GUI.Adjustment = Adjust