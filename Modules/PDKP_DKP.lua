local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Util = core.Util;
local PDKP = core.PDKP;
local Raid = core.Raid;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Import = core.import;
local Comms = core.Comms;


local dkpDB;

local success = '22bb33'
local warning = 'E71D36'
local pdkp_boss_kill_dkp = 10

DKP.bankID = nil

--[[
--  RAID DB LAYOUT
--      {members} -- Array
--           [memberName] -- String / Object
--              dkpTotal -- int
--      {history} - Array of the history
--          [all] -- Array
--              [historyID] - Identifier of latest history item
--                  [entry1] - History changes.
--
--          [memberName] -- String / Array
--              [date] -- Array - UTC string of the date the entry was made.
--                  {entry1} -
--                      raidName -- String (MC)
--                      bossKills -- Int (10)
--
]]

local MonolithData = {}


local dkpDBDefaults = {
    profile = {
        currentDB = 'Molten Core',
        members = {},
        lastEdit = 0,
        history = {
            all = {},
            deleted = {}
        },
    }
}

function DKP:InitDKPDB()
    Util:Debug('DKPDB init');
    core.DKP.db = LibStub("AceDB-3.0"):New("pdkp_dkpHistory", dkpDBDefaults, true)
    dkpDB = core.DKP.db.profile
    DKP.dkpDB = dkpDB;

    print('Current raid DKP shown: ', dkpDB.currentDB);
end

--[[
--
--     HISTORY IDEA:
--  Keep a generalized History object in the database, which houses all of the DKP history changes.
--  Give that DKP object a Unique ID, whatever members are being edited using that object, add the object ID to their
--  Personal "History" table.
--
--  HistoryDB -> History -> Array of Object details: [UID] -> Details
--  Members -> Members -> History -> Array of UUID's -> ID1, ID2, ID67
--  This would make it a lot easier to merge the tables because you would be able to tell if an edit was missing from
--  one or the other! Also, keep a list of "Deleted" entries, so that if list 1 is more up to date, and deletes an entry
--  than list 2 still has that entry, list 2 knows to delete that entry as well.
 ]]

function DKP:VerifyTables()
    local next = next
    for key, member in pairs(dkpDB.members) do
        if type(member) == type('') then -- Remove the string.
            dkpDB.members[key] = nil;
        elseif next(dkpDB.members[key]) == nil then
            dkpDB.members[key] = nil;
        end
    end
end

function DKP:GetCurrentDatabase()
    return dkpDB.currentDB
end

-- cheaty way to update dkp via the boss kill event.
function DKP:BossKilled()

end

function DKP:BossKill(charObj)

    local name = charObj.name

    if Guild:IsMember(name) == false then return end;

    local dDate, tTime, server_time, datetime = Util:GetDateTimes()
    local boss = Raid.bossIDS[Raid.recentBossKillID];
    local raid = Raid:GetCurrentRaid()

    local dkpChangeText = Util:FormatFontTextColor(success, 10 .. ' DKP')
    local historyText = raid .. ' - ' .. boss;
    historyText = Util:FormatFontTextColor(success, historyText)

    local historyEntry = {
        ['text'] = historyText,
        ['reason'] = 'Boss Kill',
        ['bossKill'] = boss,
        ['raid'] = raid,
        ['dkpChange'] = pdkp_boss_kill_dkp,
        ['dkpChangeText'] = dkpChangeText,
        ['officer'] = Util:GetMyNameColored(),
        ['item']= nil,
        ['date']= dDate,
        ['time']=tTime,
        ['serverTime']=server_time,
        ['datetime']=datetime
    }

    if not dkpDB.history[name] then
--        table.insert(dkpDB.history, name);
        dkpDB.history[name] = {};
    end

    table.insert(dkpDB.history[name], historyEntry);

    DKP:Add(name, pdkp_boss_kill_dkp);

    GUI:UpdateEasyStats()
    -- Update the slider max (if needed)
    GUI:UpdateDKPSliderMax();
    -- Re-run the table filters.

    DKP:UpdateEntryRaidDkpTotal(raid, name, pdkp_boss_kill_dkp);

    if charObj.bName then
        local dkpText = _G[charObj.bName .. '_col3'];
        dkpText:SetText(charObj.dkpTotal);
    end
