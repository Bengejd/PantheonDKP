local _, PDKP = ...

local MODULES = PDKP.MODULES

local DB = {}

local database_names = { 'personal', 'guild', 'dkp', 'pug', 'officers', 'settings', 'lockouts', 'loot', 'ledger', 'decayTracker' }

local function UpdateGuild()
    DB.server_faction_guild = string.lower(UnitFactionGroup("player") .. " " .. GetNormalizedRealmName() .. " " .. (GetGuildInfo("player") or "unguilded"))
end

function DB:Initialize()
    -- Below API requires delay after loading to work after variables loaded event
    UpdateGuild()

    local dbRef = self.server_faction_guild;

    -- Database is compressed
    if type(PDKP_DB[dbRef]) == "string" then
        --PDKP_DB[dbRef] = MODULES.CommsManager:DataDecoder(PDKP_DB[dbRef])
    end

    if type(PDKP_DB[dbRef]) ~= "table" then
        PDKP_DB[dbRef] = {}
    end

    for i = 1, #database_names do
        local db = database_names[i]
        if type(PDKP_DB[dbRef][db]) ~= "table" then
            PDKP_DB[dbRef][db] = {}
        end
    end

    self:Personal()[UnitName("PLAYER")] = true

    self:_Migrations()
end

function DB:_Migrations()
    local ldb = self:Ledger()
    local dkp = self:DKP()

    -- entry 1625706965

    if dkp[1625706965] == nil then
        if ldb[2689] ~= nil then
            if ldb[2689]['Huntswomann'] then
                local temp_entries = {}
                for k, v in pairs(ldb[2689]['Huntswomann']) do
                    if v == 1625706965 then
                        local removed = table.remove(ldb[2689]['Huntswomann'], k)
                    end
                end
            end
        end
    end
end

function DB:Global()
    return PDKP_DB['global']
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

function DB:DKP()
    return PDKP_DB[self.server_faction_guild]['dkp']
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

function DB:Decay()
    return PDKP_DB[self.server_faction_guild]['decayTracker']
end

function DB:ResetAllDatabases()
    for i = 1, #database_names do
        local db = database_names[i]
        PDKP_DB[self.server_faction_guild][db] = {}
    end
end

function DB:ResetLockouts()
    PDKP_DB[self.server_faction_guild]['lockouts'] = {}
    return PDKP_DB[self.server_faction_guild]['lockouts']
end

function DB:UpdateSetting(settingName, value)
    if settingName == 'disallow_invite' then
        PDKP_DB[self.server_faction_guild]['settings']['ignore_from'] = value
    elseif settingName == 'invite_commands' then
        PDKP_DB[self.server_faction_guild]['settings']['invite_commands'] = value
    elseif settingName == 'ignore_pugs' then
        PDKP_DB[self.server_faction_guild]['settings']['ignore_pugs'] = value
    end
end

MODULES.Database = DB