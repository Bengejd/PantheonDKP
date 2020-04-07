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

local classes = {
    'Druid', 'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Warlock', 'Warrior'
};

local class_colors = {
    ["Druid"] = "FF7D0A",
    ["Hunter"] = "ABD473" ,
    ["Mage"] = "40C7EB",
    ["Paladin"] = "F58CBA",
    ["Priest"] = "FFFFFF",
    ["Rogue"] = "FFF569",
    ["Warlock"] = "8787ED",
    ["Warrior"] = "C79C6E"
}

Util.warning = 'E71D36'
Util.success = '22bb33'

-- Returns the current player's name.
function Util:GetMyName()
    local pName, _ = UnitName("PLAYER")
    return pName;
end

function Util:GetMyClass()
    return UnitClass("PLAYER");
end

-- Removes the color from peoples names, for various purposes. Mostly data import ones.
function Util:RemoveColorFromname(name)
    local fixedName = name
    for _, val in pairs(class_colors) do
        fixedName = fixedName:gsub('|cff' .. val, '')
    end
    local fName = fixedName:sub(1, -3)
    fName = fName:gsub("%s+", "")
    fName = string.gsub(fName, "%s+", "")

    return fName
end

-- Returns all classes in WoW Classic.
function Util:GetAllClasses()
    return classes;
end

function Util:Wait(seconds)
    local start = tonumber(date('%S'))
    repeat until tonumber(date('%S')) > start + seconds
end

function Util:ThrowError(msg, debug)
    local warning = 'E71D36'
    local errorMsg = Util:FormatFontTextColor(warning, 'Error!!! ' .. msg)

    if debug then Util:Debug(errorMsg) else PDKP:Print(errorMsg) end
end

function Util:GetClassColor(class)
    return class_colors[class]
end

function Util:GetClassColoredName(name, class)
    local classColor = Util:GetClassColor(class)
    return Util:FormatFontTextColor(classColor, name)
end

function Util:GetMyNameColored()
    local name = Util:GetMyName();
    local class = Util:GetMyClass();
    local class_color = Util:GetClassColor(class);
    return Util:FormatFontTextColor(class_color, name);
end

-- Utility function that removes the server name from a characters string.
function Util:RemoveServerName(name)
    if Util:IsEmpty(name) then return nil end;

    -- Names come in with server attached e.g: ValhallaBank-Blaumeux (We gotta remove the server name)
    for w in name:gmatch("([^-]+)") do -- I'm sure there is a better way to remove the server name *shrug*
        return w;
    end
end

function Util:GetDateTimes()
    local dDate = date("%m/%d/%y"); -- LUA implementation of date.
    local tTime = date('%r'); -- LUA implementation of time.
    local server_time = GetServerTime() -- WoW API of the server time.
    local datetime = time() -- LUA implementation of local machine time.
    return dDate, tTime, server_time, datetime
end

-- Utility function to help determine if the string is empty or not.
function Util:IsEmpty(string)
    return string == nil or string == '';
end

-- Utility function to help tell if the baseString contains the searchString
function Util:StringsMatch(baseString, searchString)
    return not Util:IsEmpty(string.match(string.lower(baseString), string.lower(searchString), nil, true));
end

-- Utility function to help determine if a string matches another in order
function Util:StringsMatchInOrder(baseString, searchString)
    local first, last = string.find(string.lower(baseString), string.lower(searchString), nil, true);
    return first == 1;
end

-- Utility function to make the first character uppercase, and the rest of the string lowercase.
function Util:Capitalize(str)
    return string.lower(str):gsub("^%l", string.upper)
end

-- Utility function to format time.
function Util:FormatDateTime(dateTime)
    return date("%m/%d/%y %H:%M:%S", dateTime)
end

-- Thur, Jan 4 - 12:32 PM
function Util:Format12HrDateTime(dateTime)
    return date("%a, %b %d | %I:%M %p", dateTime)
end

-- Utility function to format the date.
function Util:GetFormatedDate(dateTime)
    return date('%m/%d/%Y', dateTime);
end

-- Utility function to remove non-numerics (except minus) from a number.
function Util:RemoveNonNumerics(str)
    return str:gsub("%D+", "")
end

-- Utility function to format text to include a color.
function Util:FormatFontTextColor(color_hex, text)
    if text == nil then return text end

    if not color_hex then
        Util:Debug("You did not give FormtFontTextColor() a hex color, setting a default!")
        color_hex = 'ff0000'
    end
    return "|cff" .. color_hex .. text .. "|r"
end

function Util:FindTableIndex(table, key)
    for k, v in ipairs(table) do
        if v == key then return k end
    end
    return nil;
end

-- Utility function that returns the hex color for a particular class.
function  Util:GetClassColor(class)
    return class_colors[class];
end

-- Debugging utility function that only prints debug messages if debugging is enabled.
function Util:Debug(string)
    if core.defaults.debug then PDKP:Print(string) end
end

-- Debugging utility function that prints what's inside of a table.
function Util:PrintTable(tt, indent)
    if not Defaults.debug then return end;

    local done = {}
    indent = 0 or 0
    if type(tt) == "table" then
        for key, value in pairs (tt) do
            print(string.rep (" ", indent)) -- indent it
            if type (value) == "table" and not done [value] then
                done [value] = true
                print(string.format("[%s] => table\n", tostring (key)));
                print(string.rep (" ", indent+4)) -- indent it
                print("(\n");
                Util:PrintTable (value, indent + 7, done)
                print(string.rep (" ", indent+4)) -- indent it
                print(")\n");
            else
                print(string.format("[%s] => %s\n",
                    tostring (key), tostring(value)))
            end
        end
    else
        print(tt .. "\n")
    end
end

--[[
Ordered table iterator, allow to iterate on the natural order of the keys of a
table.

Example:
]]
function __genOrderedIndex( t )
    local orderedIndex = {}
    for key, _ in pairs(t) do
        if type(key) == type(1) then
            table.insert( orderedIndex, key )
        else
            print(key)
        end
    end
    table.sort( orderedIndex )
    return orderedIndex
end

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
        for i = 1,table.getn(t.__orderedIndex) do
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

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end