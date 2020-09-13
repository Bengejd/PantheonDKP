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
local Minimap = core.Minimap;
local json = core.JSON;

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
        ['GUILD_ROSTER_UPDATE']=function()
            if Guild:HasMembers() then
                UnregisterEvent(self, event);
                PDKP:InitializeGuildData()
            else
                GuildRoster();
            end
        end,
        ['PLAYER_LOGIN']=function()
            if IsInGuild() then
                GuildRoster();
            end
        end,
        ['ADDON_LOADED']=function() -- The addon finished loading, most things should be available.
            Util:Debug('Addon loaded')

            PDKP:OnInitialize(event, arg1)
            return UnregisterEvent(self, event)
        end,
        ['ZONE_CHANGED_NEW_AREA']=function() -- This allows us to detect if the GuildInfo() event is available yet.
            Raid:CheckCombatLogging()
        end,
        ['PLAYER_ENTERING_WORLD']=function()
            local initialLogin, uiReload = arg1, arg2
            core.firstLogin = initialLogin
            if uiReload then
                Util:Debug('UIReload Detected');
                PDKP:InitializeGuildData()
                if Raid:IsInRaid() then
                    Comms:SendCommsMessage('DKPOfficerReq', {}, 'RAID', nil, 'BULK', nil)
                end
            end
            Setup:OfficerWindow()
            Raid:CheckCombatLogging()
        end,
        ['WORLD_MAP_UPDATE']=function()
            return UnregisterEvent(self, event)
        end,
        ['GROUP_ROSTER_UPDATE']=function()
            Util:Debug('Group_roster_update')
            GUI:ToggleOfficerInterface()
            Raid:GetRaidInfo()
            return GUI:UpdateRaidClasses()
        end,
        ['LOOT_OPENED']=function()  -- when the loot bag is opened.
--            return Raid:AnnounceLoot()
        end,
        ['OPEN_MASTER_LOOT_LIST']=function()  -- when the master loot list is opened.
            return
        end,
        ['BOSS_KILL']=function()
--            PDKP:Print('BOSS KILL: ', self, event, arg1, arg2)
            Raid:BossKill(arg1, arg2)
        end,
        ['CHAT_MSG_SYSTEM']=function() -- Fired when yellow system text is presented.
            if arg1 and string.find(arg1, 'has been reset') ~= nil then Raid:GetLockoutTimers(true) end
        end,
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
    end
end

-- event function that happens when the addon is initialized.
function PDKP:OnInitialize(event, name)
    if (name ~= "PantheonDKP") then return end

    if Defaults.silent then Defaults:DisablePrinting(Defaults.silent) end

    PDKP:Print("Welcome,", Util:GetMyName(), "to:", core.defaults.addon_name .. ': v' .. Defaults.addon_version)

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
    --  Officer Raid Control   --
    -----------------------------

    Setup:dkpOfficer()
    item:ToolTipInit()
end

function PDKP:InitializeGuildData()
    if IsInGuild() == false or core.initialized then return end; -- Fix for players not being in guild error message.
    Guild:GetGuildData(false);
    PDKP:BuildAllData();
    core.initialized = true

    if not Comms.commsRegistered then Comms:RegisterCommCommands() end
    if not Defaults.checked_addon_version then
        Comms:SendCommsMessage('pdkpVersion', 'GUILD', Defaults.addon_version, nil, 'BULK', nil)
    end
    if not Defaults.settings_complete then Setup:InterfaceOptions() end

    DKP:DeleteOldEntries()
end

function PDKP:MessageRecieved(msg, name) -- Global handler of Messages

    if Shroud.shroudPhrases[string.lower(msg)] and Raid:IsAssist() then
        -- This should send the list to everyone in the raid, so that it just automatically pops up.
        if Raid.dkpOfficer and Raid:IsDkpOfficer() then -- We have the DKP officer established
            Util:Debug('DKP Officer is updating shrouders with ' .. name)
            return Shroud:UpdateShrouders(name)
        elseif Raid.dkpOfficer == nil and Raid:isMasterLooter() then
            Util:Debug('Master Looter is updating shrouders with ' .. name)
            return Shroud:UpdateShrouders(name)
        end
    elseif core.inviteTextCommands[string.lower(msg)] and Raid:IsAssist() then -- Sends an invite to the player
        if not Raid:IsInRaid() then
            ConvertToRaid()
        end
        InviteUnit(name)
    end
end

