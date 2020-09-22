local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local PDKP = core.PDKP;
local Raid = core.Raid;
local Util = core.Util;
local Comms = core.Comms;
local Setup = core.Setup;
local Guild = core.Guild; -- Uppercase is the file
local guild = core.guild; -- Lowercase is the object
local Shroud = core.Shroud;
local Member = core.Member;
local Import = core.Import;
local Officer = core.Officer;
local Invites = core.Invites;
local Minimap = core.Minimap;
local Defaults = core.Defaults;
local Settings = core.Settings;

local SettingsDB;

Settings.bank_name = 'PantheonBank';
Settings.current_raid = 'Molten Core';

function Settings:InitDB()
    SettingsDB = core.PDKP.db['settingsDB']
end

function Settings:ChangeCurrentRaid(raid)
    if raid == 'Onyxia\'s Lair' then
        raid = 'Molten Core'
    end
    Settings.current_raid = raid;
end

function Settings:ToggleDebugging()
    SettingsDB['debug'] = not SettingsDB['debug']
    local debugText
    if SettingsDB['debug'] == true then
        debugText = 'Debugging Enabled'
    else
        debugText = 'Debugging Disabled'
    end
    Util:Debug(debugText)
end

function Settings:IsDebug()
    if SettingsDB ~= nil then
        return SettingsDB['debug'] == true
    else
        return false
    end
end



