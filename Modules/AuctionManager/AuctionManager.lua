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
    if PDKP.canEdit and GameTooltip and IsAltKeyDown() and not Auction:IsAuctionInProgress() and MODULES.AuctionManager:CanChangeAuction() then
        local itemName, itemLink = GameTooltip:GetItem()
        if itemLink then
            local iLink, iName, iTexture = GetItemCommInfo(itemLink)
            local commsData = { iLink, iName, iTexture }
            MODULES.CommsManager:SendCommsMessage('startBids', commsData)
        end
    elseif Auction:IsAuctionInProgress() then
        PDKP.CORE:Print('Another auction is in progress');
    end
end

function Auction:IsAuctionInProgress()
    return self.auctionInProgress
end

function Auction:CanChangeAuction()
    local gm = MODULES.GroupManager;
    local IStartedBid = self.CurrentAuctionInfo['startedBy'] == Utils:GetMyName()
    return (gm:IsDKPOfficer() or gm:IsMasterLoot() or IStartedBid) and gm:IsInRaid()
end

function Auction:Initialize()
    self.auctionInProgress = false
    self:HookBagSlots();
end

function Auction:HandleSlashCommands(msg)
    local cmd, arg1, arg2 = PDKP.CORE:GetArgs(msg, 3)
end

function Auction:HookBagSlots()
    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", HandleModifiedTooltipClick)

    local eventsFrame = CreateFrame("Frame", "PDKP_AuctionEvents")
    eventsFrame:RegisterEvent('LOOT_OPENED')
    eventsFrame:RegisterEvent('LOOT_SLOT_CLEARED')
    eventsFrame:SetScript("OnEvent", function(self, eventName, ...)
        if eventName == 'LOOT_OPENED' then
            Auction:HookIntoLootBag()
        elseif eventName == 'LOOT_SLOT_CLEARED' then
            GUI.AuctionGUI.frame:Hide()
        end
    end);
end

function Auction:HookIntoLootBag()
    local numLootItems = GetNumLootItems();
    for i=1, numLootItems do
        local btnName = 'LootButton'
        btnName = btnName .. tostring(i)
        local btn = _G[btnName]
        if btn then
            btn:SetScript("OnMouseDown", function(b, buttonType)
                if buttonType == 'LeftButton' and IsAltKeyDown() then
                    HandleModifiedTooltipClick()
                end
            end)
        end
    end
end

function Auction:EndAuction(manualStop, sender)
    PDKP.AuctionTimer.reset()
    self.auctionInProgress = false
    GUI.AuctionGUI:ResetAuctionInterface()

    if not PDKP.canEdit then return end

    local GroupManager = MODULES.GroupManager

    local canContinue = false
    if GroupManager:HasDKPOfficer() then
        if GroupManager:IsDKPOfficer() then
            canContinue = true
        end
    elseif GroupManager:IsMasterLoot() then
        PDKP.CORE:Print('Warning: No DKP Officer Set')
        canContinue = true
    else
        PDKP.CORE:Print('Warning: No DKP Officer Set')
    end

    if canContinue then
        local channel = "RAID"
        if GroupManager:IsAssist() or GroupManager:IsLeader() then
            channel = "RAID_WARNING"
        end
        local bidInfo = self.CurrentAuctionInfo

        local text;
        if manualStop then
            text = string.format("%s closed bids for %s", sender, bidInfo['itemLink'])
        else
            text = string.format("Bids for %s have closed", bidInfo['itemLink'])
        end

        SendChatMessage(text, channel, nil, nil)

        local winners, winningText, amount = self:_GetWinnerInfo(bidInfo['itemLink'])

        SendChatMessage(winningText, channel, nil, nil)

        wipe(self.CURRENT_BIDDERS)
        wipe(self.CurrentAuctionInfo)

        local AdjustChildren = GUI.Adjustment.entry_details.children
        local mainDD = AdjustChildren[1]
        local amtBox = AdjustChildren[3]

        mainDD.setAutoValue('Item Win')
        amtBox:SetText(amount)
    end
end

function Auction:HandleTimerFinished(manualEnd)
    manualEnd = manualEnd or false
    if not PDKP.canEdit or not MODULES.AuctionManager:CanChangeAuction() then return end
    MODULES.CommsManager:SendCommsMessage('stopBids', {['manualEnd'] = manualEnd})
end

function Auction:_GetWinnerInfo(itemLink)
    table.sort(self.CURRENT_BIDDERS, function(a, b)
        return a['bid'] > b['bid']
    end)

    local winners = {}

    local numBidders = #self.CURRENT_BIDDERS

    if numBidders == 0 then
        return winners, string.format('%s Open for free-rolls', itemLink)
    elseif numBidders == 1 then
        local winner = self.CURRENT_BIDDERS[1]
        winners[1] = winner
        return winners, string.format('%s Won by %s, for %d DKP', itemLink, winners[1].name, 1), 1
    elseif numBidders > 1 then
        local winningText = ''
        local winningAmt;

        for i=1, #self.CURRENT_BIDDERS do
            local bidder = self.CURRENT_BIDDERS[i]
            if i == 1 then
                tinsert(winners, bidder)
            elseif bidder.bid == winners[1].bid then
                tinsert(winners, bidder)
            else
                break
            end
        end

        if #winners == 1 and numBidders > 1 then -- Multiple Bidders
            winningAmt = (tonumber(self.CURRENT_BIDDERS[2]['bid']) + 1)
            winningText = string.format("%s won by %s, for %d DKP", itemLink, winners[1].name, winningAmt)
        elseif #winners == 1 and numBidders == 1 then
            winningAmt = 1
            winningText = string.format("%s won by %s, for %d DKP", itemLink, winners[1].name, winningAmt)
        elseif #winners > 1 and numBidders > 1 then
            local names = ''
            for i=1, #winners do
                local member = winners[i]
                names = names .. member.name
                if i ~= #winners then
                    names = names .. ', '
                end
            end
            winningAmt = winners[1].bid
            winningText = string.format('%s TIED, Please /roll 100', names)
        end

        return winners, winningText, winningAmt * -1
    end
end

function Auction:_GetWinners()
    local winners = {}

    table.sort(self.CURRENT_BIDDERS, function(a, b)
        return a['bid'] > b['bid']
    end)

    if #self.CURRENT_BIDDERS == 1 then
        tinsert(winners, self.CURRENT_BIDDERS[1])
    elseif #self.CURRENT_BIDDERS > 1 then
        for i=2, #self.CURRENT_BIDDERS do
            local bidder = self.CURRENT_BIDDERS[i]
            if bidder['bid'] == self.CURRENT_BIDDERS[1] then
                tinsert(winners, self.CURRENT_BIDDERS[i])
            else
                break
            end
        end
    end
    return winners
end


MODULES.AuctionManager = Auction

