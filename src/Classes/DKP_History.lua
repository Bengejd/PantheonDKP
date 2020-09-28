local _, core = ...;
local _G = _G;
local L = core.L;

local HistoryTable = core.HistoryTable;
local Util = core.Util;
local Defaults = core.Defaults;
local Guild = core.Guild;
local Raid = core.Raid;

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

-- Refreshes the data that we are utilizing.
function HistoryTable:RefreshData()
    self.data = self.retrieveDataFunc();
    self.displayData = {};

    for i=1, #self.data do
        self.displayData[i] = self:retrieveDisplayDataFunc(self.data[i]);
    end
end

function HistoryTable:GetDisplayRows()
    wipe(self.displayedRows); -- Return to initial value.
    for i=1, #self.displayData do
        local row = self.rows[i];
        if not row:ApplyFilters() then
            tinsert(self.displayedRows, row);
        else
            row:Hide();
        end
    end
end

function HistoryTable:RaidChanged()
    for i=1, #self.displayData do
        local row = self.rows[i];
        row:UpdateRowValues();
    end
end

function HistoryTable:RefreshTableSize()
    -- The last step is to ensure the scroll range is updated appropriately.
    -- Calculate the total height of the scrollable region (using the model
    -- size), and the displayed height based on the number of shown buttons.

    local total_rows = self.displayedRows and #self.displayedRows or #self.displayData;

    local buttonHeight = self.ROW_HEIGHT;
    local totalHeight = (total_rows * buttonHeight) + self.ROW_HEIGHT;
    local shownHeight = self.MAX_ROWS * buttonHeight;

    HybridScrollFrame_Update(self.ListScrollFrame, totalHeight, shownHeight);
end

function HistoryTable:RefreshLayout()
    local offset = HybridScrollFrame_GetOffset(self.ListScrollFrame);

    self:GetDisplayRows();

    for i=1, #self.displayedRows do
        local row = self.displayedRows[i];
        row:ClearAllPoints(); -- Remove it from view.
        if i >= offset + 1 and i <= offset + self.MAX_ROWS then
            row:Show();
            if i == offset + 1 then
                row:SetPoint("TOPLEFT", self.ListScrollFrame, 8, 0)
            else
                row:SetPoint("TOPLEFT", self.displayedRows[i-1], "BOTTOMLEFT")
            end
        else
            row:Hide();
        end
    end
    self:UpdateLabelTotals()
    self:RefreshTableSize();
end

