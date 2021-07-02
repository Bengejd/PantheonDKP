local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local CommsManager;
local Comm = {}

Comm.__index = Comm

local setmetatable, pairs, tremove, tinsert = setmetatable, pairs, table.remove, table.insert
local substr, type, floor = string.sub, type, math.floor

local function _prefix(prefix)
    return 'pdkpV2' .. substr(prefix, 0, 12)
end

function Comm:new(opts)
    local self = {}
    setmetatable(self, Comm); -- Set the metatable so we used entry's __index

    CommsManager = MODULES.CommsManager

    self.ogPrefix = opts['prefix']
    self.prefix = _prefix(self.ogPrefix)
    self.allowed_from_self = opts['self'] or false
    self.allowed_in_combat = opts['combat'] or false
    self.channel = opts['channel'] or "GUILD"
    self.requireCheck = opts['requireCheck'] or false

    self.channel, self.sendTo, self.priority, self.callbackFunc, self.onCommReceivedFunc = self:_Setup()

    if self:IsValid() then
        if not opts['combat'] then
            self:_InitializeCache()
        end
        self:RegisterComm()
    else
        PDKP.CORE:Print('Comm is not valid', self.ogPrefix)
    end

    return self
end

function Comm:VerifyCommSender(message, sender)
    if self.requireCheck then
        local sentMember = MODULES.GuildManager:GetMemberByName(sender)
        if sentMember == nil or not sentMember.canEdit then
            return
        end
    end

    if not self.allowed_from_self and sender == PDKP.char.name then
        return
    end

    if not self.allowed_in_combat and not self.open then
        PDKP.CORE:Print("Message received, waiting for combat to drop to process it.")
        tinsert(self.cache, {['message'] = message, ['sender'] = sender})
        return
    end

    self.onCommReceivedFunc(self, message, sender)
end

function Comm:RegisterComm()
    PDKP.CORE:RegisterComm(self.prefix, PDKP_OnCommsReceived)
end

function Comm:UnregisterComm()
    PDKP.CORE:RegisterComms(self.prefix, function()
    end)
end

function Comm:IsValid()
    local hasChannel = self.channel ~= nil and type(self.channel) == 'string'
    local hasPriority = self.priority == 'BULK' or self.priority == 'NORMAL' or self.priority == 'ALERT'
    local hasCommReceivedFunc = self.onCommReceivedFunc ~= nil and type(self.onCommReceivedFunc) == 'function'
    local hasCallbackFunc = self.callbackFunc == nil or type(self.callbackFunc) == 'function'
    return hasChannel and hasPriority and hasCommReceivedFunc and hasCallbackFunc
end

function Comm:GetSendParams()
    return { self.channel, self.sendTo, self.priority, self.callbackFunc }
end

-----------------------------
--    Private Functions     --
-----------------------------

function Comm:_Setup()
    local p = self.ogPrefix
    -- Comm Channel, SendTo, Prio, CallbackFunc, OnCommReceivedFunc
    local commParams = {
        -- Sync Section
        ['SyncSmall'] = { 'GUILD', nil, 'NORMAL', nil, PDKP_OnComm_EntrySync }, -- Single Adds/Deletes
        ['SyncLarge'] = { 'GUILD', nil, 'BULK', PDKP_SyncProgressBar, PDKP_OnComm_EntrySync }, -- Large merges / overwrites
        ['SyncAd'] = { 'GUILD', nil, 'BULK', PDKP_SyncLockout, PDKP_OnComm_EntrySync }, -- Auto Sync feature

        -- Auction Section
        ['startBids'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },
        ['stopBids'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },

        -- Officer Bid Section
        ['AddBid'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },
        ['CancelBid'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },

        -- Player Bid section
        ['bidSubmit'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },
        ['bidCancel'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },

        ['DkpOfficer'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_SetDKPOfficer },
        ['WhoIsDKP'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_GetDKPOfficer },

        --['GUILD'] = {
        --    --['V2PushReceive'] = { ['self']=true, ['combat']=false, }, -- Officer check -- When a new push is received.
        --    --['V2EntryDelete'] = { ['self']=true, ['combat']=true, }, -- Officer check -- When an entry is deleted.
        --    --['V2SyncRes']= { }, -- When an officer's sync request goes through.
        --
        --    --['V2Version']= { }, -- When someone requests the latest version of the addon.
        --    --['V2SyncProgress']= { ['self']=false, ['combat']=false, },
        --},
        --['RAID'] = {
        --    --['ClearBids']= { ['combat']=true, }, -- Officer check -- When the DKP Officer clears the Shrouding Window.
        --    --['UpdateBid']= { ['combat']=true, }, -- Officer check -- When someone new shrouds, comes from DKP Officer.
        --    --['V2WhoIsDKP']= { ['self']=false, ['combat']=true, }, -- Requests who the DKP officer is.
        --},
        --['OFFICER'] = {
        --    --['V2SyncReq'] = {},
        --},
    }

    if commParams[p] then
        return unpack(commParams[p])
    end
    return nil
end

function Comm:_InitializeCache()
    self.cache = {};
    self.open = true
    self.eventsFrame = CreateFrame("Frame", nil, UIParent)
    local COMMS_EVENTS = {'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'};
    self.eventsFrame.comm = self
    for _, eventName in pairs(COMMS_EVENTS) do self.eventsFrame:RegisterEvent(eventName) end

    self.eventsFrame:SetScript("OnEvent", PDKP_Comms_OnEvent)
end

