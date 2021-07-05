local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local SendChatMessage = SendChatMessage;

local Comms = {}

local function _prefix(prefix)
    return 'pdkpV2' .. string.sub(prefix, 0, 12)
end

function Comms:Initialize()
    self.commsRegistered = false
    self.cache = {}
    self.commsOpen = true
    self.allow_from_self = {}
    self.allow_in_combat = {}
    self.channels = {}
end

function PDKP_OnCommsReceived(prefix, message, distribution, sender)
    local channel = Comms.channels[prefix]
    if channel then
        return channel:VerifyCommSender(message, sender)
    end
end

function Comms:RegisterComms()
    local commChannels = {
        --['GUILD'] = {
        --    --['V2PushReceive'] = { ['self']=true, ['combat']=false, }, -- Officer check -- When a new push is received.
        --    --['V2EntryDelete'] = { ['self']=true, ['combat']=true, }, -- Officer check -- When an entry is deleted.
        --    --['V2SyncRes']= { }, -- When an officer's sync request goes through.
        --
        --    --['V2Version']= { }, -- When someone requests the latest version of the addon.
        --    ['V2SyncSmall']= { ['self']=true, ['combat']=true, }, -- Single adds/deletes
        --    ['V2SyncLarge']= { }, -- Large merges / overwrites.
        --    --['V2SyncProgress']= { ['self']=false, ['combat']=false, },
        --},
        --['RAID'] = {
        --    --['ClearBids']= { ['combat']=true, }, -- Officer check -- When the DKP Officer clears the Shrouding Window.
        --    --['UpdateBid']= { ['combat']=true, }, -- Officer check -- When someone new shrouds, comes from DKP Officer.
        --    --['V2SetDkpOfficer']= { ['combat']=true, }, -- Officer check -- Sets the DKP officer for everyone.
        --    --['V2WhoIsDKP']= { ['self']=false, ['combat']=true, }, -- Requests who the DKP officer is.
        --},
        --['OFFICER'] = {
        --    --['V2SyncReq'] = {},
        --},

        --- GUILD COMMS

        ['SyncSmall'] = { ['self'] = true, ['channel'] = 'GUILD', ['requireCheck'] = true, ['combat'] = true, },
        ['SyncLarge'] = { ['channel'] = 'GUILD', ['requireCheck'] = true, },

        ['SyncAd'] = { ['channel'] = 'GUILD', ['requireCheck'] = true, ['self'] = false },
        ['SyncReq'] = { ['channel'] = 'GUILD', ['requireCheck'] = false, ['self'] = false, },

        --- RAID COMMS

        ['DkpOfficer'] = { ['self'] = true, ['channel'] = 'RAID', ['requireCheck'] = true, ['combat'] = true, },
        ['WhoIsDKP'] = { ['self'] = false, ['channel'] = 'RAID', ['requireCheck'] = false, ['combat'] = true, },

        ['startBids'] = { ['channel'] = 'RAID', ['requireCheck'] = true, ['self'] = true, ['combat'] = true },
        ['stopBids'] = { ['channel'] = 'RAID', ['requireCheck'] = true, ['self'] = true, ['combat'] = true },

        ['bidSubmit'] = { ['channel'] = 'RAID', ['requireCheck'] = false, ['self'] = true, ['combat'] = true },
        ['bidCancel'] = { ['channel'] = 'RAID', ['requireCheck'] = false, ['self'] = true, ['combat'] = true },

        ['AddBid'] = { ['channel'] = 'RAID', ['requireCheck'] = true, ['self'] = true, ['combat'] = true },
        ['CancelBid'] = { ['channel'] = 'RAID', ['self'] = true, ['combat'] = true },
    }
    for prefix, opts in pairs(commChannels) do
        local commOpts = {['prefix'] = prefix, ['combat'] = opts['combat'], ['self'] = opts['self'], ['requireCheck'] = opts['requireCheck'] }
        local comm = MODULES.Comm:new(commOpts)
        self.channels[comm.prefix] = comm
        if comm.allow_in_combat then self.allow_in_combat[comm.prefix] = true end
        if comm.allowed_from_self then self.allow_from_self[comm.prefix] = true end
    end
end

function Comms:SendCommsMessage(prefix, data, skipEncoding)
    skipEncoding = skipEncoding or false
    local transmitData = data

    if not skipEncoding then
        transmitData = self:DataEncoder(data)
    end

    local comm = self.channels[_prefix(prefix)]

    if comm ~= nil and comm:IsValid() then
        local params = comm:GetSendParams()
        return PDKP.CORE:SendCommMessage(_prefix(prefix), transmitData, unpack( params ))
    end

    if PDKP:IsDev() then
        PDKP.CORE:Print('Could not complete comm request ', prefix, 'channel', comm.channel, 'Params', comm:GetSendParams())
    end
end

-----------------------------
--     Data Functions      --
-----------------------------

function Comms:_Serialize(data)
    return PDKP.CORE:Serialize(data)
end

function Comms:_Compress(serialized)
    return PDKP.LibDeflate:CompressDeflate(serialized, {level = 9})
end

function Comms:_Encode(compressed)
    return PDKP.LibDeflate:EncodeForWoWAddonChannel(compressed)
end

function Comms:_Adler(string)
    return PDKP.LibDeflate:Adler32(string)
end

function Comms:_Deserialize(string)
    local success, data = PDKP.CORE:Deserialize(string)
    if not success then return nil end
    return data;
end

function Comms:_Decompress(decoded)
    return PDKP.LibDeflate:DecompressDeflate(decoded)
end

function Comms:_Decode(transmitData)
    return PDKP.LibDeflate:DecodeForWoWAddonChannel(transmitData)
end

-----------------------------
--    Encoders Functions   --
-----------------------------

function Comms:DataEncoder(data)
    local serialized = self:_Serialize(data)
    local compressed = self:_Compress(serialized)
    local encoded = self:_Encode(compressed)
    return encoded
end

function Comms:DataDecoder(data)
    local detransmit = self:_Decode(data)
    local decompressed = self:_Decompress(detransmit)
    if decompressed == nil then -- It wasn't a message that can be decompressed.
        return self:_Deserialize(detransmit) -- Return the regular deserialized messge
    end
    local deserialized = self:_Deserialize(decompressed)
    return deserialized -- Deserialize the compressed message
end

function Comms:DatabaseEncoder(data)
    local serialized = self:_Serialize(data)
    local compressed = self:_Compress(serialized)
    return compressed
end

function Comms:DatabaseDecoder(data)
    local decompressed = self:_Decompress(data)
    if decompressed == nil then -- It wasn't a message that can be decompressed.
        return self:_Deserialize(data) -- Return the regular deserialized messge
    end
    return self:_Deserialize(decompressed)
end



MODULES.CommsManager = Comms