local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;

local Chat = {}

local trim, lower = strtrim, strlower
local contains = tContains
local C_Timer = C_Timer

local chatCache = {};
local invite_commands = nil;
local dkp_commands = { '!bid', '!dkp', '!cap' }

local CMD_COLOR = '|cffffaeae'

local msgPrefix = "PDKP Auto Response:"

function Chat:Initialize()
    PDKP.CORE:RegisterChatCommand("pdkp", function(msg)
        Chat:_HandleSlashCommands(msg)
    end)

    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(_, event, msg, author, ...)
        local isInviteCmd, isDKPCmd, shouldProcessMessage, shouldFilterMessage = false, false, false, false;
        author = Utils:RemoveServerName(author)
        msg = lower(trim(msg))
        local cmd, arg1 = PDKP.CORE:GetArgs(msg, 2)

        if invite_commands == nil then
            invite_commands = MODULES.RaidManager.invite_commands or {};
        end

        if (PDKP.canEdit and contains(dkp_commands, cmd)) then
            shouldProcessMessage = true;
            isDKPCmd = true;
        elseif contains(invite_commands, msg) then
            shouldProcessMessage = true;
            isInviteCmd = true;
        end

        if shouldProcessMessage then
            shouldFilterMessage = true
            if chatCache[author] == nil then
                chatCache[author] = {};
                chatCache[author]['messages'] = {}
                chatCache[author]['timer'] = nil;
            end

            if chatCache[author]["messages"][msg] == nil then
                local type = '';
                if isDKPCmd then
                    type = 'DKP'
                elseif isInviteCmd then
                    type = 'Invite'
                end
                chatCache[author]["messages"][msg] = {
                    ['cmd'] = cmd,
                    ['msg'] = msg,
                    ['amt'] = arg1,
                    ['type'] = type;
                    ['author'] = author,
                }
            end

            if chatCache[author]['timer'] ~= nil then
                chatCache[author]['timer']:Cancel();
                chatCache[author]['timer'] = nil;
            end
            chatCache[author]['timer'] = C_Timer.NewTicker(0.5, function()
                Chat:HandleChatEvent(author)
            end, 1)
        end
        return shouldFilterMessage
    end)
end

function Chat:HandleChatEvent(author)
    PDKP:PrintD("Handling Chat Event from", author);
    for index, message in pairs(chatCache[author]["messages"]) do
        if message['type'] == 'Invite' then
            Chat:_HandleInviteMsg(author);
        elseif message['type'] == 'DKP' then
            Chat:_HandleDKPMsg(message);
        end
        chatCache[author]["messages"][index] = nil;
    end
    wipe(chatCache[author]["messages"]);
end

-----------------------------
--     Invite Functions    --
-----------------------------

function Chat:_HandleInviteMsg(name)
    local ignore_from = MODULES.RaidManager.ignore_from or {};

    if contains(ignore_from, lower(name)) then
        local player_name = '|cffffaeae' .. name .. '|r'
        return PDKP.CORE:Print(player_name, "'s invite request was ignored")
    end

    MODULES.GroupManager:InvitePlayer(name)
end

