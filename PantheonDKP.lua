local addonName, PDKP = ...;

local LibStub = LibStub

PDKP.CORE = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0", "AceEvent-3.0")

PDKP.ldb = LibStub:GetLibrary("LibDataBroker-1.1")
PDKP.cbh = LibStub("CallbackHandler-1.0"):New(PDKP.CORE)
PDKP.LibDeflate = LibStub:GetLibrary("LibDeflate")

PDKP.MODULES = {}
PDKP.MODELS = { LEDGER = {} }
PDKP.CONSTANTS = {}
PDKP.GUI = {}
PDKP.OPTIONS = {}

PDKP.AUTOVERSION = "@project-version@"

PDKP.newVersionDetected = false

local CORE = PDKP.CORE
local MODULES = PDKP.MODULES

local C_Timer = C_Timer
local tonumber, strmatch = tonumber, string.match

-- Args: major, minor, patch, changeset
local function Initialize_Default_Version(args)
    args = args or { nil, nil, nil, nil }
    return {
        major = tonumber(args[1]) or 0,
        minor = tonumber(args[2]) or 0,
        patch = tonumber(args[3]) or 0,
        changeset = args[4] or ""
    }
end

local function Initialize_SavedVariables()
    if type(PDKP_DB) ~= "table" then
        PDKP_DB = {
            global = {
                version = Initialize_Default_Version(),
                previous = Initialize_Default_Version(),
                locked = false
            }
        }
    end
end

local function IsNewVersion(old, new)
    if old.major < new.major then
        return true
    elseif old.minor < new.minor then
        return true
    elseif old.patch < new.patch then
        return true
    end
    return false
end

local function Initialize_Versioning()
    -- Parse autoversion
    local major, minor, patch, changeset = strmatch(PDKP.AUTOVERSION, "^v(%d+).(%d+).(%d+)-?(.*)")
    local old = PDKP_DB.global.version
    local new = Initialize_Default_Version({ major, minor, patch, changeset })

    -- set new version
    PDKP_DB.global.version = new
    -- update string
    changeset = new.changeset

    changeset = PDKP.Utils:ternaryAssign(PDKP.Utils:IsEmpty(changeset), "", "-" .. changeset)

    CORE.versionString = string.format(
            "v%s.%s.%s%s",
            new.major or 0,
            new.minor or 0,
            new.patch or 0,
            changeset)
    -- return both for update purposes

    if CORE.versionString == 'v0.0.0' then
        CORE.versionString = "v" .. GetAddOnMetadata('PantheonDKP', "Version")
    end

    MODULES.Constants.COLORED_ADDON_VERSION = '|cff33FF99' .. PDKP.CORE.versionString .. '|r'

    return old, new
end

function CORE:_InitializeCore()
    PDKP.Utils:Initialize()
    MODULES.Database:Initialize()
    MODULES.ChatManager:Initialize()
end

function CORE:_InitializeFeatures()
    MODULES.GuildManager:Initialize()
    MODULES.CommsManager:Initialize()

    MODULES.Main:Initialize()
    MODULES.CommsManager:RegisterComms()
    MODULES.LedgerManager:Initialize()
    MODULES.AuctionManager:Initialize()
    MODULES.DKPManager:Initialize()
    MODULES.RaidManager:Initialize()
    MODULES.GroupManager:Initialize()
    MODULES.Lockouts:Initialize()
    MODULES.Options:Initialize()
end

function CORE:_InitializeFrontend()
    -- No GUI / OPTIONS should be dependent on each other ever, only on the managers
    for _, module in pairs(PDKP.OPTIONS) do
        module:Initialize()
    end
    for _, module in pairs(PDKP.GUI) do
        module:Initialize()
    end
end

function CORE:_SequentialInitialize(stage)
    if stage == 0 then
        self:_InitializeCore()
    elseif stage == 1 then
        self:_InitializeFeatures()
    elseif stage >= 2 then
        self:_InitializeFrontend()
        return
    end
    C_Timer.After(0.1, function() CORE:_SequentialInitialize(stage + 1) end)
end

function CORE:_ExecuteInitialize()
    if self._initialize_fired then return end

    PDKP.canEdit = false

    self._initialize_fired = true
    C_Timer.After(1, function() CORE:_SequentialInitialize(0) end)
end

function CORE:_Initialize()
    if not self._initialize_fired then
        CORE:_ExecuteInitialize()
        self:UnregisterEvent("GUILD_ROSTER_UPDATE")
    end
end

function CORE:OnInitialize()
    -- Initialize SavedVariables
    Initialize_SavedVariables()
    -- Initialize Versioning
    Initialize_Versioning()
    -- Initialize Addon
    self._initialize_fired = false
    CORE:RegisterEvent("GUILD_ROSTER_UPDATE")
    SetGuildRosterShowOffline(true)
    GuildRoster()
    -- We schedule this in case GUILD_ROSTER_UPDATE won't come early enough
    C_Timer.After(20, function()
        if IsInGuild() then
            CORE:_ExecuteInitialize()
        else
           PDKP.CORE:Print("PantheonDKP is meant for use in Guilds, please join a guild for the addon to work properly.")
        end
    end)
end

function CORE:OnEnable()
    -- Called when the addon is enabled
end

function CORE:OnDisable()
    -- Called when the addon is disabled
end

function CORE:GUILD_ROSTER_UPDATE(...)
    local inGuild = IsInGuild()
    local numTotal = GetNumGuildMembers();
    if inGuild and numTotal ~= 0 then
        self:_Initialize()
    end
end

function PDKP:IsDev()
    return MODULES.Dev and type(MODULES.Dev) == "table"
end

function PDKP:PrintD(...)
    if PDKP:IsDev() then
        local text = "|cffF4A460" .. strjoin(" ", tostringall(...)) .. "|r"
        PDKP.CORE:Print(text)
    end
end