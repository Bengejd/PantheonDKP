local _, PDKP = ...

local MODULES = PDKP.MODULES

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

function PDKP_OnCommsReceived(prefix, message, _, sender)
    local channel = Comms.channels[prefix]
    if channel then
        return channel:VerifyCommSender(message, sender)
    else
        PDKP:PrintD("Could not find comm channel", prefix)
    end
end

function Comms:RegisterComms()
    local commChannels = {
        --- GUILD COMMS
        -- defaults: self = false, combat = true, channel = Guild, requireCheck = true, officerOnly = false
        ['SyncSmall'] = { ['self'] = true, },
        ['SyncDelete'] = { ['self'] = true },
        ['SyncLarge'] = { ['combat'] = false, },
        ['SyncOver'] = { ['combat'] = false, },

        --['SyncAd'] = { ['combat'] = false },
        --['SyncReq'] = { ['self'] = false, ['requireCheck'] = false, ['combat'] = false, },

        --- RAID COMMS
        ['DkpOfficer'] = { ['self'] = true, ['channel'] = 'RAID',  },
        ['WhoIsDKP'] = { ['channel'] = 'RAID', ['requireCheck'] = false, },

        ['startBids'] = { ['channel'] = 'RAID', ['self'] = true, },
        ['stopBids'] = { ['channel'] = 'RAID',  ['self'] = true, },

        ['bidSubmit'] = { ['channel'] = 'RAID', ['requireCheck'] = false, ['self'] = true, },
        ['bidCancel'] = { ['channel'] = 'RAID', ['requireCheck'] = false, ['self'] = true, },

        ['AddBid'] = { ['channel'] = 'RAID', ['self'] = true, },
        ['CancelBid'] = { ['channel'] = 'RAID', ['self'] = true, },
        ['AddTime'] = { ['channel'] = 'RAID', ['self'] = true, ['requireCheck'] = false },

        ['SentInv'] = { ['channel'] = 'WHISPER', },
    }
    for prefix, opts in pairs(commChannels) do
        opts['prefix'] = prefix
        local comm = MODULES.Comm:new(opts)
        self.channels[comm.prefix] = comm
        if comm.allow_in_combat then
            self.allow_in_combat[comm.prefix] = true
        end
        if comm.allowed_from_self then
            self.allow_from_self[comm.prefix] = true
        end
    end
end

function Comms:UnregisterComms()
    PDKP.CORE:UnregisterAllComm()
end

function Comms:SendCommsMessage(prefix, data, skipEncoding)
    skipEncoding = skipEncoding or false
    local transmitData = data

    if not skipEncoding then
        transmitData = self:DataEncoder(data)
    end

    local comm = self.channels[_prefix(prefix)]

    if comm ~= nil and comm:IsValid() then
        if comm.requireCheck and not comm:CanSend() then
            return
        end

        local params = comm:GetSendParams()
        if prefix == 'SentInv' then
            params[2] = data
        end
        return PDKP.CORE:SendCommMessage(_prefix(prefix), transmitData, unpack(params))
    else
        PDKP:PrintD(comm.ogPrefix, comm ~= nil, comm:IsValid())
    end

    PDKP:PrintD('Could not complete comm request ', prefix)
end

-----------------------------
--     Data Functions      --
-----------------------------

function Comms:_Serialize(data)
    return PDKP.CORE:Serialize(data)
end

function Comms:_Compress(serialized)
    return PDKP.LibDeflate:CompressDeflate(serialized, { level = 4 })
end

function Comms:_Encode(compressed)
    return PDKP.LibDeflate:EncodeForWoWAddonChannel(compressed)
end

function Comms:_Adler(string)
    return PDKP.LibDeflate:Adler32(string)
end

function Comms:_Deserialize(string)
    local success, data = PDKP.CORE:Deserialize(string)
    if not success then
        return nil
    end
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
    if decompressed == nil then
        -- It wasn't a message that can be decompressed.
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
    if decompressed == nil then
        -- It wasn't a message that can be decompressed.
        return self:_Deserialize(data) -- Return the regular deserialized messge
    end
    return self:_Deserialize(decompressed)
end

MODULES.CommsManager = Comms
