local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI

local Options = {}

local strlower = string.lower

function Options:Initialize()
    self.db = MODULES.Database:Settings()
    self:_InitializeDBDefaults()
    self:SetupLDB()
end

function Options:SetupLDB()
    local pdkp_options = {
        name = "PantheonDKP",
        handler = PDKP,
        type = "group",
        childGroups = "tab",
        args = {
            showMinimapButton = {
                type = "toggle",
                name = "Show the Minimap button",
                desc = "Display a Minimap button to quickly access the addon interface or options",
                get = function(info) return not self.db['minimap'].hide end,
                set = function(info, val)
                    if val then GUI.Minimap:Show() else GUI.Minimap:Hide() end
                    self.db['minimap'].hide = not val
                end,
                width = 2.5,
                order = 1,
            },
            ignorePUGS = {
                type = "toggle",
                name = "Ignore PUGS",
                desc = "Ignore PUG auto invite requests",
                get = function(info) return not self.db['ignore_pugs'] end,
                set = function(info, val)
                    GUI.RaidTools.options['ignore_PUGS']:SetChecked(val)
                    self.db['ignore_pugs'] = not val
                end,
                width = 2.5,
                order = 2,
            },
            tab1 = {
                type = "group",
                name = "Syncing",
                width = "full",
                order = 3,
                args = {
                    spacer1 = {
                        type = "description",
                        name = "...Coming soon...",
                        width = "full",
                        order = 2,
                    },
                },
            },
        }
    }

    if true then
        PDKP.CORE:Print("Setting up dev interface");
        --pdkp_options['args']['tab9'] = {
        --    type = "group",
        --    name = "Dev",
        --    width = "full",
        --    order = 9,
        --    args = {
        --        devConsole = {
        --            type = "toggle",
        --            name = "Enable Console",
        --            desc = "Toggle the dev console",
        --            get = function(info) return PDKP.enableConsole end,
        --            set = function(info, val)
        --                return MODULES.Dev:ToggleSetting('enableConsole', val)
        --            end,
        --            width = 2.5,
        --            order = 1,
        --        },
        --        showInternalDKP = {
        --            type = "toggle",
        --            name = "Show Internal DKP",
        --            desc = "Show the true DKP values (not rounded)",
        --            get = function(info) return PDKP.showInternalDKP end,
        --            set = function(info, val)
        --                return MODULES.Dev:ToggleSetting('showInternalDKP', val)
        --            end,
        --            width = 2.5,
        --            order = 2,
        --        },
        --        showHistoryIds = {
        --            type = "toggle",
        --            name = "Show History IDS",
        --            desc = "Show entry history IDs",
        --            get = function(info) return PDKP.showHistoryIds end,
        --            set = function(info, val)
        --                return MODULES.Dev:ToggleSetting('showHistoryIds', val)
        --            end,
        --            width = 2.5,
        --            order = 3,
        --        },
        --    }
        --}
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable("PantheonDKP", pdkp_options, nil)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PantheonDKP"):SetParent(InterfaceOptionsFramePanelContainer)
end

function Options:_InitializeDBDefaults()
    if type(self.db['minimap']) ~= 'table' then
        self.db['minimap'] = nil;
    end

    self.db['ignore_from'] = self.db['ignore_from'] or {}
    self.db['minimap'] = self.db['minimap'] or { ['pos'] = 207, ['hide'] = false }
    self.db['sync'] = self.db['sync'] or {}
    self.db['ignore_pugs'] = self.db['ignore_pugs'] or true
    self.db['invite_commands'] = self.db['invite_commands'] or { 'inv', 'invite' };

    if next(self.db['sync']) == nil then
        self.db['sync'] = {
            ['lastSyncSent'] = nil,
            ['officerSyncs'] = {},
            ['totalEntries'] = 0,
            ['autoSync'] = true,
        }
    end
end

function Options:IsPlayerIgnored(playerName)
    for _, name in pairs(self.db['ignore_from']) do
        if strlower(playerName) == strlower(name) then
            return true
        end
    end
    return false
end

function Options:GetInviteCommands()
    return self.db['invite_cmds'] or { 'inv', 'invite' }
end

MODULES.Options = Options
