local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES

-- Module part
local Logger = {}
function Logger:Initialize()
    LOG:Trace("Logger:Initialize()")
    self.db = MODULES.Database:Logger()

    local options = {
        logger_header = {
            type = "header",
            name = "Logging",
            order = 100
        },
        logger_severity = {
            name = "Logging level",
            desc = "Select logging level for troubleshooting",
            type = "select",
            values = LOG.SEVERITY_LEVEL,
            set = function(i, v) self:SetSeverity(v) end,
            get = function(i) return self:GetSeverity() end,
            order = 101
        },
        logger_verbose = {
            name = "Verbose",
            desc = "Enables / disables verbose data printing during logging",
            type = "toggle",
            set = function(i, v) self:SetVerbosity(v) end,
            get = function(i) return self:GetVerbosity() end,
            order = 102
        },
    }
    --MODULES.ConfigManager:Register(PDKP.CONSTANTS.CONFIGS.GROUP.GLOBAL, options)
end

function Logger:SetSeverity(severity)
    self.db.severity = severity
    LOG:SetSeverity(self.db.severity)
end

function Logger:SetVerbosity(verbosity)
    self.db.verbosity = verbosity
    LOG:SetVerbosity(self.db.verbosity)
end

function Logger:GetSeverity()
    return LOG:GetSeverity()
end

function Logger:GetVerbosity()
    return LOG:GetVerbosity()
end

-- Publish API
MODULES.Logger = Logger



