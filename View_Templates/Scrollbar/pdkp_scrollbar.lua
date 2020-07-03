--[[
-- ALL FUNCTIONS IN THIS FILE ARE GLOBAL FUNCTIONS, DUE TO HOW TEMPLATES WORK. IDK IF I'M JUST DUMB OR CAN'T FIND OUT
-- HOW TO REFERENCE OBJECTS FROM THE TEMPLATE!!!
 ]]

local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Raid = core.Raid;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Member = core.Member;

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
function GUI:pdkp_dkp_table_filter_class(cbn, all)
    cbn = cbn:match("pdkp_(%a+)_checkbox") -- remove the 'pdkp_ & _checkbox from the string, for filtering purposes.
    cbn = (cbn:gsub("^%l", string.upper))  -- Make the first character uppercase (for consistency)

    local filterClass = filter_classes[cbn];
    if filterClass == nil then filter_classes[cbn] = true
    else filter_classes[cbn] = nil end

    if all then filter_classes[cbn] = nil end

    if filter_classes[cbn] == true and all == nil then
       _G['pdkp_all_classes']:SetChecked(false)
    end

    pdkp_dkp_table_filter()
end

-- Sorts the table based on name[1], class[2] or dkp[3] values.
-- Seems to be an issue with displaying class & dkp, some values are duplicated in the list...
function GUI:pdkp_dkp_table_sort(sortBy)
    if core.defaults.db.sortBy == sortBy then
        core.defaults.db.sortDir = 'DESC';
        core.defaults.db.sortBy = nil;
    else
        core.defaults.db.sortBy = sortBy;
        core.defaults.db.sortDir = 'ASC';
    end

    local function compare(a,b)
        if a == 0 and b == 0 then return end

        if core.defaults.db.sortDir == 'ASC' then
            return a[sortBy] > b[sortBy]
        else
            return a[sortBy] < b[sortBy]
        end
    end

    local currentRaid = DKP:GetCurrentDatabase()

    local function compareDKP(a,b)
        if core.defaults.db.sortDir == 'DESC' then
            return a.dkp[currentRaid].total > b.dkp[currentRaid].total
        else
            return a.dkp[currentRaid].total < b.dkp[currentRaid].total
        end
    end

    if sortBy == 'dkpTotal' then
        table.sort(tableData, compareDKP)
    else
        table.sort(tableData, compare) -- call the compare function on table PDKP.data
    end

    pdkp_dkp_scrollbar_Update()
end

function GUI:UpdateVisualDKP(sentMember, raid)
--    local member = Guild.members[sentMember.name];
    local dkp = sentMember:GetDKP(raid, 'total') -- Get the new DKP totals.
    for i=1, #tableData do
        local charObj = tableData[i]
        if charObj['name'] == sentMember.name then
            charObj.dkp[raid].total = dkp
            break;
        end
    end
end

-- runs everytime the scroll bar positioning moves.
function pdkp_dkp_scrollbar_Update(forceHide)

    local lineplusoffset; -- an index into our data calculated from the scroll offset
    local maxEntries = #tableData;
    FauxScrollFrame_Update(pdkp_dkp_scrollbar,maxEntries,displayLimit,entryHeight);

    local currentRaid = DKP:GetCurrentDatabase();

    for line=1,displayLimit do

        lineplusoffset = line + FauxScrollFrame_GetOffset(pdkp_dkp_scrollbar);
        local charObj = {}
        if lineplusoffset <= #tableData then charObj = tableData[lineplusoffset] end

        local cols = {'name', 'class', 'dkpTotal' }
        local entry = getglobal('pdkp_dkp_entry' .. line);

        entry.char = charObj

        if forceHide == true then
            entry.customTexture:Hide();
        elseif GUI.selected[charObj.name] then
            entry.customTexture:Show();
        elseif GUI.GetSelectedCount() > 0 then
            entry.customTexture:Hide();
        end

        for col=1, #cols do
            local name =  entry_name .. line .. "_col" .. col
            local textVal = charObj[cols[col]]
            local entryCol = _G[name];

            if lineplusoffset <= #tableData then
                if col == 2 then
                    entryCol:SetText(charObj.coloredClass)
                elseif col == 3 then
                    local member = Guild.members[charObj.name]
                    if member and member.dkp then
                        entryCol:SetText(member.dkp[currentRaid].total)
                    else
                        entryCol:SetText(0)
                    end
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