function Comm:_ProcessCache(frameCache)
    if PDKP:IsDev() then
        PDKP.CORE:Print('Processing', #self.cache, 'cached messages')
    end

    for i = #self.cache, 1, -1 do
        local transmission = self.cache[i]
        self:VerifyCommSender(transmission['message'], transmission['sender'])
        tremove(self.cache, i)
        tremove(frameCache, i)
    end
end

-----------------------------
--    OnComm Functions     --
-----------------------------

function PDKP_Comms_OnEvent(eventsFrame, event, arg1, ...)
    local comm = eventsFrame.comm

    if event == 'PLAYER_REGEN_DISABLED' then
        comm.open = false
    elseif event == 'PLAYER_REGEN_ENABLED' then
        comm.open = true
        if #comm.cache > 0 then
            PDKP.CORE:Print('Start Cached message', #comm.cache)
            comm:_ProcessCache(comm.cache)
            PDKP.CORE:Print('End Cached message', #comm.cache)
        end
    end
end

function PDKP_OnComm_SetDKPOfficer(_, message, _)
    local data = MODULES.CommsManager:DataDecoder(message)
    MODULES.GroupManager:SetDKPOfficer(data)
end

function PDKP_OnComm_GetDKPOfficer(comm, message, sender)
    local data = MODULES.CommsManager:DataDecoder(message)
    if data == 'request' and PDKP.canEdit and MODULES.GroupManager:HasDKPOfficer() then
        MODULES.CommsManager:SendCommsMessage('DkpOfficer', { MODULES.GroupManager.leadership.dkpOfficer, MODULES.GroupManager.leadership.dkpOfficer, true } )
    end
end

function PDKP_OnComm_EntrySync(comm, message, sender)
    local self = comm

    if self.ogPrefix == 'SyncSmall' then
        local data = MODULES.CommsManager:DataDecoder(message)
        return MODULES.DKPManager:ImportEntry(data, sender)
    elseif self.ogPrefix == 'SyncLarge' then
        return MODULES.DKPManager:ImportBulkEntries(message, sender)
    elseif self.ogPrefix == 'SyncAd' then
        return MODULES.DKPManager:ImportBulkEntries(message, sender)
    end
end

function PDKP_OnComm_BidSync(comm, message, sender)
    local self = comm
    local data = MODULES.CommsManager:DataDecoder(message)

    local Auction = MODULES.AuctionManager
    local AuctionGUI = GUI.AuctionGUI
    local GroupManager = MODULES.GroupManager

    if self.ogPrefix == 'startBids' then
        local itemLink, itemName, iTexture = unpack(data)
        Auction.auctionInProgress = true
        AuctionGUI:StartAuction(itemLink, itemName, iTexture)
        PDKP.AuctionTimer.startTimer()
        if PDKP.canEdit then
            GUI.Adjustment:InsertItemLink(itemLink)
        end

        if GroupManager:IsDKPOfficer() then
            local channel = "RAID"
            if GroupManager:IsAssist() or GroupManager:IsLeader() then
                channel = "RAID_WARNING"
            end
            local text = string.format("Starting bids for %s", itemLink)
            SendChatMessage(text, channel, nil, nil)
        end

    elseif self.ogPrefix == 'bidSubmit' then
        if not MODULES.AuctionManager:CanChangeAuction() then return end
        local member = MODULES.GuildManager:GetMemberByName(sender)
        local bidder_info = { ['name'] = member.name, ['bid'] = data, ['dkpTotal'] = member:GetDKP('total') }
        CommsManager:SendCommsMessage('AddBid', bidder_info)
    elseif self.ogPrefix == 'stopBids' then
        if Auction:IsAuctionInProgress() then
            Auction:EndAuction()
        end
    elseif self.ogPrefix == 'AddBid' then
        GUI.AuctionGUI:CreateNewBidder(data)
    elseif self.ogPrefix == 'CancelBid' then
        GUI.AuctionGUI:CancelBidder(sender)
    end
end

function PDKP_SyncProgressBar(arg, sent, total)
    local percentage = floor((sent / total) * 100)

    if Comm.start_time == nil then Comm.start_time = time() end

    if Comm.progress ~= percentage then
        Comm.progress = percentage
        local elapsed = time() - Comm.start_time
        PDKP_UpdatePushBar(percentage, elapsed)
    end

    if Comm.progress == nil or Comm.progress >= 100 then
        if Comm.progress >= 100 then
            PDKP.CORE:Print('Sync Complete')
        end
        Comm.progress = 0
        Comm.start_time = nil
    end
end

function PDKP_SyncLockout(arg, sent, total)
    local DKP = MODULES.DKPManager
    local percentage = floor((sent / total) * 100)
    if percentage < 100 then
        DKP.autoSyncInProgress = true
    else
        DKP.autoSyncInProgress = false
    end
end

function PDKP_UpdatePushBar(percent, elapsed)
    local remaining = 100 - percent
    local pps = percent / elapsed -- Percent per second
    local eta = (elapsed / percent) * remaining
    eta = math.floor(eta)

    local hours = string.format("%02.f", math.floor(eta/3600));
    local mins = string.format("%02.f", math.floor(eta/60 - (hours*60)));
    local secs = string.format("%02.f", math.floor(eta - hours*3600 - mins *60));

    local etatext = mins .. ':' .. secs
    local statusText = 'PDKP Push: ' .. percent .. '%' .. ' ETA: ' .. etatext
    PDKP.PushBar.setAmount(percent, statusText)
end

MODULES.Comm = Comm
