local _, core = ...;
local _G = _G;

local PDKP = core.PDKP;

local IsInGuild, GuildRoster = IsInGuild, GuildRoster

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

function PDKP:OnEnable()
    print('OnEnable Called')

end

function PDKP:OnInitialize()
    PDKP.Events:Register({ "GUILD_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_LOGIN"}, PDKP_OnEvent, "PDKP")
end