--[[
-- ALL FUNCTIONS IN THIS FILE ARE GLOBAL FUNCTIONS, DUE TO HOW TEMPLATES WORK. IDK IF I'M JUST DUMB OR CAN'T FIND OUT
-- HOW TO REFERENCE OBJECTS FROM THE TEMPLATE!!!
 ]]

local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;

local displayLimit = 26 -- the amount of rows we want to be shown on the table
local relPointY = 230 -- relative point for the col y offset
local relPointX = 15; -- relative point for the col x offset
local entryHeight = 20; -- Height of a single dkp entry in the table

local tableData = {} -- the visuaul data that is being displayed.
local tempTableData = {}; -- Temporary table data when search button is being displayed?

local filter_classes = {}
local textSearch;

local entry_template = "pdkp_dkp_entryTemplate";
local entry_name = "pdkp_dkp_entry";

-- Filters the tabledata based on what checkboxes are checked.
-- cbn (Checkbox_name)
function GUI:pdkp_dkp_table_filter_class(cbn)
    cbn = cbn:match("pdkp_(%a+)_checkbox") -- remove the 'pdkp_ & _checkbox from the string, for filtering purposes.
    cbn = (cbn:gsub("^%l", string.upper))  -- Make the first character uppercase (for consistency)

    local filterClass = filter_classes[cbn];
    if filterClass == nil then filter_classes[cbn] = true else filter_classes[cbn] = nil end
    pdkp_dkp_table_filter()
end

-- Sorts the table based on name[1], class[2] or dkp[3] values.
-- Seems to be an issue with displaying class & dkp, some values are duplicated in the list...
function GUI:pdkp_dkp_table_sort(sortBy)

    if core.sortBy == sortBy then
        core.sortDir = 'DESC';
        core.sortBy = nil;
    else
        core.sortDir = 'ASC';
        core.sortBy = sortBy;
    end

    local function compare(a,b)
        if core.sortDir == 'ASC' then
            return a[sortBy] > b[sortBy]
        else
            return a[sortBy] < b[sortBy]
        end
    end

    table.sort(tableData, compare) -- call the compare function on table PDKP.data
    pdkp_dkp_scrollbar_Update()
end

-- runs everytime the scroll bar positioning moves.
function pdkp_dkp_scrollbar_Update()

    local lineplusoffset; -- an index into our data calculated from the scroll offset
    local maxEntries = #tableData;
    FauxScrollFrame_Update(pdkp_dkp_scrollbar,maxEntries,displayLimit,entryHeight);

    for line=1,displayLimit do

        lineplusoffset = line + FauxScrollFrame_GetOffset(pdkp_dkp_scrollbar);
        local charObj = {}
        if lineplusoffset <= #tableData then charObj = tableData[lineplusoffset] end

        local cols = {'name', 'class', 'dkpTotal' }
        local entry = getglobal('pdkp_dkp_entry' .. line);

        entry.char = charObj

        if GUI.selected[charObj.name] then
            entry.customTexture:Show();
        elseif GUI.GetSelectedCount() > 0 then
            entry.customTexture:Hide();
        end

        for col=1, #cols do
            local name =  entry_name .. line .. "_col" .. col
            local textVal = charObj[cols[col]]
            local entryCol = getglobal(name);

            if lineplusoffset <= #tableData then
                if col == 2 then
                    local textColor = charObj["class_color"].hex
                    entryCol:SetText(Util:FormatFontTextColor(textColor, textVal))
                else
                    entryCol:SetText(textVal)
                end
                entryCol:Show();
            else
                entryCol:Hide();
            end
        end
    end
    GUI:UpdateSelectedEntriesLabel()
end

function GUI:GetTableDisplayData()
    tableData = PDKP:GetAllTableData();
    return tableData;
end

function GUI:GetDisplayDataCount()
    return #tableData;
end

-- Runs all of the initializing methods for the scroll bar
function pdkp_init_scrollbar()

    GUI:GetTableDisplayData()
    pdkp_setup_scrollbar_cols()
    GUI:pdkp_dkp_table_sort('dkpTotal')
    pdkp_dkp_scrollbar:Show()
    pdkp_dkp_scrollbar_Update()
    pdkp_dkp_table_filter()
end

-- Sets up the scroll bar columns & rows
function pdkp_setup_scrollbar_cols()
    for row=1, displayLimit do
        local b = CreateFrame("Button", entry_name .. row, pdkpCoreFrame, entry_template)

        if row == 1 then
            b:SetPoint("LEFT", pdkp_dkp_scrollbar, "LEFT", relPointX, relPointY)
        else
            local prevName = "pdkp_dkp_entry" .. row -1
            b:SetPoint("TOPLEFT", prevName, "BOTTOMLEFT")
        end
        GUI:CreateEntryHistoryFrame(b);
    end
end

---------------------------
--History Frame Functions--
---------------------------

