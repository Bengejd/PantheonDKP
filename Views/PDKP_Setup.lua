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
local pdkp_frame = nil
local PlaySound = PlaySound

local CLOSE_BUTTON_TEXT = "|TInterface\\Buttons\\UI-StopButton:0|t"
local TRANSPARENT_BACKGROUND = "Interface\\TutorialFrame\\TutorialFrameBackground"
local PDKP_TEXTURE_BASE = "Interface\\Addons\\PantheonDKP\\Media\\Main_UI\\PDKPFrame-"
local SHROUD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
local HIGHLIGHT_TEXTURE = 'Interface\\QuestFrame\\UI-QuestTitleHighlight'
local SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
local ARROW_TEXTURE = 'Interface\\MONEYFRAME\\Arrow-Left-Up'

local function setMovable(f)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag('LeftButton')
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

local function createCloseButton(f, mini)
    local template = mini and 'pdkp_miniButton' or 'UIPanelButtonTemplate'
    local b = CreateFrame("Button", '$parentCloseButton',  f, template)
    b:SetText(CLOSE_BUTTON_TEXT)
    b:SetParent(f)
    b:SetScript("OnClick", function(self) self:GetParent():Hide() end)
    return b
end

function Setup:MainUI()
    local f = CreateFrame("Frame", "pdkp_frame", UIParent)
    f:SetFrameStrata("LOW")

    f:SetWidth(742) -- Set these to whatever height/width is needed
    f:SetHeight(682) -- for your Texture

    local function createTextures(tex)
        local x = tex['x'] or 0
        local y = tex['y'] or 0

        local t = f:CreateTexture(nil, "BACKGROUND")
        t:SetTexture(PDKP_TEXTURE_BASE .. tex['file'])
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

    local b = createCloseButton(f, false)
    b:SetSize(22, 25) -- width, height
    b:SetPoint("TOPRIGHT", -2, -10)

    -- Submit Button

    local bc = CreateFrame("Button")
    bc:SetScript("OnClick", function(self, arg1)
        print(arg1)
    end)
    --bc:Click("foo bar") -- will print "foo bar" in the chat frame.
    --bc:Click("blah blah") -- will print "blah blah" in the chat frame.

    pdkp_frame = f

    Setup:ShroudingBox()
    Setup:Scrollbar()
    Setup:ScrollHeaders()
end

function Setup:ShroudingBox()
    local f = CreateFrame("Frame", "pdkp_shroud_frame", UIParent)
    f:SetFrameStrata("HIGH")
    f:SetPoint("BOTTOMLEFT")
    f:SetHeight(200)
    f:SetWidth(200)

    f:SetBackdrop( {
        bgFile = TRANSPARENT_BACKGROUND,
        edgeFile = SHROUD_BORDER, tile = true, tileSize = 64, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    });

    setMovable(f)

    -- mini close button
    local b = createCloseButton(f, true)
    b:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -6, -6)

    -- title
    local t = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    t:SetPoint("TOPLEFT", 5, -10)
    t:SetPoint("TOPRIGHT", -10, -30)
    t:SetText("PDKP Shrouding")
    t:SetParent(f)

    f:Show()
end

