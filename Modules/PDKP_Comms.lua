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

local OFFICER_COMMS = {
    ['pdkpSyncReq'] = true,
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
    ['pdkpSyncRes']=true,
    ['pdkpVersion']=true,
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
    end

    local data = Comms:DataDecoder(message) -- decode, decompress, deserialize it.

    -- Might be able to get rid of these comms?
    if OFFICER_COMMS[prefix] then return Comms:OnOfficerCommReceived(prefix, data, distribution, sender);
    elseif GUILD_COMMS[prefix] then return Comms:OnGuildCommReceived(prefix, data, distribution, sender);
    elseif RAID_COMMS[prefix] then return Comms:OnRaidCommReceived(prefix, data, distribution, sender);
    else
        Util:Debug("Unknown Prefix " .. prefix, " found in request...")
    end
end

function Comms:SendCommsMessage(prefix, data, distro, sendTo, bulk, func)

    if distro == 'GUILD' and IsInGuild() == nil then return end; -- Stop guildless players from sending messages.
    if distro == 'WHISPER' then Util:Debug('Sending message ' .. prefix .. ' to' .. sendTo) end

    if Util:GetMyName() == 'Karenbaskins' then return end  -- Disable messages from Karen during development

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
            if Raid.dkpOfficer ~= message then
                PDKP:Print(message .. ' is now the DKP Officer')
            end
            Raid.dkpOfficer = message
        end
    }

    local func = raidFuncs[prefix]
    if func then return func() end
end

---------------------------
-- GUILD COMMS FUNCTIONS --
---------------------------
function Comms:OnGuildCommReceived(prefix, message, distribution, sender)
    local guildFunc = {
        ['pdkpSyncRes'] = function()
            Import:AcceptData(message)
        end,
        ['pdkpEntryDelete'] = function()
            DKP:DeleteEntry(message, false)
        end,
        ['pdkpPushReceive'] = function()
            PDKP:Print("DKP Update received from " .. sender .. ' updating your DKP tables...')
            Import:AcceptData(message)
        end,
        ['pdkpVersion']= function () return PDKP:CheckForUpdate(message) end
    }
    local func = guildFunc[prefix]
    if func then return func() end
end

---------------------------
--OFFICER COMMS FUNCTIONS--
---------------------------
function Comms:OnOfficerCommReceived(prefix, message, distribution, sender)
    local officerFunc = {
        ['pdkpSyncReq'] = function() -- Send the data to the guild
            if Defaults:AllowSync() == false or Util:GetMyName() == 'Karenbaskins' then
                return PDKP:Print('Ignoring Sync request while busy')
            end  -- Make sure we can sync while in the raid
            Guild:UpdateLastSync(message) -- message contains the lastSync time.
            PDKP:Print(sender .. ' has sent a DKP sync request. Preparing sync data now, this may take a few minutes...')
            Comms:SendCommsMessage('pdkpSyncRes', Comms:PackupSyncDatabse(), 'GUILD', nil, 'BULK', UpdatePushBar)
        end,
    }
    local func = officerFunc[prefix]
    if func then return func() end
end

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

function Comms:PackupSyncDatabse()
    if IsInGuild() == false then return end; -- Fix for players not being in guild error message.

    local pdkpSyncResponseDatabase = {
        addon_version = Defaults.addon_version,
        full = false,
        syncFrom = Util:GetMyName(),
        guildDB = {
            numOfMembers = nil,
            members = nil,
        },
        dkpDB = {
            lastEdit = DKP.dkpDB.lastEdit,
            history = {
                all = DKP.dkpDB.history.all,
                deleted = DKP.dkpDB.history.deleted,
            },
            members = nil,
            currentDB = nil
        }
    }
    return pdkpSyncResponseDatabase
end

---------------------------
-- SHROUDING FUNCTIONS  --
---------------------------
function Comms:SendShroudTable()
    if Raid:IsInRaid() then
        Comms:SendCommsMessage('pdkpNewShrouds', Shroud.shrouders, 'RAID', nil, 'BULK', nil)
    elseif Defaults:IsDebug() then -- debug mode, we can't send messages to ourselves.
--        Comms:OnUnsafeCommReceived('pdkpNewShrouds', Shroud.shrouders, 'RAID', nil, 'BULK', nil)
    else -- For the sender to update their table.
--        Shroud:UpdateWindow()
    end
end

function Comms:ClearShrouders()
    Comms:SendCommsMessage('pdkpClearShrouds', '', 'RAID', nil, nil)
end


