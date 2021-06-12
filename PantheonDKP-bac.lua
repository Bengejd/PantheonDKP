local _G = _G;
local PDKP = _G.PDKP

local Guild, Defaults, Util, Character, GUI, Dev, Bid = PDKP:GetInst('Guild', 'Defaults', 'Util', 'Character', 'GUI', 'Dev', 'Bid')
local IsInGuild, GuildRoster = IsInGuild, GuildRoster
local strlen, next = string.len, next

local function PDKP_OnEvent(self, event, arg1, ...)

    local ADDON_EVENTS = {
        ['GUILD_ROSTER_UPDATE'] = function()
            if Guild:HasMembers() then
                PDKP.Events:Unregister(event, "PDKP")
                PDKP:OnDataAvailable()
            else
                GuildRoster()
            end
        end,
        ['PLAYER_LOGIN'] = function()
            if IsInGuild() then
                GuildRoster();
            end
        end,
        ['PLAYER_ENTERING_WORLD'] = function()
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
    PDKP.Events:Register({ "GUILD_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_LOGIN" }, PDKP_OnEvent, "PDKP")
end

function PDKP:OnDataAvailable()
    PDKP:CheckTOCVersion()
    PDKP:InitializeAddonModules()

    if GUI.pdkp_frame == nil then
        return
    end;

    --GameTooltip:HookScript( "OnTooltipSetItem", PDKP_SetToolTipPrio)
end

-- do init tasks here, like loading the Saved Variables,
--   -- or setting up slash commands.
function PDKP:OnInitialize()
    --- Register Slash Commands
    PDKP:RegisterChatCommand("pdkp", "HandleSlashCommands", true)

    --- Initialize the database
    PDKP:InitializeDatabases()
end

function PDKP:HandleSlashCommands(msg)
    if strlen(msg) == 0 then
        return GUI:Toggle()
    end

    local cmd = PDKP:GetArgs(msg) -- The Chat command, is nil if running /pdkp

    local iLink = nil;

    local _, arg2 = strsplit(" ", msg)

    if Util:IsItemLink(arg2) then
        iLink = arg2
    end

    --- GUI Commands
    local guiCommands = {
        ['show'] = function()
            GUI:Show()
        end,
        ['hide'] = function()
            GUI:Hide()
        end,
        ['bid'] = function()
            if GUI.bid_frame and Bid.isActive then
                GUI.bid_frame:Show()
            end
        end,
    }
    if guiCommands[cmd] and iLink == nil then
        return guiCommands[cmd]()
    end

    --- Dev Commands
    if Dev.commands[cmd] then
        return Dev:HandleCommands(msg)
    end

    print(iLink, PDKP.canEdit)
    print(msg)

    --- Officer Commands
    local officerCommands = {
        ['bid'] = function()
            if iLink ~= nil then
                Bid:Start(iLink)
            else
                -- TODO: Hook up error printing
            end
        end,
    }
    if officerCommands[cmd] and PDKP.canEdit then
        return officerCommands[cmd]()
    end
end

function PDKP:CheckTOCVersion()
    local version, build, date, game_toc_version = GetBuildInfo()
    if tonumber(game_toc_version) ~= tonumber(Defaults.addon_interface_version) then
        Dev:Print('GameTOC', game_toc_version, 'Does not equal Addon Interface', Defaults.addon_interface_version)
    end
end

-- SuppressTells
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(self, event, msg, ...)      -- suppresses outgoing whisper responses to limit spam

    --if strfind(msg, "!bid") == 1 then
    --    return true
    --else
    --    return false
    --end

    --if core.DB == nil then
    --    return false;
    --end
    --
    --if core.DB.defaults.SuppressTells then
    --    if core.BidInProgress then
    --        if strfind(msg, L["YOURBIDOF"]) == 1 then
    --            return true
    --        elseif strfind(msg, L["BIDDENIEDFILTER"]) == 1 then
    --            return true
    --        elseif strfind(msg, L["BIDACCEPTEDFILTER"]) == 1 then
    --            return true;
    --        elseif strfind(msg, L["NOTSUBMITTEDBID"]) == 1 then
    --            return true;
    --        elseif strfind(msg, L["ONLYONEROLLWARN"]) == 1 then
    --            return true;
    --        elseif strfind(msg, L["ROLLNOTACCEPTED"]) == 1 then
    --            return true;
    --        elseif strfind(msg, L["YOURBID"].." "..L["MANUALLYDENIED"]) == 1 then
    --            return true;
    --        elseif strfind(msg, L["CANTCANCELROLL"]) == 1 then
    --            return true;
    --        end
    --    end
    --
    --    if strfind(msg, "CommunityDKP: ") == 1 then
    --        return true
    --    elseif strfind(msg, L["DKPAVAILABLE"]) ~= nil and strfind(msg, '%[') ~= nil and strfind(msg, '%]') ~= nil then
    --        return true
    --    elseif strfind(msg, L["NOBIDINPROGRESS"]) == 1 then
    --        return true
    --    elseif strfind(msg, L["BIDCANCELLED"]) == 1 then
    --        return true
    --    end
    --end
end)

--SuppressTells
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(self, event, msg, ...)      -- suppresses incoming whisper responses to limit spam



    if strfind(msg, "!bid") == 1 then
        return true
    else
        return false
    end
end)