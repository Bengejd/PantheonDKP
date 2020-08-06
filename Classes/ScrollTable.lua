local _, core = ...;
local _G = _G;
local L = core.L;

local ScrollTable = core.ScrollTable;
local Util = core.Util;

ScrollTable.__index = ScrollTable; -- Set the __index parameter to reference

local type, floor, strupper, pi = type, math.floor, strupper, math.pi
local tinsert, tremove = tinsert, tremove

local HIGHLIGHT_TEXTURE = 'Interface\\QuestFrame\\UI-QuestTitleHighlight'
local SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
local ARROW_TEXTURE = 'Interface\\MONEYFRAME\\Arrow-Left-Up'
local ROW_HIGHLIGHT = 'Interface\\Artifacts\\_Artifacts-DependencyBar-BG'
local BAR_TEXTURE = 'Interface\\Artifacts\\ArtifactsVertical'

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

function ScrollTable:GetNewLastSelect(row, objIndex)
    local isSelected, selectIndex = tfind(self.selected, objIndex)
    local previousLastSelect = self.lastSelect

    if #self.selected == 0 then -- Nothing is selected anymore.
        self.lastSelect = nil;
        return
    else
        self.lastSelect = objIndex;
    end

    print('Setting new lastSelect')

    if self.lastSelect == row.realIndex and #self.selected >= 1 then

    end
end

function ScrollTable:RowClicked(row, objIndex)
    local isSelected, _ = tfind(self.selected, objIndex)
    self:ClearSelected()
    if not isSelected then
        tinsert(self.selected, objIndex)
    end
end

function ScrollTable:RowShiftClicked()

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
            self:RowShiftClicked()
        else -- Control or Regular Click.
            self:UpdateSelectStatus(objIndex, selectIndex, isSelected, not hasCtrl)
        end
        self:GetNewLastSelect(row, objIndex)
        return self.frame:Update()
    end

    local isSelected, selectIndex = tfind(self.selected, objIndex)
    self:HighlightRow(row, isSelected)
end

-- Refreshes the data that we are utilizing.
function ScrollTable:Refresh()
    self.data = self.retrieveDataFunc();
    self.displayData = {};

    for i=1, #self.data do
        self.displayData[i] = self:retrieveDisplayDataFunc(self.data[i]);
    end

    if not self.firstSortRan then
        self.cols[self.firstSort]:Click()
    end

    self.frame:Update()
end

