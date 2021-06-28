local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local CommsManager;
local Comm = {}

Comm.__index = Comm

local function _prefix(prefix)
    return 'pdkpV2' .. string.sub(prefix, 0, 12)
end

function Comm:new(opts)
    local self = {}
    setmetatable(self, Comm); -- Set the metatable so we used entry's __index

    -- TODO: Hook this up to include it's own SendCommMessage to make sending shit a lot easier...

    CommsManager = MODULES.CommsManager

    self.ogPrefix = opts['prefix']
    self.prefix = _prefix(self.ogPrefix)
    self.allowed_from_self = opts['self'] or false
    self.allowed_in_combat = opts['combat'] or false
    self.channel = opts['channel'] or "GUILD"
    self.requireCheck = opts['requireCheck'] or false

    self.onCommReceivedFunc = self:_GetOnCommReceived()

    self:RegisterComm()

    return self
end

function Comm:OnCommReceived(prefix, message, distribution, sender)
    if self.requireCheck then
        local sentMember = MODULES.GuildManager:GetMemberByName(sender)
        if sentMember == nil or not sentMember.canEdit then
            return
        end
    end

    if not self.allowed_from_self and sender == PDKP.char.name then
        return
    end

    self.onCommReceivedFunc(self, message, sender)
end

function Comm:RegisterComm()
    PDKP.CORE:RegisterComm(self.prefix, PDKP_OnCommsReceived)
end

function Comm:UnregisterComm()
    PDKP.CORE:RegisterComms(self.prefix, function() end)
end

function Comm:_GetOnCommReceived()
    local p = self.ogPrefix
    local commChannels = {
        ['SyncSmall'] = PDKP_OnComm_EntrySync, -- Single Adds/Deletes
        ['SyncLarge'] = PDKP_OnComm_EntrySync, -- Large merges / overwrites
        ['startBids'] = PDKP_OnComm_BidSync,
        ['bidSubmit'] = PDKP_OnComm_BidSync,
        ['stopBids'] = PDKP_OnComm_BidSync,
        ['AddBid'] = PDKP_OnComm_BidSync,
        ['CancelBid'] = PDKP_OnComm_BidSync,
    }
    if commChannels[p] then return commChannels[p] end

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
end

-----------------------------
--    OnComm Functions     --
-----------------------------

function PDKP_OnComm_EntrySync(comm, message, sender)
    local self = comm
    local data = MODULES.CommsManager:DataDecoder(message)

    if self.ogPrefix == 'SyncSmall' then
        return MODULES.DKPManager:ImportEntry(data, sender)
    elseif self.ogPrefix == 'SyncLarge' then
        return MODULES.DKPManager:ImportBulkEntries(data, sender)
    end
end

function PDKP_OnComm_BidSync(comm, message, sender)
    local self = comm
    local data = MODULES.CommsManager:DataDecoder(message)

    local Auction = MODULES.AuctionManager
    local AuctionGUI = GUI.AuctionGUI

    if self.ogPrefix == 'startBids' then
        local itemLink, itemName, iTexture = unpack(data)
        Auction.auctionInProgress = true
        AuctionGUI:StartAuction(itemLink, itemName, iTexture)
        if PDKP.canEdit then
            GUI.Adjustment:InsertItemLink(itemLink)
        end
    elseif self.ogPrefix == 'bidSubmit' then
        -- TODO: Should be DKP Officer

        local member = MODULES.GuildManager:GetMemberByName(sender)
        local bidder_info = { ['name'] = member.name, ['bid'] = data, ['dkpTotal'] = member:GetDKP('total') }
    elseif self.ogPrefix == 'stopBids' then

    elseif self.ogPrefix == 'AddBid' then
        GUI.AuctionGUI:CreateNewBidder(bidder_info)
    elseif self.ogPrefix == 'CancelBid' then

    end
end

MODULES.Comm = Comm
