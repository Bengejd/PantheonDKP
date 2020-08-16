local _, core = ...;
local _G = _G;
local L = core.L;

local ScrollTable = core.ScrollTable;
local Util = core.Util;
local Defaults = core.Defaults;

ScrollTable.__index = ScrollTable; -- Set the __index parameter to reference

local type, floor, strupper, pi, substr = type, math.floor, strupper, math.pi, string.match
local tinsert, tremove = tinsert, tremove

local HIGHLIGHT_TEXTURE = 'Interface\\QuestFrame\\UI-QuestTitleHighlight'
local SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
local ARROW_TEXTURE = 'Interface\\MONEYFRAME\\Arrow-Left-Up'
local ROW_SEPARATOR = 'Interface\\Artifacts\\_Artifacts-DependencyBar-BG'

local rotate_up = (pi / 180) * 270
local rotate_down = (pi / 180) * 90

function ScrollTable:SetParent(parent)
    if parent == nil then error('ScrollTable parent is nil'); end
    if type(parent) == type({}) then
        return parent
    elseif type(parent) == type('') then
        return _G[parent];
    else
        error('ScrollTable parent must be a string or table')
    end
end

function ScrollTable:HighlightRow(row, shouldHighlight)
    if shouldHighlight then row:LockHighlight() else row:UnlockHighlight() end
end

function ScrollTable:ClearSelected()
    wipe(self.selected)
    self.lastSelect = nil
end

