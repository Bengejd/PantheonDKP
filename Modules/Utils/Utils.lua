local _, PDKP = ...
local LOG = PDKP.LOG
PDKP.Utils = {}

local Utils = PDKP.Utils;
local MODULES = PDKP.MODULES;

local strsplit, strlower, strmatch, strfind, strupper = strsplit, strlower, strmatch, strfind, strupper;
local replace, format, tostring, gsub, split, trim = string.rep, string.format, tostring, string.gsub, strsplit, strtrim
local floor, fmod = math.floor, math.fmod;
local insert, sort, next = table.insert, table.sort, next;
local date, type, print = date, type, print
local getn, pairs, ipairs = table.getn, pairs, ipairs

local daysInWeek = 7
local daysInYear = 365
local hoursInDay = 24
local secondsInHour = 60 * 60

function Utils:ternaryAssign(cond, a, b)
    if cond then return a end
    return b
end

-----------------------------
--     Debug Functions     --
-----------------------------

local watchedVars = {};
function Utils:WatchVar(tData, strName)
    if ViragDevTool_AddData ~= nil and PDKP:IsDev() and watchedVars[strName] ~= true then
        ViragDevTool_AddData(tData, strName)
        print('Watching Var', strName)
        watchedVars[strName]=true
    end
end

-----------------------------
--     Item Functions      --
-----------------------------

function Utils:IsItemLink(iLink)
    return strmatch(iLink, "|Hitem:(%d+):")
end

-----------------------------
--     Color Functions     --
-----------------------------

-- Formats text color
function Utils:FormatTextColor(text, color_hex)
    if text == nil then return text end
    if not color_hex then
        PDKP:Print("No Default Color given")
        color_hex = 'ff0000' end
    return "|cff" .. color_hex .. text .. "|r"
end

-- Formats text color based on class
function Utils:FormatTextByClass(text, class)
    local class_color = MODULES.Constants.CLASS_COLORS[class]
    local colored_text, colored_class = Utils:FormatTextColor(text, class_color), Utils:FormatTextColor(class, class_color)
    return colored_text, colored_class
end

-----------------------------
--     String Functions    --
-----------------------------

-- Utility function to help determine if the string is empty or nil.
function Utils:IsEmpty(string)
    return string == nil or string == '';
end

-- Utility function to help tell if the baseString contains the searchString
function Utils:StringsMatch(baseString, searchString)
    return not Utils:IsEmpty(strmatch(strlower(baseString), strlower(searchString), nil, true));
end

-----------------------------
--     Table Functions     --
-----------------------------

-- http://lua-users.org/wiki/CopyTable
function Utils.ShallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- http://lua-users.org/wiki/CopyTable
function Utils.DeepCopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[Utils.DeepCopy(orig_key, copies)] = Utils.DeepCopy(orig_value, copies)
            end
            setmetatable(copy, Utils.DeepCopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- For finding the index of an object item.
function Utils:tfind(t, item, objIndex)
    objIndex = objIndex or nil;
    t = t or {};
    local index = 1;
    while t[index] do
        if objIndex and (item == t[index]['dataObj'][objIndex]) then
            return true, index
        elseif (item == t[index]) then
            return true, index
        end
        index = index + 1;
    end
    return nil, nil;
end

-- Finds the index of an object in a table, based on a sub-index in the object.
function Utils:tfindObj(t, item, objIndex)
    t = t or {};
    local index = 1;
    while t[index] do
        if (item == t[index][objIndex]) then
            return true, index
        end
        index = index + 1
    end
    return nil, nil
end

function Utils:tEmpty(t)
    if type(t) ~= "table" then return true end
    return next(t) == nil;
end