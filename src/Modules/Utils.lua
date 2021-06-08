local _G = _G;
local PDKP = _G.PDKP
local Defaults, Util = PDKP:GetInst('Defaults', 'Util')

local strsplit, strlower, strmatch, strfind, strupper = strsplit, strlower, strmatch, strfind, strupper;
local replace, format, tostring, gsub, split, trim = string.rep, string.format, tostring, string.gsub, strsplit, strtrim
local floor, fmod = math.floor, math.fmod;
local insert, sort, next = table.insert, table.sort, next;
local date, type, print = date, type, print
local getn, pairs, ipairs = table.getn, pairs, ipairs

Util.warning = Defaults.warning
Util.info = Defaults.info
Util.success = Defaults.success

Util.isResetDay = false
Util.serverReset = false -- tells us if the server has reset recently.
Util.dayOfReset = 10
Util.daysUntilReset = 10
Util.timeUntilReset = 0 -- Daily Quest Reset timer, there is no blizzard "timeuntilReset" unfortunately...

-----------------------------
--     Debug Functions     --
-----------------------------

local watchedVars = {};

function Util:WatchVar(tData, strName)
    if ViragDevTool_AddData and Settings:IsDebug() and not watchedVars[strName] then
        ViragDevTool_AddData(tData, strName)
        watchedVars[strName]=true
    end
end

-----------------------------
--     Color Functions     --
-----------------------------

function Util:FormatTextColor(text, color_hex)
    if text == nil then return text end
    if not color_hex then
        PDKP:Print("No Default Color given")
        color_hex = 'ff0000' end
    return "|cff" .. color_hex .. text .. "|r"
end

function Util:FormatFontTextColor(color_hex, text)
    PDKP:Print('FormatFontTextColor() is depreciated, please change to FormatTextColor()')
    return Util:FormatTextColor(text, color_hex)
end

function Util:FormatTextByClass(text, class)
    local class_color = Defaults.class_colors[class]
    local colored_name, colored_class = Util:FormatTextColor(text, class_color), Util:FormatTextColor(class, class_color)
    return colored_name, colored_class
end

function Util:RemoveColorFromText(name)
    local fixedName = name
    for _, val in pairs(Defaults.class_colors) do
        fixedName = fixedName:gsub('|cff' .. val, '')
    end
    local fName = fixedName:sub(1, -3)
    fName = fName:gsub("%s+", "")
    fName = gsub(fName, "%s+", "")
    return fName
end

-----------------------------
--     Time Functions      --
-----------------------------

do
    local day = date("*t", GetServerTime())
    local daysInWeek = 7
    local daysInYear = 365
    local secondsInHour = 60 * 60
    local secondsInDay = 60 * 60 * 24
    -- Sunday (1), Monday (2), Tuesday (3), Wednesday (4), Thursday (5), Friday (6), Saturday (7)
    local resetDay = 3
    local wday = day.wday
    local yday = day.yday

    if wday <= resetDay then
        Util.daysUntilReset = resetDay - wday
    else
        Util.daysUntilReset = daysInWeek - wday
    end

    Util.dayOfReset = yday + Util.daysUntilReset

    if Util.dayOfReset > daysInYear then -- to account for the last week of the year.
        Util.dayOfReset = Util.dayOfReset - daysInYear
    end

    Util.timeUntilReset = GetQuestResetTime() -- Seconds until daily quests reset.
    Util.isResetDay = yday == Util.dayOfReset

    --- Because Blizzard hates us, we have to figure out how many hours until reset occurs... stupid...

    if Util.isResetDay then
        local seconds_until_hour = fmod(Util.timeUntilReset, secondsInHour)
        local seconds_until_reset = Util.timeUntilReset - seconds_until_hour
        local hours_until_reset = seconds_until_reset / 60 / 60

        if hours_until_reset >= 10 then
            Util.serverReset = true
        end
    end
end

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
    elseif formatType == 'weekday' then
        return date("%a", dateTime)
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

function Util:Format12HrDateTime(dateTime)
    return date("%a, %b %d | %I:%M %p", dateTime)
end

local waitTable = {};
local waitFrame = nil;

function PDKP_wait(delay, func, ...)
    if(type(delay)~="number" or type(func)~="function") then
        return false;
    end
    if(waitFrame == nil) then
        waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
        waitFrame:SetScript("onUpdate",function (self,elapse)
            local count = #waitTable;
            local i = 1;
            while(i<=count) do
                local waitRecord = tremove(waitTable,i);
                local d = tremove(waitRecord,1);
                local f = tremove(waitRecord,1);
                local p = tremove(waitRecord,1);
                if(d>elapse) then
                    tinsert(waitTable,i,{d-elapse,f,p});
                    i = i + 1;
                else
                    count = count - 1;
                    f(unpack(p));
                end
            end
        end);
    end
    tinsert(waitTable,{delay,func,{...}});
    return true;
end