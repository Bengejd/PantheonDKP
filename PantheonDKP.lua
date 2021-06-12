local _G = _G
local addonName, PDKP = ...;

PDKP.CORE = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")

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

local function Initialize_Logger()
    LOG:SetSeverity(PDKP.global.logger.severity)
    LOG:SetVerbosity(PDKP.global.logger.verbosity)
    LOG:SetPrefix("PDKP")
    LOG:SetDatabase(PDKP)
end

function CORE:OnEnable()
    -- Called when the addon is enabled
end

function CORE:OnDisable()
    -- Called when the addon is disabled
end

function CORE:OnInitialize()
    -- Initialize SavedVariables

    -- Early Initialize Logger

    -- Initialize Versioning

    -- Initialize Addon
end


--@do-not-package@
function CORE.Debug()
    --PDKP.Debug:Initialize()
    --PDKP.Debug:RegisterSlash()
end
--@end-do-not-package@