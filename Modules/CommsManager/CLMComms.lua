local _, PDKP = ...

-- local upvalues

local MODULES = PDKP.MODULES
local LOG = PDKP.LOG
local CONSTANTS = MODULES.CONSTANTS
local UTILS = PDKP.UTILS

local Comms = PDKP.CORE:NewModule("Comms", {}, "AceComm-3.0")
local serdes = LibStub("LibSerialize")
local codec = LibStub("LibDeflate")

--- Classic Loot Manager Functions

local CommsPrefix = "PDKPV2"

function Comms:Initialize()
    self.callbacks = {}
    self.aclLevel = {}
    self.allowSelfReceive = {}
    self.enabled = false
end

function Comms:Enable()
    self.enabled = true
end

local function _prefix(prefix)
    return CommsPrefix .. string.sub(prefix, 0, 12)
end

function Comms:Register(prefix, callback, aclLevel, allowSelfReceive)
    self.callbacks[prefix] = callback
    self.aclLevel[prefix] = aclLevel
    self.allowSelfReceive[prefix] = allowSelfReceive
    self:RegisterComm(prefix, "OnReceive")
end

function Comms:Register(prefix, callback, aclLevel, allowSelfReceive)
    LOG:Trace("Comms:Register()")
    if type(callback) ~= "function" then
        LOG:Error("Comms:Register(): callback is not a function")
        return false
    end

    if type(prefix) ~= "string" then
        LOG:Error("Comms:Register(): prefix [%s] is not a string", prefix)
        return false
    end

    if string.len(prefix) > 12 then
        LOG:Warning("Comms:Register(): truncating prefix [%s] to 12 chars: ", prefix)
    end
    prefix = _prefix(prefix)

    if self.callbacks[prefix] ~= nil then
        LOG:Warning("Comms:Register(): Re-registering prefix %s", prefix)
    end

    if type(aclLevel) ~= "number" then
        LOG:Warning("Comms:Register(): Unknown ACL Level  %s. Setting to any.", aclLevel)
        aclLevel = 0
    end

    self.callbacks[prefix] = callback
    self.aclLevel[prefix] = aclLevel
    self.allowSelfReceive[prefix] = allowSelfReceive
    self:RegisterComm(prefix, "OnReceive")
end

function Comms:Send(prefix, message, distribution, target, priority)
    -- LOG:Trace("Comms:Send()")
    if not self.enabled then return false end
    -- Prefix
    prefix = _prefix(prefix)
    if not type(self.callbacks[prefix]) == "function" then
        LOG:Error("Comms:Send() unregistered prefix: %s", prefix)
        return false
    end
    -- Check ACL before working on data to prevent UI Freeze DoS
    if not ACL:CheckLevel(self.aclLevel[prefix]) then
        LOG:Warning("Trying to send privileged message [%s]", prefix)
        return false
    end
    -- Distribution
    if not CONSTANTS.COMMS.DISTRIBUTIONS[distribution] then
        LOG:Error("Comms:Send() invalid distribution: %s", distribution)
        return false
    end
    -- Priority
    if not CONSTANTS.COMMS.PRIORITIES[priority] then
        priority = CONSTANTS.COMMS.PRIORITY.NORMAL
    end
    -- Serialize
    local tmp = serdes:Serialize(message)
    if tmp == nil then
        LOG:Error("Comms:Send() unable to serialize message: %s", message)
        return false
    end
    -- Compress
    tmp = codec:CompressDeflate(tmp, { level = 4 })
    if tmp == nil then
        LOG:Error("Comms:Send() unable to compress message: %s", message)
        return false
    end
    -- Encode for WoW
    tmp = codec:EncodeForWoWAddonChannel(tmp)
    if tmp == nil then
        LOG:Error("Comms:Send() unable to encode message: %s", message)
        return false
    end
    LOG:Debug("Message on channel %s with size %s [B] ", prefix, tmp:len())
    self:SendCommMessage(prefix, tmp, distribution, target, priority)
    return true
end

function Comms:OnReceive(prefix, message, distribution, sender)
    -- LOG:Trace("Comms:OnReceive() %s", prefix)
    if not self.enabled then return false end
    -- Ignore messages from self if not allowing them specifically
    if not self.allowSelfReceive[prefix] and (sender == self.who) then
        return false
    end
    -- Validate prefix
    if self.callbacks[prefix] == nil then
        LOG:Warning("Comms:OnReceive() received message with unsupported prefix [%s] from [%s]", prefix, sender)
        return
    end
    -- Check ACL before working on data to prevent UI Freeze DoS
    if not ACL:CheckLevel(self.aclLevel[prefix], sender) then
        LOG:Warning("Comms:OnReceive() received privileged message [%s] from unprivileged sender [%s]", prefix, sender)
        return
    end
    -- Decode
    local tmp = codec:DecodeForWoWAddonChannel(message)
    if tmp == nil then
        LOG:Error("Comms:OnReceive() unable to decode message [%s] from [%s]", prefix, sender)
        return
    end
    -- Decompress
    tmp = codec:DecompressDeflate(tmp)
    if tmp == nil then
        LOG:Error("Comms:OnReceive() unable to decompress message [%s] from [%s]", prefix, sender)
        return
    end
    -- Deserialize
    local success;
    success, tmp = serdes:Deserialize(tmp)
    if not success then
        LOG:Error("Comms:OnReceive() unable to deserialize message [%s] from [%s]", prefix, sender)
        return
    end
    -- Execute callback
    self.callbacks[prefix](tmp, distribution, sender)
end

MODULES.CLMComms = Comms

--CONSTANTS.COMMS = {
--    SEPARATOR = "\t",
--    PRIORITIES = UTILS.Set({
--        "ALERT",
--        "NORMAL",
--        "BULK"
--    }),
--    PRIORITY = {
--        ALERT = "ALERT",
--        NORMAL = "NORMAL",
--        BULK = "BULK"
--    },
--    DISTRIBUTIONS = UTILS.Set({
--        "PARTY",
--        "RAID",
--        --"INSTANCE_CHAT",
--        "GUILD",
--        "MANAGER",
--        "WHISPER",
--        --"SAY",
--        --"YELL"
--    }),
--    DISTRIBUTION = {
--        PARTY = "PARTY",
--        RAID = "RAID",
--        --INSTANCE = "INSTANCE_CHAT",
--        GUILD = "GUILD",
--        OFFICER = "OFFICER",
--        WHISPER = "WHISPER",
--        --SAY = "SAY",
--        --YELL = "YELL"
--    }
--}