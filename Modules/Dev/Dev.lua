local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
--@do-not-package@

local Dev = {}
Dev.DEV_NAMES = { ['Neekio'] = true, ['Lariese'] = true }

local tinsert = table.insert
local random = math.random
local pairs = pairs
local wipe = wipe

function Dev:HandleSlashCommands(msg)
    if not PDKP:IsDev() then return end

    local cmd, arg1, arg2 = PDKP.CORE:GetArgs(msg, 3)

    local SLASH_COMMANDS = {
        ['databasePopulate'] = self:PopulateDummyDatabase(arg1)
    }
    if SLASH_COMMANDS[cmd] then return SLASH_COMMANDS[cmd]() end
end

function Dev:PopulateDummyDatabase(numOfEntriesToCreate)
    numOfEntriesToCreate = tonumber(numOfEntriesToCreate) or 500;

    local memberNames = MODULES.GuildManager.memberNames;
    local numOfMembers = #memberNames

    local valid_counter = 1
    local valid_entries = {}

    while valid_counter <= numOfEntriesToCreate do
        local entry = self:CreateDummyEntry(numOfMembers, memberNames)

        if entry:IsValid() then
            tinsert(valid_entries, entry)
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

function Dev:CreateDummyEntry(numOfMembers, memberNames)

    -- Generate the start and end indexes for our entry's members.
    local member_index_start = random(numOfMembers)
    local member_index_end = random(member_index_start, numOfMembers)

    -- Random epoch timestamp between January 1st, 2021 and now.
    local entry_id = random(1609480800, GetServerTime())

    local adjust_reasons = {'Boss Kill', 'Item Win', 'Other'}
    local reason = adjust_reasons[random(3)]

    local reason_dkp = {
        ['Boss Kill'] = 10,
        ['Item Win'] = -1,
        ['Other'] = 5,
    }
    local dkp_change = reason_dkp[reason]

    local random_names = {}
    for i=member_index_start, member_index_end do
        tinsert(random_names, memberNames[i])
    end

    local dummy_entry = {
        ['id'] = entry_id,
        ['officer'] = 'Lariese',
        ['reason'] = reason,
        ['names'] = random_names,
        ['dkp_change'] = dkp_change
    }

    if reason == 'Boss Kill' then
        local RAID_NAMES = MODULES.Constants.RAID_NAMES
        local RAID_BOSSES = MODULES.Constants.RAID_BOSSES

        local random_raid_index = random(#RAID_NAMES)
        local raid_name = RAID_NAMES[random_raid_index]
        local raid_info = RAID_BOSSES[raid_name]
        local random_boss_index = random(#raid_info['boss_names'])
        local boss_name = raid_info['boss_names'][random_boss_index]

        dummy_entry['boss'] = boss_name;
    end

    local entry = PDKP.MODULES.DKPEntry:new(dummy_entry)

    if entry:IsValid() then
        return entry;
    else

        if reason == 'Boss Kill' then
            print(entry.reason, entry.boss, entry.raid)
        end

        wipe(entry)
        return self:CreateDummyEntry(numOfMembers, memberNames)
    end
end

-- Publish API
MODULES.Dev = Dev
--@end-do-not-package@