function Chat:_HandleDKPMsg(msg)
    local cmd, amt, author = msg['cmd'], msg['amt'], msg['author'];
    local member = MODULES.GuildManager:GetMemberByName(author);
    local memberDKP = member:GetDKP();

    local chatMessage = nil;

    if cmd == '!bid' then
        if not MODULES.AuctionManager:IsAuctionInProgress() then
            chatMessage = "There are no active auctions at this time."
        elseif not MODULES.AuctionManager:CanChangeAuction() then
            chatMessage = "Can't accept bid, please whisper the Raid Leader, DKP Officer or the Master Looter instead."
        else
            local bid = tonumber(amt)
            -- Set their bid to their max DKP.
            if not bid then
                if amt == "max" then
                    bid = memberDKP;
                elseif amt == "cancel" then
                    bid = 0
                end
            end

            if bid and type(bid) == "number" then
                if bid <= memberDKP and bid >= 1 then
                    local bidder_info = { ['name'] = author, ['bid'] = bid, ['dkpTotal'] = memberDKP }
                    MODULES.CommsManager:SendCommsMessage('AddBid', bidder_info)
                    if amt == "cancel" then
                        chatMessage = "Your bid has been canceled";
                    else
                        chatMessage = "Your bid was received";
                    end
                elseif bid <= 0 then
                    chatMessage = "You cannot bid 0 or negative DKP";
                else
                    chatMessage = "Your bid of " .. bid .. " exceeds your total dkp of " .. memberDKP;
                end
            else
                chatMessage = "You sent an invalid bid amount. Try: '!bid 20' or '!bid max', instead."
            end
        end
    elseif cmd == '!dkp' then
        chatMessage = "You have " .. memberDKP .. " dkp";
    elseif cmd == '!cap' then
        local members = MODULES.GuildManager.members;
        local _, groupMembers = MODULES.GroupManager:GetRaidMemberObjects();
        local guildCap, groupCap = 0, 0;
        for _, groupMember in pairs(groupMembers) do
            local dkp = groupMember:GetDKP();
            if dkp > groupCap then
                groupCap = dkp;
            end
        end
        for _, guildMember in pairs(members) do
            local dkp = guildMember:GetDKP();
            if dkp > guildCap then
                guildCap = dkp;
            end
        end
        chatMessage = "[Guild Cap]: " .. tostring(guildCap) .. " [Raid Cap]: " .. tostring(groupCap);
    end

    if chatMessage ~= nil then
        SendChatMessage(msgPrefix .. " " .. chatMessage, "WHISPER", nil, author);
    else
        print(chatMessage);
    end
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
    if msg == "" then
        msg = 'pdkp'
    end --- Default command doesn't display in the msg.

    local command = PDKP.CORE:GetArgs(msg)

    local SLASH_COMMANDS = {
        --Help Handlers
        ['help'] = function()
            Chat:_DisplayHelp()
        end,

        -- Main Handlers
        ['pdkp'] = function()
            MODULES.Main:HandleSlashCommands(msg)
        end,
        ['show'] = function()
            MODULES.Main:HandleSlashCommands(msg)
        end,
        ['hide'] = function()

        end,

        -- Auction Handlers
        ['bid'] = function()
            MODULES.AuctionManager:HandleSlashCommands(msg)
        end,
        ['shroud'] = function()
            MODULES.AuctionManager:HandleSlashCommands(msg)
        end,
        ['thirst'] = function()
            MODULES.AuctionManager:HandleSlashCommands(msg)
        end,

        -- DKP Handlers
        ['LoadMoreEntries'] = function()
            MODULES.DKPManager:LoadPrevFourWeeks()
        end,

        -- Database Handlers
        ['databaseReset'] = function()
            MODULES.Database:ResetAllDatabases()
        end,

        ['recalibrateTotals'] = function()
            PDKP.CORE:Print("Calibrating DKP Totals")
            MODULES.DKPManager:RecalibrateDKP()
        end,
    }
    if SLASH_COMMANDS[command] then
        return SLASH_COMMANDS[command]()
    end

    -- Dev Handlers
    local DEV_SLASH_COMMANDS = {
        ['whoTest'] = true, ['databasePopulate'] = true,
        ['largeDataSync'] = true,
        ['bossKillTest'] = true,
        ['watchFramerate'] = true,
        ['unregisterCommTest'] = true, ['TestAutomaticEntries'] = true,
    }
    if DEV_SLASH_COMMANDS[command] and PDKP:IsDev() then
        return MODULES.Dev:HandleSlashCommands(msg)
    end
end

function Chat:_DisplayHelp()
    local slash_addon = MODULES.Constants.SLASH_ADDON

    local helpCommands = {
        { ['cmd'] = 'show / hide', ['desc'] = 'PantheonDKP window', },
        { ['cmd'] = 'bid <number>', ['desc'] = 'To place a bid', },
        --{ ['cmd'] = 'bid <itemLink>', ['desc'] = 'To start a bid', },
        { ['cmd'] = 'databaseReset', ['desc'] = 'To wipe your database', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
        --{ ['cmd'] = '', ['desc'] = '', },
    }

    print(" ")

    for i = 1, #helpCommands do
        local helpCmd = helpCommands[i]
        local cmd = CMD_COLOR .. helpCmd['cmd'] .. ':|r'
        local msg = slash_addon .. ' ' .. cmd .. ' ' .. helpCmd['desc']
        print(msg)
    end
    print(" ")
end

MODULES.ChatManager = Chat
