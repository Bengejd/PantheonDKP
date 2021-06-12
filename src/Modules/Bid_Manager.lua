local _G = _G;
local PDKP = _G.PDKP

local Bid, Dev, Setup, SimpleScrollFrame, Defaults = PDKP:GetInst('Bid', 'Dev', 'Setup', 'SimpleScrollFrame', 'Defaults')

local bids = {}

local test_bid_item = '|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r'

if Defaults.development then
    bids = Dev.bids
end

local CurrItemForBid, CurrItemIcon;

function Bid:Init()
    Bid.frame = SimpleScrollFrame:new(UIParent)
end

function Bid:New(prospect)
    if prospect ~= nil then
        table.insert(bids, prospect)
    end

    

    local createShroudStringFrame = function()
        local f = CreateFrame("Frame", nil, scrollContent, nil)
        f:SetSize(scrollContent:GetWidth(), 18)
        f.name = f:CreateFontString(f, "OVERLAY", "GameFontHighlightLeft")
        f.total = f:CreateFontString(f, 'OVERLAY', 'GameFontNormalRight')
        f.name:SetHeight(18)
        f.total:SetHeight(18)
        f.name:SetPoint("LEFT")
        f.total:SetPoint("RIGHT")
        return f
    end

end