function ScrollTable:UpdateLastSelect(objIndex, isSelected)
    if isSelected then
        self.lastSelect = objIndex;
    elseif #self.selected >= 1 then
        self.lastSelect = self.selected[#self.selected]
    else
        self.lastSelect = nil;
    end
end

function ScrollTable:RowShiftClicked(objIndex, selectIndex, isSelected)
    local previousSelect = self.lastSelect

    if previousSelect == objIndex then return end -- Do nothing if the same thing is clicked again.

    -- Shift clicks always add to the lastSelect.
    self:UpdateSelectStatus(objIndex, selectIndex, false, false)
    if #self.selected <= 1 then return end -- Only one thing selected, do nothing.

    local _, prevSelectIndex = tfind(self.rows, previousSelect, self.ROW_SELECT_ON)
    local _, currSelectIndex = tfind(self.rows, self.lastSelect, self.ROW_SELECT_ON)

    local startIndex = prevSelectIndex < currSelectIndex and prevSelectIndex or currSelectIndex
    local endIndex = prevSelectIndex > currSelectIndex and prevSelectIndex or currSelectIndex

    -- Grab the list items between startIndex and endIndex.
    local betweenRows = { unpack( self.rows, startIndex, endIndex) }
    for i=1, #betweenRows do
        local rowObjIndex = betweenRows[i]['dataObj'][self.ROW_SELECT_ON]
        local rowSelected = tfind(self.selected, rowObjIndex)
        if not rowSelected then -- Add it to the list, if it is not already selected.
            tinsert(self.selected, rowObjIndex)
            self:HighlightRow(betweenRows[i], true)
        end
    end
end

function ScrollTable:UpdateSelectStatus(objIndex, selectIndex, isSelected, clear)
    clear = clear or false
    if clear then
        self:ClearSelected()
    end

    if isSelected then
        tremove(self.selected, selectIndex)
    else
        tinsert(self.selected, objIndex)
    end
    self:UpdateLastSelect(objIndex, not isSelected)
end

function ScrollTable:CheckSelect(row, clickType)
    local selectOn = row.selectOn
    local objIndex = row.dataObj[selectOn]

    if clickType == 'LeftButton' then
        local hasCtrl = IsControlKeyDown()
        local hasShift = IsShiftKeyDown()
        local isSelected, selectIndex = tfind(self.selected, objIndex)

        if hasShift and hasCtrl then -- Do nothing here.
            return
        elseif hasShift then -- Shift click
            self:RowShiftClicked(objIndex, selectIndex, isSelected)
        else -- Control or Regular Click.
            self:UpdateSelectStatus(objIndex, selectIndex, isSelected, not hasCtrl)
        end

        return self:RefreshLayout()
    end

    local isSelected, selectIndex = tfind(self.selected, objIndex)
    self:HighlightRow(row, isSelected)
end

-- Refreshes the data that we are utilizing.
function ScrollTable:RefreshData()
    self.data = self.retrieveDataFunc();
    self.displayData = {};

    for i=1, #self.data do
        self.displayData[i] = self:retrieveDisplayDataFunc(self.data[i]);
    end
end

function ScrollTable:ApplyFilter(filterOn, checkedStatus)
    local filters = {

    }

    --if tContains(self.appliedFilters, filterOn) and not checkedStatus then

    self.appliedFilters[filterOn] = checkedStatus;

    for i=1, #self.displayData do
        local row = self.rows[i];
        row:ApplyFilters();
    end
end

-----------------------------------------------------------------------------------------------------------------------
--
-- MIXIN STUFF
--
-----------------------------------------------------------------------------------------------------------------------

function ScrollTable:newHybrid(table_settings, col_settings, row_settings)
    local self = {};
    setmetatable(self, ScrollTable); -- Set the metatable so we use ScrollTable's __index

    -- Set all of the important settings or default if they were not provided.
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

    self.ROW_HEIGHT = row_settings['height'] or 20
    self.ROW_WIDTH = row_settings['width'] or 300
    self.ROW_MULTI_SELECT = row_settings['multiSelect'] or false
    self.ROW_SELECT_ON = row_settings['indexOn'] or nil
    self.retrieveDataFunc = table_settings['retrieveDataFunc']
    self.retrieveDisplayDataFunc = table_settings['retrieveDisplayDataFunc']


    self.MAX_ROWS = (self.height / self.ROW_HEIGHT);

    self.COL_HEIGHT = col_settings['height'] or 14
    self.COL_WIDTH = col_settings['width'] or 100
    self.HEADERS = col_settings['headers']

    self.displayData = {};

    self.selected = {};
    self.lastSelect = nil;

    self.cols = {};
    self.data = {};

    -- Sort vars
    self.sortBy = nil;
    self.sortDir = nil;
    self.firstSort = col_settings['firstSort'] or nil;
    self.firstSortRan = false;

    -- Drag vars
    self.isDragging = false

    self.appliedFilters = {};

    self:RefreshData()

    -------------------------
    -- Setup the Frames
    -------------------------

    -- Create our base frame.
    self.frame = CreateFrame("Frame", self.name, self.parent)
    self.frame:EnableMouse(self.enableMouse)
    self.frame:SetMovable(self.movable)
    self.frame:SetSize(self.width, self.height)
    self.frame:SetHeight(self.height + (self.COL_HEIGHT * 2));
    self.frame:SetWidth(self.width)
    self.frame:SetPoint(self.anchor['point'], self.parent, self.anchor['rel_point_x'], self.anchor['rel_point_y'])

    -- Give the frame a visible background and border:
    self.frame:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    self.frame.parent = self

    -----------------
    -- Create the ScrollFrame

    local listScrollFrame = CreateFrame("ScrollFrame", "ListScrollFrame", self.frame, 'HybridScrollFrameTemplate')

    listScrollFrame:SetPoint("TOPLEFT", 0, -(self.COL_HEIGHT * 2))
    listScrollFrame:SetPoint("BOTTOMRIGHT", -30, 8)

    ----------------
    -- Create the slider
    local scrollBar = CreateFrame("Slider", 'scrollBar', listScrollFrame, 'HybridScrollBarTemplate')
    scrollBar:SetPoint("TOPLEFT", listScrollFrame, "TOPRIGHT", 1, -16)
    scrollBar:SetPoint("BOTTOMLEFT", listScrollFrame, "BOTTOMRIGHT", 1, 12)

    self.ListScrollFrame = listScrollFrame
    self.scrollChild = listScrollFrame.scrollChild;

    ----------------
    -- Set the on_ functions
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

    self.scrollChild:SetPoint("TOPLEFT", self.ListScrollFrame, "TOPLEFT", -0, 0);

    self:RefreshLayout();

    return self
end

function ScrollTable:RefreshLayout()
    local offset = HybridScrollFrame_GetOffset(self.ListScrollFrame);

    for i=1, #self.displayData do
        local row = self.rows[i]

        if i >= offset +1 and i <= offset + self.MAX_ROWS and not row.isFiltered then
            row:Show()
            if i == offset + 1 then
                row:SetPoint("TOPLEFT", self.ListScrollFrame, 8, 0)
            else
                row:SetPoint("TOPLEFT", self.rows[i-1], "BOTTOMLEFT")
            end
            self:CheckSelect(row, nil)
        else
            row:Hide()
        end
    end

    -- The last step is to ensure the scroll range is updated appropriately.
    -- Calculate the total height of the scrollable region (using the model
    -- size), and the displayed height based on the number of shown buttons.
    local buttonHeight = self.ROW_HEIGHT;
    local totalHeight = (#self.displayData * buttonHeight) + self.ROW_HEIGHT;
    local shownHeight = self.MAX_ROWS * buttonHeight;

    HybridScrollFrame_Update(self.ListScrollFrame, totalHeight, shownHeight);
end

-- OnLoad sets up the row & header structure for our hybridScroll. This should only be called once, ideally.
function ScrollTable:OnLoad()
    -- Create the item model that we'll be displaying.
    local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Button", "$parent_Row"..i, self.scrollChild)
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

        row:SetHighlightTexture(HIGHLIGHT_TEXTURE)
        row:SetPushedTexture(HIGHLIGHT_TEXTURE)
        row:SetScript("OnClick", function(r, clickType)
            self:CheckSelect(r, clickType)
        end)

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
            if row.dataObj then
                local dataObj = row.dataObj;
                if dataObj['class'] == 'Hunter' then
                    row.isFiltered = true;
                else
                    row.isFiltered = false;
                end
            end
        end

        for key, header in pairs(self.HEADERS) do
            local label = header['label']
            local col_name = '$parent' .. label
            local col = row:CreateFontString(col_name, 'OVERLAY', 'GameFontHighlightLeft')
            local getVal = header['getValueFunc']
            local val = (getVal ~= nil and row.dataObj ~= nil) and getVal(row.dataObj) or row.dataObj[label]

            col:SetJustifyH(header['point'])

            col:SetSize(self.COL_WIDTH, self.COL_HEIGHT)
            local col_point = header['point'] or 'LEFT'
            col:SetJustifyH(col_point)

            if type(val) == 'number' and val > 9999 then
                col:SetSpacing(0.5) -- For excessively large numbers. Decrease the letter spacing.
            end

            if key == 1 then
                col:SetPoint(col_point, row)
            else
                col:SetPoint("TOPLEFT", row.cols[key -1], "TOPRIGHT", 0, 0)

                if key == #self.HEADERS and col_point == 'RIGHT' then
                    col:SetPoint("TOPLEFT", row.cols[key -1], "TOPRIGHT", -10, 0)
                end
            end

            col:SetText(val)

            row.cols[key] = col;
        end

        rawset(t, i, row)
        return row
    end })
    local cols = setmetatable({}, { __index = function(t, i)
        local header = self.HEADERS[i] or {};
        local label = header['label'] or 'Test'
        local sortable = header['sortable'] or false
        local point = header['point'] or 'LEFT'
        local showSortDirection = header['showSortDirection'] or false
        local compare = header['compareFunc'];
        local font = header['font'] or "AchievementPointsFont"

        local col = CreateFrame("Button", "$parent_Col_" .. label, self.ListScrollFrame)

        local width = header['width'] or self.COL_WIDTH;

        col:SetHeight(self.COL_HEIGHT)
        col:SetWidth(width)

        if i == 1 then
            col:SetPoint("TOPLEFT", self.ListScrollFrame, -10, 20)
        else
            col:SetPoint("TOPLEFT", self.cols[i-1], "TOPRIGHT", 20, 0)
        end

        local fs = col:CreateFontString(col, "OVERLAY", font)
        fs:SetText(strupper(label))
        fs:SetPoint("CENTER")

        local fsLength = fs:GetWidth()

        col.arrow = nil;
        col.dir = nil;
        col.label = label
        col.compare = compare
        col.fontString = fs

        function col:ToggleArrow(show)
            if col.arrow ~= nil and show then
                col.arrow:Show()
            elseif col.arrow ~= nil and not show then
                col.arrow:Hide()
            end
        end

        if showSortDirection then
            local arrow = col:CreateTexture(nil, 'BACKGROUND')
            arrow:SetTexture(ARROW_TEXTURE)
            arrow:SetPoint('RIGHT', col, 0, -3)
            col.arrow = arrow;

            col:ToggleArrow(false)

            arrow:SetRotation(rotate_down)
        end

        if sortable then
            col:SetScript("OnClick", function()
                if col:GetParent():IsVisible() then
                    for key, column in pairs(self.cols) do
                        if key ~= i then
                            column.dir = nil;
                            column:ToggleArrow(false)
                        else
                            column:ToggleArrow(true)
                            self.sortBy = column.label
                        end
                    end

                    col.dir = (col.dir == nil or col.dir == 'ASC') and 'DESC' or 'ASC' -- Tenary

                    local deg = col.dir == 'DESC' and rotate_down or rotate_up
                    point = col.dir == 'DESC' and -3 or 2

                    -- Gives us uniform arrow spacing, based on label length.
                    -- Base is based off of length of "Name" and "Class" when they are uppercase.
                    local baseLength = 55
                    local arrow_x = floor((fsLength - baseLength) / 2 - 1)

                    if col.arrow ~= nil then
                        col.arrow:SetRotation(deg)
                        col.arrow:SetPoint('TOPRIGHT', col, 'TOPRIGHT', arrow_x, point)
                    end

                    self.sortDir = col.dir
                    table.sort(self.rows, col.compare)
                    self:RefreshLayout();
                end
            end)
        end

        col:Show()

        rawset(t, i, col)
        return col
    end})

    self.rows = rows
    self.cols = cols

    for i=1, #self.HEADERS do
        local col = self.cols[i]
        col:Show()
    end

    self.ListScrollFrame.buttons = self.rows;

    -- Bind the update field on the scrollframe to a function that'll update
    -- the displayed contents. This is called when the frame is scrolled.
    self.ListScrollFrame.update = function() self:RefreshLayout(); end

    -- OPTIONAL: Keep the scrollbar visible even if there's nothing to scroll.
    HybridScrollFrame_SetDoNotHideScrollBar(self.ListScrollFrame, true);
end

function ScrollTable:RemoveItem(index)
    table.remove(self.items, index);
    self:RefreshLayout();
end

pdkp_ScrollTableMixin = core.ScrollTable;