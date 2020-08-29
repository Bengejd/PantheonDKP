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

core.firstLogin = nil;

-- TODO: Fix Guild members not loading on the initial login.

local function PDKP_OnEvent(self, event, arg1, ...)

    local arg2 = ...

    local ADDON_EVENTS = {
        ['GUILD_ROSTER_UPDATE']=function()
            if Guild:HasMembers() then
                PDKP_UnregisterEvent(events, event);
                Guild:new();
                GUI:Init();
            else
                GuildRoster();
            end
        end,
        ['PLAYER_LOGIN']=function()
            if IsInGuild() then
                GuildRoster();
            end
        end,
        ['PLAYER_ENTERING_WORLD']=function()
            Util:WatchVar(core, 'PDKP');
            Guild.updateCalled = false;
        end,
        ['ZONE_CHANGED_NEW_AREA']=function()

        end,
        ['ADDON_LOADED']=function()
            PDKP:OnInitialize(event, arg1)
        end,
    }

    if ADDON_EVENTS[event] then ADDON_EVENTS[event]() end
end

function PDKP:OnInitialize(event, name)
    if (name ~= "PantheonDKP") then return end

    -----------------------------
    -- Register Slash Commands --
    -----------------------------
    self:RegisterChatCommand("pdkp", "HandleSlashCommands")
    self:RegisterChatCommand("shroud", "HandleShroudCommands")
    self:RegisterChatCommand("prio", "HandlePrioCommands")
end

function PDKP:HandleShroudCommands(item)
    ---- Normal shrouding command send by a non officer, bidding on an item.
    --if item == nil or string.len(item) == 0 then
    --    return PDKP:MessageRecieved('shroud', Util:GetMyName())
    --    -- Item linked by the officer.
    --elseif core.canEdit then -- NEED TO CHECK IF THEY ARE THE ML AS WELL.
    --    -- Check to see if the GUI is open or not.
    --    if not GUI.shown then PDKP:Show() end
    --    GUI:UpdateShroudItemLink(Item:GetItemByName(item));
    --end
end

function PDKP:HandlePrioCommands(itemLink)
    --itemLink = itemLink or nil;
    --if itemLink ~= nil and itemLink ~= '' then
    --    local prio = item:GetPriority(itemLink)
    --
    --    if prio == nil then -- Possibly we have an item link.
    --        local itemName = item:GetItemInfo(itemLink)
    --        if itemName then
    --            prio = item:GetPriority(itemName)
    --        end
    --    end
    --
    --    if prio then print(itemLink .. ' PRIO: ' .. prio) end
    --else
    --end
end

