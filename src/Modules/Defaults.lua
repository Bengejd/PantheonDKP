local _G = _G
local AddonName, core = ...

-- Set the global functions to local instances.
local GetAddonMetadata = GetAddOnMetadata

local Defaults = core.PDKP.Defaults

Defaults.addon_version = GetAddonMetadata('PantheonDKP', "Version") -- Retrieves the addon version in the .toc
Defaults.addon_name = 'PantheonDKP' -- Addon's name.
Defaults.colored_name = '|cff33ff99PDKP|r' -- Colored formatting for "PDKP" in addon.
Defaults.print_name = '|cff33ff99PDKP|r:' -- Colored formatting for "PDKP" in chat messages.

Defaults.bank_name = 'Pantheonbank'; -- TODO: Banks name should probably be a setting instead of a default.

Defaults.development = true -- Default: false, enables development protocols.

Defaults.debug = false -- Default: false, enables debugging features in the addon.
Defaults.silent = false -- Default: false, disables PDKP chat messages
Defaults.no_broadcast = false -- Default: false, disables addon data transfer to other players.

if Defaults.development then
    Defaults.debug = true;
    Defaults.no_broadcast = true;
    Defaults.silent = false;
end

-- The TBC classic classes
Defaults.classes = { 'Druid', 'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior' };
-- The TBC Classic Class colors
Defaults.class_colors = {
    ["Druid"] = "FF7C0A", ["Hunter"] = "AAD372" , ["Mage"] = "3FC7EB", ["Paladin"] = "F48CBA",
    ["Priest"] = "FFFFFF", ["Rogue"] = "FFF468", ["Shaman"]="0070DD", ["Warlock"] = "8788EE", ["Warrior"] = "C69B6D"
};