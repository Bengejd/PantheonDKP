local _G = _G;
local PDKP = _G.PDKP

local Bid, Dev, Setup, SimpleScrollFrame, Defaults, GUI = PDKP:GetInst('Bid', 'Dev', 'Setup', 'SimpleScrollFrame', 'Defaults', 'GUI')
local bids = {}

local test_bid_item = '|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r'

Bid.isActive = false

if Defaults.development then
    bids = Dev.bids
    Bid.isActive = false
end

local CurrItemForBid, CurrItemIcon;

function Bid:Init()

end

function Bid:NewProspect(prospect)

end

function Bid:Start(iLink)
    if not iLink then return end

    Dev:Print("Starting bids for", iLink)

    local f = GUI.bid_frame
    local _, itemIcon = f.item_link.SetItemLink(iLink)
    Bid.isActive = true
    f:Show()


end