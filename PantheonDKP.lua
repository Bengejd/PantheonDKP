local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Invites = core.Invites;
local Raid = core.Raid;
local Comms = core.Comms;
local Setup = core.Setup;
local Import = core.Import;
local item = core.Item;
local Member = core.Member;
local Officer = core.Officer;


local PlaySound = PlaySound

--[[
    KNOWN BUGS:
    TODO: Sending messages to offline members results in massave error message.
]]

--[[
    FEATURE REQUESTS:
        TODO: SILENT MODE - Doesn't print when an update comes through.
        TODO: Minimap Icon
        TODO: Auto-shroud wishlist.
            - Be able to move items up and down in priority when they are linked. That way your most coveted items are
            - automatically shrouded upon first?
 ]]

PDKP.data = {} -- All of the data that is supposed to be shown.
PDKP.raidData = {}
GUI.selected = {}
core.initialized = false
core.filterOffline = nil
core.databasesInitialized = false
core.firstLogin = true

core.inviteTextCommands = {
    ['invite']=true, ['inv']=true
}

-- Generic event handler that handles all of the game events & directs them.
-- This is the FIRST function to run on load triggered registered events at bottom of file
local function PDKP_OnEvent(self, event, arg1, ...)

    local arg2 = ...

    local PDKP_SIMPLE_EVENT_FUNCS = {
        ['ADDON_LOADED']=function() -- The addon finished loading, most things should be available.
            Util:Debug('Addon loaded')

            PDKP:OnInitialize(event, arg1)
            return UnregisterEvent(self, event)
        end,
        ['ZONE_CHANGED_NEW_AREA']=function() -- This allows us to detect if the GuildInfo() event is available yet.
            PDKP:InitializeGuildData()
            if core.firstLogin then Comms:DatabaseSyncRequest() end
            return UnregisterEvent(self, event)
        end,
        ['PLAYER_ENTERING_WORLD']=function()
            local initialLogin, uiReload = arg1, arg2
            core.firstLogin = initialLogin
            if uiReload then PDKP:InitializeGuildData() end
        end,
        ['WORLD_MAP_UPDATE']=function()
            return UnregisterEvent(self, event)
        end,
        ['GUILD_ROSTER_UPDATE']=function()
            return UnregisterEvent(self, event)
        end,
        ['GROUP_ROSTER_UPDATE']=function()
            return Raid:GetRaidInfo()
        end,
        ['LOOT_OPENED']=function()  -- when the loot bag is opened.
            return Raid:AnnounceLoot()
        end,
        ['OPEN_MASTER_LOOT_LIST']=function()  -- when the master loot list is opened.
            return
        end,
        ['']=function() end,
        ['']=function() end,
        ['']=function() end,
    }

    if PDKP_SIMPLE_EVENT_FUNCS[event] then PDKP_SIMPLE_EVENT_FUNCS[event]()
    elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then -- uses the same arguments
        local msg = arg1;
        local playerName, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _= ...;
        playerName = Util:RemoveServerName(playerName)
        return PDKP:MessageRecieved(msg, playerName)
    elseif event == "CHAT_MSG_WHISPER" then
        local _, _, _, arg4,_, _, _,_, _, _, _, _ = ...;
        local msg = arg1;
        local name = arg4;
        PDKP:MessageRecieved(msg, name)
        return
    elseif event == "CHAT_MSG_GUILD" then return
    elseif event == "BOSS_KILL" then
        --        PDKP:Print(self, event, arg1); -- TABLE, BOSS_KILL, EVENTID
        --        Raid:BossKill(event, arg1);
        return
    end
end

-- event function that happens when the addon is initialized.
function PDKP:OnInitialize(event, name)
    if (name ~= "PantheonDKP") then return end

    PDKP:Print("Welcome,", Util:GetMyName(), "to:", core.defaults.addon_name)

    -----------------------------
    -- Register Slash Commands --
    -----------------------------
    self:RegisterChatCommand("pdkp", "HandleSlashCommands")
    self:RegisterChatCommand("shroud", "HandleShroudCommands")
    self:RegisterChatCommand("prio", "HandlePrioCommands")

    -----------------------------
    -- Register PDKP Databases --
    -----------------------------
    PDKP:InitializeDatabases();

    -----------------------------
    -- Register Communications --
    -----------------------------

    Comms:RegisterCommCommands()

    -----------------------------
    --  Officer Raid Control   --
    -----------------------------

    Setup:dkpOfficer()
end

function PDKP:InitializeGuildData()
    if IsInGuild() == false then return end; -- Fix for players not being in guild error message.

    Guild:GetGuildData(false);
    DKP:VerifyTables()
    PDKP:BuildAllData();
    core.initialized = true
end

