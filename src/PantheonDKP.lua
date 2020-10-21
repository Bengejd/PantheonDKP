local addonFolder, core = ...;
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
local Settings = core.Settings;

core.firstLogin = nil;

local print_name = '|cff32A8A0PDKP|r:'

local function PDKP_OnEvent(self, event, arg1, ...)

    local arg2 = ...

    local ADDON_EVENTS = {
        ['GUILD_ROSTER_UPDATE']=function()
            if Guild:HasMembers() then
                PDKP_UnregisterEvent(events, event);
                PDKP:OnDataAvailable()
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

    PDKP:InitializeDatabases()
end

-- This function is only called when Guild data is ready to be processed.
function PDKP:OnDataAvailable()
    Guild:new();

    if GUI.pdkp_frame ~= nil then return end;

    if not Settings.db['mergedOld'] then pcall(PDKP_Merge_Old_Guild_Data) end

    GUI:Init();
    Raid:new();
    Comms:Init();
    Minimap:Init()
    Comms:RegisterCommCommands()

    GameTooltip:HookScript( "OnTooltipSetItem", PDKP_SetToolTipPrio)

    PDKP:Print('Testing', '123')
end

function PDKP:InitializeDatabases()
    local dbDefaults = {
        global = {}
    }
    local database = LibStub("AceDB-3.0"):New("pdkp_DB", dbDefaults, true)
    local next = next

    if database['global'] == nil or next(database.global) == nil then
        Util:Debug("Creating PDKP Database with default values")

        database.global['db'] = {
            ['guildDB'] = {
                ['members'] = {},
                ['numOfMembers'] = 0
            },
            ['officersDB'] = {},
            ['dkpDB'] = {
                ['lastEdit'] = 0,
                ['history'] = {
                    ['all'] = {},
                    ['deleted'] = {},
                }
            },
            ['settingsDB'] = {
                ['previous_version'] = "2.9.5",
                ['current_version'] = "2.9.5",
                ['minimapPos'] = 207,
                ['debug'] = false,
                ['ignore_from']={},
                ['minimap']={},
                ['mergedOld']=false
            },
        }
    end

    local db = database.global['db']
    core.PDKP.db = db

    core.PDKP.guildDB = db.guildDB -- or {};
    core.PDKP.officersDB = db.officersDB -- or {};
    core.PDKP.settingsDB = db.settingsDB -- or {};

    local oldGuildDBDefaults = {
        profile = {
            name = nil,
            numOfMembers = 0,
            members = {},
            officers = {},
            migrated = false,
        }
    }

    local old_guild_db = LibStub("AceDB-3.0"):New("pdkp_guildDB", oldGuildDBDefaults, true)
    old_guild_db = old_guild_db.profile
    core.PDKP.old_guild_db = old_guild_db

    local olddkpDBDefaults = {
        profile = {
            currentDB = 'Molten Core',
            members = {},
            lastEdit = 0,
            history = {
                all = {},
                deleted = {}
            },
        }
    }

    local old_dkp_db = LibStub("AceDB-3.0"):New("pdkp_dkpHistory", olddkpDBDefaults, true)
    old_dkp_db = old_dkp_db.profile
    core.PDKP.old_dkp_db = old_dkp_db

    core.PDKP.dkpDB = db.dkpDB;

    Settings:InitDB()
    DKP:InitDB()



    Util:Debug("Database finished Initializing")
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

-- Generic function that handles all the slash commands.
function PDKP:HandleSlashCommands(msg)
    if string.len(msg) == 0 then
        return GUI:TogglePDKP()
    end -- No command attached.

    Util:Debug('New command received ', msg);

    local guiCommands = {
        ['show']=function() GUI:Show() end,
        ['hide']=function() GUI:Hide() end,
    }

    if guiCommands[msg] then return guiCommands[msg]() end

    local debugCommands = {
        ['boss Kill']=function()
        end
    }

    if debugCommands[msg] and Settings:IsDebug() then return debugCommands[msg]() end

    local officerCommands = {
        ['debug']=function()
            Settings:ToggleDebugging()
        end,
    }

    if not Settings:CanEdit() then
        return Util:Debug('Cannot process this command because you are not an officer')
    end;

    if officerCommands[msg] then return officerCommands[msg]() end

    PDKP:Print('Unknown PDKP command:', msg)

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
    ---- OFFICER ONLY COMMANDS

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
end

local events = CreateFrame("Frame", "EventsFrame");

function PDKP_UnregisterEvent(self, event)
    events:UnregisterEvent(event);
end

function PDKP:Print(...)
    print('|cff44e3e0[PDKP]|r:', strjoin(" ", tostringall(...)))
end



local eventNames = {
    "ADDON_LOADED", "GUILD_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_LOGIN"
}

for _, eventName in pairs(eventNames) do
    events:RegisterEvent(eventName);
end
events:SetScript("OnEvent", PDKP_OnEvent); -- calls the above MonDKP_OnEvent function to determine what to do with the event
