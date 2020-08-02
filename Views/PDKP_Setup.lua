local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local PDKP = core.PDKP;
local Raid = core.Raid;
local Util = core.Util;
local Comms = core.Comms;
local Setup = core.Setup;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Member = core.Member;
local Import = core.Import;
local Officer = core.Officer;
local Invites = core.Invites;
local Minimap = core.Minimap;
local Defaults = core.Defaults;

local AceGUI = LibStub("AceGUI-3.0")

local PlaySound = PlaySound

local closeButtonText = "|TInterface\\Buttons\\UI-StopButton:0|t"

local function setMovable(f)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag('LeftButton')
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

local function createButton(f)
    local b = CreateFrame("Button", nil,  f, "UIPanelButtonTemplate")
    b:SetSize(25 ,25) -- width, height
    b:SetText(closeButtonText)
    b:SetParent(f)
    b:SetPoint("Center")
    return b
end

function Setup:MainUI()
    local f = CreateFrame("Frame", "pdkp_frame", UIParent)
    f:SetFrameStrata("LOW")

    f:SetWidth(742) -- Set these to whatever height/width is needed
    f:SetHeight(682) -- for your Texture

    local basePath = "Interface\\Addons\\PantheonDKP\\Media\\Main_UI\\PDKPFrame-"

    local function createTextures(tex)
        local x = tex['x'] or 0
        local y = tex['y'] or 0

        local t = f:CreateTexture(nil, "BACKGROUND")
        t:SetTexture(basePath .. tex['file'])
        t:SetPoint(tex['dir'], f, x, y)
        f.texture = t
    end

    local textures = {
        { ['dir'] = 'BOTTOMLEFT', ['file'] = 'BotLeft.tga', },
        { ['dir'] = 'BOTTOM', ['file'] = 'BotMid.tga', ['y']=1.5},
        { ['dir'] = 'BOTTOMRIGHT', ['file'] = 'BotRight.tga', },
        { ['dir'] = 'CENTER', ['file'] = 'Middle.tga', },
        { ['dir'] = 'LEFT', ['file'] = 'MidLeft.tga', ['y']=-42},
        { ['dir'] = 'RIGHT', ['file'] = 'MidRight.tga', ['x']=2.35},
        { ['dir'] = 'TOPLEFT', ['file'] = 'TopLeft.tga', ['x']=-8},
        { ['dir'] = 'TOP', ['file'] = 'Top.blp', },
        { ['dir'] = 'TOPRIGHT', ['file'] = 'TopRight.blp', },
    }

    for _, t in pairs(textures) do createTextures(t) end

    f:SetPoint("TOP",0,0)
    f:Show()

    setMovable(f)

    -- Close button

    local b = CreateFrame("Button", nil,  f, "UIPanelButtonTemplate")
    b:SetSize(22, 25) -- width, height
    b:SetText(closeButtonText)
    b:SetParent(f)
    b:SetPoint("TOPRIGHT", -2, -10)
    b:SetScript("OnClick", function() f:Hide() end)

    -- Submit Button

    local bc = CreateFrame("Button")
    bc:SetScript("OnClick", function(self, arg1)
        print(arg1)
    end)
    bc:Click("foo bar") -- will print "foo bar" in the chat frame.
    bc:Click("blah blah") -- will print "blah blah" in the chat frame.

    Setup:ShroudingBox()
end

function Setup:ShroudingBox()
    local f = CreateFrame("Frame", "pdkp_shroud_frame", UIParent)
    f:SetFrameStrata("HIGH")
    f:SetPoint("BOTTOMLEFT")
    f:SetHeight(200)
    f:SetWidth(200)

    f:SetBackdrop( {
        bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 64, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    }) ;

    setMovable(f)

    -- mini close button
    local b = CreateFrame("Button", "$parentCloseButton", f, "pdkp_miniButton")
    b:SetText(closeButtonText)
    b:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -6, -6)

    -- title
    local t = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    t:SetPoint("TOPLEFT", 5, -10)
    t:SetPoint("TOPRIGHT", -10, -30)
    t:SetText("PDKP Shrouding")



    f:Show()
end