function HistoryTable:UpdateLabelTotals()
    if self == nil or self.entryLabel == nil then return end
    self.entryLabel:SetText(#self.displayedRows .. " Players shown | " .. #self.selected .. " selected")
    PDKP_ToggleAdjustmentDropdown()
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

    self.ROW_HEIGHT = row_settings['height'] or 20
    self.ROW_WIDTH = row_settings['width'] or 300

    --- Row settings
    self.MAX_ROWS = (self.height / self.ROW_HEIGHT);
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

    scrollBar:SetMinMaxValues(1, (#self.data * self.ROW_HEIGHT))

    scrollBar.buttonHeight = self.ROW_HEIGHT;
    scrollBar:SetValueStep(self.ROW_HEIGHT);
    scrollBar:SetStepsPerPage(self.MAX_ROWS -2);
    scrollBar:SetValue(1);

    self.scrollBar = scrollBar;

    self.scrollChild:SetPoint("TOPLEFT", self.ListScrollFrame, "TOPLEFT", -0, 0);

    self:RefreshLayout();

    return self
end

function HistoryTable:OnLoad()
    -- Create the item model that we'll be displaying.
    local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Button", nil, self.scrollChild)
        row:SetSize(self.ROW_WIDTH, self.ROW_HEIGHT)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp");
        row:RegisterForDrag("LeftButton")

        row.cols = {};
        row.index = i
        row.realIndex = nil;
        row.selectOn = self.ROW_SELECT_ON
        row.dataObj = self.displayData[i];
        row:SetID(i)
        row.isFiltered = false;

        if i == 1 then -- Anchor the first row relative to the frame.
            row:SetPoint("TOPLEFT", self.ListScrollFrame, 16, 0)
        else
            row:SetPoint("TOPLEFT", self.rows[i-1], "BOTTOMLEFT")
        end

        if self.showRowBackdrop then
            row:SetBackdrop(backdropSettings)
        end

        if self.showHighlight then
            row:SetHighlightTexture(HIGHLIGHT_TEXTURE)
            row:SetPushedTexture(HIGHLIGHT_TEXTURE)
            row:SetScript("OnClick", function(r, clickType)
                self:CheckSelect(r, clickType)
            end)
        end

        if self.showSep then
            local sep = row:CreateTexture(nil, 'BACKGROUND')
            sep:SetTexture(ROW_SEPARATOR)
            sep:SetHeight(3)
            sep:SetWidth(self.ROW_WIDTH)

            if i == 1 then
                sep:SetPoint("TOPLEFT", row, 0, 0, row, "TOPRIGHT")
            elseif i == 2 then
                sep:SetPoint("TOPLEFT", row, 0, 0, self.rows[i-1], "TOPLEFT")
            else
                sep:SetPoint("TOPLEFT", row, 0, 0, self.rows[i-1], "TOPLEFT")
            end
        end

        row.super = self;

        function row:UpdateRowValues()
            for key, header in pairs(row.super['HEADERS']) do
                local label = header['label']
                local valFunc = header['getValueFunc']
                if valFunc ~= nil then
                    local val = (valFunc ~= nil and row.dataObj ~= nil) and valFunc(row.dataObj) or row.dataObj[label]
                    row.cols[key]:SetText(val)
                end
            end
        end

        function row:ApplyFilters()
            local dataObj = row.dataObj;
            row.isFiltered = false;
            local super = row.super;
            for filter, checkedStatus in pairs(super.appliedFilters or {}) do
                if row.isFiltered then break end -- No need to waste time looping through the rest.

                -- It's one of the classes, not all.
                if substr(filter, 'Class_') and not substr(filter, '_All') and not checkedStatus then
                    local _, class = strsplit('_', filter);
                    if dataObj['class'] == class then
                        row.isFiltered = true
                        break; -- We don't need to continue running checks, if it's filtered.
                    end
                elseif filter == 'Class_All' and not checkedStatus then
                    row.isFiltered = true;
                elseif checkedStatus then
                    if filter == 'online' then
                        if #super.online > 0 then
                            row.isFiltered = not tContains(super.online, dataObj['name'])
                        end
                    elseif filter == 'selected' then
                        row.isFiltered = not tContains(super.selected, dataObj['name'])
                    elseif filter == 'Select_All' then

                    elseif filter == 'raid' then
                        row.isFiltered = not tContains(super.raid, dataObj['name'])
                    elseif filter == 'name' then
                        row.isFiltered = not Util:StringsMatch(dataObj['name'], super.searchText)
                    end
                end
            end

            return row.isFiltered;
        end

        for key, header in pairs(self.HEADERS) do
            local label = header['label'];
            local col_name = '$parent' .. label
            local col = row:CreateFontString(col_name, 'OVERLAY', 'GameFontHighlightLeft')
            local getVal = header['getValueFunc']
            local val = (getVal ~= nil and row.dataObj ~= nil) and getVal(row.dataObj) or row.dataObj[label]
            

            --local label = header['label'] or ''
            --local col_name = '$parent' .. label
            --local col = row:CreateFontString(col_name, 'OVERLAY', 'GameFontHighlightLeft')
            --local getVal = header['getValueFunc']
            --local val = (getVal ~= nil and row.dataObj ~= nil) and getVal(row.dataObj) or row.dataObj[label]
            --
            --col:SetJustifyH(header['point'])
            --
            --if label == 'class' then
            --    local _, colored_class = Util:ColorTextByClass(val, val)
            --    val = colored_class
            --end
            --
            --col:SetSize(self.COL_WIDTH, self.COL_HEIGHT)
            --local col_point = header['point'] or 'LEFT'
            --col:SetJustifyH(col_point)
            --
            --if type(val) == 'number' and val > 9999 then
            --    col:SetSpacing(0.5) -- For excessively large numbers. Decrease the letter spacing.
            --end
            --
            --if key == 1 then
            --    col:SetPoint(col_point, row)
            --else
            --    col:SetPoint("TOPLEFT", row.cols[key -1], "TOPRIGHT", 0, 0)
            --
            --    if key == #self.HEADERS and col_point == 'RIGHT' then
            --        col:SetPoint("TOPLEFT", row.cols[key -1], "TOPRIGHT", -10, 0)
            --    end
            --end
            --
            --col:SetText(val)
            --
            --row.cols[key] = col;
        end

        rawset(t, i, row)
        return row
    end })

    self.rows = rows

    self.ListScrollFrame.buttons = self.rows;

    -- Bind the update field on the scrollframe to a function that'll update
    -- the displayed contents. This is called when the frame is scrolled.
    self.ListScrollFrame.update = function() self:RefreshLayout(); end

    -- OPTIONAL: Keep the scrollbar visible even if there's nothing to scroll.
    HybridScrollFrame_SetDoNotHideScrollBar(self.ListScrollFrame, true);
end

local eventFunc = {''}



pdkp_HistoryTableMixin = core.History_Table;