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

local function HandleModifiedTooltipClick(frame, buttonType)
    if PDKP.canEdit and GameTooltip and IsAltKeyDown() then
        local itemName, itemLink = GameTooltip:GetItem()
        if itemLink then
            Auction.auctionInProgress = true
            GUI.AuctionGUI:StartAuction(itemName, itemLink)
        end
    end
end

function Auction:IsAuctionInProgress()
    return self.auctionInProgress
end

function Auction:Initialize()
    self.auctionInProgress = false
    self:HookBagSlots();
end

function Auction:HookBagSlots()
    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", HandleModifiedTooltipClick)
end


MODULES.AuctionManager = Auction

