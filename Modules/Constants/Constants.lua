local _, PDKP = ...

local MODULES = PDKP.MODULES

local Constants = {}

local GetAddOnMetadata = GetAddOnMetadata
local tinsert, tsort, pairs = tinsert, table.sort, pairs;
local tonumber, type = tonumber, type

Constants.ADDON_HEX = '33FF99'
Constants.SLASH_HEX = 'ffaeae';
Constants.ADDON_NAME = 'PantheonDKP'
Constants.COLORED_ADDON_SHORT = '|cff33ff99PDKP|r'
Constants.SLASH_ADDON = '|cff33ff99/pdkp|r'

Constants.PHASE = tonumber(GetAddOnMetadata('PantheonDKP', 'X-Phase'))

Constants.SUCCESS = '22bb33'
Constants.WARNING = 'E71D36'

-- The WOTLK classic classes
Constants.CLASSES = { 'Druid', 'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior', 'Death Knight' }
-- The WOTLK Classic Class colors
Constants.CLASS_COLORS = {
    ["Druid"] = "FF7C0A", ["Hunter"] = "AAD372", ["Mage"] = "3FC7EB", ["Paladin"] = "F48CBA",
    ["Priest"] = "FFFFFF", ["Rogue"] = "FFF468", ["Shaman"] = "0070DD", ["Warlock"] = "8788EE", ["Warrior"] = "C69B6D",
    ['Death Knight'] = 'C41E3A'
}

