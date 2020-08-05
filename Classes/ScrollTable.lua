local _, core = ...;
local _G = _G;
local L = core.L;

local ScrollTable = core.ScrollTable;
local Row = core.ScrollTable.Row;

ScrollTable.__index = ScrollTable; -- Set the __index parameter to reference

local type, floor, strupper, pi = type, math.floor, strupper, math.pi

local CLOSE_BUTTON_TEXT = "|TInterface\\Buttons\\UI-StopButton:0|t"
local TRANSPARENT_BACKGROUND = "Interface\\TutorialFrame\\TutorialFrameBackground"
local SHROUD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
local HIGHLIGHT_TEXTURE = 'Interface\\QuestFrame\\UI-QuestTitleHighlight'
local SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
local ARROW_TEXTURE = 'Interface\\MONEYFRAME\\Arrow-Left-Up'

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

local function randomLetters(numLetters)
    local totTxt = ""
    for i = 1,numLetters do
        totTxt = totTxt..string.char(math.random(97,122))
    end
    return totTxt;
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

    self.ROW_HEIGHT = row_settings['height'] or 20
    self.ROW_WIDTH = row_settings['width'] or 300
    self.MAX_ROWS = row_settings['max_rows'] or 25
    self.ROW_MULTI_SELECT = row_settings['multiSelect'] or false

    self.COL_HEIGHT = col_settings['height'] or 14
    self.COL_WIDTH = col_settings['width'] or 100
    self.HEADERS = col_settings['headers']

    self.displayData = {};

    self.cols = {};
    self.data = {};

    self.sortBy = nil;
    self.sortDir = nil;

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
            local value = i + offset

            if value <= #s.displayData then
                -- There is a datum available to show.

                -- Get a local reference to the row to save
                -- two table lookups:
                local row = s.rows[i]

                for k=1, #s.HEADERS do
                    local col = row.cols[k]
                    local label = s.HEADERS[k]['label']
                    local val = s.displayData[value][label]
                    col:SetText(val)
                end
                row:Show()
            else
                -- We've reached the end of the data.
                -- Hide the row:
                s.rows[i]:Hide()
            end
        end
    end

      Refresh()
        for i=1, 100 do
            self.displayData[i] = {
                ['name']=randomLetters(math.random(10)),
                ['class']='Druid',
                ['dkp']=math.random(10000)
            }
        end
    end

    Refresh()

    ----------------------------------------------------------------
    -- Create the scroll bar:
    local bar = CreateFrame("ScrollFrame", "$parentScrollBar", self.frame, "FauxScrollFrameTemplate")

    self.frame.scrollBar = bar
    self.frame.scrollBar.parent = self

    bar:SetPoint("TOPLEFT", 0, -8)
    bar:SetPoint("BOTTOMRIGHT", -30, 8)

    -- Tell the scroll bar what to do when it's scrolled:
    bar:SetScript("OnVerticalScroll", function(sb, offset)
        -- These first two lines replace a call to the global
        -- FauxScrollFrame_OnVerticalScroll function, saving a
        -- global lookup and a function call.

        local scrollbar = getglobal(sb:GetName());

        --scrollbar:SetValue(offset)

        sb.offset = floor(offset / self.ROW_HEIGHT + .5)

        print(sb.offset)

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
        local compare = header['compareFunc'] or function(a,b) return a < b end

        local col = CreateFrame("Button", "$parent_Col_" .. label, self.frame)
        col:SetSize(self.COL_WIDTH, self.COL_WIDTH)

        if i == 1 then
            col:SetPoint("TOPLEFT", 0, -10)
        else
            col:SetPoint("TOPLEFT", self.cols[i-1], "TOPRIGHT", 35, 0)
        end

        local fs = col:CreateFontString(col, "OVERLAY", "AchievementPointsFont")
        fs:SetText(strupper(label))
        fs:SetPoint("CENTER")

        col.arrow = nil;
        col.dir = nil;
        col.label = label
        col.compare = compare

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

                    if col.arrow ~= nil then
                        col.arrow:SetRotation(deg)
                        col.arrow:SetPoint('RIGHT', col, 0, point)
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
        row:SetSize(self.ROW_WIDTH, self.ROW_HEIGHT)

        row.cols = {};
        row.dataObj = self.displayData[i];
        row.index = i
        row.selected = false

        for key, header in pairs(self.HEADERS) do
            local col = row:CreateFontString(row, 'OVERLAY', 'GameFontHighlightLeft')
            col:SetSize(self.COL_WIDTH, self.COL_HEIGHT)
            local point = header['point'] or 'LEFT'
            col:SetPoint(point)
            row.cols[key] = col;
        end

        if i == 0 then
            row:SetPoint("TOPLEFT", self.frame, 8, -16)
        else
            row:SetPoint("TOPLEFT", self.rows[i-1], "BOTTOMLEFT")
            row:SetHighlightTexture(HIGHLIGHT_TEXTURE)
            row:SetPushedTexture(HIGHLIGHT_TEXTURE)
            row:SetScript("OnClick", function(r)
                --print(self.index)
                --
                --local charObj = Guild:GetMemberByName(row.charObj['name'])
                --row.selected = not row.selected
                --print(row.selected)
            end)
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

    Refresh()
    self.frame:Update()

    return self
end