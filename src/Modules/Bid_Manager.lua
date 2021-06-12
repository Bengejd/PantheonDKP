local _G = _G;
local PDKP = _G.PDKP

local Bid, Dev, Setup, SimpleScrollFrame, Defaults = PDKP:GetInst('Bid', 'Dev', 'Setup', 'SimpleScrollFrame', 'Defaults')

local bids = {}

local test_bid_item = '|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r'

Bid.isActive = false

if Defaults.development then
    bids = Dev.bids
    Bid.isActive = true
end

local CurrItemForBid, CurrItemIcon;

function Bid:Init()

end

function Bid:NewProspect(prospect)

end

function Bid:New(iLink)
    Dev:Print("New Bid found", iLink)

    Bid.isActive = true
end