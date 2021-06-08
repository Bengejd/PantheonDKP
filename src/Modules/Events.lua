local _G = _G;
local PDKP = _G.PDKP

local Events, Util = PDKP:GetInst('Events', 'Util')

local eventsCache = {};

--- Events:Register
--- Desc: Registers an event to a
function Events:Register(eventNames, callbackFunc, parent)

    local frame = nil;

    if eventsCache[parent] == nil then
        frame = CreateFrame("Frame", "EventsFrame");
        if callbackFunc == nil then

            return
        end
    else
        frame = eventsCache[parent];
    end

    for _, eventName in pairs(eventNames) do
        frame:RegisterEvent(eventName)
    end
    frame:SetScript("OnEvent", callbackFunc)

    eventsCache[parent] = frame

    return frame
end

function Events:Unregister(eventName, parent)
    local frame = eventsCache[parent];
    if frame == nil then return end
    frame:UnregisterEvent(eventName)
end