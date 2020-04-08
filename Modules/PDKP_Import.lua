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
local Import = core.Import;

local reqDBHistory = {
    [1585187159] = {
        ["id"] = 1585187159,
        ["text"] = "|cff22bb33Blackwing Lair - Completion Bonus|r",
        ["reason"] = "Completion Bonus",
        ["names"] = "|cffF58CBACaptnutsack|r",
        ["datetime"] = 1585187159,
        ["dkpChangeText"] = "|cff22bb3350 DKP|r",
        ["time"] = "02:54:51 PM",
        ["date"] = "03/25/20",
        ["dkpChange"] = 50,
        ["raid"] = "Blackwing Lair",
        ["serverTime"] = 1585187159,
        ["officer"] = "|cff8787EDSparklenips|r",
    },
    [2585173212] = {
        ["id"] = 2585173212,
        ["text"] = "|cff22bb33Blackwing Lair - Completion Bonus|r",
        ["reason"] = "Completion Bonus",
        ["names"] = "|cffF58CBADolamroth|r",
        ["datetime"] = 1585173213,
        ["dkpChangeText"] = "|cff22bb3383 DKP|r",
        ["time"] = "02:53:33 PM",
        ["date"] = "03/25/20",
        ["dkpChange"] = 83,
        ["raid"] = "Blackwing Lair",
        ["serverTime"] = 2585173212,
        ["officer"] = "|cff8787EDSparklenips|r",
    },
    [2585173411] = {
        ["id"] = 2585173411,
        ["text"] = "|cff22bb33Blackwing Lair - Completion Bonus|r",
        ["reason"] = "Completion Bonus",
        ["names"] = "|cffABD473Athico|r",
        ["datetime"] = 1585173412,
        ["dkpChangeText"] = "|cff22bb33100 DKP|r",
        ["time"] = "02:56:52 PM",
        ["date"] = "03/25/20",
        ["dkpChange"] = 100,
        ["raid"] = "Blackwing Lair",
        ["serverTime"] = 2585173411,
        ["officer"] = "|cff8787EDSparklenips|r",
    },
    [2585173348] = {
        ["id"] = 2585173348,
        ["text"] = "|cff22bb33Blackwing Lair - Completion Bonus|r",
        ["reason"] = "Completion Bonus",
        ["names"] = "|cff8787EDSoftfondle|r",
        ["datetime"] = 2585173348,
        ["dkpChangeText"] = "|cff22bb3355 DKP|r",
        ["time"] = "02:55:49 PM",
        ["date"] = "03/25/20",
        ["dkpChange"] = 55,
        ["raid"] = "Blackwing Lair",
        ["serverTime"] = 2585173348,
        ["officer"] = "|cff8787EDSparklenips|r",
    },
    [2585173067] = {
        ["id"] = 2585173067,
        ["text"] = "|cff22bb33Blackwing Lair - Completion Bonus|r",
        ["reason"] = "Completion Bonus",
        ["names"] = "|cffC79C6ERetkin|r, |cffC79C6ESnaildaddy|r, |cffC79C6EGoobimus|r",
        ["datetime"] = 2585173067,
        ["dkpChangeText"] = "|cff22bb33100 DKP|r",
        ["time"] = "02:51:08 PM",
        ["date"] = "03/25/20",
        ["dkpChange"] = 100,
        ["raid"] = "Blackwing Lair",
        ["serverTime"] = 2585173067,
        ["officer"] = "|cff8787EDSparklenips|r",
    },
    [2585196310] = {
        ["reason"] = "Boss Kill",
        ["id"] = 2585196310,
        ["text"] = "|cff22bb33Blackwing Lair - Chromaggus|r",
        ["bossKill"] = "Chromaggus",
        ["names"] = "|cffFF7D0ANeekio|r, |cffFF7D0AEmmyy|r, |cffFF7D0AMorphintyme|r, |cffABD473Ithgar|r, |cffABD473Cyskul|r, |cffABD473Athico|r, |cff40C7EBVeriandra|r, |cff40C7EBJakemeoff|r, |cff40C7EBNeckbeardo|r, |cff40C7EBFlatulent|r, |cff40C7EBStitchess|r, |cff40C7EBXyen|r, |cffF58CBAOdin|r, |cffF58CBAAdvanty|r, |cffF58CBAMaryjohanna|r, |cffF58CBAForerunner|r, |cffFFFFFFPhilonious|r, |cffFFFFFFPuffhead|r, |cffFFFFFFBallour|r, |cffFFFFFFPriesticuffs|r, |cffFFFFFFTurbohealz|r, |cffFFF569Slipperyjohn|r, |cffFFF569Sicarrio|r, |cffFFF569Mozzarella|r, |cffFFF569Aku|r, |cffFFF569Mcstaberson|r, |cffFFF569Mariku|r, |cff8787EDLindo|r, |cff8787EDThenight|r, |cff8787EDRaspütin|r, |cff8787EDDalia|r, |cff8787EDGartog|r, |cff8787EDEdgyboi|r, |cffC79C6EKalita|r, |cffC79C6EGoobimus|r, |cffC79C6EGirlslayer|r, |cffC79C6EHotdogbroth|r, |cffC79C6EMihai|r, |cffC79C6EOragan|r, |cffC79C6EQew|r",
        ["datetime"] = 2585196310,
        ["dkpChangeText"] = "|cff22bb3310 DKP|r",
        ["time"] = "12:18:31 AM",
        ["date"] = "03/26/20",
        ["dkpChange"] = 10,
        ["raid"] = "Blackwing Lair",
        ["serverTime"] = 2585196310,
        ["officer"] = "|cffFF7D0ANeekio|r",
    },
}