-- Initializes the PDKP Databases.
function PDKP:InitializeDatabases()
    core.defaults:InitDB();
    Guild:InitGuildDB()
    DKP:InitDKPDB()
    Minimap:InitMapDB()
    PDKP:InitRaidDB()
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

        if prio == nil then -- Possibly we have an item link.
            local itemName = item:GetItemInfo(itemLink)
            if itemName then
                prio = item:GetPriority(itemName)
            end
        end

        if prio then print(itemLink .. ' PRIO: ' .. prio) end
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
        if GUI.shown then return GUI:Hide()
        else return PDKP:Show()
        end
    end

    local splitMsg, name = strsplit(' ', msg)

    local safeFuncs = {
        ['show']=function() return PDKP:Show() end,
        ['hide']=function() return GUI:Hide() end,
        ['shroud']=function() return PDKP:MessageRecieved('shroud', Util:GetMyName()) end,
        ['']=function() end,
    }

    local splitFuncs = {
        ['report']=function()
            local dkp = DKP:GetPlayerDKP(name)
            if dkp == 0 then
                PDKP:Print(name .. ' has 0 dkp or was not found')
            else
                PDKP:Print(name .. ' has: ' .. dkp .. ' DKP')
            end
        end,
    }

    if safeFuncs[msg] then return safeFuncs[msg]() end
    if splitFuncs[splitMsg] then return splitMsg[msg]() end

    -- OFFICER ONLY COMMANDS
    if not core.canEdit then
        return Util:Debug('Cannot process this command because you are not an officer')
    end;

    local unsafeFuncs = {
        ['professionTracking']=function()
            if not _G['pdkpProf'] then local f, t ,c = CreateFrame("Frame", "pdkpProf"), 2383,0
                f:SetScript("OnUpdate", function(_, e)
                    c=c+e
                    if c>3 then
                        c=0
                        CastSpellByID(t)
                        if t == 2383 then t= 2580 else t=2383 end
                    end
                end)
                _G['pdkpProf']:Hide()
            end
            if _G['pdkpProf']:IsVisible() then _G['pdkpProf']:Hide() else _G['pdkpProf']:Show() end
        end,
        ['pdkpTestWho']=function()
            SendWho('bob z-"Teldrassil" r-"Night Elf" c-"Rogue" 10-15');
        end,
        ['pdkpTestAutoSync']=function()
            Comms:DatabaseSyncRequest()
        end,
        ['item']=function()
            if item then
                return Item:LinkItem();
            end
        end,
        ['historyEdit']=function()
            Setup:HistoryEdit()
        end,
        ['invite']=function()
            return Invites:Show();
            --        local tempInvites = {'Sparklenips', 'Annaliese'}
            --        for i=1, #tempInvites do
            --            InviteUnit(tempInvites[i]);
            --        end
        end,
        ['pdkpPrioWindow']=function()
            --        Setup:PrioList()
        end,
        ['verifyTables']=function()
            for _, member in pairs(Guild.members) do
                member:VerifyTables()
            end
        end,
        ['officer']=function()
            Officer:Show()
        end,
        ['raidChecker']=function()
            Raid:IsInInstance()
        end,
        ['sortHistory']=function()
            DKP:SortHistory()
        end,
        ['exportDKP']=function()
            DKP:ExportCSV()
        end,
        ['bossKill']=function()
            return Raid:BossKill(669, 'Sulfuron Harbinger');
        end,
        ['classes']=function()
            return Guild:GetClassBreakdown();
        end,
        ['timer']=function()
            return GUI:CreateTimer()
        end,
        ['pdkp_reset_all_db']=function()
            if core.Defaults.IsDebug() then
                DKP:ResetDB()
                Guild:ResetDB()
            end
        end,
        ['enableDebugging']=function()
            core.defaults:ToggleDebugging()
        end,
        ['validateTables']=function()
            DKP:ValidateTables()
        end,
        ['testJSON']=function()
            return PDKP:LoadJsonData()
        end,
        ['pdkp_template']=function() end,
    }
    if unsafeFuncs[msg] then return unsafeFuncs[msg]() end
    --if msg == 'item' and item then
    --    return Item:LinkItem();
    --end
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

