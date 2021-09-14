local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;

local DB = {}

local database_names = { 'personal', 'guild', 'dkp', 'pug', 'settings', 'lockouts', 'ledger', 'decayTracker', 'sync', 'phase', 'snapshot' }

local function UpdateGuild()
    DB.server_faction_guild = string.lower(UnitFactionGroup("player") .. " " .. GetNormalizedRealmName() .. " " .. (GetGuildInfo("player") or "unguilded"))
end

function DB:Initialize()
    -- Below API requires delay after loading to work after variables loaded event
    UpdateGuild()

    local dbRef = self.server_faction_guild;

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
                for k, v in pairs(ldb[2689]['Huntswomann']) do
                    if v == 1625706965 then
                        table.remove(ldb[2689]['Huntswomann'], k)
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

function DB:Settings()
    return PDKP_DB[self.server_faction_guild]['settings']
end

function DB:Sync()
    return PDKP_DB[self.server_faction_guild]['settings']['sync']
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

function DB:Phases()
    return PDKP_DB[self.server_faction_guild]['phases']
end

function DB:Snapshot()
    return PDKP_DB[self.server_faction_guild]['snapshot']
end

--@do-not-package@
function DB:Dev()
    if PDKP_DB[self.server_faction_guild]['dev'] == nil then
        PDKP_DB[self.server_faction_guild]['dev'] = {};
    end
    return PDKP_DB[self.server_faction_guild]['dev']
end
--@end-do-not-package@

function DB:CreateSnapshot()
    PDKP_DB[self.server_faction_guild]['snapshot'] = {
        ['guild'] = Utils:DeepCopy(self:Guild()),
        ['dkp'] = Utils:DeepCopy(self:DKP()),
        ['phases'] = Utils:DeepCopy(self:Phases()),
        ['decay'] = Utils:DeepCopy(self:Decay()),
        ['Ledger'] = Utils:DeepCopy(self:Ledger()),
        ['sync'] = Utils:DeepCopy(self:Sync()),
    }
end

function DB:ApplySnapshot()
    local snap = self:Snapshot()
    PDKP_DB[self.server_faction_guild]['guild'] = Utils:DeepCopy(snap['guild'])
    PDKP_DB[self.server_faction_guild]['dkp'] = Utils:DeepCopy(snap['dkp'])
    PDKP_DB[self.server_faction_guild]['phases'] = Utils:DeepCopy(snap['phases'])
    PDKP_DB[self.server_faction_guild]['decay'] = Utils:DeepCopy(snap['decay'])
    PDKP_DB[self.server_faction_guild]['Ledger'] = Utils:DeepCopy(snap['Ledger'])
    PDKP_DB[self.server_faction_guild]['sync'] = Utils:DeepCopy(snap['sync'])
end

function DB:ResetSnapshot()
    PDKP_DB[self.server_faction_guild]['snapshot'] = nil;
    PDKP_DB[self.server_faction_guild]['snapshot'] = {};
end

function DB:ResetAllDatabases()
    for i = 1, #database_names do
        local db = database_names[i]
        PDKP_DB[self.server_faction_guild][db] = {}
    end
end

function DB:ProcessDBOverwrite(db, data)
    wipe(PDKP_DB[self.server_faction_guild][db])
    for k, v in pairs(data) do
        PDKP_DB[self.server_faction_guild][db][k] = v
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
