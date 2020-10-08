local _, core = ...;
local _G = _G;
local L = core.L;

local HistoryTable = core.HistoryTable;
local Util = core.Util;
local Defaults = core.Defaults;
local Guild = core.Guild;
local Raid = core.Raid;
local Settings = core.Settings;
local GUI = core.GUI;
local DKP = core.DKP;
local SimpleScrollFrame = core.SimpleScrollFrame;

HistoryTable.__index = HistoryTable; -- Set the __index parameter to reference

local type, floor, strupper, pi, substr, strreplace = type, math.floor, strupper, math.pi, string.match, string.gsub
local tinsert, tremove = tinsert, tremove

local TRANSPARENT_BACKGROUND = "Interface\\TutorialFrame\\TutorialFrameBackground"
local SHROUD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
local EXPAND_ALL = "Interface\\Addons\\PantheonDKP\\Icons\\expand_all.tga"
local COLLAPSE_ALL = "Interface\\Addons\\PantheonDKP\\Icons\\collapse_all.tga"

local PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local ROW_COL_HEADERS = {
    { ['variable']='formattedOfficer', ['display']='Officer', },
    { ['variable']='historyText', ['display']='Reason', ['OnClick']=true,},
    { ['variable']='formattedNames', ['display']='Members', ['OnClick']=true, },
    { ['variable']='change_text', ['display']='Amount'}
}

local deleted_row = nil;

local ROW_MARGIN_TOP = 16 -- The margin between rows.

--[[                --['headers'] = {
                --    [2] = {
                --        ['label']='historyText',
                --        ['sortable']=false,
                --        ['point']='LEFT',
                --        ['displayName']='Reason',
                --        ['showSortDirection'] = false,
                --        ['display']=false,
                --        ['onClickFunc']=function(row, buttonType)
                --            if buttonType == 'LeftButton' then
                --
                --            end
                --
                --            if buttonType == 'RightButton' then
                --                GUI.popup_entry = row.dataObj
                --                StaticPopup_Show('PDKP_DKP_ENTRY_POPUP')
                --            end
                --        end
                --    },
                --}]]

function HistoryTable:init(table_frame)
    local self = {};
    setmetatable(self, HistoryTable)

    self.frame = table_frame

    local scroll = SimpleScrollFrame:new(self.frame.content)
    local scrollFrame = scroll.scrollFrame
    local scrollContent = scrollFrame.content;

    self.scrollContent = scrollContent;

    self.appliedFilters = {};
    self.rows = {};
    self.entry_keys = {}; -- Our Entry Keys from the history table.
    self.entries = {};
    self.updateNextOpen = false
    self.displayedRows = {};
    self.collapsed = false

    self.appliedFilters['raid'] = Settings.current_raid

    self.frame:SetScript("OnShow", function()
        if self.updateNextOpen then
            self:HistoryUpdated()
            self.updateNextOpen = false
        end
    end)

    self.frame.title:SetFontObject("GameFontHighlightLarge")
    self.frame.title:SetTextColor(Util:HexToRGBA('#FFBA49'))

    local collapse_all = CreateFrame("Button", nil, self.frame)
    collapse_all:SetPoint("TOPRIGHT")
    collapse_all:SetSize(16, 16)
    collapse_all:SetNormalTexture(EXPAND_ALL)
    collapse_all:SetScript("OnClick", function()
        self.collapsed = not self.collapsed;
        collapse_all:SetNormalTexture(tenaryAssign(self.collapsed, COLLAPSE_ALL, EXPAND_ALL))
        self:CollapseAllRows(self.collapsed)
    end)

    -- TODO: Change border color on the frame to be dark and the rows to be light.
    --border:SetBackdropColor(0, 0, 0, 0.4)

    self:OnLoad()

    self:RefreshData()

    return self
end

function HistoryTable:CollapseAllRows(collapse)
    for i=1, #self.rows do
        local row = self.rows[i]
        row:collapse_frame(collapse)
    end
    self.scrollContent:Resize(0, 0)