function PDKP:LoadJsonData()
    local testDBDefaults = {
        profile = {}
    }

    local testData = {
        currentDB = 'Molten Core',
        arrayExample = {
            [1598513669] = {
                ["deleted"] = false,
                ["isShroud"] = false,
                ["id"] = 1598513669,
                ["reason"] = "Other",
                ["isRoll"] = false,
                ["text"] = "|cff22bb33Other - hazzard|r",
                ["members"] = {
                    "Tylrswftmend", -- [1]
                    "Corseau", -- [2]
                    "Funkorama", -- [3]
                    "Stellâ", -- [4]
                    "Primera", -- [5]
                    "Bigbootyhoho", -- [6]
                    "Laird", -- [7]
                    "Zukohere", -- [8]
                    "Oxford", -- [9]
                    "Jakemeoff", -- [10]
                    "Suprarz", -- [11]
                    "Bugaboom", -- [12]
                    "Dolamroth", -- [13]
                    "Captnutsack", -- [14]
                    "Boomerslayer", -- [15]
                    "Ones", -- [16]
                    "Honeypot", -- [17]
                    "Fawntine", -- [18]
                    "Rez", -- [19]
                    "Veltrix", -- [20]
                    "Whisp", -- [21]
                    "Alexinchains", -- [22]
                    "Inigma", -- [23]
                    "Knittie", -- [24]
                    "Mystile", -- [25]
                    "Gartog", -- [26]
                    "Varix", -- [27]
                    "Calixta", -- [28]
                    "Ihurricanel", -- [29]
                    "Thepurple", -- [30]
                    "Olerando", -- [31]
                    "Edgelawdy", -- [32]
                    "Snaildaddy", -- [33]
                    "Cloverduk", -- [34]
                    "Retkin", -- [35]
                    "Luckerdawg", -- [36]
                    "Goobimus", -- [37]
                    "Nightshelf", -- [38]
                    "Tokentoken", -- [39]
                },
            },
            lastEdit = 0,
            history = {
                all = {},
                deleted = {}
            },
        }
    }
    local test = LibStub("AceDB-3.0"):New("pdkp_test", testDBDefaults, true)
    local testDB = test.profile

    local serialized = PDKP:Serialize(DKP.dkpDB)
    local compressed = core.LibDeflate:CompressDeflate(serialized)
    local encoded = core.LibDeflate:EncodeForWoWAddonChannel(compressed)
    local completelyEncoded = Comms:DataEncoder(DKP.dkpDB)

    testDB['completelyEncoded'] = { }
    testDB['serizliedData']={ }
    testDB['encodedData']={ }
    testDB['compressed']={ }
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

    if GUI.pdkp_frame and GUI.pdkp_frame:IsVisible() then
        GUI.pdkp_frame:SetFrameStrata('HIGH')
    end

    Raid:GetLockedInfo()

end

function PDKP:CheckForUpdate(version, silent)
    local myMajor, myMinor, myPatch = strsplit('.',Defaults.addon_latest_version);
    local theirMajor, theirMinor, theirPatch = strsplit('.', version)
    myMajor, myMinor, myPatch = tonumber(myMajor), tonumber(myMinor), tonumber(myPatch)
    theirMajor, theirMinor, theirPatch = tonumber(theirMajor), tonumber(theirMinor), tonumber(theirPatch)

    if myMajor == nil or myMinor == nil or myPatch == nil then return end
    if theirMajor == nil or theirMinor == nil or theirPatch == nil then return end;

    local hasUpdate = false
    local majorMatch = theirMajor == myMajor
    local minorMatch = theirMinor == myMinor

    if theirMajor > myMajor then hasUpdate = true;
    elseif majorMatch and theirMinor > myMinor then hasUpdate = true
    elseif majorMatch and minorMatch and theirPatch > myPatch then hasUpdate = true
    end

    if hasUpdate then
        Defaults.addon_latest_version = version;
        if not Defaults.checked_addion_version then
            Defaults.checked_addion_version = true
            if silent == nil then
                PDKP:Print("Your version of PantheonDKP is out-of-date.\n The newest version is available for download through CurseForge or the Twitch app.")
            end
        end
    end
    return hasUpdate
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
    if funcName == 'pdkp_boss_kill_dkp' then return Raid:AcceptBossKillDKPUpdate(object) end;

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

local eventNames = {
    "ADDON_LOADED", "GUILD_ROSTER_UPDATE", "GROUP_ROSTER_UPDATE", "ENCOUNTER_START",
    "COMBAT_LOG_EVENT_UNFILTERED", "LOOT_OPENED", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_WHISPER",
    "CHAT_MSG_GUILD", "CHAT_MSG_LOOT", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA","BOSS_KILL", "CHAT_MSG_SYSTEM"
}

for _, eventName in pairs(eventNames) do
    events:RegisterEvent(eventName);
end
events:SetScript("OnEvent", PDKP_OnEvent); -- calls the above MonDKP_OnEvent function to determine what to do with the event


