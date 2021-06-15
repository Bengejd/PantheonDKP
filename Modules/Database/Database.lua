local _, PDKP = ...

local MODULES = PDKP.MODULES
local LOG = PDKP.LOG

local DB = {}

local function UpdateGuild()
    DB.server_faction_guild = string.lower(UnitFactionGroup("player") .. " " .. GetNormalizedRealmName() .. " " .. (GetGuildInfo("player") or "unguilded"))
    LOG:Debug("Using database: %s", DB.server_faction_guild)
end

function DB:Initialize()
    LOG:Trace("DB:Initialize()")
    -- Below API requires delay after loading to work after variables loaded event
    UpdateGuild()

    if type(PDKP_DB[self.server_faction_guild]) ~= "table" then
        PDKP_DB[self.server_faction_guild] = {}
    end
    if type(PDKP_DB[self.server_faction_guild]['personal']) ~= "table" then
        PDKP_DB[self.server_faction_guild]['personal'] = {}
    end
    if type(PDKP_DB[self.server_faction_guild]['guild']) ~= "table" then
        PDKP_DB[self.server_faction_guild]['guild'] = {}
    end
    if type(PDKP_DB[self.server_faction_guild]['raid']) ~= "table" then
        PDKP_DB[self.server_faction_guild]['raid'] = {}
    end
    if type(PDKP_DB[self.server_faction_guild]['ledger']) ~= "table" then
        PDKP_DB[self.server_faction_guild]['ledger'] = {}
    end
end

function DB:Global()
    return PDKP_DB['global']
end

function DB:Logger()
    return PDKP_DB['global']['logger']
end

function DB:Server()
    return PDKP_DB[self.server_faction_guild]
end

function DB:Personal()
    return PDKP_DB[self.server_faction_guild]['personal']
end

function DB:Guild()
    return PDKP_DB[self.server_faction_guild]['guild']
end

function DB:Raid()
    return PDKP_DB[self.server_faction_guild]['raid']
end

function DB:Ledger()
    return PDKP_DB[self.server_faction_guild]['ledger']
end

MODULES.Database = DB