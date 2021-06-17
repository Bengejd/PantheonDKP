local _, PDKP = ...
local LOG = PDKP.LOG
PDKP.Utils = {}

local Utils = PDKP.Utils;
local MODULES = PDKP.MODULES;

local strmatch, strlower = strmatch, strlower

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

function Utils:FormatTextColor(text, color_hex)
    if text == nil then return text end
    if not color_hex then
        PDKP:Print("No Default Color given")
        color_hex = 'ff0000' end
    return "|cff" .. color_hex .. text .. "|r"
end

function Utils:FormatTextByClass(text, class)
    local class_color = MODULES.Constants.CLASS_COLORS[class]
    local colored_text, colored_class = Utils:FormatTextColor(text, class_color), Utils:FormatTextColor(class, class_color)
    return colored_text, colored_class
end

-- Cleaner Ternary function calling.
function Utils:Ternary(eval, optA, optB)
    if eval then return optA else return optB end
end

-- Utility function to help determine if the string is empty or nil.
function Utils:IsEmpty(string)
    return string == nil or string == '';
end

-- Utility function to help tell if the baseString contains the searchString
function Utils:StringsMatch(baseString, searchString)
    return not Utils:IsEmpty(strmatch(strlower(baseString), strlower(searchString), nil, true));
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

local watchedVars = {};
function Utils:WatchVar(tData, strName)

    if ViragDevTool_AddData ~= nil and PDKP:IsDev() and watchedVars[strName] ~= true then
        ViragDevTool_AddData(tData, strName)
        print('Watching Var', strName)
        watchedVars[strName]=true
    end
end