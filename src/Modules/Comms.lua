local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local PDKP = core.PDKP;
local Raid = core.Raid;
local Util = core.Util;
local Comms = core.Comms;
local Setup = core.Setup;
local Guild = core.Guild; -- Uppercase is the file
local guild = core.guild; -- Lowercase is the object
local Shroud = core.Shroud;
local Member = core.Member;
local Import = core.Import;
local Officer = core.Officer;
local Invites = core.Invites;
local Minimap = core.Minimap;
local Defaults = core.Defaults;
local Settings = core.Settings;
local Char = core.Character;

local SendChatMessage = SendChatMessage

Comms.commsRegistered = false

--[[ MESSAGE TYPES: "PARTY", "RAID", "GUILD", "OFFICER", "BATTLEGROUND", "WHISPER" ]]

--- De-register comms via list instead of having them all listened to all the time.
----- Just ignore the messaage instead of letting it go through?

local OFFICER_COMMS = {
    ['pdkpSyncReq'] = true, -- When someone Requests a merge
}

local RAID_COMMS = {
    --['pdkpClearShrouds']=true, -- Officer check -- When the DKP Officer clears the Shrouding Window.
    --['pdkpNewShrouds']=true, -- Officer check -- When someone new shrouds, comes from DKP Officer.
    ['pdkpDkpOfficer']=true, -- Officer check -- Sets the DKP officer for everyone.
    ['pdkpWhoIsDKP']=true, -- Requests who the DKP officer is.
}

local GUILD_COMMS = {
    ['pdkp_placeholder']=true, -- Placeholder.
    ['pdkpPushReceive'] = true, -- Officer check -- When a new push is received.
    ['pdkpEntryDelete'] = true, -- Officer check -- When an entry is deleted.
    ['pdkpSyncRes']=true, -- When an officer's sync request goes through.
    ['pdkpVersion']=true, -- When someone requests the latest version of the addon.
}

local DEBUG_COMMS = {
    ['pdkpSyncSmall']=true,
    ['pdkpSyncLarge']=true,

    ['placeholder']=true,
}

function Comms:DataEncoder(data)
    local serialized = PDKP:Serialize(data)
    local compressed = core.LibDeflate:CompressDeflate(serialized)
    local encoded = core.LibDeflate:EncodeForWoWAddonChannel(compressed)
    return encoded
end

function Comms:Init()
    Util:Debug("Comms Init")

    --Comms:RegisterCommCommands()
end

---------------------------
-- GENERIC Functions   --
---------------------------
function Comms:RegisterCommCommands()
    if Comms.commsRegistered then return end -- Prevent re-registers.

    if Settings:IsDebug() then
        for key, _ in pairs(DEBUG_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end -- Debug Comms
    end
    for key, _ in pairs(RAID_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end -- General Raid comms

    --for key, _ in pairs(GUILD_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end -- General guild comms

    --
    --if core.canEdit then -- Only register officers to the officer_comms.
    --    Util:Debug('Register Officer Comms')
    --    for key, _ in pairs(OFFICER_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end
    --end

    Comms.commsRegistered = true -- Check to make sure we don't re-register the comms.
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
function OnCommReceived(prefix, data, distribution, sender)
    Util:Debug(prefix, 'message received!')

    --- Ignore comms from yourself, except under certain circumstances?

    if RAID_COMMS[prefix] then return Comms:OnRaidCommReceived(prefix, data, distribution, sender) end

    --if sender == Util:GetMyName() then -- Don't need to respond to our own messages...
    --    if prefix ~= 'pdkpNewShrouds' then
    --        return Util:Debug('Ignoring comm from me ' .. prefix)
    --    end
    --end
    --
    --local data = Comms:DataDecoder(message) -- decode, decompress, deserialize it.
    --
    ---- Might be able to get rid of these comms?
    --if OFFICER_COMMS[prefix] then return Comms:OnOfficerCommReceived(prefix, data, distribution, sender);
    --elseif GUILD_COMMS[prefix] then return Comms:OnGuildCommReceived(prefix, data, distribution, sender);
    --elseif RAID_COMMS[prefix] then return Comms:OnRaidCommReceived(prefix, data, distribution, sender);
    --else
    --    Util:Debug("Unknown Prefix " .. prefix, " found in request...")
    --end
end

function Comms:OnRaidCommReceived(prefix, data, distro, sender)

    --local myName = Char:GetMyName()
    ----local assists = Raid.raid['assistants']
    ----local member = Guild:GetMemberByName(myName)

    local RAID_COMMS_NO_AUTH = {
        ['pdkpWhoIsDKP']=function()
            if Settings:CanEdit() and Raid.raid.dkpOfficer ~= nil then
                Comms:SendCommsMessage('pdkpDkpOfficer', Raid.raid.dkpOfficer, 'RAID', nil, 'BULK', nil)
            elseif Settings:IsDebug() then
                Comms:SendCommsMessage('pdkpDkpOfficer', 'Karenbaskins', 'RAID', nil, 'BULK', nil)
            end
        end
    }

    if RAID_COMMS_NO_AUTH[prefix] then return RAID_COMMS_NO_AUTH[prefix]() end

    local sender_member = Guild:GetMemberByName(sender)
    if sender_member then

    else

    end

    local Raid_No_Auth_Funcs = {
        ['pdkpDkpOfficer']=function() end,
    }
end

function Comms:SendCommsMessage(prefix, data, distro, sendTo, bulk, func)
    Comms.start_time = time()
    Comms.progress = 0
    --if distro == 'GUILD' and IsInGuild() == nil then return end; -- Stop guildless players from sending messages.
    --if distro == 'WHISPER' then Util:Debug('Sending message ' .. prefix .. ' to' .. sendTo) end
    --
    --if prefix == 'pdkpSyncReq' and Util:GetMyName() == 'Karenbaskins' then -- Testing logic.
    --    distro, sendTo = 'WHISPER', 'Neekio'
    --elseif Util:GetMyName() == 'Karenbaskins' then return end  -- Disable messages from Karen during development

    local transmitData = Comms:DataEncoder(data)

    PDKP:SendCommMessage(prefix, transmitData, distro, sendTo, bulk, func)
end

function PDKP_CommsCallback(arg, sent, total)
    local percentage = math.floor((sent / total) * 100)

    if Comms.progress ~= percentage then
        Comms.progress = percentage
        UpdatePushBar(percentage, time() - Comms.start_time)
    end
end

function Comms:ThrowError(prefix, sender)
    local errMsg = sender .. ' is attempting to use an unsafe communication method: ' .. prefix .. ' Please contact'
    errMsg = errMsg .. ' an Officer.'
    return Util:ThrowError(errMsg, true)
end

---------------------------
--    MISC Functions     --
---------------------------