function PDKP:MessageRecieved(msg, name) -- Global handler of Messages
    if Shroud.shroudPhrases[string.lower(msg)] and Raid:isMasterLooter() then
        -- This should send the list to everyone in the raid, so that it just automatically pops up.
        Util:Debug('Updating shrouders with ' .. name)
        Shroud:UpdateShrouders(name)
    elseif core.inviteTextCommands[string.lower(msg)] and Raid:IsAssist() then -- Sends an invite to the player
        InviteUnit(name)
    end
end

-- Initializes the PDKP Databases.
function PDKP:InitializeDatabases()
    Guild:InitGuildDB()
    DKP:InitDKPDB()
    core.databasesInitialized = true
end

function PDKP:HandleShroudCommands(item)
    -- Normal shrouding command send by a non officer, bidding on an item.
    if item == nil or string.len(item) == 0 then
        return PDKP:MessageRecieved('shroud', Util:GetMyName())
    -- Item linked by the officer.
    elseif core.canEdit then -- NEED TO CHECK IF THEY ARE THE ML AS WELL.
        -- Check to see if the GUI is open or not.
        if not GUI.shown then PDKP:Show() end
        GUI:UpdateShroudItemLink(Item:GetItemByName(item));
    end
end

function PDKP:HandlePrioCommands(itemLink)
    itemLink = itemLink or nil;
    if itemLink ~= nil and itemLink ~= '' then
        local prio = item:GetPriority(itemLink)

        if prio == 'Undefined' then -- Possibly we have an item link.
            local status, itemName = pcall(item:GetItemInfo(itemLink))
            prio = item:GetPriority(itemName)
        end
        print(itemLink .. ' PRIO: ' .. prio)
    else
    end
end

-- Generic function that handles all the slash commands.
function PDKP:HandleSlashCommands(msg, item)

    -- Commands:
    -- pdkp - Opens / closes the GUI
    -- pdkp show - Opens the GUI
    -- pdkp hide - Hides the GUI

    if string.len(msg) == 0 then
        if GUI.shown then
        return GUI:Hide()
        else PDKP:Show()
        end
    elseif msg == 'show' then
        return PDKP:Show()
    elseif msg == 'hide' then
        return GUI:Hide()
    end

    if msg == 'shroud' then
        return PDKP:MessageRecieved('shroud', Util:GetMyName())
    end

    local splitMsg, name = strsplit(' ', msg)

    if splitMsg == 'report' then
        local dkp = DKP:GetPlayerDKP(name)
        if dkp == 0 then
            PDKP:Print(name .. ' has 0 dkp or was not found')
        else
            PDKP:Print(name .. ' has: ' .. dkp .. ' DKP')
        end
    end

    if msg == 'pdkpTestWho' then
        SendWho('bob z-"Teldrassil" r-"Night Elf" c-"Rogue" 10-15');
    end

    -- OFFICER ONLY COMMANDS
    if not core.canEdit then
        return Util:Debug('Cannot process this command because you are not an officer')
    end;

    if msg == 'pdkpTestDataImport' then
        return Import:TestDataImport()
    end

    if msg == 'pdkpTestValidateTables' then
        local invalidMembers = {}
        for key, member in pairs(Guild.members) do
            member:ValidateTable()

--            if hasEntries then break end;
        end
    end

    if msg == 'TestDatabaseCompression' then
        Comms:TestNonEncoded()
    end

    if msg == 'pdkpTestAutoSync' then
        Comms:DatabaseSyncRequest()
    end

    if msg == 'item' and item then
        return Item:LinkItem();
    end

    if msg == 'invite' then
        return Invites:Show();
        --        local tempInvites = {'Sparklenips', 'Annaliese'}
        --        for i=1, #tempInvites do
        --            InviteUnit(tempInvites[i]);
        --        end
    end

    if msg == 'officer' then
        Officer:Show()
    end

    if msg == 'sortHistory' then
        DKP:SortHistory()
    end

    if msg == 'pdkpExportDKP' then
        Setup:dkpExport()
    end

    if msg == 'bossKill' then
        return Raid:BossKill(663, 'Lucifron');
    end

    if msg == 'classes' then
        return Guild:GetClassBreakdown();
    end

    if msg == 'timer' then
        return GUI:CreateTimer()
    end

    if msg == 'pdkp_reset_all_db' and core.defaults.debug then
        DKP:ResetDB()
        Guild:ResetDB()
    end

    if msg == 'enableDebugging' then
        core.defaults.debug = true
    end

    if msg == 'validateTables' then
        DKP:ValidateTables()
    end


end

function PDKP:BuildAllData()
    PDKP.data = {};
    for _, member in pairs(Guild.members) do
        if type(member) == type({}) then
            setmetatable(member, Member); -- Set the metatable so we used Members's __index
            table.insert(PDKP.data, member)
        end
    end
end

function PDKP:GetAllTableData()
    return PDKP.data;
end

function PDKP:GetDataCount()
    return table.getn(PDKP.data);
