local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils
--@do-not-package@

local Dev = {}
Dev.DEV_NAMES = { ['Neekio'] = true, ['Lariese'] = true }

local tinsert = table.insert
local random = math.random
local pairs = pairs
local wipe = wipe

local decayCount = 0

function Dev:HandleSlashCommands(msg)
    if not PDKP:IsDev() then
        return
    end

    local cmd, arg1, _ = PDKP.CORE:GetArgs(msg, 3)

    if cmd == 'databasePopulate' then
        return self:PopulateDummyDatabase(arg1)
    elseif cmd == 'whoTest' then
        self:WhoTest(msg)
    elseif cmd == 'largeDataSync' then
        self:LargeDataSync(msg)
    elseif cmd == 'decayTest' then
        self:DecayTest(msg)
    elseif cmd == 'bossKillTest' then
        self:BossKillTest(msg)
    elseif cmd == 'testAuctionTimer' then
        PDKP.AuctionTimer.startTimer()
    end
end

function Dev:DecayTest()
    local member1 = MODULES.GuildManager:GetMemberByName('Mariku')
    local member2 = MODULES.GuildManager:GetMemberByName('Oxford')

    local m1DKP = member1:GetDKP()
    local m2DKP = member2:GetDKP()

    if m1DKP == 30 or m2DKP == 30 then
        member1.dkp['total'] = 20000
        member2.dkp['total'] = 19999
    else
        decayCount = decayCount + 1
        local diffOffset = 0
        local decayAmount = 0.9

        if m1DKP - m2DKP == 1 then
            diffOffset = 1
        end

        if decayCount % 10 == 0 then
            decayAmount = 0.5
            PDKP.CORE:Print('50% Decay')
        end

        member1.dkp['total'] = math.floor((m1DKP + diffOffset) * 0.9)
        member2.dkp['total'] = math.floor((m2DKP) * 0.9)
    end

    m1DKP = member1:GetDKP()
    m2DKP = member2:GetDKP()

    if m1DKP <= m2DKP then
        PDKP:PrintD(Utils:FormatTextColor('OXFORD CAUGHT UP TO MARIKU on week: ' .. tostring(decayCount), MODULES.Constants.WARNING))
    end

    MODULES.DKPManager:_UpdateTables()
end

function Dev:LargeDataSync()
    local DKP = MODULES.DKPManager
    local entries, total = DKP.currentLoadedWeekEntries, DKP.numCurrentLoadedWeek
    local transmission_data = { ['total'] = total, ['entries'] = entries }
    MODULES.CommsManager:SendCommsMessage('SyncLarge', transmission_data)
end

function Dev:PopulateDummyDatabase(numOfEntriesToCreate)
    numOfEntriesToCreate = tonumber(numOfEntriesToCreate) or 500;

    local memberNames = MODULES.GuildManager.memberNames;
    local numOfMembers = #memberNames
    local officers = MODULES.GuildManager.officers
    local officerNames = {}

    for officerName, _ in pairs(officers) do
        table.insert(officerNames, officerName)
    end

    local valid_counter = 1
    local valid_entries = {}

    while valid_counter <= numOfEntriesToCreate do
        local entry = self:CreateDummyEntry(numOfMembers, memberNames, officerNames)

        if entry:IsValid() then
            tinsert(valid_entries, entry)
            valid_counter = valid_counter + 1
        else
            wipe(entry)
        end
    end

    for key, entry in pairs(valid_entries) do
        MODULES.LedgerManager:GenerateEntryHash(entry)
        if key == #valid_entries then
            entry:Save(true)
        else
            entry:Save(false)
        end
    end

    PDKP.CORE:Print('Dummy database has been created with ' .. tostring(MODULES.DKPManager.numOfEntries) .. ' Entries');
end

function Dev:CreateDummyEntry(numOfMembers, memberNames, officerNames)

    -- Generate the start and end indexes for our entry's members.
    local member_index_start = random(numOfMembers)
    local member_index_end = random(member_index_start, numOfMembers)

    -- Random epoch timestamp between January 1st, 2021 and now.
    local entry_id = random(1609480800, GetServerTime())

    local adjust_reasons = { 'Boss Kill', 'Item Win', 'Other' }
    local reason = adjust_reasons[random(3)]

    local reason_dkp = {
        ['Boss Kill'] = 10,
        ['Item Win'] = -1,
        ['Other'] = 5,
    }
    local dkp_change = reason_dkp[reason]

    local random_names = {}
    for i = member_index_start, member_index_end do
        tinsert(random_names, memberNames[i])
    end

    local random_officer_index = random(#officerNames)
    local officer = officerNames[random_officer_index]

    local dummy_entry = {
        ['id'] = entry_id,
        ['officer'] = officer,
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
    elseif reason == 'Item Win' then
        wipe(random_names)
        tinsert(random_names, memberNames[member_index_end])

        -- Ateish, Kingsfall, Blade, Edgemasters
        local items = { 22589, 22802, 17780, 14551 }
        local randomItemIndex = random(5)

        if randomItemIndex ~= 5 then
            dummy_entry['item'] = Utils:GetItemLink(items[randomItemIndex])
        end
    end

    local entry = PDKP.MODULES.DKPEntry:new(dummy_entry)

    if entry:IsValid() then
        return entry;
    else
        wipe(entry)
        return self:CreateDummyEntry(numOfMembers, memberNames)
    end
end

function Dev:WhoTest(_)
    PDKP:Print('Dev: Testing Who');
    SendWho('Lariese');
end

function Dev:BossKillTest()
    local RAID_NAMES = MODULES.Constants.RAID_NAMES
    local RAID_BOSSES = MODULES.Constants.RAID_BOSSES

    local random_raid_index = random(#RAID_NAMES)
    local raid_name = RAID_NAMES[random_raid_index]
    local raid_info = RAID_BOSSES[raid_name]
    local random_boss_index = random(#raid_info['boss_names'])
    local boss_name = raid_info['boss_names'][random_boss_index]

    MODULES.DKPManager:BossKillDetected(nil, boss_name)
end

-- Publish API
MODULES.Dev = Dev
--@end-do-not-package@