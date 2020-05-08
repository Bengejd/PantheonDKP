local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Raid = core.Raid;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Import = core.import;

local englishFaction, _ = UnitFactionGroup("PLAYER");

local SettingsDB;

local pdkpSettingsDefaults = {
    profile = {
        silent = false,
        debug = false,
        sortBy = nil,
        sortDir = nil,
        syncInRaid = false,
    }
}

PDKP.data = {}
PDKP.raidData = {}
core.initialized = false
core.sortBy = nil
core.sortDir = nil
core.filterOffline = nil
core.pdkp_frame = nil;
core.canEdit = false;

core.defaults = {
    -- ADDON INFO
    addon_version = GetAddOnMetadata('PantheonDKP', "Version"),
    addon_name = 'PantheonDKP',
    bank_name = 'Pantheonbank',
    addon_latest_version = GetAddOnMetadata('PantheonDKP', "Version"),
    checked_addion_version = false,

    debug = true,
    no_broadcast = false,

    -- PLAYER INFO
    playerUID = UnitGUID("PLAYER"), -- Unique Blizzard Player ID
    isInGuild = IsInGuild(), -- Boolean
    faction = englishFaction, -- Alliance or Horde

    -- UTILTIY INFO
    classes = { -- Utility table of the available classes for that player's faction.
        'Druid', 'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Warlock', 'Warrior', },
    class_colors = { -- Utility table of the available class colors for that player's faction.
        ["Druid"] = { r = 1, g = 0.49, b = 0.04, hex = "FF7D0A" },
        ["Hunter"] = {r = 0.67, g = 0.83, b = 0.45, hex = "ABD473" },
        ["Mage"] = { r = 0.25, g = 0.78, b = 0.92, hex = "40C7EB" },
        ["Paladin"] = { r = 0.96, g = 0.55, b = 0.73, hex = "F58CBA" },
        ["Priest"] = { r = 1, g = 1, b = 1, hex = "FFFFFF" },
        ["Rogue"] = { r = 1, g = 0.96, b = 0.41, hex = "FFF569" },
        ["Warlock"] = { r = 0.53, g = 0.53, b = 0.93, hex = "8787ED" },
        ["Warrior"] = { r = 0.78, g = 0.61, b = 0.43, hex = "C79C6E" }
    }
}

-- Creates and assigns the Guild Database.
function core.defaults:InitDB()
    Util:Debug('DefaultsDB init');

    core.defaults.db = LibStub("AceDB-3.0"):New("pdkp_settingsDB", pdkpSettingsDefaults, true);
    SettingsDB = core.defaults.db.profile;
    core.defaults.db = SettingsDB;
    core.defaults.SettingsDB = SettingsDB
end

function core.defaults:IsDebug()
    if SettingsDB then
       return SettingsDB.debug;
    end
    return false;
end

function core.defaults:ToggleDebugging()
    SettingsDB.debug = not SettingsDB.debug

    PDKP:Print('Debugging Enabled: ' .. tostring(SettingsDB.debug))
end

function core.defaults:SyncInRaid()
    local syncInRaid = SettingsDB.syncInRaid
    local isInInstance = Raid:IsInInstance()

    if isInInstance then -- We're in an instance, do what they have it set to.
        return syncInRaid -- (Defaults to false)
    else -- Not in an instance, don't care about their preference.
        return true
    end
end

core.GUI = {
    shown = false;
    sortBy = nil;
    sortDir = 'ASC';
    pdkp_frame = nil;
    lastEntryClicked = nil;
    sliderVal = 1;
    hasTimer = false;
}



core.raids = {
    'Onyxia\'s Lair',
    'Molten Core',
    'Blackwing Lair',
--    'Ahn\'Qiraj',
    --    'Naxxramas',
}

core.raidBosses = {
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
}

core.bossIDS = {
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
