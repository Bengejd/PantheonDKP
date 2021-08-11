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

PDKP.disableDev = false
PDKP.showInternal = false;
PDKP.showHistoryIds = true;

function Dev:HandleSlashCommands(msg)
    if not PDKP:IsDev() then
        return
    end

    local cmd, arg1, _ = PDKP.CORE:GetArgs(msg, 3)

    if cmd == 'databasePopulate' then
        return self:PopulateDummyDatabase(arg1)
    elseif cmd == 'TestAutomaticEntries' then
        self:TestAutomaticEntries();
    elseif cmd == 'largeDataSync' then
        self:LargeDataSync(msg)
    elseif cmd == 'bossKillTest' then
        self:BossKillTest(msg)
    elseif cmd == 'rapidDKPOfficerReq' then
        C_Timer.NewTicker(0.1, function()
            MODULES.CommsManager:SendCommsMessage('WhoIsDKP', 'request')
        end, 40)
    elseif cmd == 'rapidAdReq' then
        C_Timer.NewTicker(0.1, function()
            MODULES.CommsManager:SendCommsMessage('WhoIsDKP', 'request')
        end, 40)
    elseif cmd == 'watchFramerate' then
        if self.frameRateTimer ~= nil then
            self.frameRateTimer:Cancel()
            self.frameRateTimer = nil
            return
        end
        self.frameRateTimer = C_Timer.NewTicker(1, function()
            PDKP:PrintD("FrameRate", GetFramerate())
        end)
    elseif cmd == 'watchFramerate' then
        if self.frameRateTimer ~= nil then
            self.frameRateTimer:Cancel()
            self.frameRateTimer = nil
            return
        end
        self.frameRateTimer = C_Timer.NewTicker(1, function()
            PDKP:PrintD("FrameRate", GetFramerate())
        end)
    elseif cmd == 'unregisterCommTest' then
        MODULES.CommsManager:UnregisterComms()
        PDKP:PrintD('Unregistering Comms');
    elseif cmd == 'registerCommTest' then
        MODULES.CommsManager:RegisterComms()
        PDKP:PrintD('Unregistering Comms');
    elseif cmd == 'registerCommTest' then
        MODULES.CommsManager:RegisterComms()
        PDKP:PrintD('Unregistering Comms');
    end
end

