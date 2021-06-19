local _G = _G
local addonName, PDKP = ...;

PDKP.CORE = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0", "AceEvent-3.0")

PDKP.MODULES = {}
PDKP.MODELS = { LEDGER = {} }
PDKP.CONSTANTS = {}
PDKP.GUI = {}
PDKP.OPTIONS = {}

PDKP.AUTOVERSION = "@project-version@"

PDKP.LOG = LibStub("LibLogger"):New()

local CORE = PDKP.CORE
local LOG = PDKP.LOG
local MODULES = PDKP.MODULES

local function Initialize_SavedVariables()

    if type(PDKP_DB) ~= "table" then
        PDKP_DB = {
            global = {
                version = {
                    major = 0,
                    minor = 0,
                    patch = 0,
                    changeset = ""
                },
                logger = {
                    severity = PDKP.LOG.SEVERITY.ERROR,
                    verbosity = false
                }
            }
        }
    end

    if type(PDKP_Logs) ~= "table" then PDKP_Logs = {} end
end

local function Initialize_Logger()
    LOG:SetSeverity(PDKP_DB.global.logger.severity)
    LOG:SetVerbosity(PDKP_DB.global.logger.verbosity)
    LOG:SetPrefix("PDKP")
    LOG:SetDatabase(PDKP_Logs)
end

local function Initialize_Versioning()
    -- Parse autoversion
    local major, minor, patch, changeset = string.match(PDKP.AUTOVERSION, "^v(%d+).(%d+).(%d+)-?(.*)")
    local old = PDKP_DB.global.version
    local new = {
        major = tonumber(major) or 0,
        minor = tonumber(minor) or 0,
        patch = tonumber(patch) or 0,
        changeset = changeset or ""
    }
    -- set new version
    PDKP_DB.global.version = new
    -- update string
    changeset = new.changeset
    if changeset and changeset ~= "" then
        changeset = "-" .. changeset
    else
        changeset = ""
    end
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

    return old, new
end

function CORE:_InitializeCore()
    LOG:Trace("CORE:_InitializeCore()")

    MODULES.Database:Initialize()
    --MODULES.ConfigManager:Initialize()
    --MODULES.ACL:Initialize()
end

function CORE:_InitializeBackend()
    LOG:Trace("CORE:_InitializeBackend()")
    MODULES.Logger:Initialize()
    --MODULES.Comms:Initialize()
    --MODULES.EventManager:Initialize()
    --MODULES.GuildInfoListener:Initialize()
    --MODULES.LedgerManager:Initialize()
    if type(self.Debug) == "function" then
        self.Debug()
    end
end

function CORE:_InitializeFeatures()
    LOG:Trace("CORE:_InitializeFeatures()")
    MODULES.GuildManager:Initialize()
    MODULES.Main:Initialize()
    MODULES.AuctionManager:Initialize()
    MODULES.DKPManager:Initialize()
    MODULES.RaidManager:Initialize()
    MODULES.Lockouts:Initialize()
    MODULES.Loot:Initialize()
    MODULES.Options:Initialize()
    MODULES.History:Initialize()

    -- We keep the order
    --MODULES.ProfileManager:Initialize()
    --MODULES.RosterManager:Initialize()
    --MODULES.PointManager:Initialize()
    --MODULES.LootManager:Initialize()
    --MODULES.RaidManager:Initialize()
    --MODULES.AuctionManager:Initialize()
    --MODULES.BiddingManager:Initialize()
    -- Initialize Migration
    --PDKP.Migration:Initialize()
end

function CORE:_InitializeFrontend()
    LOG:Trace("CORE:_InitializeFrontend()")
    -- No GUI / OPTIONS should be dependent on each other ever, only on the managers
    for _, module in pairs(PDKP.OPTIONS) do
        module:Initialize()
    end
    for _, module in pairs(PDKP.GUI) do
        module:Initialize()
    end


    -- TODO Initialize Minmap
    --MODULES.Minimap:Initialize()
    -- Hook Minimap Icon

    --hooksecurefunc(MODULES.LedgerManager, "UpdateSyncState", function()
    --    if MODULES.LedgerManager:IsInSync() then
    --        PDKP.MinimapDBI.icon = "Interface\\AddOns\\ClassicLootManager\\Media\\Icons\\PDKP-ok-32.tga"
    --    elseif MODULES.LedgerManager:IsSyncOngoing() then
    --        PDKP.MinimapDBI.icon = "Interface\\AddOns\\ClassicLootManager\\Media\\Icons\\PDKP-nok-32.tga"
    --    else -- Unknown state
    --        PDKP.MinimapDBI.icon = "Interface\\AddOns\\ClassicLootManager\\Media\\Icons\\PDKP-sync-32.tga"
    --    end
    --end)
end

function CORE:_Enable()
    LOG:Trace("CORE:_Enable()")
    --MODULES.Comms:Enable()
    --MODULES.LedgerManager:Enable()
end

function CORE:_SequentialInitialize(stage)
    LOG:Trace("CORE:_SequentialInitialize()")
    if stage == 0 then
        self:_InitializeCore()
    elseif stage == 1 then
        self:_InitializeBackend()
    elseif stage == 2 then
        self:_InitializeFeatures()
    elseif stage == 3 then
        self:_InitializeFrontend()
    elseif stage >= 4 then
        self:_Enable()
        LOG:Info("Initialization complete")
        return
    end
    C_Timer.After(0.1, function() CORE:_SequentialInitialize(stage + 1) end)
end

function CORE:_ExecuteInitialize()
    if self._initialize_fired then return end
    self._initialize_fired = true
    C_Timer.After(1, function() CORE:_SequentialInitialize(0) end)
end

function CORE:_Initialize()
    LOG:Trace("CORE:_Initialize()")
    if not self._initialize_fired then
        CORE:_ExecuteInitialize()
        self:UnregisterEvent("GUILD_ROSTER_UPDATE")
    end
end

function CORE:OnInitialize()
    -- Initialize SavedVariables
    Initialize_SavedVariables()
    -- Early Initialize Logger
    Initialize_Logger()
    -- Initialize Versioning
    Initialize_Versioning()
    -- Initialize Addon
    LOG:Trace("OnInitialize")
    self._initialize_fired = false
    CORE:RegisterEvent("GUILD_ROSTER_UPDATE")
    SetGuildRosterShowOffline(true)
    GuildRoster()
    -- We schedule this in case GUILD_ROSTER_UPDATE won't come early enough
    C_Timer.After(20, function()
        CORE:_ExecuteInitialize()
    end)
end

function CORE:OnEnable()
    -- Called when the addon is enabled
end

function CORE:OnDisable()
    -- Called when the addon is disabled
end

function CORE:GUILD_ROSTER_UPDATE(...)
    LOG:Trace("GUILD_ROSTER_UPDATE")
    local inGuild = IsInGuild()
    local numTotal = GetNumGuildMembers();
    if inGuild and numTotal ~= 0 then
        self:_Initialize()
    end
end

function PDKP:IsDev()
    return MODULES.Dev and type(MODULES.Dev) == "table"
end

--@do-not-package@
function CORE.Debug()
    --PDKP.Debug:Initialize()
    --PDKP.Debug:RegisterSlash()
end
--@end-do-not-package@