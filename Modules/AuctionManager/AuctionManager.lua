local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils

local hooksecurefunc, GameTooltip, IsAltKeyDown = hooksecurefunc, GameTooltip, IsAltKeyDown

local Auction = {}

Auction.CurrentAuctionInfo = {}
Auction.CURRENT_BIDDERS = {}

local function GetItemCommInfo(itemIdentifier)
    local itemName, itemLink, _, _, _, _, _, _, _, itemTexture,
    _ = GetItemInfo(itemIdentifier)
    return itemLink, itemName, itemTexture
end

local function HandleModifiedTooltipClick()
    if PDKP.canEdit and GameTooltip and IsAltKeyDown() and not Auction:IsAuctionInProgress() and MODULES.AuctionManager:CanChangeAuction() then
        local _, itemLink = GameTooltip:GetItem()
        if itemLink then
            local iLink, iName, iTexture = GetItemCommInfo(itemLink)
            local commsData = { iLink, iName, iTexture }
            MODULES.CommsManager:SendCommsMessage('StartBids', commsData)
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
    local guild = MODULES.GuildManager;
    local myName = Utils:GetMyName();
    local IStartedBid = self.CurrentAuctionInfo['startedBy'] == myName
    return (gm:IsDKPOfficer() or gm:IsMasterLoot() or IStartedBid) and gm:IsInRaid() and guild:IsMemberOfficer(myName)
end

function Auction:Initialize()
    self.auctionInProgress = false
    self:HookBagSlots();
end

function Auction:HandleSlashCommands(msg)
    local _, _, _ = PDKP.CORE:GetArgs(msg, 3)
end

function Auction:HookBagSlots()
    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", HandleModifiedTooltipClick)

    local eventsFrame = CreateFrame("Frame", "PDKP_AuctionEvents")
    eventsFrame:RegisterEvent('LOOT_OPENED')
    eventsFrame:RegisterEvent('LOOT_SLOT_CLEARED')
    eventsFrame:SetScript("OnEvent", function(_, eventName, ...)
        if eventName == 'LOOT_OPENED' then
            Auction:HookIntoLootBag()
        elseif eventName == 'LOOT_SLOT_CLEARED' then
            GUI.AuctionGUI.frame:Hide()
        end
    end);
end

function Auction:HookIntoLootBag()
    local numLootItems = GetNumLootItems();
    for i = 1, numLootItems do
        -- ElvUI doesn't use the default frame names... so this doesn't work with it enabled.
        -- Check to see if ElvUI addon exists and if it does, change btn to use the ElvUI one instead.
        local btnName = Utils:ternaryAssign(_G['ElvUI'] ~= nil, 'ElvLootSlot', 'LootButton')

        btnName = btnName .. tostring(i)
        local btn = _G[btnName]

        if btn and not btn.oldClickEventPDKP then
            btn.oldClickEventPDKP = btn:GetScript("OnClick");
            btn:SetScript("OnClick", function(btnObj, ...)
                if not IsAltKeyDown() then
                    return btnObj.oldClickEventPDKP(btnObj, ...);
                else
                    HandleModifiedTooltipClick()
                end
            end)
        end
    end
end

