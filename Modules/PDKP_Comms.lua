local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Comms = core.Comms;
local Import = core.Import;
local Raid = core.Raid;

--[[
--
--  MESSAGE TYPES: "PARTY", "RAID", "GUILD", "OFFICER", "BATTLEGROUND", "WHISPER"
--
 ]]

local SAFE_COMMS = {
    ['pdkpPushRequest'] = true,
    ['pdkpLastEditReq'] = true,
    ['pdkpLastEditRec'] = true,
    ['pdkpBusyTryAgai'] = true,
    ['pdkpPushInProg'] = true,
    ['pdkpSyncRequest'] = true,
};

local UNSAFE_COMMS = {
    ['pdkpPushReceive'] = true,
    ['pdkpBusyTryAgai'] = true,
    ['pdkpEntryDelete'] = true,
    ['pdkpClearShrouds'] = true,
    ['pdkpNewShrouds'] = true,
    ['pdkpSyncResponse'] = true
}

local pdkpPushDatabase = {
    full = false,
    guildDB = {
        numOfMembers = nil,
        members = {},
    },
    dkpDB = {
        lastEdit = nil,
        currentDB = nil,
        history = {},
        members = {},
    }
}

Comms.processing = false

---------------------------
-- GENERIC Functions   --
---------------------------
function Comms:RegisterCommCommands()
    for key, _ in pairs(SAFE_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end
    for key, _ in pairs(UNSAFE_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end
end

function Comms:Serialize(data)
    return PDKP:Serialize(data);
end

function pdkp_serialize(data)
    return PDKP:Serialize(data);
end

function Comms:Deserialize(string)
    local success, data = PDKP:Deserialize(string)

    if success == false or success == nil then
        Util:ThrowError('Deserialization of data...');
        return nil;
    end
    return data;
end

function Comms:SendCommsMessage(prefix, data, distro, sendTo, bulk, func)
    if Defaults.debug and distro == 'WHISPER' and sendTo ~= 'Pantheonbank' then
        print('Skipping broadcast Cause ' .. sendTo .. ' is not bank!!!')

        return
    elseif Defaults.no_broadcast then
        print('Skipping broadcast!')
        return
    end

    if distro == 'WHISPER' then
        Util:Debug('Sending message ' .. prefix .. ' to' .. sendTo)
    end

    PDKP:SendCommMessage(prefix, data, distro, sendTo, bulk, func)
end

function OnCommReceived(prefix, message, distribution, sender)
    if Comms.processing then -- If we're processing a com, don't overload yourself.
        return Comms:SendCommsMessage('pdkpBusyTryAgai', PDKP:Serialize('Busy'), 'WHISPER', sender, 'BULK')
    end

    if sender == Util:GetMyName() then -- Don't need to respond to our own messages...
        if prefix ~= 'pdkpNewShrouds' then
            Util:Debug('Ignoring comm from me ' .. prefix)
            return
        end;
    end;

    Comms.processing = false -- This should be true, but it's not working for some reason...

    local data = Comms:Deserialize(message) -- deserialize it.

    if SAFE_COMMS[prefix] then Comms:OnSafeCommReceived(prefix, data, distribution, sender);
    elseif UNSAFE_COMMS[prefix] then Comms:OnUnsafeCommReceived(prefix, data, distribution, sender);
    else
        print("Unknown Prefix " .. prefix, " found in request...")
    end

    Comms.processing = false
end

function Comms:ThrowError(prefix, sender)
    local errMsg = sender .. ' is attempting to use an unsafe communication method: ' .. prefix .. ' Please contact'
    errMsg = errMsg .. ' an Officer.'
    return Util:ThrowError(errMsg, true)
end

---------------------------
-- SAFE FUNCTIONS     --
---------------------------
function Comms:OnSafeCommReceived(prefix, message, distribution, sender)
    -- We received a communication that we shouldn't have...
    if not SAFE_COMMS[prefix] then return Comms:ThrowError(prefix, sender) end

    local safeFuncs = {
        ['pdkpBusyTryAgai'] = function() PDKP:Print(sender .. ' is currently busy, please try again later') end,
        -- Send them back your lastEdit time
        ['pdkpLastEditReq'] = function()
            Comms:SendCommsMessage('pdkpLastEditRec', PDKP:Serialize(DKP.dkpDB.lastEdit), 'WHISPER', sender, 'BULK')
        end,
        -- Process their lastEdit time
        ['pdkpLastEditRec'] = function() Comms:LastEditReceived(sender, message) end,
        -- Someone Sent you a push request
        ['pdkpPushRequest'] = function()
            PDKP:Print("Preparing data to push to " .. sender .. ' This may take a few minutes...')

            -- TODO: Fix this so that it only requests the keys that you don't have.

            Comms:PrepareDatabase(false)
            Comms:SendCommsMessage('pdkpPushReceive', PDKP:Serialize(pdkpPushDatabase), 'WHISPER', sender, 'BULK', UpdatePushBar)
        end,
        ['pdkpSyncRequest'] = function()
            if core.canEdit then
                local database = Comms:PrepareDatabaseSyncResponse(message)
                Comms:SendCommsMessage('pdkpSyncResponse', PDKP:Serialize(database), 'WHISPER', sender, 'BULK')
            end
        end,
    }

    if safeFuncs[prefix] then safeFuncs[prefix]() end
end

---------------------------
-- UNSAFE FUNCTIONS    --
---------------------------
function Comms:OnUnsafeCommReceived(prefix, message, distribution, sender)

    -- We received a communication that we shouldn't have...
    if not UNSAFE_COMMS[prefix] or not Guild:CanMemberEdit(sender) then return Comms:ThrowError(prefix, sender) end

    local unsafeFuncs = {
        ['pdkpBusyTryAgai'] = function() PDKP:Print(sender .. ' is currently busy, please try again later') end,
        ['pdkpPushReceive'] = function()
            PDKP:Print("DKP Update received from " .. sender .. ' updating your DKP tables...')
            Import:AcceptData(message)
        end,
        ['pdkpEntryDelete'] = function()
            DKP:DeleteEntry(message, false)
        end,
        ['pdkpClearShrouds'] = function() Shroud:ClearShrouders() end,
        ['pdkpNewShrouds'] = function()
            Shroud.shrouders = message -- assign the shrouding table that was sent.
            Shroud:UpdateWindow() -- Update the window.
        end,
        ['pdkpSyncResponse'] = function()
            Import:AcceptData(message)
        end,
        ['pdkpPlaceholder'] = function() end,
    }

    if unsafeFuncs[prefix] then unsafeFuncs[prefix]() end

    -- We've finished processing the comms.
    Comms.processing = false
end

function Comms:SendGuildPush(full)
    Comms:ResetDatabse()
    PDKP:Print("Preparing data to push to GUILD this may take a few minutes...")
    Comms:PrepareDatabase(full)
    Comms:SendCommsMessage('pdkpPushReceive', PDKP:Serialize(pdkpPushDatabase), 'GUILD', nil, 'BULK', UpdatePushBar)
end

function Comms:SendGuildUpdate(histEntry)
    Comms:ResetDatabse()
    pdkpPushDatabase.dkpDB.lastEdit = DKP.dkpDB.lastEdit
    table.insert(pdkpPushDatabase.dkpDB.history, histEntry)

    Comms:SendCommsMessage('pdkpPushReceive', PDKP:Serialize(pdkpPushDatabase), 'GUILD', nil, nil)
end

function Comms:ResetDatabse()
    pdkpPushDatabase = {
        addon_version = '',
        full = false,
        guildDB = {
            numOfMembers = nil,
            members = nil,
        },
        dkpDB = {
            lastEdit = nil,
            history = {},
            members = nil,
            currentDB = nil
        }
    }
end

function Comms:PrepareDatabase(full)
    if full then -- full overwrite
        pdkpPushDatabase = {
            addon_version = '',
            full = full,
            guildDB = {
                numOfMembers = Guild.db.numOfMembers,
                members = Guild.db.members
            },
            dkpDB = {
                lastEdit = DKP.dkpDB.lastEdit,
                history = DKP.dkpDB.history,
                members = nil,
                currentDB = nil
            }
        }
    else -- merge, partial.
        pdkpPushDatabase = {
            addon_version = '',
            full = full,
            guildDB = {
                numOfMembers = Guild.db.numOfMembers,
                members = Guild.members,
            },
            dkpDB = {
                lastEdit = DKP.dkpDB.lastEdit,
                history = DKP.dkpDB.history,
                members = nil,
                currentDB = nil
            }
        }
    end
end

function Comms:RequestOfficersLastEdit()
    Guild:GetGuildData() -- Retrieve up to date guild data.

    local oneReqTriggered = false

    local officers = Guild.officers;
    for i = 1, #officers do
        local officer = officers[i]
        officer['lastEdit'] = -1
        if officer['online'] and officer['name'] ~= Util:GetMyName() then
            oneReqTriggered = true
            Util:Debug('sending lastEdit request to ' .. officer['name'])
            Comms:SendCommsMessage('pdkpLastEditReq', PDKP:Serialize(''), 'WHISPER', officer['name'], 'BULK')
        end
    end

    if oneReqTriggered == true then -- check for if the officer actually has the addon or not.
        local shouldContinue = false
        for i = 1, #officers do
            local officer = officers[i]
            if officer['online'] and officer['name'] ~= Util:GetMyName() then
                if officer['lastEdit'] ~= -1 then
                    shouldContinue = true
                    break
                end
            end
        end
        oneReqTriggered = shouldContinue
    end

    -- Pop up the frame if we didn't get any hits from the officers & you are an officer.
    if oneReqTriggered == false and Guild:CanEdit() then
        GUI:UpdatePushFrame()
    elseif oneReqTriggered == false then
        PDKP:Print('No up to date officers are online currently. Please try again later!')
    else
    end
end

function Comms:LastEditReceived(sender, message)
    Util:Debug('Received Last Edit from ' .. sender)
    for i = 1, #Guild.officers do
        local officer = Guild.officers[i];
        if officer['name'] == sender then
            officer['lastEdit'] = message
        end
    end
    GUI:UpdatePushFrame()
end

---------------------------
-- SHROUDING FUNCTIONS  --
---------------------------
function Comms:SendShroudTable()
    if Raid:IsInRaid() then
        Comms:SendCommsMessage('pdkpNewShrouds', PDKP:Serialize(Shroud.shrouders), 'RAID', nil, 'BULK', nil)
    elseif Defaults.debug then -- debug mode, we can't send messages to ourselves.
--        Comms:OnUnsafeCommReceived('pdkpNewShrouds', PDKP:Serialize(Shroud.shrouders), 'RAID', nil, 'BULK', nil)
    else -- For the sender to update their table.
--        Shroud:UpdateWindow()
    end
end

function Comms:ClearShrouders()
    Comms:SendCommsMessage('pdkpClearShrouds', PDKP:Serialize(''), 'RAID', nil, nil)
end

-- Innermediate function between Request & Reponse.
function Comms:PrepareDatabaseSyncResponse(historyKeys)
    local pdkpSyncResponseDatabase = {
        addon_version = Defaults.addon_version,
        full = false,
        guildDB = {
            numOfMembers = nil,
            members = nil,
        },
        dkpDB = {
            lastEdit = DKP.dkpDB.lastEdit,
            history = {
                all = nil,
                deleted = nil,
            },
            members = nil,
            currentDB = nil
        }
    }

    local theirAll = historyKeys.all;
    local theirDeleted = historyKeys.deleted;

    local myAll = {}
    local myDeleted = {}

    for key, entry in pairs(DKP.dkpDB.history.all) do
        myAll[key] = entry;
        for i = 1, #theirAll do
            local theirKey = theirAll[i];
            if theirKey == entry['id'] then -- Found a match
                myAll[key] = nil -- Remove it from the list.
                break -- Break out of the inner loop & continue.
            end
        end
    end

    for _, entryID in pairs(DKP.dkpDB.history.deleted) do
        table.insert(myDeleted, entryID)
        for i = 1, #theirDeleted do
            local theirKey = theirDeleted[i];
            if theirKey == entryID then -- Found a match
                for j = 1, #myDeleted do -- loop through myDeleted and remove the entry.
                    local deleteKey = myDeleted[j];
                    if deleteKey == theirKey then  -- Found a match
                        table.remove(myDeleted, j); -- Remove it
                        break; -- Break out
                    end
                end
                break -- Break out
            end
        end
    end

    pdkpSyncResponseDatabase.dkpDB.history = {
        all = myAll,
        deleted = myDeleted
    }
    return pdkpSyncResponseDatabase
end

function Comms:DatabaseSyncRequest()
    PDKP:Print('Attempting Automatic Database Sync...')

    local myHistory = {
        all = {},
        deleted = {}
    }
    local dkpDB = DKP.dkpDB.history
    for _, entry in pairs(dkpDB.all) do table.insert(myHistory.all, entry['id']); end
    for _, entryKey in pairs(dkpDB.deleted) do table.insert(myHistory.deleted, entryKey); end

    Comms:SendCommsMessage('pdkpSyncRequest', PDKP:Serialize(myHistory), 'GUILD', nil, 'BULK', nil)
end