end

function HistoryTable:RefreshData()
    self.scrollContent:WipeChildren(self.scrollContent)
    wipe(self.entry_keys)
    local keys, _ = DKP:GetEntries(true, nil);
    self.entry_keys = keys;

    wipe(self.entries)

    for i=1, #self.entry_keys do self.entries[i] = DKP:GetEntries(nil, self.entry_keys[i]) end

    self:RefreshTable()
end

function HistoryTable:RefreshTable()
    wipe(self.displayedRows)
    for i=1, #self.entry_keys do
        local row = self.rows[i]
        row:Hide()
        if not row:ApplyFilters() then
            tinsert(self.displayedRows, row)
            row:Show()
        end
    end

    self.scrollContent:AddBulkChildren(self.displayedRows)
end

-- Refresh the data, resize the table, re-add the children?
function HistoryTable:HistoryUpdated(selectedUpdate)
    self.appliedFilters['raid']=Settings.current_raid

    local selected = GUI.memberTable.selected;
    if #selected > 0 then self.appliedFilters['selected']=selected;
    elseif #selected == 0 then self.appliedFilters['selected'] = nil;
    end

    self:UpdateTitleText(selected)

    self:RefreshTable()
end

function HistoryTable:UpdateTitleText(selected)
    local raid = Settings.current_raid;
    local text = raid .. ' History'

    if #selected == 1 then text = selected[1] .. ' History'; end

    self.frame.title:SetText(text)
end

function PDKP_History_OnClick(frame, buttonType)
    if not Settings:CanEdit() or not IsShiftKeyDown() then return end

    local label = frame.label;
    local dataObj = frame:GetParent()['dataObj']

    if label == 'Members' then return GUI.memberTable:SelectNames(dataObj['names'])
    elseif label == 'Reason' and buttonType == 'RightButton' then
        GUI.popup_entry = dataObj
        StaticPopup_Show('PDKP_DKP_ENTRY_POPUP')
        deleted_row = frame:GetParent() -- This only gets used if the deletion goes through.
    end
end

function PDKP_History_EntryDeleted(id)
    local self = GUI.history_table;

    local row = self.rows[deleted_row.index]
    row['dataObj']['deleted'] = true

    GUI.history_table:RefreshData()
    GUI.history_table:HistoryUpdated()
end

