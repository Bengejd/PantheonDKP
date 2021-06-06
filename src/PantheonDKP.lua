local _, core = ...;
local _G = _G;

local PDKP = core.PDKP;
local Defaults = PDKP.Defaults;
local Util = PDKP.Util

local IsInGuild, GuildRoster = IsInGuild, GuildRoster
local strlen = string.len

local function PDKP_OnEvent(self, event, arg1, ...)

    local ADDON_EVENTS = {
        ['GUILD_ROSTER_UPDATE']=function()
            PDKP.Events:Unregister(event, "PDKP")

            --if Guild:HasMembers() then
            --    PDKP_UnregisterEvent(events, event);
            --    PDKP:OnDataAvailable()
            --else
            --    GuildRoster();
            --end
        end,
        ['PLAYER_LOGIN']=function()
            if IsInGuild() then
                GuildRoster();
            end
        end,
        ['PLAYER_ENTERING_WORLD']=function()
            --Util:WatchVar(core, 'PDKP');
            --Guild.updateCalled = false;
        end,
    }

    if ADDON_EVENTS[event] then
        return ADDON_EVENTS[event]()
    end
end

-- Do more initialization here, that really enables the use of your addon.
--   -- Register Events, Hook functions, Create Frames, Get information from
--   -- the game that wasn't available in OnInitialize
function PDKP:OnEnable()

    --- Register Events
    PDKP.Events:Register({ "GUILD_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_LOGIN"}, PDKP_OnEvent, "PDKP")
end

-- do init tasks here, like loading the Saved Variables,
--   -- or setting up slash commands.
function PDKP:OnInitialize()

    --- Register Slash Commands
    --self:RegisterChatCommand("pdkp", "HandleSlashCommands")

    --PDKP:RegisterChatCommand("pdkp", "HandleSlashCommands", true)
    PDKP:RegisterChatCommand("pdkp", "HandleSlashCommands", true)
end

function PDKP:PrintDev(...)
    local string = strjoin(" ", tostringall(...))
    if Defaults.development or Defaults.debug then
        PDKP:Print(Util:FormatTextColor(string, Util.info))
    end
end

function PDKP:HandleSlashCommands(msg)
    if strlen(msg) == 0 then
        return PDKP:PrintDev('Toggle PDKP GUI')
    end

    local cmd = PDKP:GetArgs(msg) -- The Chat command, is nil if running /pdkp

    --- GUI Commands
    local guiCommands = {
        ['show']=function()
            PDKP:PrintDev('Show GUI')
        end,
        ['hide']=function()
            PDKP:PrintDev('Hide GUI')
        end
    }
    if guiCommands[cmd] then return guiCommands[cmd]() end

    --- Debug Commands
    local debugCommands = {}
    if debugCommands[cmd] then return debugCommands[cmd]() end

    --- Officer Commands
    local officerCommands = {}
    if officerCommands[cmd] then return officerCommands[cmd]() end

    --local arg1 = PDKP:GetArgs(msg)
    --local t1, t2, t3 = PDKP:GetArgs(msg, 10)
end