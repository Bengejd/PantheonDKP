local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Chat = {}

function Chat:Initialize()
    PDKP.CORE:RegisterChatCommand("pdkp", function(msg) Chat:HandleSlashCommands(msg) end)
end

function Chat:HandleSlashCommands(msg)
    if msg == "" then msg = 'pdkp' end --- Default command doesn't display in the msg.

    local command = PDKP.CORE:GetArgs(msg)

    local SLASH_COMMANDS = {
        -- Help Handlers
        ['help'] = function() Chat:DisplayHelp() end,

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
        ['LoadMoreEntries'] = function() MODULES.DKPManager:LoadPrevFourWeeks() end,

        -- Database Handlers
        ['databaseReset'] = function() MODULES.Database:ResetAllDatabases() end,
    }

    -- Dev Handlers
    local DEV_SLASH_COMMANDS = {
        ['databasePopulate'] = function() MODULES.Dev:HandleSlashCommands(msg) end,
    }

    if SLASH_COMMANDS[command] then return SLASH_COMMANDS[command]() end
    if DEV_SLASH_COMMANDS[command] and PDKP:IsDev() then return DEV_SLASH_COMMANDS[command]() end
end

function Chat:DisplayHelp()
    local slash_addon = MODULES.Constants.SLASH_ADDON
    local CMD_COLOR = '|cffffaeae'

    local helpCommands = {
        { ['cmd'] = 'show / hide', ['desc'] = 'PantheonDKP window', },
        { ['cmd'] = 'bid <number>', ['desc'] = '', },
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