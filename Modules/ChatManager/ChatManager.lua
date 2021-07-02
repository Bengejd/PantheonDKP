local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Chat = {}

local trim, lower, contains = strtrim, strlower, tContains

function Chat:Initialize()
    PDKP.CORE:RegisterChatCommand("pdkp", function(msg) Chat:_HandleSlashCommands(msg) end)

    self.eventsFrame = CreateFrame("Frame", "PDKP_Chat_EventsFrame")
    self.eventsFrame:SetScript("OnEvent", Chat.HandleChatEvent)

    local eventNames = {
        'CHAT_MSG_WHISPER',
        --'CHAT_MSG_WHISPER_INFORM',
        --'CHAT_MSG_GUILD',
        'CHAT_MSG_RAID', 'CHAT_MSG_RAID_LEADER', 'CHAT_MSG_RAID_WARNING',
    }

    for _, eventName in pairs(eventNames) do
        self:RegisterEvent(eventName)
    end
end

function Chat:HandleChatEvent(eventName, msg, author, ...)
    author = Utils:RemoveServerName(author)
    msg = lower(trim(msg))
    local invite_commands = MODULES.RaidManager.invite_commands

    if eventName == 'CHAT_MSG_WHISPER' and contains(invite_commands, msg) then
        return Chat:_HandleInviteMsg(author)
    end
end

-----------------------------
--     Invite Functions    --
-----------------------------

function Chat:_HandleInviteMsg(name)
    local RaidManager = MODULES.RaidManager

    local ignore_from = RaidManager.ignore_from

    if contains(ignore_from, lower(name)) then
        local player_name = '|cffffaeae' .. name .. '|r'
        return PDKP.CORE:Print(player_name, "'s invite request was ignored")
    end

    MODULES.GroupManager:InvitePlayer(name)
end

--- Events

function Chat:RegisterEvent(eventName)
    self.eventsFrame:RegisterEvent(eventName)
end

function Chat:UnregisterEvent(eventName)
    self.eventsFrame:UnregisterEvent(eventName)
end


--- Slash commands stuff
function Chat:_HandleSlashCommands(msg)
    if msg == "" then msg = 'pdkp' end --- Default command doesn't display in the msg.

    local command = PDKP.CORE:GetArgs(msg)

    local SLASH_COMMANDS = {
        -- Help Handlers
        ['help'] = function() Chat:_DisplayHelp() end,

        -- Main Handlers
        ['pdkp'] = function() MODULES.Main:HandleSlashCommands(msg) end,
        ['show'] = function() MODULES.Main:HandleSlashCommands(msg) end,
        ['hide'] = function() MODULES.Main:HandleSlashCommands(msg) end,

        -- Auction Handlers
        ['bid'] = function() MODULES.AuctionManager:HandleSlashCommands(msg) end,
        ['shroud'] = function() MODULES.AuctionManager:HandleSlashCommands(msg) end,
        ['thirst'] = function() MODULES.AuctionManager:HandleSlashCommands(msg) end,
        [''] = function()  end,
        [''] = function()  end,
        [''] = function()  end,

        -- DKP Handlers
        ['LoadMoreEntries'] = function() MODULES.DKPManager:LoadPrevFourWeeks() end,

        -- Database Handlers
        ['databaseReset'] = function() MODULES.Database:ResetAllDatabases() end,
    }
    if SLASH_COMMANDS[command] then return SLASH_COMMANDS[command]() end

    -- Dev Handlers
    local DEV_SLASH_COMMANDS = {
        ['whoTest'] = function() MODULES.Dev:HandleSlashCommands(msg) end,
        ['databasePopulate'] = function() MODULES.Dev:HandleSlashCommands(msg) end,
        ['largeDataSync'] = function() MODULES.Dev:HandleSlashCommands(msg) end,
        ['decayTest'] = function() MODULES.Dev:HandleSlashCommands(msg) end,
        ['bossKillTest'] = function() MODULES.Dev:HandleSlashCommands(msg) end,
        ['testAuctionTimer'] = function() MODULES.Dev:HandleSlashCommands(msg) end,
    }
    if DEV_SLASH_COMMANDS[command] and PDKP:IsDev() then return DEV_SLASH_COMMANDS[command]() end
end

function Chat:_DisplayHelp()
    local slash_addon = MODULES.Constants.SLASH_ADDON
    local CMD_COLOR = '|cffffaeae'

    local helpCommands = {
        { ['cmd'] = 'show / hide', ['desc'] = 'PantheonDKP window', },
        { ['cmd'] = 'bid <number>', ['desc'] = 'To place a bid', },
        { ['cmd'] = 'bid <itemLink>', ['desc'] = 'To start a bid', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
    }

    print(" ")

    for i=1, #helpCommands do
        local helpCmd = helpCommands[i]
        local cmd = CMD_COLOR .. helpCmd['cmd'] .. ':|r'
        local msg = slash_addon .. ' ' .. cmd .. ' ' .. helpCmd['desc']
        print(msg)
    end
end


MODULES.ChatManager = Chat