local _, core = ...;
local _G = _G;

local PDKP = core.PDKP;
local Guild, Defaults, Util, Character, GUI = PDKP:GetInst('Guild', 'Defaults', 'Util', 'Character', 'GUI')
local Guild, Defaults, Util, Character, GUI, Dev = PDKP:GetInst('Guild', 'Defaults', 'Util', 'Character', 'GUI', 'Dev')
local IsInGuild, GuildRoster = IsInGuild, GuildRoster
local strlen, next = string.len, next

local function PDKP_OnEvent(self, event, arg1, ...)

    local ADDON_EVENTS = {
        ['GUILD_ROSTER_UPDATE']=function()
            if Guild:HasMembers() then
                PDKP.Events:Unregister(event, "PDKP")
                PDKP:OnDataAvailable()
            else
                GuildRoster()
            end
        end,
        ['PLAYER_LOGIN']=function()
            if IsInGuild() then
                GuildRoster();
            end
        end,
        ['PLAYER_ENTERING_WORLD']=function()
            --Util:WatchVar(core, 'PDKP');
            --Guild.updateCalled = false;
        end,
    }

    if ADDON_EVENTS[event] then
        return ADDON_EVENTS[event]()
    end
end

-- Do more initialization here, that really enables the use of your addon.
--   -- Register Events, Hook functions, Create Frames, Get information from
--   -- the game that wasn't available in OnInitialize
function PDKP:OnEnable()
    --- Register Events
    PDKP.Events:Register({ "GUILD_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_LOGIN"}, PDKP_OnEvent, "PDKP")
end

function PDKP:OnDataAvailable()
    PDKP:CheckTOCVersion()

    Character:init()
    Guild:new()

    if GUI.pdkp_frame ~= nil then return end;

    GUI:Init();
    --Raid:new();
    --Minimap:Init()
    --
    --GameTooltip:HookScript( "OnTooltipSetItem", PDKP_SetToolTipPrio)

    Dev:Print('Change this back after tomorrow, Is Server Reset Day: ', Util.serverReset)
end

-- do init tasks here, like loading the Saved Variables,
--   -- or setting up slash commands.
function PDKP:OnInitialize()
    --- Register Slash Commands
    PDKP:RegisterChatCommand("pdkp", "HandleSlashCommands", true)

    --- Initialize the database
    PDKP:InitializeDatabases()
end

function PDKP:HandleSlashCommands(msg)
    if strlen(msg) == 0 then
        return GUI:Toggle()
    end

    local cmd = PDKP:GetArgs(msg) -- The Chat command, is nil if running /pdkp

    --- GUI Commands
    local guiCommands = {
        ['show']=function()
            GUI:Show()
        end,
        ['hide']=function()
            GUI:Hide()
        end
    }
    if guiCommands[cmd] then return guiCommands[cmd]() end

    --- Dev Commands
    if Dev.commands[cmd] then return Dev:HandleCommands(msg) end

    --- Officer Commands
    local officerCommands = {}
    if officerCommands[cmd] then return officerCommands[cmd]() end
end

function PDKP:CheckTOCVersion()
    local version, build, date, game_toc_version = GetBuildInfo()
    if tonumber(game_toc_version) ~= tonumber(Defaults.addon_interface_version) then
        Dev:Print('GameTOC', game_toc_version, 'Does not equal Addon Interface', Defaults.addon_interface_version)
    end
end

function PDKP:InitializeDatabases()
    local dbDefaults = {
        global = {}
    }
    local database = PDKP.AceDB:New("pdkp_DB", dbDefaults, true)

    if database['global'] == nil or next(database.global) == nil then
        Dev:Print("Creating PDKP Database with default values")

        database.global['db'] = {
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
            },
            ['testDB']={},
        }
    end

    local db = database.global['db']
    PDKP.db = db

    PDKP.guildDB = db.guildDB -- or {};
    PDKP.officersDB = db.officersDB -- or {};
    PDKP.settingsDB = db.settingsDB -- or {};
    PDKP.dkpDB = db.dkpDB;

    --Settings:InitDB()
    --DKP:InitDB()

    Dev:Print("Database finished Initializing")
end