function ScrollTable:new(table_settings, col_settings, row_settings)
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
    self.retrieveDataFunc = table_settings['retrieveDataFunc']
    self.retrieveDisplayDataFunc = table_settings['retrieveDisplayDataFunc']

    self.ROW_HEIGHT = row_settings['height'] or 20
    self.ROW_WIDTH = row_settings['width'] or 300
    self.MAX_ROWS = row_settings['max_rows'] or 25
    self.ROW_MULTI_SELECT = row_settings['multiSelect'] or false
    self.ROW_SELECT_ON = row_settings['indexOn'] or nil

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

    -- Create our base frame.
    self.frame = CreateFrame("Frame", self.name, self.parent)
    self.frame:EnableMouse(self.enableMouse)
    self.frame:SetMovable(self.movable)
    self.frame:SetSize(self.width, self.height)
    self.frame:SetPoint(self.anchor['point'], self.anchor['rel_point_x'], self.anchor['rel_point_y'])

    -- Give the frame a visible background and border:
    self.frame:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    self.frame.parent = self

    ----------------------------------------------------------------
    -- Define a function that we'll call later to update the datum
    -- displayed in each row:

    function self.frame:Update()

        local s = self.parent;
        -- Using method notation (object:function) means that the
        -- object (in this case, our frame) is available within the
        -- function's scope via the variable "self".

        -- Call the FauxScrollFrame template's Update function, with
        -- the relevant parameters:
        FauxScrollFrame_Update(s.frame.scrollBar, #s.displayData, s.MAX_ROWS, s.ROW_HEIGHT)
        -- #1 is a reference to the scroll bar frame.
        -- #2 is the total number of data available to be shown.
        -- #3 is how many rows of data can be displayed at once.
        -- #4 is the height of each row.

        -- Now figure out which datum to show in each row,
        -- and show it:
        local offset = FauxScrollFrame_GetOffset(s.frame.scrollBar)

        for i = 1, s.MAX_ROWS do
            local realIndex = i + offset

            if realIndex <= #s.displayData then
                -- There is a datum available to show.

                -- Get a local reference to the row to save
                -- two table lookups:
                local row = s.rows[i]
                row.realIndex = realIndex
                row.dataObj = s.displayData[realIndex]

                for k=1, #s.HEADERS do
                    local col = row.cols[k]
                    local label = s.HEADERS[k]['label']
                    local getVal = s.HEADERS[k]['getValueFunc']
                    local val = (getVal ~= nil and row.dataObj ~= nil) and getVal(row.dataObj) or row.dataObj[label]

                    if type(val) == type(0) and val > 9999 then
                        col:SetSpacing(0.5) -- For excessively large numbers. Decrease the letterSpacing.
                    end

                    col:SetText(val)
                end
                s:CheckSelect(row, nil, realIndex)

                row:Show()
            else
                -- We've reached the end of the data.
                -- Hide the row:
                s.rows[i]:Hide()
            end
        end
    end

    ----------------------------------------------------------------
    -- Create the scroll bar:
    local bar = CreateFrame("ScrollFrame", "$parentScrollBar", self.frame, "FauxScrollFrameTemplate")

    -- Create a right hand divider for the table & the bar. Aesthetics mostly.
    local rightBorder = bar:CreateTexture(nil, 'BACKGROUND')
    rightBorder:SetTexture(BAR_TEXTURE)
    rightBorder:SetWidth(6)
    rightBorder:SetPoint('TOPRIGHT', bar, 'TOPRIGHT', 0, -29)
    rightBorder:SetPoint('BOTTOMRIGHT', bar, 'BOTTOMRIGHT', 0, -5)

    self.frame.scrollBar = bar
    self.frame.scrollBar.parent = self

    bar:SetPoint("TOPLEFT", 0, -8)
    bar:SetPoint("BOTTOMRIGHT", -30, 8)

    -- Tell the scroll bar what to do when it's scrolled:
    bar:SetScript("OnVerticalScroll", function(sb, offset)
        -- These first two lines replace a call to the global
        -- FauxScrollFrame_OnVerticalScroll function, saving a
        -- global lookup and a function call.

        sb.offset = floor(offset / self.ROW_HEIGHT + .5)

        -- FauxScrollFrame_OnVerticalScroll can also call an update
        -- function if we pass it one, but since we aren't using it,
        -- we should just call the function ourselves:
        self.frame:Update()
    end)

    bar:SetScript("OnShow", function()
        self.frame:Update()
    end)

    bar:Show()

    ----------------------------------------------------------------
    -- Create the individual cols/rows:

    -- I'm using a metatable here for efficiency (rows are not created
    -- until they are needed) and convenience (I don't have
    -- to check if a row exists yet and create one manually).

    local cols = setmetatable({}, { __index = function(t, i)
        local header = self.HEADERS[i] or {};
        local label = header['label'] or 'Test'
        local sortable = header['sortable'] or false
        local point = header['point'] or 'LEFT'
        local showSortDirection = header['showSortDirection'] or false
        local compare = header['compareFunc'];
        local font = header['font'] or "AchievementPointsFont"

        local col = CreateFrame("Button", "$parent_Col_" .. label, self.frame)

        local width = header['width'] or self.COL_WIDTH;

        col:SetHeight(self.COL_HEIGHT)
        col:SetWidth(width)

        if i == 1 then
            col:SetPoint("TOPLEFT", -6, -10)
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
                    table.sort(self.displayData, col.compare)
                    self.frame:Update()
                end
            end)
        end

        col:Show()

        rawset(t, i, col)
        return col
        end})
    local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Button", "$parent_Row"..i, self.frame)
        row:SetHeight(self.ROW_HEIGHT)
        row:SetWidth(self.ROW_WIDTH)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp");
        row:RegisterForDrag("LeftButton")

        row:SetScript("OnDragStart", function(r, ...)
            self.isDragging = true
            self:CheckSelect(r, 'LeftButton')
        end)

        row:SetScript("OnDragStop", function(r, ...)
            self.isDragging = false
        end)

        row:SetScript("OnReceiveDrag", function(r)
            print(r.dataObj['name'])
        end)

        row:SetScript("OnEnter", function(r)
            if not self.isDragging then return end

            print(r.dataObj['name'])
        end)

        row.cols = {};
        row.index = i
        row.realIndex = nil;
        row.selectOn = self.ROW_SELECT_ON
        row.dataObj = nil;

        if i == 0 then
            row:SetPoint("TOPLEFT", self.frame, 10, -16)
        else
            row:SetPoint("TOPLEFT", self.rows[i-1], "BOTTOMLEFT")
            row:SetHighlightTexture(HIGHLIGHT_TEXTURE)
            row:SetPushedTexture(HIGHLIGHT_TEXTURE)
            row:SetScript("OnClick", function(r, clickType)
                self:CheckSelect(r, clickType)
            end)

            local sep = row:CreateTexture(nil, 'BACKGROUND')
            sep:SetTexture(ROW_HIGHLIGHT)
            sep:SetPoint("BOTTOMLEFT", row, 0, -1, self.rows[i-1], "BOTTOMRIGHT")
            sep:SetHeight(3)
            sep:SetWidth(self.ROW_WIDTH)

            if i == 1 then
                local topSep = row:CreateTexture(nil, 'BACKGROUND')
                topSep:SetTexture(ROW_HIGHLIGHT)
                topSep:SetPoint("TOPLEFT", row, 0, 0, row, "TOPRIGHT")
                topSep:SetHeight(3)
                topSep:SetWidth(self.ROW_WIDTH)
            end
        end

        for key, header in pairs(self.HEADERS) do
            local col = row:CreateFontString(row, 'OVERLAY', 'GameFontHighlightLeft')
            col:SetSize(self.COL_WIDTH, self.COL_HEIGHT)
            local point = header['point'] or 'LEFT'
            col:SetJustifyH(point)

            if key == 1 then
                col:SetPoint(point, row)
            else
                col:SetPoint("TOPLEFT", row.cols[key -1], "TOPRIGHT", 0, 0)

                if key == #self.HEADERS and point == 'RIGHT' then
                    col:SetPoint("TOPLEFT", row.cols[key -1], "TOPRIGHT", -10, 0)
                end
            end

            row.cols[key] = col;
        end

        rawset(t, i, row)
        return row
    end })

    self.cols = cols
    self.rows = rows

    for i=1, #self.HEADERS do
        local col = self.cols[i]
        col:Show()
    end

    return self
end