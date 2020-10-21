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
Settings.db = nil;

Settings.sync = {}
Settings.settings = {};
Settings.silent = false;

Settings.smallSyncAvailable = true;
Settings.longSyncAvailable = true;

function Settings:InitDB()
    SettingsDB = core.PDKP.db['settingsDB']
    Settings.db = SettingsDB
    Settings.current_raid = SettingsDB['current_raid'] or 'Molten Core';
    Settings:SetSettings()
    Settings:RespectSettings();
end

function Settings:ChangeCurrentRaid(raid)
    Settings.current_raid = raid;
    SettingsDB['current_raid']=raid;
end

function Settings:UpdateIgnoreFrom(ignore_arr, init)
    if init then return SettingsDB['ignore_from'] end

    SettingsDB['ignore_from']=ignore_arr
    return SettingsDB['ignore_from']
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

function Settings:CanEdit()
    local pName = Util:GetMyName()

    local debugNames = {'Lariese'}
    if tContains(debugNames, pName) then
        pName = 'Neekio'
    end

    local member = Guild.members[pName]

    if (member and member.canEdit) or Settings:IsDebug() then
        return true
    end
    return false
end

function Settings:GetAddonVersion()
    return GetAddOnMetadata('PantheonDKP', "Version")
end

function Settings:SetSettings()
    Settings.settings = {
        ['silent']=Settings.db.silent,
        ['pvp']=Settings.db.sync.pvp,
        ['raids']=Settings.db.sync.raids,
        ['dungeons']=Settings.db.sync.dunegeons,
        ['debug']=Settings.db.debug,
    }
    return Settings.settings;
end

function Settings:GetSetInterface(type, setting, value)
    Settings:SetSettings()
    local types = {
        ['get']=function() return Settings.settings[setting] end,
        ['set']=function()
            if setting == 'pvp' or setting == 'raids' or setting == 'dungeons' then Settings.db.sync[setting] = value end
            if setting == 'debug' then Settings:ToggleDebugging() end
            if setting == 'silent' then Settings.db.silent = not value end
        end,
    }

    if types[type] ~= nil then
        local setting_val = types[type]()
        Settings:SetSettings()
        if type == 'set' then Settings:RespectSettings(true) end
        return setting_val
    end
end

function Settings:RespectSettings(clicked)
    for s_name, s_val in pairs(Settings.settings) do
        local val = Settings.settings[s_name]
        if s_name == 'silent' then
            if val then Settings.silent = true else Settings.silent = false end
        end
    end
end




