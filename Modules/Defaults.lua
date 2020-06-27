local _, core = ...;
local _G = _G;
local L = core.L;

local Defaults = core.Defaults;

core.Defaults = {

    addon_version = GetAddOnMetadata('PantheonDKP', "Version"),
    addon_name = 'PantheonDKP',
    bank_name = 'Pantheonbank',
    addon_latest_version = GetAddOnMetadata('PantheonDKP', "Version"),
    print_name = '|cff33ff99PDKP|r:',

    debug = true,
    no_broadcast = false,

    -- PLAYER INFO
    playerUID = UnitGUID("PLAYER"), -- Unique Blizzard Player ID
    isInGuild = IsInGuild(), -- Boolean
    faction = englishFaction, -- Alliance or Horde

    classes = { 'Druid', 'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Warlock', 'Warrior' };
    class_colors = {
        ["Druid"] = "FF7D0A", ["Hunter"] = "ABD473" , ["Mage"] = "40C7EB", ["Paladin"] = "F58CBA",
        ["Priest"] = "FFFFFF", ["Rogue"] = "FFF569", ["Warlock"] = "8787ED", ["Warrior"] = "C79C6E"
    };
    raids = {
        'Onyxia\'s Lair',
        'Molten Core',
        'Blackwing Lair',
        --    'Ahn\'Qiraj',
        --    'Naxxramas',
    };
    raidBosses = {
        ["Onyxia's Lair"] = {
            'Onyxia'
        },
        ["Molten Core"] = {
            "Lucifron",
            'Magmadar',
            'Gehennas',
            'Garr',
            'Shazzrah',
            'Baron Geddon',
            'Sulfuron Harbinger',
            'Golemagg the Incinerator',
            'Majordomo Executus',
            'Ragnaros',
        },
        ["Blackwing Lair"] = {
            "Razorgore the Untamed",
            "Vaelastrasz the Corrupt",
            "Broodlord Lashlayer",
            "Firemaw",
            "Ebonroc",
            "Flamegor",
            "Chromaggus",
            "Nefarian",
        },
        ['Ahn\'Qiraj']={
            "The Prophet Skeram",
            "Bug Trio",
            "Battleguard Satura",
            "Fankriss the Unyeilding",
            "Viscidus",
            "Princess Huhuran",
            "Twin Emperors",
            "Ouro",
            "C\'Thun"
        },
        ['Naxxramas']={
            "Anub\'Rekhan",
            "Grand Widow Faerlina",
            "Maexxna",
            "Noth the Plaguebringer",
            "Heigan the Unclean",
            "Loatheb",
            "Instructor Razuvious",
            "Gothik the Harvester",
            "The Four Horsemen",
            "Patchwerk",
            "Grobbulus",
            "Gluth",
            "Thaddius",
            "Sapphiron",
            "Kel\'Thuzad",
        },
    };
    bossIDS = {
        ["Onyxia's Lair"] = {
            [1084] = "Onyxia"
        },
        ["Molten Core"] = {
            [663] = "Lucifron",
            [664] = 'Magmadar',
            [665] = 'Gehennas',
            [666] = 'Garr',
            [667] = 'Shazzrah',
            [668] = 'Baron Geddon',
            [669] = 'Sulfuron Harbinger',
            [670] = 'Golemagg the Incinerator',
            [671] = 'Majordomo Executus',
            [672] = 'Ragnaros',
        },
        ["Blackwing Lair"] = {
            [610] = "Razorgore the Untamed",
            [611] = "Vaelastrasz the Corrupt",
            [612] = "Broodlord Lashlayer",
            [613] = "Firemaw",
            [614] = "Ebonroc",
            [615] = "Flamegor",
            [616] =  "Chromaggus",
            [617] = "Nefarian",
        },
        ['Ahn\'Qiraj']={
            [709] = 'The Prophet Skeram',
            [710] = 'Bug Trio',
            [711] = 'Battleguard Satura',
            [712] = 'Fankriss the Unyeilding',
            [713] = 'Viscidus',
            [714] = 'Princess Huhuran',
            [715] = 'Twin Emperors',
            [716] = 'Ouro',
            [717] = 'C\'Thun',
        },
        ['Naxxramas']={
            [1107] = 'Anub\'Rekhan',
            [1108] = 'Gluth',
            [1109] = 'Gothik the Harvester',
            [1110] = 'Grand Widow Faerlina',
            [1111] = 'Grobbulus',
            [1112] = 'Heigan the Unclean',
            [1113] = 'Instructor Razuvious',
            [1114] = 'Kel\'Thuzad',
            [1115] = 'Loatheb',
            [1116] = 'Maexxna',
            [1117] = 'Noth the Plaguebringer',
            [1118] = 'Patchwerk',
            [1119] = 'Sapphiron',
            [1120] = 'Thaddius',
            [1121] = 'The Four Horsemen',
        },
    }
}

-- Returns all Alliance classes in WoW Classic.
function Defaults:GetAllClasses()
    return Defaults.classes;
end

function Defaults:GetClassColor(class)
    return class_colors[class]
end

function Defaults:GetClassColoredName(name, class)
    local classColor = Util:GetClassColor(class)
    return Util:FormatFontTextColor(classColor, name)
end
