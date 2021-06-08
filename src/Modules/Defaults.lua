local _G = _G
local AddonName, core = ...

local PDKP = core.PDKP

-- Set the global functions to local instances.
local GetAddonMetadata = GetAddOnMetadata
local tinsert, tsort, strupper, tostring = tinsert, table.sort, string.upper, tostring;

local Defaults = PDKP:GetInst('Defaults')

Defaults.warning = 'E71D36'
Defaults.success = '22bb33'
Defaults.info = 'F4A460'

Defaults.addon_version = GetAddonMetadata('PantheonDKP', "Version") -- Retrieves the addon version in the .toc
Defaults.addon_interface_version = GetAddonMetadata('PantheonDKP', "X-Interface") -- Retrieves the addon's Interface #
Defaults.addon_name = 'PantheonDKP' -- Addon's name.
Defaults.colored_name = '|cff33ff99PDKP|r' -- Colored formatting for "PDKP" in addon.
Defaults.print_name = '|cff33ff99PDKP|r:' -- Colored formatting for "PDKP" in chat messages.

Defaults.bank_name = 'Pantheonbank' -- TODO: Banks name should probably be a setting instead of a default.

Defaults.phase = GetAddonMetadata('PantheonDKP', 'X-Phase')

Defaults.development = true -- Default: false, enables development protocols.

Defaults.debug = false -- Default: false, enables debugging features in the addon.
Defaults.silent = false -- Default: false, disables PDKP chat messages
Defaults.no_broadcast = false -- Default: false, disables addon data transfer to other players.

Defaults.dev_names = { ['Neekio'] = true, ['Pantheonbank'] = true, ['Lariese'] = true }

if Defaults.development then
    Defaults.debug = true
    Defaults.no_broadcast = true
    Defaults.silent = false
end

-- The TBC classic classes
Defaults.classes = { 'Druid', 'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior' }
-- The TBC Classic Class colors
Defaults.class_colors = {
    ["Druid"] = "FF7C0A", ["Hunter"] = "AAD372" , ["Mage"] = "3FC7EB", ["Paladin"] = "F48CBA",
    ["Priest"] = "FFFFFF", ["Rogue"] = "FFF468", ["Shaman"]="0070DD", ["Warlock"] = "8788EE", ["Warrior"] = "C69B6D"
}

--- TODO: TBC - Remove Raid requirement for lookup. Should be standardized to just one raid.
Defaults.adjustment_amounts = {
    ['Boss Kill'] = 10,
    ['Weekly Decay'] = 0.1,
    ['Content Decay'] = 0.5,
    ['Benched'] = 10,
}

Defaults.raids = {
    ["Gruul's Lair"] = {
        ["phase"] = 1,
        ['index']= 1,
        [649] = "High King Maulgar",
        [650] = "Gruul the Dragonkiller",
    },
    ["Magtheridon's Lair"] = {
        ["phase"] = 1,
        ['index']= 2,
        [651] = "Magtheridon",
    },
    ["Serpentshrine Cavern"] = {
        ["phase"] = 2,
        ['index']= 3,
        [623] = "Hydross the Unstable",
        [624] = "The Lurker Below",
        [625] = "Leotheras the Blind",
        [626] = "Fathom-Lord Karathress",
        [627] = "Morogrim Tidewalker",
        [628] = "Lady Vashj",
    },
    ["Tempest Keep"] = {
        ["phase"] = 2,
        ['index']= 4,
        [730] = "Al'ar",
        [731] = "Void Reaver",
        [732] = "High Astromancer Solarian",
        [733] = "Kael'thas Sunstrider",
    },
    ["The Battle for Mount Hyjal"] = {
        ["phase"] = 3,
        ['index']= 5,
        [618] = "Rage Winterchill",
        [619] = "Anetheron",
        [620] = "Kaz'rogal",
        [621] = "Azgalor",
        [622] = "Archimonde",
    },
    ["Black Temple"] = {
        ["phase"] = 3,
        ['index']= 6,
        [601] = "High Warlord Naj'entus",
        [602] = "Supremus",
        [603] = "Shade of Akama",
        [604] = "Teron Gorefiend",
        [605] = "Gurtogg Bloodboil",
        [606] = "Reliquary of Souls",
        [607] = "Mother Shahraz",
        [608] = "The Illidari Council",
        [609] = "Illidan Stormrage",
    },
    ["The Sunwell"] = {
        ["phase"] = 5,
        ['index']= 7,
        [724] = "Kalecgos",
        [725] = "Brutallus",
        [726] = "Felmyst",
        [727] = "Eredar Twins",
        [728] = "M'uru",
        [729] = "Kil'jaeden",
    },
}

Defaults.raid_names = {}
Defaults.raid_indexes = {}
Defaults.boss_names = {}
Defaults.boss_ids = {}

do
    for raid, raid_table in pairs(Defaults.raids) do
        local raid_phase = tostring(raid_table['phase'])
        if raid_phase <= Defaults.phase then
            tinsert(Defaults.raid_names, raid)
            Defaults.raid_indexes[raid] = raid_table['index']
            for boss_id, boss in pairs(raid_table) do
                tinsert(Defaults.boss_names, boss)
            end
        end
    end

    tsort(Defaults.raid_names, function(a,b) return Defaults.raid_indexes[a] < Defaults.raid_indexes[b] end)
