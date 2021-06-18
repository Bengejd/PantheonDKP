local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Adjust = {}
Adjust.entry = {}

function Adjust:Initialize() end

function Adjust:Update(adjustments)
    wipe(Adjust.entry)

    Adjust.entry['reason'] = adjustments['reason']
    Adjust.entry['dkp_change'] = adjustments['amount']

    if adjustments['item'] then
        -- Set the item link & item icon here.
    end

    if adjustments['other'] then
        -- Do other shit here.
    end

    if adjustments['raid_boss'] then
        -- Grab the raid & boss info
    end

    return GUI.Adjustment:UpdatePreview(false)
end

MODULES.Adjustment = Adjust