end

function DKP:ConfirmChange()
    local dkpChange = GUI.pdkp_dkp_amount_box:GetNumber();
    if dkpChange == 0 then return end; -- Don't need to change anything.

    if dkpChange > 0 then dkpChange = Util:FormatFontTextColor(Util.success, dkpChange)
    else dkpChange = Util:FormatFontTextColor(Util.warning, dkpChange)
    end

    local text = ''
    local chars = {};

    for _, char in pairs(GUI.selected) do
       if char.name then table.insert(chars, char) end
    end

    local function compareClass(a,b) return a.class < b.class end
    table.sort(chars, compareClass)

    for key, member in pairs(chars) do
        text = text..member['formattedName']
        if key < #chars then text = text .. ', ' end
    end

    local titleText = 'Are you sure you\'d like to give '..dkpChange..' DKP to the following players: \n \n'..text
    StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].text = titleText
    StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].data = chars;
    StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].charNames = text
    StaticPopup_Show('PDKP_CONFIRM_DKP_CHANGE')
end

function DKP:SortHistory()
    local tempTable = {}
    for key, val in orderedPairs(dkpDB.history.all) do
        tempTable[key] = val
    end
    dkpDB.history.all = tempTable;
end

-- Fixes the names of the entry members, if necessary.
function DKP:FixEntryMembers(entry)
    if entry['members'] == nil or #entry['members'] == 0 then -- Fixing legacy code.
        entry['members'] = {}
        for name in string.gmatch(entry['names'], '([^,]+)') do
            name = Util:RemoveColorFromname(name)
            table.insert(entry['members'], name)
        end
        if #entry['members'] == 0 then
            table.insert(entry['members'], Util:RemoveColorFromName(entry['names']))
        end
    end
    return entry
end

function DKP:DeleteEntry(entry, noBroacast)
    local entryKey = entry['id']

    for _, key in pairs(dkpDB.history['deleted']) do
       if key == entryKey then
           return Util:Debug("Entry was previously deleted")
       end
    end

    local isInHistory = false;

    for key, _ in pairs(dkpDB.history['all']) do
        if key == entryKey then isInHistory = true; end
    end

    if isInHistory == false then return PDKP:Print('You dkp tables are outdated, please request a full dkp push') end

    local changeAmount = entry['dkpChange']
    local raid = entry['raid']

--    -- We have to inverse the amount (make negatives positives, and positives negatives).
    changeAmount = changeAmount * -1;

    local members = Guild.members

    entry = DKP:FixEntryMembers(entry)

    local entryMembers = entry['members']
    entry['deleted'] = true

    for _, name in pairs(entryMembers) do
        local member = Guild.members[name]
        if member then
            local history = member.dkp[raid].entries
            local deleted = member.dkp[raid].deleted

            for key, val in pairs(history) do
                if val == entryKey then table.remove(history, key) end
            end

            table.insert(deleted, entryKey)

            member.dkp[raid].previousTotal = member.dkp[raid].total
            member.dkp[raid].total = changeAmount + member.dkp[raid].previousTotal
            member:Save()

            -- filter out based on online status
            for key, charObj in pairs(PDKP.data) do
                if charObj.name == member.name then
                    PDKP.data[key] = member;
                    break; -- Break the loop after we find our match.
                end
            end
        end
    end

    table.insert(dkpDB.history['deleted'], entryKey)

    DKP:ChangeDKPSheets(raid, true)
    GUI:UpdateEasyStats();

    local _, _, server_time, _ = Util:GetDateTimes()
    dkpDB.lastEdit = server_time

    -- Update the slider max (if needed)
    GUI:UpdateDKPSliderMax();
    -- Re-run the table filters.
    pdkp_dkp_table_filter()

    Guild:UpdateBankNote(dkpDB.lastEdit)
    DKP.bankID = dkpDB.lastEdit

    if noBroacast then return end -- Don't broadcast this change.
    Comms:SendGuildUpdate(entry)
end

