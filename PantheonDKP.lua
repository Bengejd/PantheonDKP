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


local PlaySound = PlaySound

--[[
    KNOWN BUGS:
]]

--[[
    FEATURE REQUESTS:
        - Show MS > OS > Roll for pdkp shrouding.
        - Display what classes / specs are allowed to roll on certain items.
        - When an item is linked for distribution, throw a RW out for people to see.
 ]]

PDKP.data = {} -- All of the data that is supposed to be shown.
PDKP.raidData = {}
GUI.selected = {}
core.initialized = false
core.filterOffline = nil

-- Generic event handler that handles all of the game events & directs them.
-- This is the FIRST function to run on load triggered registered events at bottom of file
local function PDKP_OnEvent(self, event, arg1, ...)
    if event == "ADDON_LOADED" then
        Util:Debug('Addon loaded')
        PDKP:OnInitialize(event, arg1)
        UnregisterEvent(self, event)
        return
    elseif event == "PLAYER_ENTERING_WORLD" then
        local arg1, arg2, arg3, arg4,arg5, _, _,_, _, _, _, _ = ...;
--        print(arg1, arg2)
--        print(event, ...)
       -- UnregisterEvent(self, event)
        return
    elseif event == "GUILD_ROSTER_UPDATE" then
--        Guild:GetGuildData();
--        DKP:SyncWithGuild();
        return;
    elseif event == "GROUP_ROSTER_UPDATE" then
        Raid:GetRaidInfo()
        return
    elseif event == "ENCOUNTER_START" then return -- for testing purposes
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then return -- NPC kill event
    elseif event == "LOOT_OPENED" then
        Raid:AnnounceLoot()
        return -- when the loot bag is opened.
    elseif event == "OPEN_MASTER_LOOT_LIST" then return -- when the master loot list is opened.
    elseif event == "CHAT_MSG_RAID" then
        local msg = arg1;
        local playerName, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _= ...;
        playerName = Util:RemoveServerName(playerName)
        PDKP:MessageRecieved(msg, playerName)
        return
    elseif event == "CHAT_MSG_RAID_LEADER" then return
    elseif event == "CHAT_MSG_WHISPER" then
        local _, _, _, arg4,_, _, _,_, _, _, _, _ = ...;
        local msg = arg1;
        local name = arg4;
        PDKP:MessageRecieved(msg, name)
        return
    elseif event == "CHAT_MSG_GUILD" then return

    elseif event == "ZONE_CHANGED_NEW_AREA" then return
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

    -----------------------------
    -- Register PDKP Databases --
    -----------------------------
    PDKP:InitializeDatabases();

    -----------------------------
    --  Initialize Addon Data  --
    -----------------------------

    Guild:GetGuildData(false);
    DKP:SyncWithGuild();

    PDKP:BuildAllData();

    -----------------------------
    -- Register Communications --
    -----------------------------

    Comms:RegisterCommCommands()
end

function PDKP:MessageRecieved(msg, name) -- Global handler of Messages
    if Shroud.shroudPhrases[string.lower(msg)] and (Raid:isMasterLooter() or Defaults.debug) then
        -- This should send the list to everyone in the raid, so that it just automatically pops up.
        print(name)
        Shroud:UpdateShrouders(name)
    end
end

-- Initializes the PDKP Databases.
function PDKP:InitializeDatabases()
    Guild:InitGuildDB()
    DKP:InitDKPDB()

--    DKP:ImportMonolithData()
end

function PDKP:HandleShroudCommands(item)
    -- Normal shrouding command send by a non officer, bidding on an item.
    if item == nil or string.len(item) == 0 then
        return Shroud:ShroudingSent('shroud', Util:GetMyName());
    -- Item linked by the officer.
    elseif core.canEdit then -- NEED TO CHECK IF THEY ARE THE ML AS WELL.

        -- Check to see if the GUI is open or not.
        if not GUI.shown then PDKP:Show() end
        GUI:UpdateShroudItemLink(Item:GetItemByName(item));
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

    -- OFFICER ONLY COMMANDS
    if not core.canEdit then return end;

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
    end

    if msg == 'test_boss' then
        Raid:GetCurrentRaid()
    end

    if msg == 'test_getML' then
        Raid:isMasterLooter()
    end

    if msg == 'pdkp_testing_com' then
        Comms:pdkp_send_comm()
    end

    if msg == 'pdkp_getTime' then
        print(Util:Format12HrDateTime(GetServerTime()))
    end

    if msg == 'importDKP' then
        DKP:ImportMonolithData()
    end

    if msg == 'TestImportData' then
        Import:AcceptData()
    end

    if msg == 'enableDebugging' then
        core.defaults.debug = true
    end

    if msg == 'validateTables' then
        DKP:ValidateTables()
    end
end

function PDKP:BuildAllData()
    -- Pug Data -- Need to think of clever solution for this!
    local dkpEntries = DKP:GetMembers();
    local gMembers = Guild:GetMembers();

    PDKP.data = {};

    local errorText;

    for i=1, #gMembers do
        local gMember = gMembers[i];

        -- Check for weird gMember bug where shit is missing?
        if gMember.name then
            local dkpEntry = dkpEntries[gMember.name];

            if gMember and dkpEntry then
                gMember.dkpTotal = dkpEntry.dkpTotal;
                table.insert(PDKP.data, gMember);
            elseif gMember.name then
                errorText = 'BuildAllData...Member was not found ' .. gMember.name;
            else
                errorText = 'BuildAllData Initilization... Index: ' .. i
            end

        else
            errorText = 'BuildAllData...Improperly created member ' .. i;
        end
        if errorText then Util:ThrowError(errorText); end
        errorText = nil;
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
end


function UnregisterEvent(self, event)
    self:UnregisterEvent(event);
end

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