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
local Character = core.Character;

local strsplit, strlower, strmatch, strfind, strupper = strsplit, strlower, strmatch, strfind, strupper;
local replace, format, tostring, gsub = string.rep, string.format, tostring, string.gsub
local floor, fmod = math.floor, math.fmod;
local insert, sort = table.insert, table.sort;
local date, type, print = date, type, print
local getn, pairs, ipairs = table.getn, pairs, ipairs

Util.warning = 'E71D36';
Util.success = '22bb33';
Util.info = 'F4A460';

local class_colors = Defaults.class_colors;

-----------------------------
--     Color Functions     --
-----------------------------

-- Color text based on the class.
function Util:ColorTextByClass(name, class)
    local classColor = class_colors[class]
    local coloredName = Util:FormatFontTextColor(classColor, name)
    local coloredClass = Util:FormatFontTextColor(classColor, class)
    return coloredName, coloredClass
end

-- Formats text with color_hex.
function Util:FormatFontTextColor(color_hex, text)
    if text == nil then return text end
    if not color_hex then
        Util:Debug("You did not give FormtFontTextColor() a hex color, setting a default!")
        color_hex = 'ff0000'
    end
    return "|cff" .. color_hex .. text .. "|r"
end

-- Removes color from text
function Util:RemoveColorFromText(name)
    local fixedName = name
    for _, val in pairs(class_colors) do
        fixedName = fixedName:gsub('|cff' .. val, '')
    end
    local fName = fixedName:sub(1, -3)
    fName = fName:gsub("%s+", "")
    fName = gsub(fName, "%s+", "")
    return fName
end

-- Returns all Alliance classes in WoW Classic.
--function Defaults:GetAllClasses()
--    return Defaults.classes;
--end

--function Defaults:GetClassColor(class)
--    return class_colors[class]
--end
--
--function Defaults:GetClassColoredName(name, class)
--    local classColor = Util:GetClassColor(class)
--    return Util:FormatFontTextColor(classColor, name)
--end

-----------------------------
--     Time Functions      --
-----------------------------

-- Subtracts two timestamps from one another.
function Util:SubtractTime(baseTime, subTime)
    local secondsSinceSync = (subTime - baseTime) -- the seconds since our last sync
    local minsSinceFirstReset = floor(secondsSinceSync / 60) -- Minutes since last sync.
    return minsSinceFirstReset
end

function Util:AddTime(base, seconds)
    return base + seconds
end

function Util:SecondsToDays(days)
    local secondsInDay = 86400
    return secondsInDay * days
end

-- Utility function that provides all date & time variations that LUA & WoW have.
function Util:GetDateTimes()
    local dDate = date("%m/%d/%y"); -- LUA implementation of date.
    local tTime = date('%r'); -- LUA implementation of time.
    local server_time = GetServerTime() -- WoW API of the server time.
    local datetime = time() -- LUA implementation of local machine time.
    return lDate, lTime, server_time, datetime
end

function Util:FormatDateTime(formatType)
    formatType = formatType or ''; -- Default value.

    if formatType == 'twelve' then
        return date("%a, %b %d | %I:%M %p", dateTime); -- Thur, Jan 4 - 12:32 PM
    elseif formatType == 'date' then
        return date('%m/%d/%Y', dateTime); -- 06/21/2020
    else
        return date("%m/%d/%y %H:%M:%S", dateTime); -- 06/21/20 07:30:21
    end
end

-- Calculates the difference in timestamps, and returns it to you in minutes and seconds.
function Util:CalculateTimeDifference(startTime, endTime)
    local difference = endTime - startTime -- in seconds
    local mins = floor(difference / 60) -- mins
    local seconds = difference - (mins * 60) -- seconds
    return mins .. ':'..seconds
end

-- Displays timestamps in D:H:M format.
function Util:displayTime(timeInSeconds)
    local days = floor(timeInSeconds/86400)
    local hours = floor(fmod(timeInSeconds, 86400)/3600)
    local minutes = floor(fmod(timeInSeconds,3600)/60)
    local seconds = floor(fmod(timeInSeconds,60))
    return format("%dD:%2dHr:%2dMin",days,hours,minutes)
end

-----------------------------
--     String Functions    --
-----------------------------

-- Utility function to help determine if the string is empty or nil.
function Util:IsEmpty(string)
    return string == nil or string == '';
end

-- Utility function that removes the server name from a characters string.
function Util:RemoveServerName(name)
    if Util:IsEmpty(name) then return nil end;
    -- Names come in with server attached e.g: XYZ-Blaumeux (We gotta remove the server name)
    local newName, _ = strsplit('-', name)
    return newName
end

-- Utility function to help tell if the baseString contains the searchString
function Util:StringsMatch(baseString, searchString)
    return not Util:IsEmpty(strmatch(strlower(baseString), strlower(searchString), nil, true));
end

-- Utility function to help determine if a string matches another in order
function Util:StringsMatchInOrder(baseString, searchString)
    local first, last = strfind(strlower(baseString), strlower(searchString), nil, true);
    return first == 1;
end

-- Utility function to make the first character uppercase, and the rest of the string lowercase.
function Util:Capitalize(str)
    return strlower(str):gsub("^%l", strupper)
end

-- Utility function to remove non-numerics (except minus) from a number.
function Util:RemoveNonNumerics(str)
    return str:gsub("%D+", "")
end

-----------------------------
--      Class Functions    --
-----------------------------



-----------------------------
--      Table Functions    --
-----------------------------

-- Returns the tableIndex of a table key.
function Util:FindTableIndex(table, key)
    for k, v in ipairs(table) do
        if v == key then return k end
    end
    return nil;
end

-- Debugging utility function that only prints debug messages if debugging is enabled.
function Util:Debug(string)
    if Defaults:IsDebug() and not Defaults.silent then
        PDKP:Print(Util:FormatFontTextColor(Util.info, string))
    end
end

-- Debugging utility function that prints what's inside of a table.
function Util:PrintTable(tt, indent)
--    if not Defaults:IsDebug() then return end;

    local done = {}
    indent = 0 or 0
    if type(tt) == "table" then
        for key, value in pairs (tt) do
            print(replace (" ", indent)) -- indent it
            if type (value) == "table" and not done [value] then
                done [value] = true
                print(format("[%s] => table\n", tostring (key)));
                print(replace (" ", indent+4)) -- indent it
                print("(\n");
                Util:PrintTable (value, indent + 7, done)
                print(replace (" ", indent+4)) -- indent it
                print(")\n");
            else
                print(format("[%s] => %s\n",
                        tostring (key), tostring(value)))
            end
        end
    else
        print(tt .. "\n")
    end
end

-- OrderedNext helper function
function __genOrderedIndex( t )

    local orderedIndex = {}
    for key, _ in pairs(t) do
        if type(key) == type(1) then
            insert( orderedIndex, key )
        else
            print(key)
        end
    end
    sort( orderedIndex )
    return orderedIndex
end

-- OrderedPairs helper function
function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

-- Equivalent of the pairs() function on tables. But this allows you to iterate in order.
function orderedPairs(t)
    return orderedNext, t, nil
end