function DKP:UpdateEntries()
    local dkpChange = GUI.pdkp_dkp_amount_box:GetNumber();
    if dkpChange == 0 then return end; -- Don't need to change anything.

    local dDate, tTime, server_time, datetime = Util:GetDateTimes()

    local reasonDrop = GUI.reasonDropdown
    local dropdowns = GUI.adjustDropdowns

    local reason = reasonDrop.text:GetText()
    local raid, boss, historyText, dkpChangeText, itemText;

    local reasonVal = reasonDrop:GetValue();

    if reasonVal >= 1 and reasonVal <= 5 then
        raid = dropdowns[2].text:GetText();
        if reasonVal >= 1 and reasonVal <= 3 or reasonVal == 5 then -- Ontime, Signup, Benched, Unexcused Absence
            historyText = raid .. ' - ' .. reason;
        end

        if reasonVal == 4 then
            boss = dropdowns[3].text:GetText();
            historyText = raid .. ' - ' .. boss;
        end
    elseif reasonVal == 6 then -- item Win
        historyText = 'Item Win - ';
    elseif reasonVal == 7 then -- Other selected
        local otherBox = getglobal('pdkp_other_entry_box')
        historyText = 'Other - ' .. otherBox:GetText();
    end

    if dkpChange > 0 then
        dkpChangeText = Util:FormatFontTextColor(success, dkpChange .. ' DKP')
        historyText = Util:FormatFontTextColor(success, historyText)
    elseif dkpChange < 0 then
        dkpChangeText = Util:FormatFontTextColor(warning, dkpChange .. ' DKP')
        historyText = Util:FormatFontTextColor(warning, historyText)
    end

    if reasonVal == 6 then -- item win
        local buttonText = _G['pdkp_item_link_text']
        historyText = historyText .. buttonText:GetText()
        itemText = buttonText:GetText();
    end

    if raid == nil then
        raid = DKP.dkpDB.currentDB
        Util:Debug('No raid found, setting raid to '.. raid)
    end

    local charObjs = StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].data -- Grab the data from our popup.
    local charNames = StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].charNames -- The char name string.

    local memberNames = {}
    for key, member in pairs(charObjs) do table.insert(memberNames, member.name) end

    local historyEntry = {
        ['id']=server_time,
        ['text'] = historyText,
        ['reason'] = reason,
        ['bossKill'] = boss,
        ['raid'] = raid,
        ['dkpChange'] = dkpChange,
        ['dkpChangeText'] = dkpChangeText,
        ['officer'] = Util:GetMyNameColored(),
        ['item']= itemText,
        ['date']= dDate,
        ['time']=tTime,
        ['serverTime']=server_time,
        ['datetime']=datetime,
        ['names']=charNames,
        ['members']= memberNames,
        ['deleted']=false,
        ['edited']=false
    }

    for key, member in pairs(charObjs) do
        local name = member.name;
        local dkp = member.dkp[raid];
        if dkp.entries == nil then member.dkp[raid].entries = {} end
        table.insert(dkp.entries, server_time)

        dkp.previousTotal = dkp.total
        dkp.total = dkp.total + dkpChange

        if dkp.total < 0 then dkp.total = 0 end

        if member.bName then -- update the player, visually.
            local dkpText = _G[member.bName ..'_col3'];
            dkpText:SetText(dkp.total)
        end
        member:Save() -- Update the database locally.
    end

    dkpDB.history['all'][server_time] = historyEntry;
    dkpDB.lastEdit = server_time
    Guild:UpdateBankNote(server_time)
    DKP.bankID = server_time

    if GUI.pdkp_frame:IsVisible() then
        GUI:UpdateEasyStats()

        -- Update the slider max (if needed)
        GUI:UpdateDKPSliderMax();
        -- Re-run the table filters.
        pdkp_dkp_table_filter()

        GUI.pdkp_dkp_amount_box:SetText('');
    end

    Comms:SendGuildUpdate(historyEntry)
end

function DKP:GetLastEdit()
    return dkpDB.lastEdit
end

function DKP:GetCurrentDB()
return dkpDB.currentDB
end

function DKP:UpdateEntryRaidDkpTotal(raid, name, dkpChange)
    if dkpChange == 0 or Util:IsEmpty(name) then return end;
    if raid == 'Onyxia\'s Lair' then raid = 'Molten Core' end
    if raid == nil then raid = dkpDB.currentDB; end

    local entry = dkpDB.members[name];
    entry[raid] = entry[raid] or 0;

    entry[raid] = entry[raid] + dkpChange;
    if entry[raid] < 0 then entry[raid] = 0 end
