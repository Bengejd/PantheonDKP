local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES

local Constants = {}

local GetAddOnMetadata = GetAddOnMetadata
local tinsert, tsort, strupper, tostring = tinsert, table.sort, string.upper, tostring;

Constants.ADDON_HEX = '33FF99'
Constants.SLASH_HEX = 'ffaeae';
Constants.ADDON_NAME = 'PantheonDKP'
Constants.COLORED_ADDON_SHORT = '|cff33ff99PDKP|r'
Constants.SLASH_ADDON = '|cff33ff99/pdkp|r'

Constants.PHASE = GetAddOnMetadata('PantheonDKP', 'X-Phase')

Constants.BANK_NAME = "Testing" -- TODO: Factor this out of Member class, and into a setting.

-- The TBC classic classes
Constants.CLASSES = { 'Druid', 'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior' }
-- The TBC Classic Class colors
Constants.CLASS_COLORS = {
    ["Druid"] = "FF7C0A", ["Hunter"] = "AAD372" , ["Mage"] = "3FC7EB", ["Paladin"] = "F48CBA",
    ["Priest"] = "FFFFFF", ["Rogue"] = "FFF468", ["Shaman"]="0070DD", ["Warlock"] = "8788EE", ["Warrior"] = "C69B6D"
}

Constants.RAID_NAMES = {}
Constants.RAID_INDEXES = {}
Constants.RAID_BOSSES = {}
Constants.BOSS_TO_RAID = {}
Constants.RAIDS = {
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


-- Setup RAID_NAMES, RAID_INDEXES, BOSS_NAMES, BOSS_IDS
do
    for raid, raid_table in pairs(Constants.RAIDS) do
        local raid_phase = tostring(raid_table['phase'])
        if raid_phase <= Constants.PHASE then
            tinsert(Constants.RAID_NAMES, raid)
            Constants.RAID_INDEXES[raid] = raid_table['index']

            local raidInfo = {
                ['id_to_name'] = {},
                ['name_to_id'] = {},
                ['boss_names'] = {}
            }
            for index, value in pairs(raid_table) do
                if type(index) == "number" then
                    raidInfo['id_to_name'][index] = value
                    raidInfo['name_to_id'][value] = index
                    tinsert(raidInfo['boss_names'], value)
                    Constants.BOSS_TO_RAID[value] = raid
                end
            end

            tsort(raidInfo['boss_names'], function(a, b)
                return raidInfo['name_to_id'][a] < raidInfo['name_to_id'][b]
            end)

            Constants.RAID_BOSSES[raid] = raidInfo
        end
    end

    tsort(Constants.RAID_NAMES, function(a,b) return Constants.RAID_INDEXES[a] < Constants.RAID_INDEXES[b] end)
end






-- Publish API
MODULES.Constants = Constants