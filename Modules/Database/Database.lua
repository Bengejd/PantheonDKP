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

    local dbRef = self.server_faction_guild;

    local tables = { 'personal', 'guild', 'dkp', 'pug', 'officers', 'settings', 'lockouts', 'loot' }

    -- Database is compressed
    if type(PDKP_DB[dbRef]) == "string" then
        --PDKP_DB[dbRef] = MODULES.CommsManager:DataDecoder(PDKP_DB[dbRef])
    end

    if type(PDKP_DB[dbRef]) ~= "table" then PDKP_DB[dbRef] = {} end

    for i=1, #tables do
        local db = tables[i]
        if type(PDKP_DB[dbRef][db]) ~= "table" then
            PDKP_DB[dbRef][db] = {}
        end
    end

    PDKP.CORE:RegisterEvent('PLAYER_LOGOUT', function()
        print('Player Logout called');
        PDKP_DB[dbRef] = MODULES.CommsManager:DataEncoder(PDKP_DB[dbRef])
    end)
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

function DB:Pug()
    return PDKP_DB[self.server_faction_guild]['pug']
end

function DB:Officers()
    return PDKP_DB[self.server_faction_guild]['officers']
end

function DB:Settings()
    return PDKP_DB[self.server_faction_guild]['settings']
end

function DB:Loot()
    return PDKP_DB[self.server_faction_guild]['loot']
end

function DB:Lockouts()
    return PDKP_DB[self.server_faction_guild]['lockouts']
end

function DB:Ledger()
    return PDKP_DB[self.server_faction_guild]['ledger']
end

MODULES.Database = DB