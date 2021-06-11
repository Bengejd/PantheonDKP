local _G = _G
local AddonName, _ = ...

local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')
local PDKP = AceAddon:NewAddon(AddonName, "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")

PDKP.Media = {}
PDKP.GUI = {}
PDKP.DKP = {}
PDKP.Settings = {}
PDKP.Guild = {}
PDKP.Util = {}
PDKP.Character = {}
PDKP.Raid = {}
PDKP.Defaults = {}
PDKP.Member = {}
PDKP.Setup = {}
PDKP.Loot = {}
PDKP.Shroud = {}
PDKP.Comms = {}
PDKP.ScrollTable = {}
PDKP.DKP_Entry = {}
PDKP.HistoryTable = {}
PDKP.SimpleScrollFrame = {}
PDKP.Minimap = {}
PDKP.Export = {}
PDKP.Import = {}
PDKP.Events = {}
PDKP.Dev = {}

PDKP.ldb = _G.LibStub:GetLibrary("LibDataBroker-1.1")
PDKP.cbh = _G.LibStub("CallbackHandler-1.0"):New(PDKP)
PDKP.LibDeflate = _G.LibStub:GetLibrary("LibDeflate")
PDKP.AceDB = _G.LibStub:GetLibrary("AceDB-3.0")

local PDKP_Instances = {
    ['Media']=PDKP.Media,
    ['GUI']=PDKP.GUI,
    ['DKP']=PDKP.DKP,
    ['Settings']=PDKP.Settings,
    ['Guild']=PDKP.Guild,
    ['Util']=PDKP.Util,
    ['Character']=PDKP.Character,
    ['Raid']=PDKP.Raid,
    ['Defaults']=PDKP.Defaults,
    ['Member']=PDKP.Member,
    ['Setup']=PDKP.Setup,
    ['Loot']=PDKP.Loot,
    ['Shroud']=PDKP.Shroud,
    ['Comms']=PDKP.Comms,
    ['ScrollTable']=PDKP.ScrollTable,
    ['DKP_Entry']=PDKP.DKP_Entry,
    ['HistoryTable']=PDKP.HistoryTable,
    ['SimpleScrollFrame']=PDKP.SimpleScrollFrame,
    ['Minimap']=PDKP.Minimap,
    ['Export']=PDKP.Export,
    ['Import']=PDKP.Import,
    ['Events']=PDKP.Events,
    ['Dev']=PDKP.Dev
}

-- Assign a variable tableName to all of our instances, for easier debugging.
do
    for key, instTable in pairs(PDKP_Instances) do
        instTable.instTableName = key
    end
end

local unpack, pairs = unpack, pairs

PDKP.dbDefaults = {
    ['global'] = {
        ['db'] = {
            ['guildDB'] = {
                ['members'] = {},
                ['numOfMembers'] = 0
            },
            ['pugDB'] = {},
            ['officersDB'] = {},
            ['dkpDB'] = {
                ['lastEdit'] = 0,
                ['history'] = {},
                ['old_entries']= {},
            },
            ['settingsDB'] = {
                ['minimapPos'] = 207,
                ['debug'] = false,
                ['ignore_from']={},
                ['minimap']={},
                ['sync'] = {
                    ['pvp'] = true,
                    ['raids'] = true,
                    ['dungeons'] = true
                },
                ['notifications'] = true,
                ['debug'] = false,

            },
            ['testDB']={},
        }
    }
}

_G.PDKP = PDKP

function PDKP:InitializeDatabases()
    local Dev = PDKP:GetInst('Dev')
    local database = PDKP.AceDB:New("pdkp_DB", PDKP.dbDefaults, true)

    database.global = PDKP.dbDefaults['global']

    if database['global'] == nil or next(database.global) == nil then
        Dev:Print('Creating PDKP Database with default values')
        database.global = PDKP.dbDefaults['global']
    end

    local db = database.global['db']
    PDKP.db = db

    PDKP.guildDB = db.guildDB -- or {};
    PDKP.officersDB = db.officersDB -- or {};
    PDKP.settingsDB = db.settingsDB -- or {};
    PDKP.dkpDB = db.dkpDB
    PDKP.testDB = db.testDB
    PDKP.pugDB = db.pugDB

    Dev:Print("Databases finished Initializing")
end

-- Simple way of initializing a bunch of different modules, instead of going through them line by line.
function PDKP:InitializeAddonModules()
    PDKP.Dev:Print('InitializingAddonModules')
    local InitModules = {
        PDKP.Util,
        PDKP.Settings, PDKP.DKP, PDKP.Character, PDKP.Guild, PDKP.GUI, PDKP.Raid, PDKP.Minimap,
    }

    for _, instance in ipairs(InitModules) do
        local funcs = { instance.InitDB, instance.Init, instance.New }
        for _, func in pairs(funcs) do
            if func then
                func()
                instance.initialized = true
                break
            end
        end

        if not instance.initialized then
            --PDKP.Dev:Print('No initializer found for:', instance.instTableName)
        end
    end
end

-- Retrieves the requested module instances and sends them back in the order you asked for them.
-- This helps us cleanup the top of files, instead of them being 30 lines long just for module references.
function PDKP:GetInst(...)
    local reqInstances = {}
    for key, val in pairs({...}) do reqInstances[key] = PDKP_Instances[val] end
    return unpack(reqInstances)
end

