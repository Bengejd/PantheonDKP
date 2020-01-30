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
local Comms = core.comms;

Shroud.window = nil;

local shrouders = {
    names={},
    table={},
};

function Shroud:ShroudingSent(text, playerName)
    local lower_text = string.lower(text);
    if lower_text == "shrouding" or lower_text == "shroud" or lower_text == "thirsting" then
        if shrouders.names[playerName] == nil then
            local dkpChar = DKP:GetMembers()[playerName];
            Util:Debug('Adding shrouder!');
            table.insert(shrouders.names, playerName);
            shrouders.names[playerName] = true;
            table.insert(shrouders.table, {
                name=playerName, dkpTotal=dkpChar.dkpTotal,
            });
        end
        Shroud:CreateFrame();
    end
end

-- Resets the shrouding table.
function Shroud:ClearShrouders()
    shrouders.names = {};
    shrouders.table = {};
end

function Shroud:CreateFrame()
    Util:Debug('Creating Shrouding Frame')

    local f = getglobal('pdkp_shrouding_window');
    f:SetPoint('BOTTOMLEFT', 0, 0);

    f:SetWidth(194);
    f:SetHeight(170);

    local nameColor = 'e6cc80';
    local br = "\n"
    local winningColor = '00FF96';
    local losingColor = 'FF3F40';

    local function compare(a, b) return a.dkpTotal > b.dkpTotal end

    table.sort(shrouders.table, compare);

    local shroudingText = Util:FormatFontTextColor(winningColor, '[WINNER]' .. br);

    for i=1, #shrouders.table do
        local spacing = ":";
        local shroud = shrouders.table[i];

        shroudingText = shroudingText ..
                Util:FormatFontTextColor(nameColor, shroud.dkpTotal) .. spacing .. shroud.name .. br;

        if i == 1 then
            shroudingText = shroudingText .. br;
        end

        if i+1 == 2 then
            shroudingText = shroudingText .. Util:FormatFontTextColor(losingColor, '[SHROUDERS]' .. br);
        end
    end

    _G['pdkp_shroudingText']:SetText(shroudingText);
    Shroud.window = f;
    Shroud.window:Show();
end


function Shroud:Hide()
    Shroud.window:Hide();
end

function Shroud:Announce()
    PDKP:Print("Congrats", UnitName('PLAYER'));
end

function shrouding_template_function_calls(funcName)
    if funcName == 'pdkp_shrouding_hide' then return Shroud:Hide() end;
    if funcName == 'pdkp_announce_winner' then return Shroud:Announce() end;
end