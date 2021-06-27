local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local SendChatMessage = SendChatMessage;

local Comms = {}

function Comms:Initialize()
    self.commsRegistered = false
    self.cache = {}
    self.commsOpen = true
    self.allow_from_self = {}
    self.allow_in_combat = {}
end

local function _prefix(prefix)
    return 'pdkp' .. string.sub(prefix, 0, 12)
end

function Comms:_InitGuildComms()
    local GUILD_COMMS = {
        ['PushReceive'] = { ['self']=true, ['combat']=false, }, -- Officer check -- When a new push is received.
        ['EntryDelete'] = { ['self']=true, ['combat']=true, }, -- Officer check -- When an entry is deleted.
        ['SyncRes']= { ['self']=true, ['combat']=false, }, -- When an officer's sync request goes through.
        ['Version']= { ['self']=false, ['combat']=false, }, -- When someone requests the latest version of the addon.
    }
end

function Comms:_InitRaidComms()
    local RAID_COMMS = {
        ['ClearBids']= { ['self']=true, ['combat']=true, }, -- Officer check -- When the DKP Officer clears the Shrouding Window.
        ['UpdateBid']= { ['self']=true, ['combat']=true, }, -- Officer check -- When someone new shrouds, comes from DKP Officer.
        ['SetDkpOfficer']= { ['self']=true, ['combat']=true, }, -- Officer check -- Sets the DKP officer for everyone.
        ['WhoIsDKP']= { ['self']=false, ['combat']=true, }, -- Requests who the DKP officer is.
    }
end

function Comms:_InitSyncComms()
    local SYNC_COMMS = {
        ['SyncSmall']= { ['self']=true, ['combat']=true, }, -- Single adds/deletes
        ['SyncLarge']= { ['self']=false, ['combat']=false, }, -- Large merges / overwrites.
        ['SyncProgress']= { ['self']=false, ['combat']=false, },
    }
end

function Comms:_InitOfficerComms()
    local OFFICER_COMMS = {
        ['SyncReq'] = { ['self']=false, ['combat']=false, }, -- When someone Requests a merge
    }
end

function Comms:_RegisterComm()

end

function Comms:_Prefix(prefix)

end

function Comms:SendCommsMessage(prefix, data, distro, sendTo, bulk, func)
    local transmitData = self:DataEncoder(data)
    PDKP.CORE:SendCommMessage(prefix, transmitData, distro, sendTo, bulk, func)
end









-----------------------------
--     Data Functions      --
-----------------------------

function Comms:_Serialize(data)
    return PDKP.CORE:Serialize(data)
end

function Comms:_Compress(serialized)
    return PDKP.LibDeflate:CompressDeflate(serialized)
end

function Comms:_Encode(compressed)
    return PDKP.LibDeflate:EncodeForWoWAddonChannel(compressed)
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
    local serialized = self:Serialize(data)
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