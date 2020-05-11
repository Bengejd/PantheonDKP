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
local Import = core.import;

core.defaults = {
    -- ADDON INFO
    addon_version = GetAddOnMetadata('PantheonDKP', "Version"),
    addon_name = 'PantheonDKP',
    bank_name = 'Pantheonbank',
    addon_latest_version = GetAddOnMetadata('PantheonDKP', "Version"),
    checked_addion_version = false,
    print_name = '|cff33ff99PDKP|r:',
    settings_complete = false,

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
local Defaults = core.defaults;

local englishFaction, _ = UnitFactionGroup("PLAYER");

local SettingsDB;

local pdkpSettingsDefaults = {
    profile = {
        silent = false,
        debug = false,
        sortBy = nil,
        sortDir = nil,
        errors = false,
        previous_version = '2.3.2',
        changelog_shown = false,
        sync = {
            pvp = false,
            dungeons = false,
            raids = false
        }
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

function Defaults:CheckChangelog()
    local shownChange = not SettingsDB.changelog_shown and PDKP:CheckForUpdate(SettingsDB.previous_version, true);
    if (shownChange or SettingsDB.debug) and PDKP.changeLog ~= nil then
        PDKP.changeLog:Show()
        SettingsDB.changelog_shown = true
        SettingsDB.previous_version = GetAddOnMetadata('PantheonDKP', "Version")
    end
end

-- Creates and assigns the Guild Database.
function Defaults:InitDB()
    Util:Debug('DefaultsDB init');

    core.defaults.db = LibStub("AceDB-3.0"):New("pdkp_settingsDB", pdkpSettingsDefaults, true);
    SettingsDB = core.defaults.db.profile;
    core.defaults.db = SettingsDB;
    core.defaults.SettingsDB = SettingsDB
    Defaults.SettingsDB = SettingsDB;
end

function Defaults:IsDebug()
    if SettingsDB then
       return SettingsDB.debug;
    end
    return false;
end

function Defaults:ToggleDebugging()
    SettingsDB.debug = not SettingsDB.debug
    print(Defaults.print_name .. ' Debugging Enabled: ' .. tostring(SettingsDB.debug))
end

function Defaults:AllowSync()
    local _, type, _, _, _, _, _, _, _ = GetInstanceInfo()
    if type == 'party' then
        return SettingsDB.sync.dungeons
    elseif type == 'raid' then
        return SettingsDB.sync.raid
    elseif type == 'pvp' then
        return SettingsDB.sync.pvp
    end
    return true;
end

function Defaults:TogglePrinting(val)
    if val ~= nil then
        if val then
            PDKP.Print = function() end;
        elseif Defaults.SettingsDB.silent ~= val and not val then
            print('|cff33ff99PDKP|r: A reload is required for printing to be re-enabled');
        end
    end

    Defaults.SettingsDB.silent = val
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

Defaults.changelog = {
    version='2.4.2',
    features= {
        name='New Features',
        changes = {
            {
                name="Addon Settings Interface",
                list = {
                    'Right click the minimap icon to open settings interface',
                    'Enable / Disable Notifications', 'Enable / Disable DKP syncing in \n Instances, Raids or Battlegrounds.',
                }
            },
            {
                name="Addon Settings Interface",
                list = {
                    'Enable / Disable Notifications', 'Enable / Disable DKP syncing in \n Instances, Raids or Battlegrounds.',
                }
            }
        }
    },
    bugFixes= {
        name='Bug Fixes',
        changes =  {
            { name="Raid Tools", list = {
                    'Now usable by anyone, not just officers or assistants.', 'Spam text resets if it\'s empty when the raid-tools window is closed.',
                },
            },
            { name="Lockout Timers", list = {
                    'Timer format has been changed to be more readable.',
                },
            },
            { name="Syncing", list = {
                    'Sync allowances is now handled by addon infterface settings. This will prevent syncs from occurring in the middle of raids.',
                },
            },
            { name="Shrouding Window", list = {
                    'I believe I fixed the shrouding window sizing issue. TBD though as it is hard to consistently reproduce.',
                },
            },
        }
    },
    itemPrio= {
        name='Prio Changes',
        changes =  {
            {
                name="Robes of Volatile Power",
                list = {
                    'Fixed Robes of Volatile Power. Paladins are now equal.'
                }
            }
        }
    },
}
