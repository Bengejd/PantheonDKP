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
local Invites = core.Invites;


function Invites:Show()
    local inviteFrame = _G['pdkp_invites_window']
    inviteFrame:Show();
end