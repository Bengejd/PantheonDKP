local _, PDKP = ...

local MODULES = PDKP.MODULES
local LOG = PDKP.LOG

local DB = {}

local database_names = { 'personal', 'guild', 'dkp', 'pug', 'officers', 'settings', 'lockouts', 'loot' }

local function UpdateGuild()
    DB.server_faction_guild = string.lower(UnitFactionGroup("player") .. " " .. GetNormalizedRealmName() .. " " .. (GetGuildInfo("player") or "unguilded"))
    LOG:Debug("Using database: %s", DB.server_faction_guild)
end

function DB:Initialize()
    LOG:Trace("DB:Initialize()")
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

    --PDKP.CORE:RegisterEvent('PLAYER_LOGOUT', function()
    --    print('Player Logout called');
    --    PDKP_DB[dbRef] = MODULES.CommsManager:DataEncoder(PDKP_DB[dbRef])
    --end)
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

function DB:ResetAllDatabases()
    for i = 1, #database_names do
        local db = database_names[i]
        PDKP_DB[self.server_faction_guild][db] = {}
    end
    PDKP.CORE:Print('Databases have been reset');
end

function DB:PopulateDummyDatabase()

    local memberNames = MODULES.GuildManager.memberNames;
    local numOfMembers = #memberNames

    local DKP_DB = self:DKP()

    local valid_counter = 1
    local valid_entries = {}
    while valid_counter <= 500 do
        local random_member_start = math.random(numOfMembers)
        local random_member_end = math.random(random_member_start, numOfMembers)

        -- Random epoch datetime between January 1st, 2021 and now.
        local server_time = math.random(1609480800, GetServerTime())
        local year = PDKP.Utils:GetYear(server_time)

        local random_names = {}

        for k=1, #memberNames do
            if k >= random_member_start and k < random_member_end then
                table.insert(random_names, memberNames[k])
            end
        end

        local reasons = {'Boss Kill', 'Item Win', 'Other'}
        local randomReason = math.random(3)
        local reason = reasons[randomReason]

        local dkp_change;
        if reason == 'Boss Kill' then
            dkp_change = 10
        elseif reason == 'Item Win' then
            dkp_change = -1
            reason = 'Other'
        else
            dkp_change = 5
        end

        local dummy_entry = {
            ['id'] = server_time,
            ['officer'] = 'Lariese',
            ['reason'] = reason,
            ['names'] = random_names,
            ['dkp_change'] = dkp_change
        }

        if reason == 'Boss Kill' then
            dummy_entry['boss'] = 'Magtheridon';
        end

        local entry = PDKP.MODULES.DKPEntry:new(dummy_entry)

        if entry:IsValid() then
            table.insert(valid_entries, entry)
            valid_counter = valid_counter + 1
        else
            wipe(entry)
        end
    end

    for key, entry in pairs(valid_entries) do
        if key == #valid_entries then
            entry:Save(true)
        else
            entry:Save(false)
        end
    end

    PDKP.CORE:Print('Dummy database has been created with ' .. tostring(MODULES.DKPManager.numOfEntries) .. ' Entries');
end

MODULES.Database = DB