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
    ['pdkpLastEditReq'] = true,
    ['pdkpLastEditRec'] = true,
    ['pdkpPushInProg'] = true,
    ['pdkpModLastEdit']=true,
};

local UNSAFE_COMMS = {
    ['pdkpSyncResponse'] = true
}

local OFFICER_COMMS = {
    ['pdkpSyncRequest'] = true,
}

local RAID_COMMS = {
    ['pdkpClearShrouds']=true, -- Officer check
    ['pdkpNewShrouds']=true, -- Officer check
    ['pdkpDkpOfficer']=true, -- Officer check
}

local GUILD_COMMS = {
    ['pdkp_placeholder']=true,
    ['pdkpPushReceive'] = true, -- Officer check
    ['pdkpEntryDelete'] = true, -- Officer check
    ['pdkpSyncRes']=true
}

Comms.commsRegistered = false

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

local skipBroadcastMsg = 'Skipping broadcast because '

---------------------------
-- GENERIC Functions   --
---------------------------
function Comms:RegisterCommCommands()
    Comms.commsRegistered = true -- Check to make sure we don't re-register the comms.

    for key, _ in pairs(SAFE_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end
    for key, _ in pairs(UNSAFE_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end
    for key, _ in pairs(GUILD_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end -- General guild comms
    for key, _ in pairs(RAID_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end -- General Raid comms

    if core.canEdit then -- Only register officers to the officer_comms.
        Util:Debug('Register Officer Comms')
        for key, _ in pairs(OFFICER_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end
    end
end

function Comms:Serialize(data)
    return PDKP:Serialize(data);
end

function Comms:Deserialize(string)
    local success, data = PDKP:Deserialize(string)

    if success == false or success == nil then
        Util:ThrowError('An error occured Deserializing the data...');
        return nil;
    end
    return data;
end

function Comms:DataEncoder(data)
    local serialized = PDKP:Serialize(data)
    local compressed = core.LibDeflate:CompressDeflate(serialized)
    local encoded = core.LibDeflate:EncodeForWoWAddonChannel(compressed)
    return encoded;
end

function Comms:DataDecoder(data)
    local detransmit = core.LibDeflate:DecodeForWoWAddonChannel(data)
    local decompressed = core.LibDeflate:DecompressDeflate(detransmit)
    if decompressed == nil then -- It wasn't a message that can be decompressed.
        return Comms:Deserialize(detransmit) -- Return the regular deserialized messge
    end
    local deserialized = Comms:Deserialize(decompressed)
    return deserialized -- Deserialize the compressed message
end

---------------------------
--    Send Functions     --
---------------------------
function OnCommReceived(prefix, message, distribution, sender)
    if sender == Util:GetMyName() then -- Don't need to respond to our own messages...
        if prefix ~= 'pdkpNewShrouds' then
            return Util:Debug('Ignoring comm from me ' .. prefix)
        end;
    end;

    local data = Comms:DataDecoder(message) -- decode, decompress, deserialize it.

    -- Might be able to get rid of these comms?
    if SAFE_COMMS[prefix] then return Comms:OnSafeCommReceived(prefix, data, distribution, sender);
    elseif UNSAFE_COMMS[prefix] then return Comms:OnUnsafeCommReceived(prefix, data, distribution, sender);
    elseif OFFICER_COMMS[prefix] then return Comms:OnOfficerCommReceived(prefix, data, distribution, sender);
    elseif GUILD_COMMS[prefix] then return Comms:OnGuildCommReceived(prefix, data, distribution, sender);
    elseif RAID_COMMS[prefix] then return Comms:OnRaidCommReceived(prefix, data, distribution, sender);
    else
        Util:Debug("Unknown Prefix " .. prefix, " found in request...")
    end
end

function Comms:SendCommsMessage(prefix, data, distro, sendTo, bulk, func)

    if distro == 'GUILD' and IsInGuild() == nil then return end; -- Stop guildless players from sending messages.

    if Defaults.no_broadcast then return print(skipBroadcastMsg .. ' no_broadcast is enabled') end
--    if Defaults.debug then -- Don't send messages unnecessarily when developing.
--        if distro == 'GUILD' then -- in debug, change distro to whisper, and send to bank, or Pantheonbank or KarolBaskins
--            distro = 'WHISPER'
--            sendTo = 'Pantheonbank'
--            if Util:GetMyName() == sendTo then sendTo = 'Karenbaskins' end -- send to alt char instead of bank.
--
--        elseif distro == 'WHISPER' and (sendTo ~= 'Pantheonbank' and sendTo ~= 'Karenbaskins') then
--            return print(skipBroadcastMsg .. sendTo .. " is not bank!")
--        end
--    end
    if distro == 'WHISPER' then Util:Debug('Sending message ' .. prefix .. ' to' .. sendTo) end

    local transmitData = Comms:DataEncoder(data)

    PDKP:SendCommMessage(prefix, transmitData, distro, sendTo, bulk, func)
end

function Comms:ThrowError(prefix, sender)
    local errMsg = sender .. ' is attempting to use an unsafe communication method: ' .. prefix .. ' Please contact'
    errMsg = errMsg .. ' an Officer.'
    return Util:ThrowError(errMsg, true)
end

---------------------------
-- RAID COMMS FUNCTIONS  --
---------------------------
function Comms:OnRaidCommReceived(prefix, message, distribution, sender)
    -- This shouldn't ever happen, but who knows.
    if distribution ~= 'RAID' then return Util:Debug('Non-raid comm found in OnRaidCommReceived! '.. prefix) end
    if not Guild:CanMemberEdit(sender) then return Comms:ThrowError(prefix, sender) end

    local raidFuncs = {
        ['pdkpClearShrouds'] = function() Shroud:ClearShrouders() end,
        ['pdkpNewShrouds'] = function()
            Shroud.shrouders = message -- assign the shrouding table that was sent.
            Shroud:UpdateWindow() -- Update the window.
        end,
        ['pdkpDkpOfficer'] = function()
            Raid.dkpOfficer = message
            PDKP:Print(Raid.dkpOfficer .. ' is now the DKP Officer')
        end
    }

    local func = raidFuncs[prefix]
    if func then return func() end
end

---------------------------
-- GUILD COMMS FUNCTIONS --
---------------------------
function Comms:OnGuildCommReceived(prefix, message, distribution, sender)
--    PackupSyncDatabse
end

---------------------------
--OFFICER COMMS FUNCTIONS--
---------------------------
function Comms:OnOfficerCommReceived(prefix, message, distribution, sender)
    local officerFunc = {
        ['pdkpSyncRequest'] = function()
            Comms:SendCommsMessage('pdkpSyncRes', database, 'WHISPER', sender, 'BULK')

        end,
    }
    local func = officerFunc[prefix]
    if func then return func() end
end

---------------------------
-- SAFE FUNCTIONS     --
---------------------------
function Comms:OnSafeCommReceived(prefix, message, distribution, sender)
    -- We received a communication that we shouldn't have...
    if not SAFE_COMMS[prefix] then return Comms:ThrowError(prefix, sender) end

    local safeFuncs = {
        -- Send them back your lastEdit time
        -- Need to edit to be only officers.
        ['pdkpLastEditReq'] = function()
            Comms:SendCommsMessage('pdkpLastEditRec', DKP.dkpDB.lastEdit, 'WHISPER', sender, 'BULK')
        end,
        -- Need to edit to be only officers.
        -- Process their lastEdit time
        ['pdkpLastEditRec'] = function() Comms:LastEditReceived(sender, message) end,
        -- Someone Sent you a push request
        -- Need to edit to be guild only instead of whispers.
        ['pdkpPushRequest'] = function()
            PDKP:Print("Preparing data to push to " .. sender .. ' This may take a few minutes...')
            Comms:PrepareDatabase(false)
            Comms:SendCommsMessage('pdkpPushReceive', pdkpPushDatabase, 'WHISPER', sender, 'BULK', UpdatePushBar)
        end,
        -- Need to edit to be guild only
        ['pdkpSyncRequest'] = function()
            if core.canEdit then
--                local database = Comms:PrepareDatabaseSyncResponse(message)
--                Comms:SendCommsMessage('pdkpSyncResponse', database, 'WHISPER', sender, 'BULK')
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
        ['pdkpPushReceive'] = function()
            PDKP:Print("DKP Update received from " .. sender .. ' updating your DKP tables...')
            Import:AcceptData(message)
        end,
        ['pdkpEntryDelete'] = function()
            DKP:DeleteEntry(message, false)
        end,
        ['pdkpSyncResponse'] = function()
--            Import:AcceptData(message)
        end,
        ['pdkpPlaceholder'] = function() end,
    }

    if unsafeFuncs[prefix] then unsafeFuncs[prefix]() end

    -- We've finished processing the comms.
    Comms.processing = false
end

---------------------------
--   REWORK FUNCTIONS    --
---------------------------

function Comms:SendGuildPush(full)
    Comms:ResetDatabse()
    PDKP:Print("Preparing data to push to GUILD this may take a few minutes...")
    Comms:PrepareDatabase(full)
    Comms:SendCommsMessage('pdkpPushReceive', pdkpPushDatabase, 'GUILD', nil, 'BULK', UpdatePushBar)
end

function Comms:SendGuildUpdate(histEntry)
    Comms:ResetDatabse()
    pdkpPushDatabase.dkpDB.lastEdit = DKP.dkpDB.lastEdit
    table.insert(pdkpPushDatabase.dkpDB.history, histEntry)

    Comms:SendCommsMessage('pdkpPushReceive', pdkpPushDatabase, 'GUILD', nil, nil)
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

function Comms:RequestOfficerLastEdit(isRequest)

end

function Comms:RequestOfficersLastEdit()
    Guild:GetGuildData() -- Retrieve up to date guild data.
    Comms:SendCommsMessage('pdkpLastEditReq', '', 'GUILD', nil, 'BULK')
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
    if IsInGuild() == false then return end; -- Fix for players not being in guild error message.
    PDKP:Print('Attempting Automatic Database Sync...')

    local myHistory = {
        all = {},
        deleted = {}
    }
    local dkpDB = DKP.dkpDB.history
    for _, entry in pairs(dkpDB.all) do table.insert(myHistory.all, entry['id']); end
    for _, entryKey in pairs(dkpDB.deleted) do table.insert(myHistory.deleted, entryKey); end

    Comms:SendCommsMessage('pdkpSyncRequest', myHistory, 'GUILD', nil, 'BULK', nil)
end

function Comms:PackupSyncDatabse()
    if IsInGuild() == false then return end; -- Fix for players not being in guild error message.
    local myHistory = {
        all = {},
        deleted = {}
    }
    local dkpDB = DKP.dkpDB.history
    for _, entry in pairs(dkpDB.all) do table.insert(myHistory.all, entry['id']); end
    for _, entryKey in pairs(dkpDB.deleted) do table.insert(myHistory.deleted, entryKey); end

    return myHistory
end

---------------------------
-- SHROUDING FUNCTIONS  --
---------------------------
function Comms:SendShroudTable()
    if Raid:IsInRaid() then
        Comms:SendCommsMessage('pdkpNewShrouds', Shroud.shrouders, 'RAID', nil, 'BULK', nil)
    elseif Defaults.debug then -- debug mode, we can't send messages to ourselves.
--        Comms:OnUnsafeCommReceived('pdkpNewShrouds', Shroud.shrouders, 'RAID', nil, 'BULK', nil)
    else -- For the sender to update their table.
--        Shroud:UpdateWindow()
    end
end

function Comms:ClearShrouders()
    Comms:SendCommsMessage('pdkpClearShrouds', '', 'RAID', nil, nil)
end