function Auction:IsTierGear()
    --[Chestguard of the Fallen Champion]
    -- Fallen Defender
    -- Fallen Hero
    -- [Pauldrons of the Fallen Champion]
    -- [Leggings of the Fallen Champion]
    -- [Gloves of the Vanquished Champion]
    -- Defender
    -- Hero
    -- [Leggings of the Vanquished Champion]
    -- [Helm of the Vanquished Champion]
    -- [Pauldrons of the Vanquished Champion]
    -- [Chestguard of the Vanquished Champion]

    -- [Gloves of the Forgotten Conqueror]
    -- [Gloves of the Forgotten Protector]
    -- [Gloves of the Forgotten Vanquisher]
    --[Helm of the Forgotten Conqueror]
    -- [Pauldrons of the Forgotten Conqueror]
    -- [Leggings of the Forgotten Conqueror]
    -- [Chestguard of the Forgotten Conqueror]

    -- [Bracers of the Forgotten Conqueror]
    -- [Belt of the Forgotten Conqueror]
    -- [Boots of the Forgotten Conqueror]

    --local items = { 34851, 29754, 40, 28774, 34334 }
    --
    --for _, itemID in pairs(items) do
    --    GetItemInfoInstant(itemID);
    --
    --    local itemName, _, itemQuality, _, itemMinLevel, itemType, itemSubType, itemStackCount,
    --    itemEquipLoc, itemTexture, sellPrice, classID, subclassID, _, _, _, _
    --    = GetItemInfo(itemID)
    --
    --    -- minLevel 70, type Miscellaneous, subType Junk, equipLoc string.len(itemEquipLoc) == 0,
    --    -- classID 15, subClassID 0 (Check to see if consumes are considered this as well), sellPrice 50000.
    --
    --    -- Also have to check to see if there are multiple of the same token that has dropped.
    --
    --    print('Name', itemName, 'quality', itemQuality, 'minLevel', itemMinLevel, 'type', itemType, 'subType', itemSubType,
    --            'stackCount', itemStackCount, 'equipLoc', itemEquipLoc, 'texture', itemTexture, 'sellPrice', sellPrice, 'classId', classID, 'subClassId', subclassID,);
    --
    --    print(string.len(itemEquipLoc) == 0);
    --end




    --print(itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, classID, subclassID, bindType, setID);
    --
    --print(self.CurrentAuctionInfo['itemName'], self.CurrentAuctionInfo['itemLink']);
end

function Auction:EndAuction(manualStop, sender)
    PDKP.AuctionTimer.reset()
    self.auctionInProgress = false
    GUI.AuctionGUI:ResetAuctionInterface()

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

        local _, winningText, amount = self:_GetWinnerInfo(bidInfo['itemLink'])

        SendChatMessage(winningText, channel, nil, nil)

        local AdjustChildren = GUI.Adjustment.entry_details.children
        local mainDD = AdjustChildren[1]
        local amtBox = AdjustChildren[3]

        mainDD.setAutoValue('Item Win')

        if amount ~= nil then
            amtBox:SetText(amount)
        end
    end

    wipe(self.CURRENT_BIDDERS)
    wipe(self.CurrentAuctionInfo)
end

function Auction:HandleTimerFinished(manualEnd)
    manualEnd = manualEnd or false
    if not PDKP.canEdit or not MODULES.AuctionManager:CanChangeAuction() then
        return
    end
    MODULES.CommsManager:SendCommsMessage('StopBids', { ['manualEnd'] = manualEnd })
end

function Auction:_GetWinnerInfo(itemLink)
    --self:IsTierGear();

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

        for i = 1, #self.CURRENT_BIDDERS do
            local bidder = self.CURRENT_BIDDERS[i]
            if i == 1 then
                tinsert(winners, bidder)
            elseif bidder.bid == winners[1].bid then
                tinsert(winners, bidder)
            else
                break
            end
        end

        if #winners == 1 and numBidders > 1 then
            -- Multiple Bidders
            winningAmt = (tonumber(self.CURRENT_BIDDERS[2]['bid']) + 1)
            winningText = string.format("%s won by %s, for %d DKP", itemLink, winners[1].name, winningAmt)
        elseif #winners == 1 and numBidders == 1 then
            winningAmt = 1
            winningText = string.format("%s won by %s, for %d DKP", itemLink, winners[1].name, winningAmt)
        elseif #winners > 1 and numBidders > 1 then
            local names = ''
            for i = 1, #winners do
                local member = winners[i]
                names = names .. member.name
                if i ~= #winners then
                    names = names .. ', '
                end
            end
            winningAmt = winners[1].bid
            winningText = string.format('%s TIED with %d DKP, Please /roll 100', names, winningAmt)
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
        for i = 2, #self.CURRENT_BIDDERS do
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