function Dev:TestAutomaticEntries()
    PDKP.testRunning = true;

    MODULES.Database:ResetAllDatabases();
    MODULES.GuildManager:Initialize();
    MODULES.DKPManager:Initialize();

    local selectAllBtn = _G['pdkp_filter_Select_All'];

    local function toggleCheck(check)
        if check then
            if selectAllBtn:GetChecked() then
                return
            else
                selectAllBtn:Click();
            end
        else
            if selectAllBtn:GetChecked() then
                selectAllBtn:Click();
            end
        end
    end

    --[[ TESTS:
        Boss Kill Deletion (110): Totals (27) reverts to 27;
        Decay
    --]]

    local server_time = GetServerTime()

    local tests = {
        ['Boss Kill - Mag'] = {
            ['expected'] = 40,
            ['description'] = 'Single Boss Kill Entry',
            ['reason'] = '',
            ['entryCount'] = 1,
            ['entryDetails'] = {
                ['id'] = server_time,
                ['officer'] = Utils:GetMyName(),
                ['reason'] = 'Boss Kill',
                ['names'] = { 'Lilduder' },
                ['dkp_change'] = 10,
                ['boss'] = 'Magtheridon'
            },
            ['func'] = function(test)
                test.passed = true;
                local entry = MODULES.DKPEntry:new(test.entryDetails)
                local save_details = MODULES.LedgerManager:GenerateEntryHash(entry)

                if save_details then
                    local importEntry = MODULES.DKPManager:ImportEntry2(save_details)

                    if importEntry == nil then
                        test.passed = false;
                        test.reason = 'No import Entry found';
                    else
                        for _, member in pairs(importEntry.members) do
                            if member:GetDKP() ~= test.expected then
                                test.passed = false;
                                test.reason = member.name .. member:GetDKP() .. ' Did not match' .. test.expected;
                            end
                        end
                    end
                else
                    test.reason = 'No Save Details found';
                    test.passed = false;
                end
                return test.passed
            end,
        },
        ['Duplicate Boss Kill - Mag'] = {
            ['expected'] = 40,
            ['description'] = 'Duplicate Boss Kill Entry',
            ['reason'] = '',
            ['entryCount'] = 0,
            ['entryDetails'] = {
                ['id'] = server_time,
                ['officer'] = Utils:GetMyName(),
                ['reason'] = 'Boss Kill',
                ['names'] = { 'Lilduder' },
                ['dkp_change'] = 10,
                ['boss'] = 'Magtheridon'
            },
            ['func'] = function(test)
                test.passed = true;
                local entry = MODULES.DKPEntry:new(test.entryDetails)
                local save_details = MODULES.LedgerManager:GenerateEntryHash(entry)

                if save_details then
                    local importEntry = MODULES.DKPManager:ImportEntry2(save_details)
                    if importEntry ~= nil then
                        test.passed = false;
                        test.reason = 'Import Entry found';
                    else
                        for _, member in pairs(entry.members) do
                            if member:GetDKP() ~= test.expected then
                                test.passed = false;
                                test.reason = member.name .. member:GetDKP() .. ' Did not match' .. test.expected;
                            end
                        end
                    end
                else
                    test.reason = 'No save details found';
                    test.passed = false;
                end
                return test.passed
            end,
        },
        ['Item Win'] =  {
            ['expected'] = 33,
            ['description'] = 'Item Win for 7 DKP',
            ['reason'] = '',
            ['entryCount'] = 1,
            ['entryDetails'] = {
                ['id'] = server_time,
                ['officer'] = Utils:GetMyName(),
                ['reason'] = 'Item Win',
                ['names'] = { 'Lilduder' },
                ['dkp_change'] = -7,
            },
            ['func'] = function(test)
                test.passed = true;
                local entry = MODULES.DKPEntry:new(test.entryDetails)
                local save_details = MODULES.LedgerManager:GenerateEntryHash(entry)

                if save_details then
                    local importEntry = MODULES.DKPManager:ImportEntry2(save_details)
                    if importEntry == nil then
                        test.passed = false;
                        test.reason = 'No import Entry found';
                    else
                        for _, member in pairs(importEntry.members) do
                            if member:GetDKP() ~= test.expected then
                                test.passed = false;
                                test.reason = member.name .. member:GetDKP() .. ' Did not match' .. test.expected;
                            end
                        end
                    end
                else
                    test.reason = 'No save details found';
                    test.passed = false;
                end
                return test.passed
            end,
        },
        ['Boss Kill Deletion'] =  {
            ['expected'] = 23,
            ['description'] = 'Delete Boss Kill',
            ['reason'] = '',
            ['async'] = true,
            ['entryCount'] = 2,
            ['entryDetails'] = {
                ['id'] = server_time,
            },
            ['func'] = function(test)
                test.passed = true;
                local entry_to_delete = MODULES.DKPManager.entries[server_time + 1]
                MODULES.DKPManager:DeleteEntry(entry_to_delete, Utils:GetMyName());
                C_Timer.After(0.5, function()
                    for _, member in pairs(entry_to_delete.members) do
                        if member:GetDKP() ~= test.expected then
                            test.passed = false;
                            test.reason = member.name .. member:GetDKP() .. ' Did not match' .. test.expected;
                        end
                    end
                    test.passed = test.passed;
                end)
            end,
        },
        ['Other'] =  {
            ['expected'] = 101,
            ['description'] = 'Other for 78',
            ['reason'] = '',
            ['entryCount'] = 1,
            ['entryDetails'] = {
                ['id'] = server_time,
                ['officer'] = Utils:GetMyName(),
                ['reason'] = 'Other',
                ['names'] = { 'Lilduder' },
                ['dkp_change'] = 78,
            },
            ['func'] = function(test)
                test.passed = true;
                local entry = MODULES.DKPEntry:new(test.entryDetails)
                local save_details = MODULES.LedgerManager:GenerateEntryHash(entry)

                if save_details then
                    local importEntry = MODULES.DKPManager:ImportEntry2(save_details)
                    if importEntry == nil then
                        test.passed = false;
                        test.reason = 'No import Entry found';
                    else
                        for _, member in pairs(importEntry.members) do
                            if member:GetDKP() ~= test.expected then
                                test.passed = false;
                                test.reason = member.name .. member:GetDKP() .. ' Did not match' .. test.expected;
                            end
                        end
                    end
                else
                    test.reason = 'No save details found';
                    test.passed = false;
                end
                return test.passed
            end,
        },
        ['Decay'] =  {
            ['expected'] = 90,
            ['description'] = 'Decay for 10%',
            ['reason'] = '',
            ['entryCount'] = 2,
            ['entryDetails'] = {
                ['id'] = server_time,
                ['officer'] = Utils:GetMyName(),
                ['reason'] = 'Decay',
                ['names'] = { 'Lilduder' },
            },
            ['func'] = function(test)
                test.passed = true;
                local entry = MODULES.DKPEntry:new(test.entryDetails)
                local save_details = MODULES.LedgerManager:GenerateEntryHash(entry)

                if save_details then
                    local importEntry = MODULES.DKPManager:ImportEntry2(save_details)
                    if importEntry == nil then
                        test.passed = false;
                        test.reason = 'No import Entry found';
                    else
                        for _, member in pairs(importEntry.members) do
                            if member:GetDKP() ~= test.expected then
                                test.passed = false;
                                test.reason = member.name .. member:GetDKP() .. ' Did not match' .. test.expected;
                            end
                        end
                    end
                else
                    test.reason = 'No save details found';
                    test.passed = false;
                end
                return test.passed
            end,
        },
        ['Boss Kill - Gruul'] = {
            ['expected'] = 100,
            ['description'] = 'Single Boss Kill Entry',
            ['reason'] = '',
            ['entryCount'] = 1,
            ['entryDetails'] = {
                ['id'] = server_time,
                ['officer'] = Utils:GetMyName(),
                ['reason'] = 'Boss Kill',
                ['names'] = { 'Lilduder' },
                ['dkp_change'] = 10,
                ['boss'] = 'Gruul the Dragonkiller'
            },
            ['func'] = function(test)
                test.passed = true;
                local entry = MODULES.DKPEntry:new(test.entryDetails)
                local save_details = MODULES.LedgerManager:GenerateEntryHash(entry)

                if save_details then
                    local importEntry = MODULES.DKPManager:ImportEntry2(save_details)

                    if importEntry == nil then
                        test.passed = false;
                        test.reason = 'No import Entry found';
                    else
                        for _, member in pairs(importEntry.members) do
                            if member:GetDKP() ~= test.expected then
                                test.passed = false;
                                test.reason = member.name .. member:GetDKP() .. ' Did not match' .. test.expected;
                            end
                        end
                    end
                else
                    test.reason = 'No Save Details found';
                    test.passed = false;
                end
                return test.passed
            end,
        },
        ['Decay Deletion'] =  {
            ['expected'] = 111,
            ['description'] = 'Decay Deletion',
            ['reason'] = '',
            ['entryCount'] = 1,
            ['entryDetails'] = {
                ['id'] = server_time,
            },
            ['func'] = function(test)
                test.passed = true;
                local entry_to_delete = MODULES.DKPManager.entries[server_time + test.index - 2]
                MODULES.DKPManager:DeleteEntry(entry_to_delete, Utils:GetMyName());
                C_Timer.After(0.5, function()
                    for _, member in pairs(entry_to_delete.members) do
                        if member:GetDKP() ~= test.expected then
                            test.passed = false;
                            test.reason = member.name .. member:GetDKP() .. ' Did not match' .. test.expected;
                        end
                    end
                    test.passed = test.passed;
                end)
            end,
        },
    }

    local testNames = {'Boss Kill - Mag', 'Duplicate Boss Kill - Mag', 'Item Win', 'Boss Kill Deletion', 'Other',
                       'Decay', 'Boss Kill - Gruul', 'Decay Deletion',
    }

    local tickCounter = 0;
    local entryCount = 0;

    local ticker = C_Timer.NewTicker(1.5, function()
        tickCounter = tickCounter + 1;
        local testName = testNames[tickCounter];
        local test = tests[testName]

        entryCount = entryCount + test.entryCount;

        test.entryDetails['id'] = server_time + entryCount;

        test.index = entryCount;
        test['func'](test)

        C_Timer.After(0.75, function()
            PDKP:PrintT(test.passed, testName .. ' | ' .. test.entryDetails['id'] ..  ' | ', test.reason);
            PDKP.GUI.MemberScrollTable:Reinitialize();
            MODULES.DKPManager:_UpdateTables();
        end)

    end, #testNames)
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

        if entry:IsValid() and valid_entries[entry.id] == nil then
            local entryDetails = MODULES.LedgerManager:GenerateEntryHash(entry)
            valid_entries[entry.id] = MODULES.CommsManager:DatabaseEncoder(entryDetails);
            valid_counter = valid_counter + 1
        else
            wipe(entry)
        end

        if valid_counter == numOfEntriesToCreate then
            local data = { ['total'] = valid_counter, ['entries'] = valid_entries }
            local encodedData = MODULES.CommsManager:DataEncoder(data)
            MODULES.DKPManager:ImportBulkEntries(encodedData, 'Lilduder', 'Large');

            PDKP.CORE:Print('Dummy database has been created with ' .. tostring(MODULES.DKPManager.numOfEntries) .. ' Entries');
        end
    end
end

function Dev:CreateDummyEntry(numOfMembers, memberNames, officerNames)

    -- Generate the start and end indexes for our entry's members.
    local member_index_start = random(numOfMembers)
    local member_index_end = random(member_index_start, numOfMembers)

    -- Random epoch timestamp between July 19th, 2021 and now.
    -- January 1st, 2021: 1609480800
    -- July 19, 2021: 1626652800
    local entry_id = random(1626652800, GetServerTime())

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
