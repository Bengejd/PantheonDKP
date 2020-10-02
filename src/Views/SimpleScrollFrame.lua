local _, core = ...;
local _G = _G;
local L = core.L;

local Util = core.Util;
local SimpleScrollFrame = core.SimpleScrollFrame

SimpleScrollFrame.__index = SimpleScrollFrame; -- Set the __index parameter to reference

-- Lua APIs
local pairs, assert, type = pairs, assert, type
local min, max, floor = math.min, math.max, math.floor

local TRANSPARENT_BACKGROUND = "Interface\\TutorialFrame\\TutorialFrameBackground"
local SHROUD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"


-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

function SimpleScrollFrame:FixScrollOnUpdate()
    if self.updateLock then return end
    self.updateLock = true
    local status = self.status or self.localstatus
    local height, viewheight = self.scrollFrame:GetHeight(), self.content:GetHeight()
    local offset = status.offset or 0
    -- Give us a margin of error of 2 pixels to stop some conditions that i would blame on floating point inaccuracys
    -- No-one is going to miss 2 pixels at the bottom of the frame, anyhow!

    if viewheight < height + 2 then
        if self.scrollBarShown then
            self.scrollBarShown = nil
            self.scrollBar:Hide()
            self.scrollBar:SetValue(0)
            self.scrollFrame:SetPoint("BOTTOMRIGHT")
            if self.content.original_width then
                self.content.width = self.content.original_width
            end
        end
    else
        if not self.scrollBarShown then
            self.scrollBarShown = true
            self.scrollBar:Show()
            self.scrollFrame:SetPoint("BOTTOMRIGHT", -20, 0)
            if self.content.original_width then
                self.content.width = self.content.original_width - 20
            end
        end

        local value = (offset / (viewheight - height) * 1000)
        if value > 1000 then value = 1000 end
        self.scrollBar:SetValue(value)
        self:SetScroll(value)
        if value < 1000 then
            self.content:ClearAllPoints()
            self.content:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT", 0, offset)
            self.content:SetPoint("TOPRIGHT", self.scrollFrame, "TOPRIGHT", 0, offset)
            status.offset = offset
        end
    end
    self.updateLock = nil
end

function SimpleScrollFrame:MoveScroll(value)
    local status = self.status or self.localstatus

    local height, viewheight = self.scrollFrame:GetHeight(), self.content:GetHeight()

    if self.scrollBar:IsVisible() then
        local diff = height - viewheight;
        local delta = 1
        if value < 0 then delta = -1 end
        self.scrollBar:SetValue(min(max(status.scrollvalue + delta*(1000/(diff/45)), 0), 1000))
    end
end

function SimpleScrollFrame:SetScroll(value)
    local status = self.status or self.localstatus
    local viewheight = self.scrollFrame:GetHeight()
    local height = self.content:GetHeight()
    local offset

    if viewheight > height then
        offset = 0
    else
        offset = floor((height - viewheight) / 1000.0 * value)
    end
    self.content:ClearAllPoints()

    self.content:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT", 0, offset)
    self.content:SetPoint("TOPRIGHT", self.scrollFrame, "TOPRIGHT", 0, offset)
    status.offset = offset
    status.scrollvalue = value
end

function SimpleScrollFrame:new(parent)
    local self = {}
    setmetatable(self, SimpleScrollFrame); -- Set the metatable so we use HistoryTable's __index

    local sf = CreateFrame("ScrollFrame", '$parent_scrollFrame', parent)
    sf:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    sf:SetHeight(parent:GetHeight())
    sf:SetWidth(parent:GetWidth())

    sf:EnableMouseWheel(1)

    local sb = CreateFrame("Slider", '$parent_scrollBar', sf, "UIPanelScrollBarTemplate")
    sb:SetPoint("TOPLEFT", sf, "TOPRIGHT", 2, -20)
    sb:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", -2, 18)
    sb:SetMinMaxValues(0, 1000)
    sb:SetValueStep(1)
    sb:SetValue(0)
    sb:SetWidth(16)
    sb:Hide()

    sf:SetScript("OnMouseWheel", function(_, value) self:MoveScroll(value) end)

    sb:SetScript("OnValueChanged", function(_, value) self:SetScroll(value) end)

    sf.scrollBar = sb

    local sbg = sb:CreateTexture(nil, "BACKGROUND")
    sbg:SetAllPoints(sb)
    sbg:SetColorTexture(0, 0, 0, 0.4)
    sb:SetBackdrop({
        bgFile = TRANSPARENT_BACKGROUND,
        edgeFile = SHROUD_BORDER, tile = true, tileSize = 4, edgeSize = 4,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })

    sf.scrollBar.bg = sbg

    local sc = CreateFrame("Frame", '$parent_scrollContent', sf)
    sc:SetPoint("TOPLEFT", sf, "TOPLEFT", 0, 0)
    sc:SetPoint("TOPRIGHT", sf, "TOPRIGHT", 0, 0)
    sc:SetWidth(parent:GetWidth() - 20)

    sc:Show()
    sc.children = {}

    sc.AddChild = function(content, frame)
        local childCount = #content.children;

        if childCount == 0 then
            frame:SetPoint("TOPLEFT", 10, 0)
            frame:SetPoint("TOPRIGHT", -10, 0)
        else
            local previous_frame = content.children[childCount]
            frame:SetPoint("TOPLEFT", previous_frame, "BOTTOMLEFT", 0, 0)
            frame:SetPoint("TOPRIGHT", previous_frame, "BOTTOMRIGHT", 0, 0)
        end
        sc:SetHeight(sc:GetHeight() + frame:GetHeight())
        table.insert(content.children, frame)
    end

    sc:SetScript("OnSizeChanged", function(_, value)
        sc:SetScript("OnUpdate", function()
            sc:SetScript("OnUpdate", nil)
            self:FixScrollOnUpdate(value)
        end)
    end)

    sc.Resize = function(content)
        sc:SetHeight(0)
        for i=1, #content.children do
            local child_frame = content.children[i]
            sc:SetHeight(sc:GetHeight() + child_frame:GetHeight())
        end
    end

    sf.content = sc

    sf:SetScrollChild(sc)

    self.localstatus = { ['scrollvalue'] = 0 }

    self.scrollFrame = sf
    self.scrollBar = sb
    self.scrollBarBG = sbg
    self.content = sc

    self.scrollFrame.obj, self.scrollBar.obj = self, self

    return self
end

pdkp_SimpleScrollFrameMixin = core.SimpleScrollFrame;