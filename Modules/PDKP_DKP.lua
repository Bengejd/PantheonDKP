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

local dkpDB;

local success = '22bb33'
local warning = 'E71D36'
local pdkp_boss_kill_dkp = 10

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

local dkpDBDefaults = {
    profile = {
        currentDB = 'Molten Core',
        members = {},
        lastEdit = {},
        history = {
            all = {}
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

-- cheaty way to update dkp via the boss kill event.
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
        table.insert(dkpDB.history, name);
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

function DKP:UpdateEntry()
    local dkpChange = getglobal('pdkp_dkp_amount_box'):GetNumber();
    if dkpChange == 0 then return end; -- Don't need to change anything.

    local _, _, server_time, _ = Util:GetDateTimes()

    -- itterate through all of the selected entries and do the operations.
    for key, charObj in pairs(GUI.selected) do
        if charObj.name then
            -- Determine if we're adding or subtracting
            if dkpChange > 0 then charObj.dkpTotal = DKP:Add(charObj.name, dkpChange);
            elseif dkpChange < 0 then charObj.dkpTotal = DKP:Subtract(charObj.name, dkpChange);
            end
            -- Now update the visual text

            if charObj.bName then
                local dkpText = _G[charObj.bName .. '_col3'];
                dkpText:SetText(charObj.dkpTotal);
            end

            DKP:UpdateHistory(charObj.name, dkpChange, server_time);
        end
    end

    GUI:UpdateEasyStats()

    -- Update the slider max (if needed)
    GUI:UpdateDKPSliderMax();
    -- Re-run the table filters.
    pdkp_dkp_table_filter()
end

function DKP:UpdateHistory(name, dkpChange, global_server_time)
    local amountBox = getglobal('pdkp_dkp_amount_box');
    local itemLink = getglobal('pdkp_item_link');

    local reasonDrop = GUI.reasonDropdown
    local dropdowns = GUI.adjustDropdowns

    local reason = reasonDrop.text:GetText()
    local raid;
    local boss;
    local historyText;
    local dkpChangeText;
    local dDate, tTime, server_time, datetime = Util:GetDateTimes()

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
    end

    if reasonVal == 6 then -- item win
        historyText = 'Item Win -';
    end

    if reasonVal == 7 then -- Other selected
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
        local buttonText = getglobal('pdkp_item_link_text')
        historyText = historyText .. buttonText:GetText()
    end

    if raid == nil then
        raid = DKP.dkpDB.currentDB
        print('No raid found, setting raid to '.. raid)
    end

    local historyEntry = {
        ['text'] = historyText,
        ['reason'] = reason,
        ['bossKill'] = boss,
        ['raid'] = raid,
        ['dkpChange'] = dkpChange,
        ['dkpChangeText'] = dkpChangeText,
        ['officer'] = Util:GetMyNameColored(),
        ['item']= nil,
        ['date']= dDate,
        ['time']=tTime,
        ['serverTime']=server_time,
        ['datetime']=datetime
    }

    if not dkpDB.history[name] then
       table.insert(dkpDB.history, name);
        dkpDB.history[name] = {};
    end

    table.insert(dkpDB.history[name], historyEntry);
    dkpDB.lastEdit = {
        ['reason'] = reason,
        ['raid'] = raid,
        ['dkpChange'] = dkpChange,
        ['dkpChangeText'] = dkpChangeText,
        ['officer'] = Util:GetMyNameColored(),
        ['serverTime']= global_server_time,
    }

    DKP:UpdateEntryRaidDkpTotal(raid, name, dkpChange);
end

function DKP:GetLastEdit()
    return dkpDB.lastEdit
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

function DKP:ChangeDKPSheets(raid)
    if raid == 'Onyxia\'s Lair' then raid = 'Molten Core'; end

    for key, name in ipairs(DKP:GetMembers()) do
        dkpDB.members[name].dkpTotal = dkpDB.members[name][raid];
    end
    dkpDB.currentDB = raid;

    PDKP:BuildAllData()
    GUI:GetTableDisplayData()
    pdkp_dkp_scrollbar_Update()

    print('Showing ' .. Util:FormatFontTextColor(warning, raid) .. ' DKP');
end

function DKP:SyncWithGuild()
    Util:Debug('Syncing Guild Data...');
    local guildMembers = Guild:GetMembers();
    local dkpMembers = DKP:GetMembers();
    for i=1, #guildMembers do
        local gMember = guildMembers[i];
        if not dkpMembers[gMember.name] then -- Add a new entry to the database.
            DKP:NewEntry(gMember.name)
        end
    end
end

function DKP:Add(name, dkp)
    dkpDB.members[name].dkpTotal = dkpDB.members[name].dkpTotal + dkp;
    return dkpDB.members[name].dkpTotal;
end

function DKP:Subtract(name, dkp)
    local newTotal = dkpDB.members[name].dkpTotal + dkp; -- Add the negative number.
    if newTotal < 0 then newTotal = 0 end-- It shouldn't be possible for anyone to go negative in this system.
    dkpDB.members[name].dkpTotal = newTotal;
    return dkpDB.members[name].dkpTotal;
end

function DKP:NewEntry(name)
    if Util:IsEmpty(name) then return end;

    local dkpEntry = dkpDB.members[name];

    if dkpEntry then -- Entry already exists!
        Util:Debug("This entry already exists!!")
    else
        Util:Debug("Adding new DKP entry for " .. name)
        table.insert(dkpDB.members, name)
        dkpDB.members[name] = {
            dkpTotal = 0;
            ['Molten Core'] = 0,
            ['Blackwing Lair'] = 0,
        }
    end
end

function DKP:GetPlayerDKP(name)
    return dkpDB.members[name].dkpTotal;
end

function DKP:ResetDB()
    core.DKP.db:ResetDB(nil)
end

function DKP:GetDB()
    return dkpDB;
end

function DKP:GetMembers()
    return dkpDB.members;
end

function DKP:GetMemberCount()
    return table.getn(dkpDB.members);
end

function DKP:GetHighestDKP()
    local maxDKP = 0;
    for key, charObj in pairs(DKP:GetMembers()) do
        if charObj.dkpTotal then
            if charObj.dkpTotal > maxDKP then
                if Guild:IsMember(key) then maxDKP = charObj.dkpTotal end
            end
        end
    end

    if maxDKP == 0 and Defaults.debug then return 50 end;
    return maxDKP;
end

function DKP:GetCommsData()

end