-- Check banks latest officer note. If the value is higher than your value, then you can assume you're out of date.
-- If you are out of date, look to see what officers are online, and request a push from their database, if their last
-- edit is equal to the banks last edit or greater than your own. If not, continue until you find one.
--

function Import:AcceptData(reqData)
    if reqData.full then -- THIS IS A FULL OVERWRITE
--        Import:AcceptFullDatabase(requestedData)
        print('Full database overwrite in progress')
    else -- THIS IS A MERGE
        local reqDKP = reqData.dkpDB;
        local reqGuild = reqData.guildDB;

        local reqNumOfMembers, reqMembers = reqGuild.numOfMembers, reqGuild.members;
        local reqLastEdit, reqHistory = reqDKP.lastEdit, reqDKP.history;
        local reqAll, reqDeleted = reqHistory.all, reqHistory.deleted

        local members = Guild.members;
        local history = DKP.dkpDB.history;
        local allHistory = history.all;
        local deleted = history.deleted;

        local function updateEntry(entry)
            if entry['deleted'] then
                Util:Debug("Processing as a delete")
                return DKP:DeleteEntry(entry, true)
            elseif entry['edited'] then
                Util:Debug("Processing as an edit")
            else
                Util:Debug('Processing an addition')
                local raid = entry['raid']
                local entryKey = entry['id']

                for _, memberName in pairs(entry['members']) do
                    local member = members[memberName];
                    local isInDeleted, isInHistory = member:CheckForEntryHistory(entry)

                    if isInDeleted == false and isInHistory == false then
                        local dkp = member.dkp[raid]
                        if dkp.entries == nil then member.dkp[raid].entries = {} end
                        table.insert(dkp.entries, entryKey)
                        dkp.previousTotal = dkp.total;
                        dkp.total = dkp.total + entry['dkpChange']
                        if dkp.total < 0 then dkp.total = 0 end;

                        if member.bName then -- update the player visually.
                            local dkpText = _G[member.bName .. '_col3']
                            dkpText:SetText(dkp.total)
                        end
                        member:Save() -- Update the database locally.
                    else
                        if isInDeleted then
                           Util:Debug('This entry was recently deleted, skipping.')
                        elseif isInHistory then
                            Util:Debug('This entry already exists, skipping.')
                        end
                    end
                end
            end
        end

        if #reqHistory == 1 and (reqAll == nil and reqDeleted == nil) then -- This is a single entry update.
            local entry = DKP:FixEntryMembers(reqHistory[1])
            updateEntry(entry)
        elseif #reqHistory > 1 then

        end

--        dkpDB.history['all'][server_time] = historyEntry;
--        dkpDB.lastEdit = server_time
--
--        GUI:UpdateEasyStats()
--
--        -- Update the slider max (if needed)
--        GUI:UpdateDKPSliderMax();
--        -- Re-run the table filters.
--        pdkp_dkp_table_filter()
--
--        Guild:UpdateBankNote(server_time)
--        DKP.bankID = server_time
--
--        GUI.pdkp_dkp_amount_box:SetText('');
--
--        Comms:SendGuildUpdate(historyEntry)


--        local function processLastEdit()
--            Util:Debug("Processing LastEdit")
--            DKP.dkpDB.lastEdit = reqLastEdit
--        end
--
--        if reqAllData == nil then reqAllData = reqHistory end
--        if reqAllData ~= nil then processAllData() end
--        if reqDeleted ~= nil then processDeleted() end
--        if reqLastEdit ~= nil and reqLastEdit > DKP.dkpDB.lastEdit then processLastEdit() end
    end

    GUI:pdkp_dkp_table_sort('dkpTotal')
    DKP:ChangeDKPSheets(DKP.dkpDB.currentDB, true)
    pdkp_dkp_scrollbar_Update()
    pdkp_dkp_table_filter()
    GUI:pdkp_dkp_table_sort('dkpTotal')

    GUI.pushFrame:Hide()

    PDKP:Print("The DKP push has completed successfully")
end

function Import:AcceptFullDatabase(data)
    local guildData = data.guildDB
    local dkpData = data.dkpDB

    Guild.db.numOfMembers = guildData.numOfMembers
    Guild.db.members = guildData.members

    DKP.dkpDB.lastEdit = dkpData.lastEdit;
    DKP.dkpDB.history = dkpData.history;
    DKP.dkpDB.members = dkpData.members;
    DKP.dkpDB.currentDB = dkpData.currentDB;
end

function Import:RequestData(officer)
    Util:Debug("Requesting data from " .. officer['formattedName'] .. ' this may take a few minutes...')
    local TwoWeeksAgo = 1209600 -- two weeks in seconds.
    local server_time = GetServerTime()
    local requestTime = server_time - TwoWeeksAgo
    PDKP:SendCommMessage('pdkpPushRequest', PDKP:Serialize(requestTime), 'WHISPER', officer['name'], 'BULK')
end