-- Creates the history frame popup for the particular item.
function GUI:CreateEntryHistoryFrame(b)
    local historyName = b:GetName() .. '_history';
    local frame=CreateFrame("Frame",historyName,b, nil);
    frame:SetSize(270,120)
    frame:SetPoint("RIGHT", b, "RIGHT", 285, 0);
    frame:SetFrameStrata("HIGH");

    local border=frame:CreateTexture(nil,"BACKGROUND")
    border:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    border:SetPoint("TOPLEFT",-2,2)
    border:SetPoint("BOTTOMRIGHT",2,-2)
    border:SetVertexColor(0.85, 0.85, 0.85, .5) -- half-alpha light grey

    local body=frame:CreateTexture(nil,"ARTWORK")
    body:SetTexture("Interface\\AddOns\\PantheonDKP\\Media\\PDKPFrame-Middle.tga")
    body:SetAllPoints(frame)

    for i=1, 10 do
        local font = "GameFontNormalSmall"
        local history;
        if i == 1 then
            font="GameFontHighlightLarge"
            history = frame:CreateFontString('pdkp_history_label', "ARTWORK", font);
            history:SetText('')
            history:SetPoint("CENTER", 0, 50);
            frame.historyTitle = history;
        else
            local lineName = historyName .. '_line_' .. i -1;
            history=frame:CreateFontString(lineName, "ARTWORK", font)
            history:SetText('')
            history:SetPoint("TOPLEFT", 5, i*-10);

            local dkpChange = frame:CreateFontString(lineName .. '_change', "ARTWORK", font);
            dkpChange:SetText('');
            dkpChange:SetPoint("TOPRIGHT", -5, i*-10);
        end
    end

    b.historyFrame = frame;
    frame:Hide();
    frame:SetScript("OnShow", function(self)
        GUI:UpdateHistoryFrame(self);
    end)
end

function GUI:UpdateHistoryFrame(historyFrame)
    local historyName = historyFrame:GetName()
    local buttonName = string.gsub(historyName, '_history', '');

    local b = getglobal(buttonName);

    local dkpHistory = DKP.dkpDB.history[b.char.name]

    if dkpHistory == nil or #dkpHistory == 0 then -- There is no history to show, hide the frame and end function.
        historyFrame:Hide()
        return
    end

    local charName = Util:FormatFontTextColor(Util:GetClassColor(b.char.class), b.char.name);
    local title = Util:FormatFontTextColor('FFBA49', 'Recent History for ');

    historyFrame.historyTitle:SetText(title .. charName);

    local lineCount = 1;
    for i = #dkpHistory, 1, -1 do
        local lineName = b:GetName() .. '_history_line_' .. lineCount

        local raid = dkpHistory[i]['raid'];
        if raid == 'Onyxia\'s Lair' then raid = 'Molten Core'; end-- Set the default since MC & Ony are combined.

        local line = getglobal(lineName);
        line:SetText(dkpHistory[i]['text'])

        local change = getglobal(lineName .. '_change')
        change:SetText(dkpHistory[i]['dkpChangeText'])

        lineCount = lineCount + 1;

        if raid and raid ~= DKP.dkpDB.currentDB then -- Don't show history from other raids.
            if lineCount > 1 then lineCount = lineCount -1; end
            line:SetText('');
            change:SetText('');
        end
        if lineCount >= 9 then break end; -- Stop at 9 items in the list.
    end

    if lineCount == 1 then historyFrame:Hide() end; -- A catch if there isn't history in the frame.
end



function GUI:SearchInputUpdated(text)
    textSearch = text;
    pdkp_dkp_table_filter()
end

-- Search on Name, Class & DKP attributes
function GUI:SearchOnAttributes(char)
    if Util:StringsMatch(char.name, textSearch) then return true; -- Search on name
    elseif Util:StringsMatchInOrder(char.class, textSearch) then return true -- search on Class
    elseif Util:StringsMatchInOrder(tostring(char.dkpTotal), textSearch) then return true; -- search on DKP
    else return false;
    end
end

function GUI:UpdateOnlineStatus(status)
    core.filterOffline = status

    local onlineMembers = Guild:GetGuildData(true)

    if #onlineMembers == 0 then return end; -- Just incase something weird happens.

    for i=1, PDKP:GetDataCount() do
        local char = PDKP.data[i];

        for j=1, #onlineMembers do
            local onlineChar = onlineMembers[j];

            if onlineChar['name'] == char['name'] then
                char['online'] = true;
                break;
            end
            char['online'] = false;
        end
    end
end

-- Generic catch all for the filter functions.
function pdkp_dkp_table_filter()
    local newTableData = {}
    local selectedFilterChecked = GUI:GetSelectedFilterStatus()
    local hasSearch = not Util:IsEmpty(textSearch);

    -- filter out based on online status
    for i=1, PDKP:GetDataCount() do
        local char = PDKP.data[i]

        local showingOffline = core.filterOffline == nil or core.filterOffline == false;
        local onlineStatusMatch = char["online"] == not showingOffline
        local isSelected = false;
        local searchFound = false;

        if selectedFilterChecked and GUI.selected[char.name] then isSelected = true; end
        if hasSearch then searchFound = GUI:SearchOnAttributes(char) end

        local selectStatusMatch = selectedFilterChecked == isSelected;
        local searchStatusMatch = searchFound == hasSearch;
        local sliderValsMatch = GUI.sliderVal <= char['dkpTotal'];

        -- This is really complicated... I should figure out a better way to handle this...
        if (showingOffline or onlineStatusMatch) -- If online selected, the status matches.
                and (selectStatusMatch) -- If selections, the entry is in the array.
                and (searchStatusMatch) -- If search, the entry matches the search
                and (sliderValsMatch) and -- If slider, the entry's dkp is > sliderVal
                not filter_classes[char['class']] then -- Entries class isn't deselected.
            table.insert(newTableData, char)
        end
    end
    tableData = newTableData;
    pdkp_dkp_scrollbar_Update()
end

-- Made for the scrollbar to retrieve the item height, for consistency & simplicities sake.
function getItemHeight()
    return entryHeight;
end