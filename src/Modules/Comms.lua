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
Comms.cache = {} -- A cache for our recently sent data. Wait until combat has dropped to decode and process the data.
Comms.commsOpen = true -- Determines whether we're able to process comms at this time.
Comms.allow_from_self = {};
Comms.allow_in_combat = {};

--[[ MESSAGE TYPES: "PARTY", "RAID", "GUILD", "OFFICER", "BATTLEGROUND", "WHISPER" ]]

local RAID_COMMS = {
    ['pdkpClearShrouds']= { ['self']=true, ['combat']=true, }, -- Officer check -- When the DKP Officer clears the Shrouding Window.
    ['pdkpUpdateShroud']= { ['self']=true, ['combat']=true, }, -- Officer check -- When someone new shrouds, comes from DKP Officer.
    ['pdkpDkpOfficer']= { ['self']=true, ['combat']=true, }, -- Officer check -- Sets the DKP officer for everyone.
    ['pdkpWhoIsDKP']= { ['self']=false, ['combat']=true, }, -- Requests who the DKP officer is.
}

local GUILD_COMMS = {
    ['pdkp_placeholder']= { ['self']=false, ['combat']=false, }, -- Placeholder.
    ['pdkpPushReceive'] = { ['self']=true, ['combat']=false, }, -- Officer check -- When a new push is received.
    ['pdkpEntryDelete'] = { ['self']=true, ['combat']=true, }, -- Officer check -- When an entry is deleted.
    ['pdkpSyncRes']= { ['self']=true, ['combat']=false, }, -- When an officer's sync request goes through.
    ['pdkpVersion']= { ['self']=false, ['combat']=false, }, -- When someone requests the latest version of the addon.
}

local SYNC_COMMS = {
    ['pdkpSyncSmall']= { ['self']=true, ['combat']=true, }, -- Single adds/deletes
    ['pdkpSyncLarge']= { ['self']=false, ['combat']=false, }, -- Large merges / overwrites.
    ['pdkpSyncProgress']= { ['self']=false, ['combat']=false, },
}

local OFFICER_COMMS = {
    ['pdkpSyncReq'] = { ['self']=false, ['combat']=false, }, -- When someone Requests a merge
}

---------------------------
-- GENERIC Functions   --
---------------------------

function Comms:RegisterSelfAndCombatComms()
    for _, comm_Obj in pairs({RAID_COMMS, GUILD_COMMS, SYNC_COMMS, OFFICER_COMMS}) do
        for key, val in pairs(comm_Obj) do
            if val['self'] == true then table.insert(Comms.allow_from_self, key) end
            if val['combat'] == true then table.insert(Comms.allow_in_combat, key) end
        end
    end
end

