local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils
local Utils = PDKP.Utils

local hooksecurefunc, GameTooltip, IsAltKeyDown = hooksecurefunc, GameTooltip, IsAltKeyDown

local Auction = {}

Auction.CurrentAuctionInfo = {}
Auction.CURRENT_BIDDERS = {}

local function GetItemCommInfo(itemIdentifier)
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, _, _, itemStackCount, _, itemTexture,
    itemSellPrice = GetItemInfo(itemIdentifier)
    return itemLink, itemName, itemTexture
end

local function HandleModifiedTooltipClick()
    if PDKP.canEdit and GameTooltip and IsAltKeyDown() and not Auction:IsAuctionInProgress() then
        local itemName, itemLink = GameTooltip:GetItem()
        if itemLink then
            local iLink, iName, iTexture = GetItemCommInfo(itemLink)
            local commsData = { iLink, iName, iTexture }
            MODULES.CommsManager:SendCommsMessage('startBids', commsData, 'RAID', nil, 'BULK', nil)
        end
    elseif Auction:IsAuctionInProgress() then
        PDKP.CORE:Print('Another auction is in progress');
    end
end

function Auction:IsAuctionInProgress()
    return self.auctionInProgress
end

function Auction:Initialize()
    self.auctionInProgress = false
    self:HookBagSlots();
end

function Auction:HandleSlashCommands(msg)
    local cmd, arg1, arg2 = PDKP.CORE:GetArgs(msg, 3)

    print(cmd, arg1, arg2)

    --print('Auction:', cmd, args)
end

function Auction:HookBagSlots()
    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", HandleModifiedTooltipClick)
end


MODULES.AuctionManager = Auction

