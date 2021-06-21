local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Adjust = {}
Adjust.entry = {}

function Adjust:Update(adjustments)
    wipe(self.entry)

    self.entry['reason'] = adjustments['reason']
    self.entry['dkp_change'] = adjustments['amount']

    if PDKP.char.canEdit and PDKP.canEdit then
        self.entry['officer'] = PDKP.char.name
    end

    self.entry['names'] = PDKP.memberTable:GetSelected()

    --self.entry['names'] = nil

    -- TODO: Finish Adjust['Item']
    if adjustments['item'] then
        -- Set the item link & item icon here.
    end

    -- TODO: Finish Adjust['Other']
    if adjustments['other'] then
        -- Do other shit here.
    end

    if adjustments['raid_boss'] then
        self.entry['boss'] = adjustments['raid_boss']
        self.entry['raid'] = MODULES.Constants.BOSS_TO_RAID[self.entry['boss']]
    end

    local isValid = Adjust:_IsEntryValid()
    return GUI.Adjustment:UpdatePreview(isValid)
end

function Adjust:_GetSelectedMembers()

end

function Adjust:_HasCore(entry)
    local hasCore = true
    local core_details = { 'reason', 'dkp_change', 'officer', 'names' }

    for i = 1, #core_details do
        local detail = entry[core_details[i]]
        hasCore = hasCore and not (Utils:IsEmpty(detail))
    end
    return hasCore
end

function Adjust:_IsEntryValid()
    local entry = self.entry;
    local hasCore = Adjust:_HasCore(entry)
    local hasDependants = false

    if entry['reason'] == 'Boss Kill' then
        local boss, raid = entry['boss'], entry['raid']
        local hasRaid = not Utils:IsEmpty(raid)
        local hasBoss = not Utils:IsEmpty(boss)
        hasDependants = hasRaid and hasBoss
    end

    return hasCore and hasDependants
end

MODULES.Adjustment = Adjust