function HistoryTable:OnLoad()
    local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Frame", nil, self.scrollContent)
        row:SetSize(350, 50)
        row.index = i;
        row.dataObj = self.entries[i];
        row.cols = {};

        row.isFiltered, row.collapsed, row.max_width, row.max_height = false, false, 0, 0

        local collapse_text, row_title;
        local expand_tex = 'Interface\\Buttons\\UI-Panel-CollapseButton-Up'
        local collapse_tex = 'Interface\\Buttons\\UI-Panel-ExpandButton-Up'

        local border = CreateFrame("Frame", nil, row)
        border:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -ROW_MARGIN_TOP)
        border:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -1, 0)
        border:SetBackdrop(PaneBackdrop)
        border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
        border:SetBackdropBorderColor(0.4, 0.4, 0.4)

        row_title = border:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
        row_title:SetPoint("TOPLEFT", 14, 14)
        row_title:SetHeight(18)
        row_title:SetText(i)

        local content = CreateFrame("Frame", nil, border)
        content:SetWidth(row:GetWidth() - 20)
        content:SetPoint("TOPLEFT", border, "TOPLEFT", 5, -5)
        content:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -10, 0)
        content:SetBackdropColor(0.5, 0.5, 0.5, 1)

        collapse_text = border:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        collapse_text:SetHeight(18)
        collapse_text:SetPoint("LEFT", 14, 0)
        collapse_text:Hide()

        row.border = border
        row.content = content

        local collapse_button = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        collapse_button:SetPoint("TOPRIGHT", -2, -2)
        collapse_button:SetNormalTexture(collapse_tex)
        collapse_button:SetSize(15, 15)

        row.super = self;

        row.collapse_frame = function(_, collapse)
            collapse_button:SetNormalTexture(tenaryAssign(collapse, collapse_tex, expand_tex))
            row:SetHeight(tenaryAssign(collapse, 50, row.max_height + ROW_MARGIN_TOP))
            row.collapsed = tenaryAssign(collapse, true, false)
            if collapse then
                collapse_text:Show(); row.content:Hide()
            else
                collapse_text:Hide(); row.content:Show();
            end

        end

        collapse_button:SetScript("OnClick", function()
            row:collapse_frame(not row.collapsed)
            self.scrollContent:Resize(0, 0)
        end)

        function row:ApplyFilters()
            local self = row.super;
            local dataObj = row.dataObj;
            row.isFiltered = false;
            if dataObj['deleted'] == true then row.isFiltered = true end

            local selected = self.appliedFilters['selected']

            for filter, val in pairs(self.appliedFilters or {}) do
                if row.isFiltered then break end -- No need to continue the loop.
                if filter == 'raid' then row.isFiltered = row.dataObj['raid'] ~= val
                elseif filter == 'selected' and selected ~= nil and #selected == 1 then
                    for _, n in pairs(selected) do
                        row.isFiltered = not row.dataObj:IsMemberInEntry(n)
                        if row.isFiltered then break end
                    end
                end
            end

            return row.isFiltered;
        end

        function row:UpdateRowValues(entry)
            local self = row.super;

            if entry then row.dataObj = entry end
            row.max_height = 0
            row:SetID(row.dataObj['id'])

            for key=1, #ROW_COL_HEADERS do
                local header = ROW_COL_HEADERS[key]
                local variable, displayName = header['variable'], header['display']
                local col = row.cols[key]
                local val = row.dataObj[variable]

                if col == nil then
                    col = content:CreateFontString(nil, 'OVERLAY', "GameFontHighlightLeft")
                    col.click_frame = nil;
                end

                if header['OnClick'] then
                    local cf = col.click_frame;
                    if cf == nil then
                        cf = CreateFrame("Frame", nil, row)
                        cf:SetAllPoints(col)
                        cf.value = val;
                        cf.label = header['display']
                        cf:SetScript("OnMouseUp", PDKP_History_OnClick)
                        col.click_frame = cf;
                    end
                end

                col:SetWidth(content:GetWidth() - 5)
                if key == 1 then
                    col:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
                else
                    col:SetPoint("TOPLEFT", row.cols[key -1], "BOTTOMLEFT", 0, -2)
                end
                col:SetText(displayName .. ": " .. val)

                if string.find(val, "Item Win -") then
                    local _, item = strsplit(' - ', val)
                    item = strtrim(item)
                    if item then
                        --print('Need to do fancy Tooltip stuff here')
                    end
                end
                row.max_height = row.max_height + col:GetStringHeight() + 6
                row.cols[key] = col
            end

            row:SetHeight(row.max_height + ROW_MARGIN_TOP)
            row:UpdateTextValues()
        end

        function row:UpdateTextValues()
            row_title:SetText(row.dataObj['formattedID'])
            local c_raid = row.dataObj['raid']
            local c_officer = row.dataObj['formattedOfficer']
            local c_hist = row.dataObj['collapsedHistoryText']
            local c_text = c_raid .. ' | ' .. c_officer .. ' | ' .. c_hist
            collapse_text:SetText(c_text)
            if collapse_text:GetStringWidth() > 325 then collapse_text:SetWidth(315) end
        end

        row.collapse_frame(true)

        row:UpdateRowValues()

        rawset(t, i, row)
        return row
    end})

    self.rows = rows

    -- TODO: BUG: When selecting the same raid again in the dropdown, history disappears.
end



pdkp_HistoryTableMixin = core.History_Table;