end







--[[Defaults.raids = {
--    'Gruul\'s Lair',
--    'Magtheridon\'s Lair',
--    'Serpentshrine Cavern',
--    'Tempest Keep: The Eye',
--    'Battle for Mount Hyjal',
--    'Black Temple',
--    'Sunwell Plateau',
--}
--Defaults.raid_boss_names = {
--    ["Gruul's Lair"] = {
--        "High King Maulgar",
--        "Gruul the Dragonkiller",
--    },
--    ["Magtheridon's Lair"] = {
--        "Magtheridon",
--    },
--    ["Serpentshrine Cavern"] = {
--        "Hydross the Unstable",
--        "The Lurker Below",
--        "Leotheras the Blind",
--        "Fathom-Lord Karathress",
--        "Morogrim Tidewalker",
--        "Lady Vashj",
--    },
--    ["Tempest Keep"] = {
--        "Al'ar",
--        "Void Reaver",
--        "High Astromancer Solarian",
--        "Kael'thas Sunstrider",
--    },
--    ["Battle for Mount Hyjal"] = {
--        "Rage Winterchill",
--        "Anetheron",
--        "Kaz'rogal",
--        "Azgalor",
--        "Archimonde",
--    },
--    ["Black Temple"] = {
--        "High Warlord Naj'entus",
--        "Supremus",
--        "Shade of Akama",
--        "Teron Gorefiend",
--        "Gurtogg Bloodboil",
--        "Reliquary of Souls",
--        "Mother Shahraz",
--        "The Illidari Council",
--        "Illidan Stormrage",
--    },
--    ["The Sunwell"] = {
--        "Kalecgos",
--        "Brutallus",
--        "Felmyst",
--        "Eredar Twins",
--        "M'uru",
--        "Kil'jaeden",
--    },
--}
--Defaults.boss_ids = {
--    [649] = "High King Maulgar",
--    [650] = "Gruul the Dragonkiller",
--    [651] = "Magtheridon",
--    [623] = "Hydross the Unstable",
--    [624] = "The Lurker Below",
--    [625] = "Leotheras the Blind",
--    [626] = "Fathom-Lord Karathress",
--    [627] = "Morogrim Tidewalker",
--    [628] = "Lady Vashj",
--    [730] = "Al'ar",
--    [731] = "Void Reaver",
--    [732] = "High Astromancer Solarian",
--    [733] = "Kael'thas Sunstrider",
--    [618] = "Rage Winterchill",
--    [619] = "Anetheron",
--    [620] = "Kaz'rogal",
--    [621] = "Azgalor",
--    [622] = "Archimonde",
--    [601] = "High Warlord Naj'entus",
--    [602] = "Supremus",
--    [603] = "Shade of Akama",
--    [604] = "Teron Gorefiend",
--    [605] = "Gurtogg Bloodboil",
--    [606] = "Reliquary of Souls",
--    [607] = "Mother Shahraz",
--    [608] = "The Illidari Council",
--    [609] = "Illidan Stormrage",
--    [724] = "Kalecgos",
--    [725] = "Brutallus",
--    [726] = "Felmyst",
--    [727] = "Eredar Twins",
--    [728] = "M'uru",
--    [729] = "Kil'jaeden",
--}
--
--Defaults.dkp_raids = {
--    'Gruul\'s Lair',
--    'Magtheridon\'s Lair',
--    'Serpentshrine Cavern',
--    'Tempest Keep: The Eye',
--    'Battle for Mount Hyjal',
--    'Black Temple',
--    'Sunwell Plateau',
--};
--Defaults.raidBosses = {
--    ["Gruul's Lair"] = {
--        "High King Maulgar",
--        "Gruul the Dragonkiller",
--    },
--    ["Magtheridon's Lair"] = {
--        "Magtheridon",
--    },
--    ["Serpentshrine Cavern"] = {
--        "Hydross the Unstable",
--        "The Lurker Below",
--        "Leotheras the Blind",
--        "Fathom-Lord Karathress",
--        "Morogrim Tidewalker",
--        "Lady Vashj",
--    },
--    ["Tempest Keep"] = {
--        "Al'ar",
--        "Void Reaver",
--        "High Astromancer Solarian",
--        "Kael'thas Sunstrider",
--    },
--    ["Battle for Mount Hyjal"] = {
--        "Rage Winterchill",
--        "Anetheron",
--        "Kaz'rogal",
--        "Azgalor",
--        "Archimonde",
--    },
--    ["Black Temple"] = {
--        "High Warlord Naj'entus",
--        "Supremus",
--        "Shade of Akama",
--        "Teron Gorefiend",
--        "Gurtogg Bloodboil",
--        "Reliquary of Souls",
--        "Mother Shahraz",
--        "The Illidari Council",
--        "Illidan Stormrage",
--    },
--    ["The Sunwell"] = {
--        "Kalecgos",
--        "Brutallus",
--        "Felmyst",
--        "Eredar Twins",
--        "M'uru",
--        "Kil'jaeden",
--    },
]]--};
