local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;
local GUtils = PDKP.GUtils;

local Comms = {}

function Comms:Initialize()
    self.commsRegistered = false
    self.cache = {}
    self.commsOpen = true
    self.allow_from_self = {}
    self.allow_in_combat = {}
    self.channels = {}
    self.officerCommPrefixes = {}
    self.syncInProgress = false;

    self.autoSyncData = self:DataEncoder({ ['type'] = 'request' });

    local opts = {
        ['name'] = 'OFFICER_COMMS',
        ['events'] = {'GUILD_ROSTER_UPDATE', 'ZONE_CHANGED_NEW_AREA'},
        ['tickInterval'] = 5,
        ['onEventFunc'] = function()
            MODULES.GuildManager:GetMembers()
            self:RegisterOfficerAdComms()
        end,
    }
    self.eventFrame = GUtils:createThrottledEventFrame(opts)
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
        --['SyncReq'] = { ['self'] = false, ['requireCheck'] = false, ['combat'] = true, },

        --- RAID COMMS
        ['DkpOfficer'] = { ['self'] = true, ['channel'] = 'RAID',  },
        ['WhoIsDKP'] = { ['channel'] = 'RAID', ['requireCheck'] = false, },

        ['StartBids'] = { ['channel'] = 'RAID', ['self'] = true, },
        ['StopBids'] = { ['channel'] = 'RAID',  ['self'] = true, },

        ['BidSubmit'] = { ['channel'] = 'RAID', ['requireCheck'] = false, ['self'] = true, },
        ['BidCancel'] = { ['channel'] = 'RAID', ['requireCheck'] = false, ['self'] = true, },

        ['AddBid'] = { ['channel'] = 'RAID', ['self'] = true, },
        ['CancelBid'] = { ['channel'] = 'RAID', ['self'] = true, },
        ['AddTime'] = { ['channel'] = 'RAID', ['self'] = true, ['requireCheck'] = false },

        ['SentInv'] = { ['channel'] = 'WHISPER', },
        --['Version'] = { ['channel'] = 'GUILD', },
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

function Comms:RegisterOfficerAdComms()
    local myName = Utils:GetMyName()

    local syncStatus = MODULES.Options:GetAutoSyncStatus()

    for name, member in pairs(MODULES.GuildManager:GetOfficers()) do
        if member:IsStrictRaidReady() then
            local pfx = self.officerCommPrefixes[name]
            local comm;

            if pfx == nil then
                local opts = {
                    ['combat'] = false,
                    ['self'] = false,
                    ['requireCheck'] = false,
                    ['prefix'] = member.name,
                    ['officerComm'] = true,
                    ['isSelfComm'] = name == myName,
                }
                comm = MODULES.Comm:new(opts)
                self.channels[comm.prefix] = comm;
                self.officerCommPrefixes[name] = comm.prefix;
            else
                comm = self.channels[pfx]
            end

            comm:HandleOfficerCommStatus(member, myName, syncStatus)

            if comm.registered and name ~= myName then
                PDKP:PrintD("Sending Officer Comms message", member.name)
                self:SendCommsMessage(name, self.autoSyncData, true);
            end
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

    local comm = self.channels[Utils:GetCommPrefix(prefix)]

    if comm ~= nil and comm:IsValid() then
        if comm.requireCheck and not comm:CanSend() then
            return
        end

        if self.syncInProgress and comm.isSelfComm then
            return
        end

        local params = comm:GetSendParams()
        if prefix == 'SentInv' then
            params[2] = data
        end
        return PDKP.CORE:SendCommMessage(comm.prefix, transmitData, unpack(params))
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

function Comms:_Decompress(decoded, chunksMode)
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

function Comms:DataDecoder(data, chunksMode)
    local detransmit = self:_Decode(data)
    local decompressed = self:_Decompress(detransmit, chunksMode)
    if decompressed == nil then
        -- It wasn't a message that can be decompressed.
        return self:_Deserialize(detransmit) -- Return the regular deserialized messge
    end
    local deserialized = self:_Deserialize(decompressed)
    return deserialized -- Deserialize the compressed message
end

function Comms:ChunkedDecoder(data, sender)
    local detransmit = self:_Decode(data)
    local chunkSize = 1024 * 4;
    local WoW_decompress_co = PDKP.LibDeflate:DecompressDeflate(detransmit, {chunksMode=true, yieldOnChunkSize=chunkSize })
    local processing = CreateFrame('Frame')
    PDKP.CORE:Print("Processing large import from", sender .. "...")
    processing:SetScript('OnUpdate', function()
        local ongoing, WoW_decompressed = WoW_decompress_co()
        if not ongoing then
            PDKP:PrintD("Chunk Processing finished", sender);
            processing:SetScript('OnUpdate', nil)
            local deserialized = self:_Deserialize(WoW_decompressed)
            return MODULES.DKPManager:ImportBulkEntries(deserialized, sender, true);
        end
    end)
end

function Comms:DatabaseEncoder(data, save)
    local serialized = self:_Serialize(data)
    local compressed = self:_Compress(serialized)

    if save then
        local db = MODULES.Database:Decay();
        db['original'] = data
        db['serialized'] = serialized;
        db['compressed'] = compressed;
        db['adler_serialized'] = self:_Adler(serialized)
        db['adler_compressed'] = self:_Adler(compressed);
    end

    return compressed
end

function Comms:DatabaseDecoder(data, save)
    local decompressed = self:_Decompress(data)
    if decompressed == nil then
        -- It wasn't a message that can be decompressed.
        return self:_Deserialize(data) -- Return the regular deserialized messge
    end
    return self:_Deserialize(decompressed)
end

MODULES.CommsManager = Comms