function Comms:RegisterCommCommands()
    if Comms.commsRegistered then return end -- Prevent re-registers.

    Comms:RegisterSelfAndCombatComms()

    for key, _ in pairs(RAID_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end -- General Raid comms
    for key, _ in pairs(GUILD_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end -- General guild comms
    for key, _ in pairs(SYNC_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end -- General guild comms
    for key, _ in pairs(OFFICER_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end -- General guild comms

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
        --Util:ThrowError('An error occured Deserializing the data...');
        return nil;
    end
    return data;
end

function Comms:DataEncoder(data)
    local serialized = PDKP:Serialize(data)
    local compressed = core.LibDeflate:CompressDeflate(serialized)
    local encoded = core.LibDeflate:EncodeForWoWAddonChannel(compressed)
    return encoded
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
    if sender == Char:GetMyName() and not tContains(Comms.allow_from_self, prefix) then -- Don't need to respond to our own messges...
        Util:Debug('Ignoring message from self', prefix)
        return
    end

    Util:Debug(prefix, 'message received!')

    if not Comms.commsOpen and not tContains(Comms.allow_in_combat, prefix) then
        PDKP:Print("PDKP message received, waiting for combat to drop to process it!")
        table.insert(Comms.cache, {['prefix']=prefix, ['message']=message, ['distribution']=distribution, ['sender']=sender})
        return
    end


    local data = Comms:DataDecoder(message)
    if RAID_COMMS[prefix] then return Comms:OnRaidCommReceived(prefix, data, distribution, sender) end
    if GUILD_COMMS[prefix] then return Comms:OnGuildCommReceived(prefix, data, distribution, sender) end
    if SYNC_COMMS[prefix] then return Comms:OnSyncCommReceived(prefix, data, distribution, sender) end
end

function Comms:OnRaidCommReceived(prefix, data, distro, sender)
    -- TODO: Finish this
    local RAID_COMMS_NO_AUTH = {
        --['pdkpWhoIsDKP']=function()
        --    if Settings:CanEdit() and Raid.raid.dkpOfficer ~= nil then
        --        Comms:SendCommsMessage('pdkpDkpOfficer', Raid.raid.dkpOfficer, 'RAID', nil, 'BULK', nil)
        --    end
        --end
    }

    if RAID_COMMS_NO_AUTH[prefix] then return RAID_COMMS_NO_AUTH[prefix]() end

    local sender_member = Guild:GetMemberByName(sender)
    if (sender_member == nil or not sender_member.canEdit) and not Settings:IsDebug() then return end

    local RAID_COMMS_AUTH = {
        ['pdkpDkpOfficer']=function()
            if data ~= nil then Raid:SetDkpOfficer(false, data) end
        end,

        ['pdkpClearShrouds']=function() Shroud:ClearShrouders() end,
        ['pdkpUpdateShroud']=function() Shroud:UpdateShrouders(data) end,
    }
    if RAID_COMMS_AUTH[prefix] then return RAID_COMMS_AUTH[prefix]() end
end

function Comms:OnSyncCommReceived(prefix, data, distro, sender)
    if prefix == 'pdkpSyncProgress' then
        return UpdatePushBar(data['percentage'], data['elapsed'])
    else
        Import:New(prefix, data, sender)
    end
end

function Comms:SendCommsMessage(prefix, data, distro, sendTo, bulk, func)
    local transmitData = Comms:DataEncoder(data)
    PDKP:SendCommMessage(prefix, transmitData, distro, sendTo, bulk, func)
end

function PDKP_CommsCallback(arg, sent, total)
    local percentage = math.floor((sent / total) * 100)

    if Comms.start_time == nil then Comms.start_time = time() end

    if Comms.progress ~= percentage then
        Comms.progress = percentage
        local elapsed = time() - Comms.start_time
        UpdatePushBar(percentage, elapsed)
    end

    if Comms.progress == nil or Comms.progress >= 100 then
        Comms.progress = 0
        Comms.start_time = nil
    end
end

function Comms:ThrowError(prefix, sender)
    local errMsg = sender .. ' is attempting to use an unsafe communication method: ' .. prefix .. ' Please contact'
    errMsg = errMsg .. ' an Officer.'
    --return Util:ThrowError(errMsg, true)
end

---------------------------
--    MISC Functions     --
---------------------------

function PDKP_Comms_OnEvent(self, event, arg1, ...)
    if event == 'PLAYER_REGEN_DISABLED' then
        Comms.commsOpen = false
    elseif event == 'PLAYER_REGEN_ENABLED' then
        Comms.commsOpen = true
        if #Comms.cache > 0 then
            Comms:ProcessCache()
        end
    end
end

function Comms:ProcessCache()
    for i = #Comms.cache, 1, -1 do
        local comm = Comms.cache[i]
        OnCommReceived(comm['prefix'], comm['message'], comm['distribution'], comm['sender'])
        table.remove(Comms.cache, i)
    end
end

local COMMS_EVENTS = {'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'};
local comms_eventsFrame = CreateFrame("Frame", nil, UIParent)
for _, eventName in pairs(COMMS_EVENTS) do comms_eventsFrame:RegisterEvent(eventName) end
comms_eventsFrame:SetScript("OnEvent", PDKP_Comms_OnEvent)