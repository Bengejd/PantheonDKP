local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Import = core.Import;
local Setup = core.Setup;
local Comms = core.Comms;

local Officer = core.Officer;

function Officer:Show()
    print('Showing officer, show')
end