function GUI:GetTableDisplayData(noQuery)
    if noQuery then return tableData; end
    tableData = Guild:GetMembers();
    return tableData;
end

function GUI:GetDisplayDataCount()
    return #tableData;
end

-- Runs all of the initializing methods for the scroll bar
function pdkp_init_scrollbar()
    GUI:GetTableDisplayData()
    pdkp_setup_scrollbar_cols()
    pdkp_dkp_scrollbar:Show()
    pdkp_dkp_scrollbar_Update()
    pdkp_dkp_table_filter()
end

-- Sets up the scroll bar columns & rows
function pdkp_setup_scrollbar_cols()
    for row=1, displayLimit do
        local b = CreateFrame("Button", entry_name .. row, pdkpCoreFrame, entry_template)
        if  row == 1 then b:SetPoint("LEFT", pdkp_dkp_scrollbar, "LEFT", relPointX, relPointY)
        else
            local prevName = entry_name .. row - 1;
            b:SetPoint("TOPLEFT", prevName, "BOTTOMLEFT")
        end
    end
end

---------------------------
--History Frame Functions--
---------------------------

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

function GUI:ToggleInRaid(status)
    core.filterInRaid = status;

    local select_all = _G['pdkp_select_all_filtered_checkbox']
    local raidMembers = Raid:GetRaidInfo()

    if status then select_all:Show() else
        select_all:SetChecked(false)
        select_all:Hide()
    end

    for i=1, PDKP:GetDataCount() do
        local char = PDKP.data[i];
        local inRaid = false

        for j=1, #raidMembers do
           local raidMember = raidMembers[j];
            if raidMember['name'] == char['name'] then
               inRaid = true;
                break;
            end
        end
        char['inRaid'] = inRaid;
    end
    pdkp_dkp_table_filter()
end

function GUI:UpdateOnlineStatus(status)
    core.filterOffline = status
    local onlineMembers, allMembers = Guild:GetGuildData(true)

    if #onlineMembers == 0 then return end; -- Just incase something weird happens.

    for key, char in pairs(PDKP.data) do
       for name, onlineChar in pairs(onlineMembers) do
          if onlineChar.name == char.name then
             char.online = onlineChar.online;
              break;
          end
          char.online = false;
       end
    end
end

function GUI:UpdateScrollValues()

end

-- Generic catch all for the filter functions.
function pdkp_dkp_table_filter()
    local newTableData = {}
    local selectedFilterChecked = GUI:GetSelectedFilterStatus()
    local hasSearch = not Util:IsEmpty(textSearch);

    local currentRaid = DKP:GetCurrentDB()

    -- filter out based on online status
    for i=1, PDKP:GetDataCount() do
        local char = PDKP.data[i]

        local showingOffline = core.filterOffline == nil or core.filterOffline == false;
        local onlineStatusMatch = char["online"] == not showingOffline
        local isSelected, searchFound = false, false;

        local showingInRaid = core.filterInRaid == true;
        local inRaidStatusMatch = true; -- set this as the default.

        if showingInRaid then inRaidStatusMatch = showingInRaid == char['inRaid']; end

        if selectedFilterChecked and GUI.selected[char.name] then isSelected = true; end
        if hasSearch then searchFound = GUI:SearchOnAttributes(char) end

        local selectStatusMatch = selectedFilterChecked == isSelected;
        local searchStatusMatch = searchFound == hasSearch;
        local sliderValsMatch = true;
        local sliderValsMatch = GUI.sliderVal <= char.dkp[currentRaid].total

        -- This is really complicated... I should figure out a better way to handle this...
        if (showingOffline or onlineStatusMatch) -- If online selected, the status matches.
                and (selectStatusMatch) -- If selections, the entry is in the array.
                and (searchStatusMatch) -- If search, the entry matches the search
                and (sliderValsMatch)  -- If slider, the entry's dkp is > sliderVal
                and (inRaidStatusMatch) and -- In raid status matches.
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