end

-----------------------------
-- UI FUNCTIONS       --
-----------------------------

function PDKP:GetCharName()
    return UnitName("PLAYER")
end

-- Shows the PDKP UI
function PDKP:Show()
    if GUI.shown then return end -- Don't open more than one instance of PDKP
    if not core.initialized then return PDKP:Print("Initialization has not finished...") end

    PlaySound(826)

    --    print('PDKP_UID: ', core.defaults.pdkp_is_in_guild)

    Setup:MainUI()
    pdkp_init_scrollbar()

    -- Displays the current character's dkp at the top for accessability.
    GUI:UpdateEasyStats()

    -- Automatically update the online status regardless of whether it's checked, when the app is reopened.
    GUI:UpdateOnlineStatus(core.filterOffline)

    GUI.pdkp_frame:Show()
    GUI.shown = true;
    GUI.HistoryCheck.frame:Show()

    if GUI.reasonDropdown then GUI.reasonDropdown.frame:Show() end;
    if GUI.raidDropdown then GUI.raidDropdown.frame:Show() end;

end

-----------------------------
--     GLOBAL FUNCTIONS    --
-----------------------------


-- General handler for template object clicks.
function pdkp_template_function_call(funcName, object, clickType, buttonName)
    if funcName == "Hide" then return GUI:Hide() end

    if funcName == "pdkp_entry_clicked" then return GUI:EntryClicked(object, clickType, buttonName) end;
    if funcName == 'pdkp_entry_control_clicked' then return GUI:EntryControlClicked(object, clickType, buttonName) end;
    if funcName == 'pdkp_entry_shift_clicked' then return GUI:EntryShiftClicked(object, clickType, buttonName) end;

    if funcName == "pdkp_dkp_table_sort" then return GUI:pdkp_dkp_table_sort(object) end;
    if funcName == "pdkp_dkp_scrollbar_Update" then return GUI:pdkp_dkp_scrollbar_Update() end;
    if funcName == "pdkp_dkp_table_filter_class" then return GUI:pdkp_dkp_table_filter_class(object) end;
    if funcName == 'pdkp_change_table_view' then return GUI:pdkp_change_view(object) end;

    if funcName == 'pdkp_toggle_online' then return GUI:UpdateOnlineStatus(object) end;
    if funcName == 'pdkp_in_raid_checkbox' then return GUI:ToggleInRaid(object) end;
    if funcName == 'pdkp_dkp_table_filter' then return pdkp_dkp_table_filter() end;

    if funcName == 'pdkp_toggle_selected' then return GUI:pdkp_toggle_selected() end;
    if funcName == 'GetSelectedFilterStatus' then return GUI:GetSelectedFilterStatus() end;
    if funcName == 'SearchInputUpdated' then return GUI:SearchInputUpdated(object) end
    if funcName == 'pdkp_dkp_update' then return DKP:ConfirmChange() end;
    if funcName == 'pdkp_boss_kill_dkp' then return Raid:AcceptDKPUpdate(object) end;

    if funcName == 'pdkp_quick_shroud' then return GUI:QuickCalculate('shroud') end;
    if funcName == 'pdkp_quick_roll' then return GUI:QuickCalculate('roll') end;

    if funcName == 'toggleSubmitButton' then return GUI:ToggleSubmitButton() end;

    if funcName == 'pdkp_select_all_classes' then return GUI:ToggleAllClasses(object) end;

    if funcName == 'pdkp_prio_hide' then return GUI.prio:Hide() end;

    if funcName == 'pdkp_select_all_filtered_checkbox' then return GUI:SelectAllVisible() end
end


function UnregisterEvent(self, event)
    self:UnregisterEvent(event);
end

--seterrorhandler(function(msg)
--    print('PDKP ERROR: ', msg);
--end);


local events = CreateFrame("Frame", "EventsFrame");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("GUILD_ROSTER_UPDATE");
events:RegisterEvent("GROUP_ROSTER_UPDATE");
events:RegisterEvent("ENCOUNTER_START"); -- FOR TESTING PURPOSES.
events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED"); -- NPC kill event
events:RegisterEvent("LOOT_OPENED");
events:RegisterEvent("CHAT_MSG_RAID");
events:RegisterEvent("CHAT_MSG_RAID_LEADER");
events:RegisterEvent("CHAT_MSG_WHISPER");
events:RegisterEvent("CHAT_MSG_GUILD");
events:RegisterEvent("CHAT_MSG_LOOT"); -- someone selects need, greed, passes, rolls, receives
events:RegisterEvent("PLAYER_ENTERING_WORLD");
events:RegisterEvent("ZONE_CHANGED_NEW_AREA");
events:RegisterEvent("BOSS_KILL");
events:SetScript("OnEvent", PDKP_OnEvent); -- calls the above MonDKP_OnEvent function to determine what to do with the event