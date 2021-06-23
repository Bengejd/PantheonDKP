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
local GetServerTime, GetQuestResetTime = GetServerTime, GetQuestResetTime

local daysInWeek = 7
local daysInYear = 365
local hoursInDay = 24
local secondsInHour = 60 * 60

function Utils:Initialize()
    self:GetResetInfo()
end

-----------------------------
--     Reset Functions     --
-----------------------------

function Utils:GetResetInfo()
    local server_time = GetServerTime()
    local daily_reset_time = GetQuestResetTime() -- Seconds until daily quests reset.
    local seconds_until_hour = fmod(daily_reset_time, secondsInHour)
    local seconds_until_daily_reset = daily_reset_time - seconds_until_hour
    local hours_until_daily_reset = seconds_until_daily_reset / 60 / 60

    -- Blizzard Format Sunday (1), Monday (2), Tuesday (3), Wednesday (4), Thursday (5), Friday (6), Saturday (7)
    local day = date("*t", server_time)
    local wday = day.wday
    local yday = day.yday

    -- custom date schedule.
    local customWeeklySchedule = {
        [1] = { -- Old Sunday
            ['daysFromReset'] = 2
        },
        [2] = { -- Old Monday
            ['daysFromReset'] = 1
        },
        [3] = { -- Old Tuesday
            ['daysFromReset'] = 0 -- Tuesday can either be 0 or 7 depending on time of day.
        },
        [4] = { -- Old Wednesday
            ['daysFromReset'] = 6
        },
        [5] = { -- Old Thursday
            ['daysFromReset'] = 5
        },
        [6] = { -- Old Friday
            ['daysFromReset'] = 4
        },
        [7] = { -- Old Saturday
            ['daysFromReset'] = 3
        },
    }

    local customDay = customWeeklySchedule[wday]
    local daysUntilReset = customDay['daysFromReset']
    local isResetDay = daysUntilReset == 0
    local serverReset = false

    -- Today is weekly reset day, Daily reset happens at 9:59:59 AM, server time.
    if daysUntilReset == 0 and hours_until_daily_reset >= 10 then
        serverReset = true
        daysUntilReset = 7
    end

    local dayOfReset = yday + daysUntilReset

    if dayOfReset > daysInYear then
        dayOfReset = dayOfReset - daysInYear
    end

    isResetDay = isResetDay or yday == dayOfReset

    -- Set our globals
    Utils.isResetDay = isResetDay
    Utils.serverHasReset = serverReset
    Utils.dayOfReset = dayOfReset
    Utils.daysUntilReset = daysUntilReset
    Utils.wday = wday
    Utils.yday = yday
    Utils.weekNumber = Utils:GetWeekNumber(server_time)
end

function Utils:GetWeekInfo()
    return Utils.weekNumber, Utils.wday, Utils.yday
end

function Utils:GetYDay(unixtimestamp)
    return date("*t", unixtimestamp).yday
end

function Utils:GetWDay(unixtimestamp)
    return date("*t", unixtimestamp).wday
end

-- Return the 1-based unix epoch week number. Seems to be off by 2 weeks?
function Utils:GetWeekNumber(unixtimestamp)
    return 1 + floor(unixtimestamp / 604800)
end

function Utils:WeekStart(week)
    return (week - 1) * 604800
end

-----------------------------
--      Time Functions     --
-----------------------------

function Utils:Format12HrDateTime(dateTime)
    return date("%a, %b %d | %I:%M %p", dateTime)
end

-----------------------------
--      MISC Functions     --
-----------------------------

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

-- Utility function to remove non-numerics (except minus) from a number.
function Utils:RemoveNonNumerics(str)
    if str == nil then return str end
    return str:gsub("%D+", "")
end

function Utils:RemoveAllNonNumerics(str)
    if str == nil then return str end
    return str:gsub("[^0-9]", "")
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