function Setup:Scrollbar()
    ----------------------------------------------------------------
    -- Set up some constants (really just variables, except we call
    -- them "constants" because we will never change their values,
    -- only read them) to keep track of values we'll use repeatedly:

    local ROW_HEIGHT = 20   -- How tall is each row?
    local ROW_WIDTH = 300
    local MAX_ROWS = 25      -- How many rows can be shown at once?
    local REL_POINT_Y = -100 -- relative point for the col y offset
    local REL_POINT_X = 20; -- relative point for the col x offset
    local MAX_VALUE = #Guild.members

    local COL_CONSTANTS = {
        COL_HEIGHT = 14,
        COL_WIDTH = 100,

        [1]= {
            label='name',
            point='LEFT'
        },
        [2] = {
            label='class',
            point='CENTER',
        },
        [3] = {
            label='dkp.Molten Core.total',
            point='RIGHT',
        }
    }

    local FRAME_HEIGHT = 540
    local FRAME_WIDTH = 350

    -- Create the frame:
    local frame = CreateFrame("Frame", "pdkp_scrollbar", pdkp_frame)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("TOPLEFT", REL_POINT_X, REL_POINT_Y)

    -- Give the frame a visible background and border:
    frame:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    ----------------------------------------------------------------
    -- Define a function that we'll call later to update the datum
    -- displayed in each row:

    function frame:Update()
        --local visible_rows = 0;
        --for i=1, #Guild.memberNames do
        --    local member = Guild.members[Guild.memberNames[i]]
        --    if member:ShouldShow() then visible_rows = visible_rows + 1 end
        --end

        -- Using method notation (object:function) means that the
        -- object (in this case, our frame) is available within the
        -- function's scope via the variable "self".

        -- Call the FauxScrollFrame template's Update function, with
        -- the relevant parameters:
        FauxScrollFrame_Update(self.scrollBar, MAX_VALUE, MAX_ROWS, ROW_HEIGHT)
        -- #1 is a reference to the scroll bar frame.
        -- #2 is the total number of data available to be shown.
        -- #3 is how many rows of data can be displayed at once.
        -- #4 is the height of each row.

        -- Now figure out which datum to show in each row,
        -- and show it:
        local offset = FauxScrollFrame_GetOffset(self.scrollBar)
        --local max_rows = visible_rows
        --if max_rows > MAX_ROWS then max_rows = MAX_ROWS end

        for i = 1, MAX_ROWS do
            local value = i + offset

            if value <= MAX_VALUE then
                -- There is a datum available to show.

                -- Get a local reference to the row to save
                -- two table lookups:
                local row = self.rows[i]
                -- Fill in the row with the datum:
                local memberName = Guild.memberNames[value]
                local charObj = Guild.members[memberName]

                if charObj:ShouldShow() then
                    for k=1, 3 do
                        local col = row.cols[k]
                        local label = COL_CONSTANTS[k]['label']
                        local val = charObj[label]
                        if k == 3 then val = charObj:GetDKP(nil, 'total') end
                        col:SetText(val)
                    end
                    row:Show()
                else
                    row:Hide()
                end
            else
                -- We've reached the end of the data.
                -- Hide the row:
                self.rows[i]:Hide()
            end
        end
    end

    function frame:FilterTable()

    end

    ----------------------------------------------------------------
    -- Create the scroll bar:

    local bar = CreateFrame("ScrollFrame", "$parentScrollBar", frame, "FauxScrollFrameTemplate")
    bar:SetPoint("TOPLEFT", 0, -8)
    bar:SetPoint("BOTTOMRIGHT", -30, 8)

    -- Tell the scroll bar what to do when it's scrolled:
    bar:SetScript("OnVerticalScroll", function(self, offset)
        print(offset)
        -- These first two lines replace a call to the global
        -- FauxScrollFrame_OnVerticalScroll function, saving a
        -- global lookup and a function call.
        local scrollbar = getglobal(self:GetName().."ScrollBar");
        scrollbar:SetValue(offset)
        self.offset = math.floor(offset / ROW_HEIGHT + .5)

        -- FauxScrollFrame_OnVerticalScroll can also call an update
        -- function if we pass it one, but since we aren't using it,
        -- we should just call the function ourselves:
        frame:Update()
    end)

    bar:SetScript("OnShow", function()
        frame:Update()
    end)

    frame.scrollBar = bar

    ----------------------------------------------------------------
    -- Create the individual rows:

    -- I'm using a metatable here for efficiency (rows are not created
    -- until they are needed) and convenience (I don't have
    -- to check if a row exists yet and create one manually).

    -- I don't feel like writing out a long explanation of how this
    -- works right now; feel free to look at the "How to localize an
    -- addon" page on my author portal for a more detailed explanation
    -- of how a metatable like this works. If you don't care how it
    -- works, feel free to use it anyway. :)
    local header_names = {'name', 'class', 'dkp'}

    local headers = setmetatable({}, { __index = function(t, i)
        local col = CreateFrame("Button", "$parentCol"..i, frame)
        col:SetSize(75, 14)

        if i == 1 then
            col:SetPoint("TOPLEFT", 0, -10)
        else
            col:SetPoint("TOPLEFT", frame.headers[i-1], "TOPRIGHT", 35, 0)
        end

        local fs = col:CreateFontString(col, 'OVERLAY', 'AchievementPointsFont')
        fs:SetText(strupper(header_names[i]))
        fs:SetPoint("CENTER")

        col.dir = nil

        local arrow = col:CreateTexture(nil, 'BACKGROUND')

        arrow:SetTexture(ARROW_TEXTURE)
        arrow:SetPoint('RIGHT', col, 5, -3)
        col.arrow = arrow

        local rotate_up = (math.pi / 180) * 270
        local rotate_down = (math.pi / 180) * 90

        arrow:Hide()

        arrow:SetRotation(rotate_down)

        col:SetScript('OnClick', function(self)
            if self:GetParent():IsVisible() then
                local cols = self:GetParent().headers

                for key, c in pairs(cols) do
                    if key ~= i then
                        c.dir = nil
                        c.arrow:Hide()
                    else
                        c.arrow:Show()
                        GUI.sortBy = header_names[key]
                    end
                end

                col.dir = (col.dir == nil or col.dir == 'ASC') and 'DESC' or 'ASC' -- Tenary
                local deg = col.dir == 'DESC' and rotate_down or rotate_up
                local point = col.dir == 'DESC' and -3 or 2
                self.arrow:SetRotation(deg)
                arrow:SetPoint('RIGHT', col, 5, point)

                GUI.sortDir = col.dir

                Guild:SortBy(header_names[i], col.dir)
                frame:Update()
            end
        end)
        rawset(t, i, col)
        return col
    end})

    function frame:setupHeaders()
        for i=1, 3 do
            local header = self.headers[i]
            header:Show()
        end
    end

    local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Button", "$parentRow"..i, frame)
        row:SetSize(ROW_WIDTH, ROW_HEIGHT)

        row.cols = {};
        row.charObj = nil;
        row.index = i
        row.selected = false

        for k=1, 3 do
            local col = row:CreateFontString(row, 'OVERLAY', 'GameFontHighlightLeft')
            col:SetSize(COL_CONSTANTS['COL_WIDTH'], COL_CONSTANTS['COL_HEIGHT'])
            col:SetPoint(COL_CONSTANTS[k]['point'])
            row.cols[k] = col;
        end

        if i == 0 then
            row:SetPoint("TOPLEFT", frame, 8, -16)
        else
            row:SetPoint("TOPLEFT", frame.rows[i-1], "BOTTOMLEFT")
            row:SetHighlightTexture(HIGHLIGHT_TEXTURE)
            row:SetPushedTexture(HIGHLIGHT_TEXTURE)
            row:SetScript('OnClick', function(self)
                print(self.index)

                local charObj = Guild:GetMemberByName(row.charObj['name'])
                row.selected = not row.selected
                print(row.selected)
            end)
        end

        rawset(t, i, row)
        return row
    end })

    frame.rows = rows
    frame.headers = headers

    frame:setupHeaders()
    frame:Update()
end

function Setup:ScrollHeaders()

end

