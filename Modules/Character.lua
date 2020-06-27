local _, core = ...;
local _G = _G;
local L = core.L;

local Character = core.Character;
local Util = core.Util;

function Character:GetMyName()
    local pName, _ = UnitName("PLAYER")
    return pName;
end

-- Returns the player's class
function Character:GetMyClass()
    return UnitClass("PLAYER");
end

-- Utility function to color your name based on your class.
function Util:GetMyNameColored()
    local name = Util:GetMyName();
    local class = Util:GetMyClass();
    local class_color = Util:GetClassColor(class);
    return Util:FormatFontTextColor(class_color, name);
end