-- Generic function that handles all the slash commands.
function PDKP:HandleSlashCommands(msg)

    Util:Debug('New command received ' .. msg);

    -- Commands:
    -- pdkp - Opens / closes the GUI
    -- pdkp show - Opens the GUI
    -- pdkp hide - Hides the GUI

    --if string.len(msg) == 0 then
    --    if GUI.shown then return GUI:Hide()
    --    else return PDKP:Show()
    --    end
    --end
    --
    --local splitMsg, name = strsplit(' ', msg)
    --
    --local safeFuncs = {
    --    ['show']=function() return PDKP:Show() end,
    --    ['hide']=function() return GUI:Hide() end,
    --    ['shroud']=function() return PDKP:MessageRecieved('shroud', Util:GetMyName()) end,
    --    ['']=function() end,
    --}
    --
    --local splitFuncs = {
    --    ['report']=function()
    --        local dkp = DKP:GetPlayerDKP(name)
    --        if dkp == 0 then
    --            PDKP:Print(name .. ' has 0 dkp or was not found')
    --        else
    --            PDKP:Print(name .. ' has: ' .. dkp .. ' DKP')
    --        end
    --    end,
    --}
    --
    --if safeFuncs[msg] then return safeFuncs[msg]() end
    --if splitFuncs[splitMsg] then return splitMsg[msg]() end
    --
    --if msg == 'professionTracking' then
    --    if not _G['pdkpProf'] then local f, t ,c = CreateFrame("Frame", "pdkpProf"), 2383,0
    --        f:SetScript("OnUpdate", function(_, e)
    --            c=c+e
    --            if c>3 then
    --                c=0
    --                CastSpellByID(t)
    --                if t == 2383 then t= 2580 else t=2383 end
    --            end
    --        end)
    --        _G['pdkpProf']:Hide()
    --    end
    --    if _G['pdkpProf']:IsVisible() then _G['pdkpProf']:Hide() else _G['pdkpProf']:Show() end
    --end
    --
    --if msg == 'pdkpTestWho' then
    --    SendWho('bob z-"Teldrassil" r-"Night Elf" c-"Rogue" 10-15');
    --end
    --
    ---- OFFICER ONLY COMMANDS
    --if not core.canEdit then
    --    return Util:Debug('Cannot process this command because you are not an officer')
    --end;
    --
    --if msg == 'pdkpTestAutoSync' then
    --    Comms:DatabaseSyncRequest()
    --end
    --
    --if msg == 'item' and item then
    --    return Item:LinkItem();
    --end
    --
    --if msg == 'historyEdit' then
    --    Setup:HistoryEdit()
    --end
    --
    --if msg == 'invite' then
    --    return Invites:Show();
    --    --        local tempInvites = {'Sparklenips', 'Annaliese'}
    --    --        for i=1, #tempInvites do
    --    --            InviteUnit(tempInvites[i]);
    --    --        end
    --end
    --
    --if msg == 'pdkpPrioWindow' then
    --    --        Setup:PrioList()
    --end
    --
    --if msg == 'officer' then
    --    Officer:Show()
    --end
    --
    --if msg == 'raidChecker' then
    --    Raid:IsInInstance()
    --end
    --
    --if msg == 'sortHistory' then
    --    DKP:SortHistory()
    --end
    --
    --if msg == 'exportDKP' then
    --    DKP:ExportCSV()
    --end
    --
    --if msg == 'bossKill' then
    --    return Raid:BossKill(669, 'Sulfuron Harbinger');
    --end
    --
    --if msg == 'classes' then
    --    return Guild:GetClassBreakdown();
    --end
    --
    --if msg == 'timer' then
    --    return GUI:CreateTimer()
    --end
    --
    --if msg == 'pdkp_reset_all_db' and core.Defaults:IsDebug() then
    --    DKP:ResetDB()
    --    Guild:ResetDB()
    --end
    --
    --if msg == 'enableDebugging' then
    --    core.defaults:ToggleDebugging()
    --end
    --
    --if msg == 'validateTables' then
    --    DKP:ValidateTables()
    --end
end

--function PDKP:MessageRecieved(msg, name) -- Global handler of Messages
--
--    if Shroud.shroudPhrases[string.lower(msg)] and Raid:IsAssist() then
--        -- This should send the list to everyone in the raid, so that it just automatically pops up.
--        if Raid.dkpOfficer and Raid:IsDkpOfficer() then -- We have the DKP officer established
--            Util:Debug('DKP Officer is updating shrouders with ' .. name)
--            return Shroud:UpdateShrouders(name)
--        elseif Raid.dkpOfficer == nil and Raid:isMasterLooter() then
--            Util:Debug('Master Looter is updating shrouders with ' .. name)
--            return Shroud:UpdateShrouders(name)
--        end
--    elseif core.inviteTextCommands[string.lower(msg)] and Raid:IsAssist() then -- Sends an invite to the player
--        if not Raid:IsInRaid() then
--            ConvertToRaid()
--        end
--        InviteUnit(name)
--    end
--end

local events = CreateFrame("Frame", "EventsFrame");

function PDKP_UnregisterEvent(self, event)
    events:UnregisterEvent(event);
end

local eventNames = {
    "ADDON_LOADED", "GUILD_ROSTER_UPDATE", "GROUP_ROSTER_UPDATE", "ENCOUNTER_START", "PLAYER_GUILD_UPDATE",
    "COMBAT_LOG_EVENT_UNFILTERED", "LOOT_OPENED", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_WHISPER",
    "CHAT_MSG_GUILD", "CHAT_MSG_LOOT", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA","BOSS_KILL", "CHAT_MSG_SYSTEM"
}

for _, eventName in pairs(eventNames) do
    events:RegisterEvent(eventName);
end
events:SetScript("OnEvent", PDKP_OnEvent); -- calls the above MonDKP_OnEvent function to determine what to do with the event
