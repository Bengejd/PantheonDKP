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
local Comms = core.Comms;

-- Check banks latest officer note. If the value is higher than your value, then you can assume you're out of date.
-- If you are out of date, look to see what officers are online, and request a push from their database, if their last
-- edit is equal to the banks last edit or greater than your own. If not, continue until you find one.
--

function Import:AcceptData(reqData)
    local addon_version = tonumber(reqData.addon_version)
    local my_addon_version = tonumber(Defaults.addon_version)

    if (my_addon_version and addon_version) and (my_addon_version > addon_version) then
        -- TODO: Possibly do something here??
    end

    Util:Debug('Import received from addon version '.. tostring(reqData.addon_version))

    if reqData.full then -- THIS IS A FULL OVERWRITE
        Import:AcceptFullDatabase(reqData)
        PDKP:Print('Full database overwrite in progress')
    else -- THIS IS A MERGE
        Util:Debug('Merging data...')

        local reqDKP = reqData.dkpDB;

        local reqLastEdit, reqHistory = reqDKP.lastEdit, reqDKP.history;
        local reqAll, reqDeleted = reqHistory.all, reqHistory.deleted

        local members = Guild.members;
        local history = DKP.dkpDB.history;
        local allHistory = history.all;
        local deleted = history.deleted;
        local lastEdit = DKP.dkpDB.lastEdit;

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

                    if member ~= nil then
                        local isInDeleted, isInHistory = member:CheckForEntryHistory(entry)

                        if isInDeleted == false and isInHistory == false then
                            local dkp = member:GetDKP(raid, 'all')
                            if dkp then
                                if dkp.entries == nil then member.dkp[raid].entries = {} end
                                table.insert(dkp.entries, entryKey)
                                dkp.previousTotal = dkp.total;
                                dkp.total = dkp.total + entry['dkpChange']
                                if dkp.total < 0 then dkp.total = 0 end;

                                GUI:UpdateVisualDKP(member, raid)

                                if member.bName then -- update the player visually.
                                    local dkpText = _G[member.bName .. '_col3']
                                    if dkpText:IsVisible() then
                                        dkpText:SetText(dkp.total)
                                    end
                                end
                                member:Save() -- Update the database locally.
                            else
                                Util:ThrowError('Sync Error: Could not find dkp for '.. member.name)
                            end
                        else
                            if isInDeleted then
                                Util:Debug('This entry was recently deleted, skipping.')
                            elseif isInHistory then
                                Util:Debug('This entry already exists, skipping.')
                            end
                        end
                    end
                end
                if entryKey > lastEdit then DKP.dkpDB.lastEdit = entryKey; end
                allHistory[entryKey] = entry; -- Add the entry to the all history.
            end
        end

        if #reqHistory == 1 and (reqAll == nil and reqDeleted == nil) then -- This is a single entry update.
            local entry = DKP:FixEntryMembers(reqHistory[1])
            updateEntry(entry)
        elseif reqAll and reqDeleted and (#reqAll > 1 or #reqDeleted > 1) then -- we have the [deleted] and [all] tables in this table.
            for key, entry in pairs(reqAll) do
                Util:Debug('Processing entry...' .. key)
                if key ~= 1 and entry ~= nil then
                    entry = DKP:FixEntryMembers(entry)
                    updateEntry(entry)
                end
            end
            for _, entryID in pairs(reqDeleted) do
                Util:Debug('Processing deleted entry: ' .. entryID)
                local entry = reqAll[entryID]
                if entry ~= nil then
                    entry['deleted'] = true
                    updateEntry(entry)
                end
            end
        end
    end

   if GUI.pdkp_frame and GUI.pdkp_frame:IsVisible() then
       GUI:pdkp_dkp_table_sort('dkpTotal')
       DKP:ChangeDKPSheets(DKP.dkpDB.currentDB, true)
       pdkp_dkp_scrollbar_Update()
       pdkp_dkp_table_filter()
       GUI:pdkp_dkp_table_sort('dkpTotal')
   end

    PDKP:Print("A DKP push has completed")
end

function Import:AcceptFullDatabase(data)
    local guildData = data.guildDB
    local dkpData = data.dkpDB

    Guild.db.members = guildData.members

    DKP.dkpDB.lastEdit = dkpData.lastEdit;
    DKP.dkpDB.history = dkpData.history;
    DKP.dkpDB.members = dkpData.members;

    PDKP:InitializeGuildData() -- Re-initialize the guild data.
    pdkp_init_scrollbar() -- re-setup the scroll section, if necessary.
end

function Import:GetHistoryKeys()
    local pushHistory = { ['all'] = {}, ['deleted'] = {}, }
    for entryKey, entry in pairs(DKP.dkpDB.history) do
        pushHistory['all'][entryKey] = true
    end
    if DKP.dkpDB.deleted ~= nil then
        for key, entryKey in pairs(DKP.dkpDB.deleted) do
            pushHistory['deleted'][entryKey] = true
        end
    end
    return pushHistory
end

function Import:RequestData(officer)
    Util:Debug("Requesting data from " .. officer['formattedName'] .. ' this may take a few minutes...')
    local historyKeys = Import:GetHistoryKeys()

    -- TODO Hook this function up!

    Comms:SendCommsMessage('pdkpPushRequest', PDKP:Serialize(''), 'WHISPER', officer['name'], 'BULK')
end

function Import:TestDataImport()

end
