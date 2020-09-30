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

HistoryTable.__index = HistoryTable; -- Set the __index parameter to reference

local type, floor, strupper, pi, substr = type, math.floor, strupper, math.pi, string.match
local tinsert, tremove = tinsert, tremove

local HIGHLIGHT_TEXTURE = 'Interface\\QuestFrame\\UI-QuestTitleHighlight'
local SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
local ARROW_TEXTURE = 'Interface\\MONEYFRAME\\Arrow-Left-Up'
local ROW_SEPARATOR = 'Interface\\Artifacts\\_Artifacts-DependencyBar-BG'

local backdropSettings = {
    tile = true, tileSize = 0,
    edgeFile = SCROLL_BORDER, edgeSize = 8,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local rotate_up = (pi / 180) * 270
local rotate_down = (pi / 180) * 90

----- MISC FUNCTIONS -----

function HistoryTable:SetParent(parent)
    if parent == nil then error('HistoryTable parent is nil'); end
    if type(parent) == type({}) then
        return parent
    elseif type(parent) == type('') then
        return _G[parent];
    else
        error('HistoryTable parent must be a string or table')
    end
end

----- REFRESH FUNCTIONS -----

function HistoryTable:HistoryUpdated(selectedUpdate)

    self.appliedFilters['raid']=Settings.current_raid
    Util:WatchVar(self.appliedFilters, 'HistoryFilters')

    local selected = GUI.memberTable.selected;

    if #selected > 0 then self.appliedFilters['selected']=selected; end

    self:UpdateHistoryLabel(selected)

    if selectedUpdate and self.appliedFilters['selected'] == nil then return end

    for i=1, #self.rows do
        local row = self.rows[i]
        row:Hide()
    end

    self:RefreshData()
    self:RefreshLayout(true)

    if #selected == 0 then self.appliedFilters['selected'] = nil end
    self:UpdateHistoryLabel(selected)
end

function HistoryTable:UpdateHistoryLabel(selected)
    local hex = 'FFBA49'
    local history_text;

    local selectedName;

    local row_count = #self.displayedRows;

    if #selected == 0 then -- none selected.
        if row_count == 0 then history_text = 'No History Found'; else history_text = 'Recent History'; end
    elseif #selected == 1 then -- 1 selected
        if row_count == 0 then history_text = 'No History Found For ' .. selected[1]
        else history_text = 'Recent History For ' .. selected[1]
        end
    else -- More than 1 selected.
        if row_count == 0 then history_text = 'No History Found For Selected'
        elseif row_count >= 1 then history_text = 'Recent History For Selected'
        end
    end

    local title = Util:FormatFontTextColor(hex, history_text)

    self.hist_title:SetText(title)
end

-- Refreshes the data that we are utilizing.
function HistoryTable:RefreshData()
     wipe(self.data)

    self.data = self.retrieveDataFunc();
    wipe(self.displayData);
    for i=1, #self.data do
        self.displayData[i] = self:retrieveDisplayDataFunc(self.data[i]);
    end
end

function HistoryTable:GetDisplayRows(update)
    wipe(self.displayedRows)
    for i=1, #self.displayData do
        local row = self.rows[i];
        local dataObj = self.displayData[i] --- This is the key to updating the table values correctly.
        if update then row:UpdateRowValues(dataObj) end

        row:Hide()

        if not row:ApplyFilters() then
            tinsert(self.displayedRows, row);
            row:Show()
        end
    end

end

function HistoryTable:RefreshTableSize()
    local shownHeight, totalHeight, collapsed, tablePadding, averageHeight = 0, 0, 0, 75, 0

    -- Since the rows have varying heights, we have to collect this info ourselves, instead of using a template.
    for i=1, #self.displayedRows do
        local row = self.displayedRows[i]
        if row:IsVisible() then -- If the row is not collapsed.
            shownHeight = math.floor(shownHeight + row:GetHeight())
        end
        if row.collapsed then collapsed = collapsed + 1 end
        totalHeight = totalHeight + row:GetHeight() + 12
        averageHeight = averageHeight + row:GetHeight() - 12
    end

    averageHeight = averageHeight / #self.displayedRows

    totalHeight = math.floor(totalHeight) + tablePadding -- add some padding just to be safe.

    if averageHeight < 50 then averageHeight = 51 end

    self.ListScrollFrame.buttonHeight = averageHeight

    HybridScrollFrame_Update(self.ListScrollFrame, totalHeight, shownHeight);
    self.ListScrollFrame:UpdateScrollChildRect()
end

function HistoryTable:RefreshLayout(update)
    self:GetDisplayRows(update);

    local offset = HybridScrollFrame_GetOffset(self.ListScrollFrame);

    local collapsed_rows = 0

    for i=1, #self.displayedRows do
        local row = self.displayedRows[i];
        row:ClearAllPoints(); -- Remove it from view

        if row.collapsed then collapsed_rows = collapsed_rows + 1 end

        if i >= offset + 1 and i <= offset + self.MAX_ROWS + collapsed_rows then
            row:Show();
            if i == offset + 1 then
                row:SetPoint("TOPLEFT", self.ListScrollFrame, 8, -14)
            else
                row:SetPoint("TOPLEFT", self.displayedRows[i-1], "BOTTOMLEFT")
            end
        else
            row:Hide();
            if row.collapsed then collapsed_rows = collapsed_rows + 1 end
        end
    end
    self:RefreshTableSize();
end

----- FILTER FUNCTIONS -----

function HistoryTable:ApplyFilter(filterOn, checkedStatus)
    Util:WatchVar(self.appliedFilters, 'PDKP_Table_Filters')

    if filterOn == 'Class_All' then -- Reset all class filters if this gets checked.
        for _, class in pairs(Defaults.classes) do
            local fClass = 'Class_' .. class;
            self.appliedFilters[fClass] = checkedStatus;
        end
    else
        self.appliedFilters[filterOn] = checkedStatus;
    end

    if filterOn == 'online' and checkedStatus then
        self.online = Guild:UpdateOnlineStatus()
    elseif filterOn == 'raid' and checkedStatus then
        self.raid = Raid:GetRaidInfo()
    end

    self.displayedRows = {};
    for i=1, #self.displayData do
        local row = self.rows[i];
        if not row:ApplyFilters() then
            table.insert(self.displayedRows, row);
        end
    end

    if filterOn == 'Select_All' and checkedStatus then
        self:SelectAll()
    end

    self:RefreshTableSize();
    self:RefreshLayout();
end

----- INITIALIZATION FUNCTIONS -----

function HistoryTable:newHybrid(table_settings, col_settings, row_settings)
    local self = {};
    setmetatable(self, HistoryTable); -- Set the metatable so we use HistoryTable's __index

    --- Table settings
    self.parent = self:SetParent(table_settings['parent'])
    self.name = self.parent and self.parent:GetName() .. '_' .. table_settings['name'] or table_settings['name']
    self.height = table_settings['height'] or 300
    self.width = table_settings['width'] or 300
    self.movable = table_settings['movable'] or false
    self.enableMouse = table_settings['enableMouse'] or false
    self.anchor = table_settings['anchor'] or {
        ['point']='CENTER',
        ['rel_point_x']=0,
        ['rel_point_y']=0
    }
    self.retrieveDataFunc = table_settings['retrieveDataFunc']
    self.retrieveDisplayDataFunc = table_settings['retrieveDisplayDataFunc']

    self.showTableBackdrop = table_settings['showBackdrop'] or false

    self.default_title = Util:FormatFontTextColor('FFBA49', 'Recent History')

    --- Generic Settings
    self.displayData = {};
    self.displayedRows = {};
    self.appliedFilters = {};
    self.cols = {};
    self.data = {};
    self.sortBy = nil;
    self.sortDir = nil;
    self.firstSortRan = false;
    self.isDragging = false
    self.rows = {};

    self.appliedFilters['raid']=Settings.current_raid

    Util:WatchVar(self.data, 'HistoryTable Data')
    Util:WatchVar(self.displayData, 'HistoryTable DisplayData')
    Util:WatchVar(self.displayedRows, 'HistoryTable DisplayedRows')
    Util:WatchVar(self.rows, 'HistoryTable Rows')

    self.total_row_height = 0

    self.ROW_HEIGHT = row_settings['height'] or 20
    self.ROW_WIDTH = row_settings['width'] or 300

    --- Row settings
    self.MAX_ROWS =  5  -- arbitrary

    self.showHighlight = row_settings['showHighlight'] or false
    self.showSep = row_settings['showSep'] or false
    self.showRowBackdrop = row_settings['showbackdrop'] or false

    --- Col settings
    self.COL_HEIGHT = col_settings['height'] or 14
    self.COL_WIDTH = col_settings['width'] or 100
    self.HEADERS = col_settings['headers']
    self.firstSort = col_settings['firstSort'] or nil;

    self:RefreshData()

    -------------------------
    --- Setup the Frames
    -------------------------

    -- Create our base frame.
    self.frame = CreateFrame("Frame", self.name, self.parent)
    self.frame:EnableMouse(self.enableMouse)
    self.frame:SetMovable(self.movable)
    self.frame:SetSize(self.width, self.height)
    self.frame:SetHeight(self.height + (self.COL_HEIGHT * 2));
    self.frame:SetWidth(self.width)
    self.frame:SetPoint(self.anchor['point'], self.parent, self.anchor['rel_point_x'], self.anchor['rel_point_y'])

    --- Create History Title
    self.hist_title = self.frame:CreateFontString(f, "OVERLAY", "GameFontHighlightLarge")
    self.hist_title:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 14, 20)
    self.hist_title:SetText(self.default_title)

    self.collapse_all = CreateFrame("Button", nil, self.frame)

    if self.showTableBackdrop then
        self.frame:SetBackdrop(backdropSettings)
    end

    self.frame.parent = self

    -----------------
    --- Create the ScrollFrame

    local listScrollFrame = CreateFrame("ScrollFrame", "ListScrollFrame", self.frame, 'HybridScrollFrameTemplate')

    listScrollFrame:SetPoint("TOPLEFT", 0, -(self.COL_HEIGHT * 2))
    listScrollFrame:SetPoint("BOTTOMRIGHT", -30, 8)

    ----------------
    --- Create the slider
    local scrollBar = CreateFrame("Slider", 'scrollBar', listScrollFrame, 'HybridScrollBarTemplate')
    scrollBar:SetPoint("TOPLEFT", listScrollFrame, "TOPRIGHT", 1, -16)
    scrollBar:SetPoint("BOTTOMLEFT", listScrollFrame, "BOTTOMRIGHT", 1, 12)

    self.ListScrollFrame = listScrollFrame
    self.scrollChild = listScrollFrame.scrollChild;

    ----------------
    --- Set the on_ functions
    self:OnLoad()

    self.ListScrollFrame.buttonHeight = self.ROW_HEIGHT;

    self.scrollChild:SetWidth(self.ListScrollFrame:GetWidth())

    listScrollFrame:SetVerticalScroll(0);
    listScrollFrame:UpdateScrollChildRect();

    self.ListScrollFrame.buttons = self.rows;

    local max_row_value = (#self.data * self.ROW_HEIGHT)
    if max_row_value == 0 then max_row_value = 10 end

    scrollBar:SetMinMaxValues(1, max_row_value)

    scrollBar.buttonHeight = self.ROW_HEIGHT;
    scrollBar:SetValueStep(self.ROW_HEIGHT);
    scrollBar:SetStepsPerPage(self.MAX_ROWS + 2);
    scrollBar:SetValue(1);

    self.scrollBar = scrollBar;

    self.scrollChild:SetPoint("TOPLEFT", self.ListScrollFrame, "TOPLEFT", 0, 0);

    self:RefreshLayout();

    return self
end

function HistoryTable:OnLoad()
    -- Create the item model that we'll be displaying.
    local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Frame", '$parent_row_' .. i, self.scrollChild)

        row.cols = {};
        row.index = i
        row.realIndex = nil;
        row.selectOn = self.ROW_SELECT_ON
        row.dataObj = self.displayData[i];

        function row:ReportID(state)
            if row:GetID() ~= row.dataObj['id'] then row:SetID(row.dataObj['id'])
            else return
            end

            if not Settings:IsDebug() then return end

            state = state or 'Initial'
            --print('row:', i, state .. ' ID:', row:GetID())
        end

        row:ReportID() -- Prints out the ID.

        row.isFiltered = false;
        row.collapsed = false;

        local collapse_text, titletext;

        local collapse_button = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        collapse_button:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)

        local expand_tex = collapse_button:CreateTexture('expand', 'BACKGROUND', 'Interface\\Buttons\\UI-PlusButton-Up')
        local collapse_tex = collapse_button:CreateTexture('collapse', 'BACKGROUND', 'Interface\\Buttons\\UI-Panel-MinimizeButton-Up')

        row.collapse_frame = function()
            if row.content:IsVisible() then
                row.content:Hide()
                row:SetHeight(50)
                collapse_button:SetTexture('Interface\\Buttons\\UI-PlusButton-Up')
                collapse_text:Show()
                row.collapsed = true
            else
                row.content:Show()
                row:SetHeight(row.max_height)
                collapse_button:SetTexture('Interface\\Buttons\\UI-Panel-MinimizeButton-Up')
                collapse_text:Hide()
                row.collapsed = false
            end
        end

        collapse_button:SetScript("OnClick", function()
            row:collapse_frame()
            self:RefreshLayout(false)
        end)
        collapse_button:SetSize(30, 20)
        collapse_button:SetText("X")

        local border = CreateFrame("Frame", nil, row)
        border:SetPoint("TOPLEFT", 0, -17)
        border:SetPoint("BOTTOMRIGHT", -1, 3)
        border:SetBackdrop(PaneBackdrop)
        border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
        border:SetBackdropBorderColor(0.4, 0.4, 0.4)

        titletext = border:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titletext:SetPoint("TOPLEFT", 14, 15)
        titletext:SetJustifyH("LEFT")
        titletext:SetHeight(18)

        collapse_text = border:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        collapse_text:SetHeight(18)
        collapse_text:SetPoint("LEFT", 14, 0)
        collapse_text:Hide()

        local content = CreateFrame("Frame", nil, border)
        content:SetPoint("TOPLEFT", 10, -10)
        content:SetPoint("BOTTOMRIGHT", -10, 10)

        row.border = border;
        row.content = content;

        row:SetSize(self.ROW_WIDTH, self.ROW_HEIGHT)

        row.max_width = 0;
        row.max_height = 0;

        if i == 1 then -- Anchor the first row relative to the frame.
            row:SetPoint("TOPLEFT", self.ListScrollFrame, 8, -14)
        else
            row:SetPoint("TOPLEFT", self.rows[i-1], "BOTTOMLEFT")
        end

        row.super = self;

        function row:UpdateRowValues(entry)
            local self = row.super
            local headers = self.HEADERS;
            if entry then row.dataObj = entry; end
            row.max_height = 0

            row:SetID(row.dataObj['id'])
            row:ReportID('Updated')

            for key=1, #headers do
                local header = headers[key]
                local label = header['label']
                local display_name = header['displayName']
                local col_name = '$parent_' .. row:GetID() .. '_' .. label
                local col = row.cols[key]
                local getVal = header['getValueFunc']
                local val = (getVal ~= nil and row.dataObj ~= nil) and getVal(row.dataObj) or row.dataObj[label]

                if col == nil then
                    col = content:CreateFontString(col_name, 'OVERLAY', 'GameFontHighlightLeft')
                    col.click_frame = nil;
                end

                if header['onClickFunc'] then
                    local cf = col.click_frame;
                    if cf == nil then
                        cf = CreateFrame("Frame", nil, row)
                        cf:SetAllPoints(col)
                        cf:SetScript("OnMouseUp", function(_, buttonType)
                            if row.content:IsVisible() then
                                header['onClickFunc'](row, buttonType)
                            end
                        end)
                        col.click_frame = cf;
                    end
                end

                col:SetSize(row:GetWidth() - 15, self.COL_HEIGHT)
                if key == 1 then
                    col:SetPoint("TOPLEFT", 5, -5)
                else
                    col:SetPoint("TOPLEFT", row.cols[key -1], "BOTTOMLEFT", 0, -2)
                end
                col:SetText(display_name .. ": " .. val)

                row.max_height = row.max_height + col:GetStringHeight() + 12
                row.cols[key] = col
            end
            row:SetHeight(row.max_height)
            if row.max_height < self.ROW_HEIGHT then self.ROW_HEIGHT = row.max_height end

            row:UpdateTextValues()
        end

        function row:UpdateTextValues()
            local formattedID = row.dataObj['formattedID']
            titletext:SetText(formattedID)
            collapse_text:SetText(row.dataObj['raid'] .. " | " .. row.dataObj['formattedOfficer']  .. " | " .. row.dataObj['historyText'])

            if collapse_text:GetStringWidth() > 325 then collapse_text:SetWidth(325) end

            row:collapse_frame()
        end

        function row:ApplyFilters()
            local dataObj = row.dataObj;
            row.isFiltered = false;

            if dataObj['deleted'] == true then row.isFiltered = true end

            local self = row.super;
            local selected = self.appliedFilters['selected']

            for filter, val in pairs(self.appliedFilters or {}) do
                if row.isFiltered then break end -- No need to waste time looping through the rest.

                if filter == 'raid' then
                    row.isFiltered = row.dataObj['raid'] ~= val
                elseif filter == 'selected' and #selected > 0 then
                    for _, n in pairs(selected) do
                        row.isFiltered = not row.dataObj:IsMemberInEntry(n)
                        if row.isFiltered then break end
                    end
                end
            end

            return row.isFiltered;
        end

        row:UpdateRowValues()

        row:collapse_frame()

        rawset(t, i, row)
        return row
    end })


    self.rows = rows

    self.ListScrollFrame.buttons = self.rows;

    -- Bind the update field on the scrollframe to a function that'll update
    -- the displayed contents. This is called when the frame is scrolled.
    self.ListScrollFrame.update = function() self:RefreshLayout(); end

    self:RefreshLayout()

    -- OPTIONAL: Keep the scrollbar visible even if there's nothing to scroll.
    HybridScrollFrame_SetDoNotHideScrollBar(self.ListScrollFrame, false);
end

local eventFunc = {''}



pdkp_HistoryTableMixin = core.History_Table;