end

function DKP:ChangeDKPSheets(raid, noUpdate)
    if raid == 'Onyxia\'s Lair' then raid = 'Molten Core'; end

    dkpDB.currentDB = raid;

    GUI:GetTableDisplayData()

    if GUI.pdkp_frame:IsVisible() then
        pdkp_dkp_scrollbar_Update()
        GUI:UpdateDKPSliderMax()
    end

    GUI:ClearSelected()

    print('PantheonDKP: Showing ' .. Util:FormatFontTextColor(warning, raid) .. ' DKP table');
end

function DKP:GetPlayerDKP(name)
    local member = Guild.members[name]
    if member == nil then return 0 end;
    return member:GetDKP(dkpDB.currentDB, 'total')
end

function DKP:ResetDB()
    core.DKP.db:ResetDB(nil)
end

function DKP:GetDB()
    return dkpDB;
end

function DKP:GetHistory()
    return dkpDB.history.all
end

function DKP:GetMembers()
    return dkpDB.members;
end

function DKP:GetMemberCount()
    return table.getn(dkpDB.members);
end

function DKP:GetHighestDKP()
    local maxDKP = 0;
    local currentRaid = DKP:GetCurrentDB();

    for key, charObj in pairs(Guild.members) do
       if charObj.dkp then
           if charObj.dkp[currentRaid] and charObj.dkp[currentRaid].total and charObj.dkp[currentRaid].total > maxDKP then
              maxDKP = charObj.dkp[currentRaid].total
           end
       end
    end
    if maxDKP == 0 and Defaults.debug then return 50 end;
    return maxDKP;
end

function DKP:ValidateTables()
    local type = type

    local members = dkpDB.members;
    local history = dkpDB.history;
    local deleted = history.deleted;
    local all = history.all;

    local function compare(a,b)
        if a == nil and b == nil then return false
        elseif a == nil then return false
        elseif b == nil then return true
        else return a > b
        end
    end

    local function validateEntries(entries, name) -- Ensures that the entries are unique across the board.
        table.sort(entries, compare)
        local nonDuplicates = {}
        for key, value in pairs(entries) do -- remove the duplicates.
            if value ~= nil and value >= 1500000000 and value ~= entries[key + 1] then
                table.insert(nonDuplicates, value)
                for _, deletedEntry in pairs(deleted) do
                    if value == deletedEntry then
                        Util:Debug('Removing deleted entry ' .. value .. ' from ' .. name)
                        table.remove(nonDuplicates, key)
                    end
                end
            end
        end
--        print(name, ' had ', #entries - #nonDuplicates, ' duplicate or corrupt entries')
        return nonDuplicates;
    end

    local function validateDKP(name, member)
        local validBwlDKP = 0
        local validMcDKP = 0

        local mcDKP = member['Molten Core']
        local bwlDKP = member['Blackwing Lair']

        for i=1, #member['entries'] do
            local entryKey = member['entries'][i]
            local histEntry = all[entryKey]
            if histEntry ~= nil then
                local change = histEntry['dkpChange']
                if histEntry['raid'] == 'Blackwing Lair' then
                    validBwlDKP = validBwlDKP + change
                end
            end
        end
        if validBwlDKP ~= bwlDKP then
           print(name, ' validDKP: ', validBwlDKP, 'actual', bwlDKP)
        end
    end

    for key, member in pairs(members) do
        if type(key) == type('') then -- we have an object.
            local entries = member['entries']
            if entries then -- Make sure that the entries are unique.
                entries = validateEntries(entries, key)
                if #entries > 0 then
                    validateDKP(key, member)
                end
            end
        end
    end
end

function DKP:ImportMonolithData()
    local mono = MonolithData
    local dkp = dkpDB.members
--    local g = Guild.GuildDB.members

    for key,m in pairs(mono) do
        local name = m['name']
        if dkp[name] ~= nil then
            dkp[name]['dkpTotal'] = m['dkp']
            dkp[name]['Molten Core']=m['dkp']
        end
    end
    print('Finished Import data')
end

function DKP:CheckHistoryKeys(history)
    local deleted = history['deleted']
    local all = history['all']
end