Constants.RAID_NAMES = {} -- 'Gruul's Lair', 'Tempest Keep', ...
Constants.RAID_INDEXES = {} -- ['Gruul's Lair'] = 1
Constants.RAID_BOSSES = {} -- ['Gruul's Lair'] = { ['id_to_name'] = ..., ['name_to_id'] = ..., ['boss_names'] = ...
Constants.BOSS_TO_RAID = {} -- ['High King Maulgar'] = 'Gruul's Lair'
Constants.ID_TO_BOSS_NAME = {};
Constants.RAIDS = {
    ["Vault of Archavon"] = {
        ["phase"] = 1,
        ['index'] = 1,
        [1126] = "Archavon the Stone Watcher",
        [1127] = "Emalon the Storm Watcher",
        [1128] = "Toravon the Ice Watcher",
        [1129] = "Koralon the Flame Watcher",
    },
    ["Naxxramas"] = {
        ["phase"] = 1,
        ['index'] = 2,
        [1107] = "Anub'Rekhan",
        [1108] = "Gluth",
        [1109] = "Gothik the Harvester",
        [1110] = "Grand Widow Faerlina",
        [1111] = "Grobbulus",
        [1112] = "Heigan the Unclean",
        [1113] = "Instructor Razuvious",
        [1114] = "Kel'Thuzad",
        [1115] = "Loatheb",
        [1116] = "Maexxna",
        [1117] = "Noth the Plaguebringer",
        [1118] = "Patchwerk",
        [1119] = "Sapphiron",
        [1120] = "Thaddius",
        [1121] = "The Four Horsemen",
    },
    ["The Obsidian Sanctum"] = {
        ["phase"] = 1,
        ['index'] = 3,
        [1090] = "Sartharion",
        [1091] = "Shadron",
        [1092] = "Tenebron",
        [1093] = "Vesperon",
    },
    ["The Eye of Eternity"] = {
        ["phase"] = 1,
        ['index'] = 4,
        [1094] = "Malygos",
    },
    ["Ulduar"] = {
        ["phase"] = 2,
        ['index'] = 5,
        [1130] = "Algalon the Observer",
        [1131] = "Auriaya",
        [1132] = "Flame Leviathan",
        [1133] = "Freya",
        [1134] = "General Vezax",
        [1135] = "Hodir",
        [1136] = "Ignis the Furnace Master",
        [1137] = "Kologarn",
        [1138] = "Mimiron",
        [1139] = "Razorscale",
        [1140] = "The Assembly of Iron",
        [1141] = "Thorim",
        [1142] = "XT-002 Deconstructor",
        [1143] = "Yogg-Saron",
    },
    ["Trial of the Crusader"] = {
        ["phase"] = 3,
        ['index'] = 6,
        [1085] = "Anub'arak",
        [1086] = "Faction Champions",
        [1087] = "Lord Jaraxxus",
        [1088] = "Northrend Beasts",
        [1089] = "Val'kyr Twins",
    },
    ["Onyxia's Lair"] = {
        ["phase"] = 4,
        ['index'] = 7,
        [1084] = "Onyxia",
        [1086] = "Faction Champions",
    },
    ["Icecrown Citadel"] = {
        ["phase"] = 5,
        ['index'] = 8,
        [1095] = "Blood Council",
        [1096] = "Deathbringer Saurfang",
        [1097] = "Festergut",
        [1098] = "Valithria Dreamwalker",
        [1099] = "Icecrown Gunship Battle",
        [1100] = "Lady Deathwhisper",
        [1101] = "Lord Marrowgar",
        [1102] = "Professor Putricide",
        [1103] = "Queen Lana'thel",
        [1104] = "Rotface",
        [1105] = "Sindragosa",
        [1106] = "The Lich King",
    },
    ["The Ruby Sanctum"] = {
        ["phase"] = 6,
        ['index'] = 9,
        [1147] = "Baltharus the Warborn",
        [1148] = "General Zarithrian",
        [1149] = "Saviana Ragefire",
        [1150] = "Halion",
    },
}


-- Setup RAID_NAMES, RAID_INDEXES, BOSS_NAMES, BOSS_IDS
do
    for raid, raid_table in pairs(Constants.RAIDS) do
        local raid_phase = tonumber(raid_table['phase'])
        if raid_phase <= Constants.PHASE then
            tinsert(Constants.RAID_NAMES, raid)
            Constants.RAID_INDEXES[raid] = raid_table['index']

            local raidInfo = {
                ['id_to_name'] = {},
                ['name_to_id'] = {},
                ['boss_names'] = {},
                ['encounterIds'] = {};
            }
            for encounterID, encounterName in pairs(raid_table) do
                if type(encounterID) == "number" then
                    raidInfo['id_to_name'][encounterID] = encounterName
                    raidInfo['name_to_id'][encounterName] = encounterID
                    tinsert(raidInfo['boss_names'], encounterName)
                    tinsert(raidInfo['encounterIds'], encounterID)
                    Constants.BOSS_TO_RAID[encounterName] = raid
                    Constants.ID_TO_BOSS_NAME[encounterID] = encounterName
                end
            end

            tsort(raidInfo['boss_names'], function(a, b)
                return raidInfo['name_to_id'][a] < raidInfo['name_to_id'][b]
            end)

            Constants.RAID_BOSSES[raid] = raidInfo
        end
    end

    tsort(Constants.RAID_NAMES, function(a, b)
        return Constants.RAID_INDEXES[a] < Constants.RAID_INDEXES[b]
    end)
end


Constants.TIER_GEAR = {
    ['Bracers of the Forgotten Conqueror'] = {"Paladin", "Priest", "Warlock"},
    ['Bracers of the Forgotten Protector'] = {"Hunter", "Shaman", "Warrior"},
    ['Bracers of the Forgotten Vanquisher'] = {"Druid", "Mage", "Rogue"},
    ['Belt of the Forgotten Conqueror'] = {"Paladin", "Priest", "Warlock"},
    ['Belt of the Forgotten Vanquisher'] = {"Druid", "Mage", "Rogue"},
    ['Belt of the Forgotten Protector'] = {"Hunter", "Shaman", "Warrior"},
    ['Boots of the Forgotten Conqueror'] = {"Paladin", "Priest", "Warlock"},
    ['Boots of the Forgotten Protector'] = {"Hunter", "Shaman", "Warrior"},
    ['Boots of the Forgotten Vanquisher'] = {"Druid", "Mage", "Rogue"},
    ['Chestguard of the Forgotten Vanquisher'] = {"Druid", "Mage", "Rogue"},
    ['Chestguard of the Forgotten Protector'] = {"Hunter", "Shaman", "Warrior"},
    ['Chestguard of the Forgotten Conqueror'] = {"Paladin", "Priest", "Warlock"},
    ['Helm of the Forgotten Conqueror'] = {"Paladin", "Priest", "Warlock"},
    ['Helm of the Forgotten Protector'] = {"Hunter", "Shaman", "Warrior"},
    ['Helm of the Forgotten Vanquisher'] = {"Druid", "Mage", "Rogue"},
    ['Gloves of the Forgotten Conqueror'] = {"Paladin", "Priest", "Warlock"},
    ['Gloves of the Forgotten Protector'] = {"Hunter", "Shaman", "Warrior"},
    ['Gloves of the Forgotten Vanquisher'] = {"Druid", "Mage", "Rogue"},
    ['Pauldrons of the Forgotten Protector'] = {"Hunter", "Shaman", "Warrior"},
    ['Pauldrons of the Forgotten Conqueror'] = {"Paladin", "Priest", "Warlock"},
    ['Pauldrons of the Forgotten Vanquisher'] = {"Druid", "Mage", "Rogue"},
    ['Chestguard of the Vanquished Defender'] = {"Druid", "Priest", "Warrior"},
    ['Chestguard of the Vanquished Champion'] = {"Paladin", "Rogue", "Shaman"},
    ['Gloves of the Vanquished Defender'] = {"Druid", "Priest", "Warrior"},
    ['Chestguard of the Vanquished Hero'] = {"Hunter", "Mage", "Warlock"},
    ['Gloves of the Vanquished Champion'] = {"Paladin", "Rogue", "Shaman"},
    ['Gloves of the Vanquished Hero'] = {"Hunter", "Mage", "Warlock"},
    ['Leggings of the Vanquished Hero'] = {"Hunter", "Mage", "Warlock"},
    ['Leggings of the Vanquished Champion'] = {"Paladin", "Rogue", "Shaman"},
    ['Leggings of the Vanquished Defender'] = {"Druid", "Priest", "Warrior"},
    ['Helm of the Vanquished Defender'] = {"Druid", "Priest", "Warrior"},
    ['Helm of the Vanquished Hero'] = {"Hunter", "Mage", "Warlock"},
    ['Helm of the Vanquished Champion'] = {"Paladin", "Rogue", "Shaman"},
    ['Pauldrons of the Vanquished Defender'] = {"Druid", "Priest", "Warrior"},
    ['Pauldrons of the Vanquished Champion'] = {"Paladin", "Rogue", "Shaman"},
    ['Pauldrons of the Vanquished Hero'] = {"Hunter", "Mage", "Warlock"},
    ['Chestguard of the Fallen Hero'] = {"Hunter", "Mage", "Warlock"},
    ['Chestguard of the Fallen Defender'] = {"Druid", "Priest", "Warrior"},
    ['Chestguard of the Fallen Champion'] = {"Paladin", "Rogue", "Shaman"},
    ['Leggings of the Fallen Hero'] = {"Hunter", "Mage", "Warlock"},
    ['Leggings of the Fallen Defender'] = {"Druid", "Priest", "Warrior"},
    ['Leggings of the Fallen Champion'] = {"Paladin", "Rogue", "Shaman"},
    ['Pauldrons of the Fallen Champion'] = {"Paladin", "Rogue", "Shaman"},
    ['Pauldrons of the Fallen Hero'] = {"Hunter", "Mage", "Warlock"},
    ['Pauldrons of the Fallen Defender'] = {"Druid", "Priest", "Warrior"},
    ['Helm of the Fallen Defender'] = {"Druid", "Priest", "Warrior"},
    ['Helm of the Fallen Hero'] = {"Hunter", "Mage", "Warlock"},
    ['Helm of the Fallen Champion'] = {"Paladin", "Rogue", "Shaman"},
    ['Gloves of the Fallen Defender'] = {"Druid", "Priest", "Warrior"},
    ['Gloves of the Fallen Hero'] = {"Hunter", "Mage", "Warlock"},
    ['Gloves of the Fallen Champion'] = {"Paladin", "Rogue", "Shaman"},
    ['Leggings of the Forgotten Conqueror'] = {"Paladin", "Priest", "Warlock"},
    ['Leggings of the Forgotten Vanquisher'] = {"Druid", "Mage", "Rogue"},
    ['Leggings of the Forgotten Protector'] = {"Hunter", "Shaman", "Warrior"},
};



-- Publish API
MODULES.Constants = Constants
