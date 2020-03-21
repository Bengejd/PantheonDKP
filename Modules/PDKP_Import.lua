local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Util = core.Util;
local PDKP = core.PDKP;
local Raid = core.Raid;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Import = core.Import;

local db1 = {
    ['members'] = {
        ["Lemonz"] = {
            ["dkpTotal"] = 153,
            ["Blackwing Lair"] = 0,
            ["Molten Core"] = 153,
        },
        ["Corseau"] = {
            ["dkpTotal"] = 275,
            ["Blackwing Lair"] = 0,
            ["Molten Core"] = 275,
        },
        ["Iszell"] = {
            ["dkpTotal"] = 0,
            ["Blackwing Lair"] = 0,
            ["Molten Core"] = 0,
        },
    }
}
local db2 = {
    ['members'] = {
        ["Lemonz"] = {
            ["dkpTotal"] = 153,
            ["Blackwing Lair"] = 0,
            ["Molten Core"] = 153,
        },
        ["Corseau"] = {
            ["dkpTotal"] = 275,
            ["Blackwing Lair"] = 0,
            ["Molten Core"] = 275,
        },
        ["Iszell"] = {
            ["dkpTotal"] = 0,
            ["Blackwing Lair"] = 0,
            ["Molten Core"] = 0,
        },
    }
}

-- Check banks latest officer note. If the value is higher than your value, then you can assume you're out of date.
-- If you are out of date, look to see what officers are online, and request a push from their database, if their last
-- edit is equal to the banks last edit or greater than your own. If not, continue until you find one.
--

function Import:TestCombine()

end