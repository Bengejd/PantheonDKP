local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP
local Defaults, Util = core.Defaults, core.Util;

DKP.dkpSheets = {}

function DKP:RaidNotOny(raid)
    return raid ~= 'Onyxia\'s Lair'
end