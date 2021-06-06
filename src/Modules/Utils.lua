local _, core = ...;
local _G = _G;

local PDKP = core.PDKP
local Defaults = PDKP.Defaults
local Util = PDKP.Util

Util.warning = Defaults.warning
Util.info = Defaults.info
Util.success = Defaults.success

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