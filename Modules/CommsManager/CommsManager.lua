local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Comms = {}

function Comms:Initialize()

end

function Comms:Serialize(data)
    return PDKP.CORE:Serialize(data);
end

function Comms:Deserialize(string)
    local success, data = PDKP.CORE:Deserialize(string)
    if success == false or success == nil then
        --Util:ThrowError('An error occured Deserializing the data...');
        return nil;
    end
    return data;
end

function Comms:DataEncoder(data)
    local serialized = self:Serialize(data)
    local compressed = PDKP.LibDeflate:CompressDeflate(serialized)
    local encoded = PDKP.LibDeflate:EncodeForWoWAddonChannel(compressed)
    return encoded
end

function Comms:DataDecoder(data)
    local detransmit = PDKP.LibDeflate:DecodeForWoWAddonChannel(data)
    local decompressed = PDKP.LibDeflate:DecompressDeflate(detransmit)
    if decompressed == nil then -- It wasn't a message that can be decompressed.
        return Comms:Deserialize(detransmit) -- Return the regular deserialized messge
    end
    local deserialized = Comms:Deserialize(decompressed)
    return deserialized -- Deserialize the compressed message
end


MODULES.CommsManager = Comms