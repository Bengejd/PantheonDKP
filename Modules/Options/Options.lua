local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI


local Options = {}

local strlower = string.lower
local GetServerTime = GetServerTime

function Options:Initialize()
    self.db = MODULES.Database:Settings() or {};
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
                        name = "Once per day, per officer, your addon will automatically sync the last two weeks worth of data. Auto sync will not work while in a dungeon, raid, battleground or arena.",
                        width = "full",
                        order = 1,
                    },
                    autoSync = {
                        type = "toggle",
                        name = "Auto Sync",
                        desc = "Synchronize DKP entries with officers automatically, once per day.",
                        get = function(info) return self.db['sync']['autoSync'] end,
                        set = function(info, val)
                            self.db['sync']['autoSync'] = val
                        end,
                        width = 2.5,
                        order = 2,
                    },
                    spacer2 = {
                        type = "description",
                        name = "These values decide how many entries you want to process at a time when receiving a push (auto or manual) from an officer. Higher values result in faster processing, but may cause lag.",
                        width = "full",
                        order = 3,
                    },
                    processingChunkSize = {
                        type = "select",
                        name = "Processing Chunk Size",
                        values = {
                            [2] = "2x",
                            [3] = "3x",
                            [4] = "4x",
                            [5] = "5x",
                        },
                        desc = "The amount of items you want to process in one frame update.",
                        get = function(info) return self.db['sync']['processingChunkSize'] or 2 end,
                        set = function(info, val)
                            self.db['sync']['processingChunkSize'] = val
                        end,
                        style = "dropdown",
                        width = 1,
                        order = 4,
                    },
                    decompressChunkSize = {
                        type = "select",
                        name = "Decompression Chunk Size",
                        desc = "The amount of items you want to decompress in one frame update.",
                        values = {
                            [2] = "2x",
                            [4] = "4x",
                            [8] = "8x",
                            [16] = "16x",
                            [32] = "32x",
                        },
                        style = "dropdown",
                        get = function(info) return self.db['sync']['decompressChunkSize'] or 4 end,
                        set = function(info, val)
                            self.db['sync']['decompressChunkSize'] = val
                        end,
                        width = 1,
                        order = 5,
                    },
                },
            },
            tab2 = {
                type = "group",
                name = "Database",
                width = "full",
                order = 4,
                args = {
                    spacer0Tab2 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 1,
                    },
                    createBackup = {
                        type = "execute",
                        name = "Create DB Backup",
                        desc = "Create a database snapshot for use in the future",
                        func = function()
                            MODULES.Database:CreateSnapshot()
                        end,
                        disabled = function()
                            return MODULES.Database:HasSnapshot()
                        end,
                        width = 1,
                        order = 1,
                    },
                    spacer1Tab2 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 2,
                    },
                    ApplyBackup = {
                        type = "execute",
                        name = "Restore DB Backup",
                        desc = "Restore your database to it's previously backed up state",
                        disabled = function()
                            return not MODULES.Database:HasSnapshot()
                        end,
                        func = function()
                            MODULES.Database:ApplySnapshot()
                        end,
                        width = 1,
                        order = 3,
                    },
                    spacer2Tab2 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 4,
                    },
                    ResetBackup = {
                        type = "execute",
                        name = "Wipe DB Backup",
                        desc = "Wipe your database backup",
                        func = function()
                            MODULES.Database:ResetSnapshot()
                        end,
                        disabled = function()
                            return not MODULES.Database:HasSnapshot()
                        end,
                        width = 1,
                        order = 5,
                    },
                    spacer3Tab2 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 6,
                    },
                    ResetAllDB = {
                        type = "execute",
                        name = "Purge All Databases",
                        desc = "This is irreversible. All database tables will be reset along with all settings. Backups will not be affected.",
                        func = function()
                            MODULES.Database:ResetAllDatabases()
                            ReloadUI()
                        end,
                        width = 1,
                        order = 7,
                    },
                    spacer4Tab2 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 8,
                    },
                },
            },
        }
    }

    --@do-not-package@
    if PDKP:IsDev() then
        PDKP.CORE:Print("Setting up dev interface");
        pdkp_options['args']['tab9'] = {
            type = "group",
            name = "Dev",
            width = "full",
            order = 9,
            args = {
                devConsole = {
                    type = "toggle",
                    name = "Enable Console",
                    desc = "Toggle the dev console",
                    get = function(info) return PDKP.enableConsole end,
                    set = function(info, val)
                        return MODULES.Dev:ToggleSetting('enableConsole', val)
                    end,
                    width = 2.5,
                    order = 1,
                },
                showInternalDKP = {
                    type = "toggle",
                    name = "Show Internal DKP",
                    desc = "Show the true DKP values (not rounded)",
                    get = function(info) return PDKP.showInternalDKP end,
                    set = function(info, val)
                        return MODULES.Dev:ToggleSetting('showInternalDKP', val)
                    end,
                    width = 2.5,
                    order = 2,
                },
                showHistoryIds = {
                    type = "toggle",
                    name = "Show History IDS",
                    desc = "Show entry history IDs",
                    get = function(info) return PDKP.showHistoryIds end,
                    set = function(info, val)
                        return MODULES.Dev:ToggleSetting('showHistoryIds', val)
                    end,
                    width = 2.5,
                    order = 3,
                },
                showBidAmounts = {
                    type = "toggle",
                    name = "Show Bid amounts",
                    desc = "Show active bid amounts",
                    get = function(info) return PDKP.showBidAmounts end,
                    set = function(info, val)
                        return MODULES.Dev:ToggleSetting('showBidAmounts', val)
                    end,
                    width = 2.5,
                    order = 4,
                },
            }
        }
    end
    --@end-do-not-package@

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
            ['processingChunkSize'] = 2,
            ['decompressChunkSize'] = 4,
        }
    end
end

function Options:GetLastSyncSent()
    return self.db['sync']['lastSyncSent']
end

function Options:SetLastSyncSent()
    self.db['sync']['lastSyncSent'] = GetServerTime()
end

function Options:GetAutoSyncStatus()
    return self.db['sync']['autoSync'];
end

function Options:IsPlayerIgnored(playerName)
    for _, name in pairs(self.db['ignore_from']) do
        if strlower(playerName) == strlower(name) then
            return true
        end
    end
    return false
end

function Options:processingChunkSize()
    return self.db['sync']['processingChunkSize'] or 2
end

function Options:decompressChunkSize()
    return self.db['sync']['decompressChunkSize'] or 32
end

function Options:GetInviteCommands()
    return self.db['invite_cmds'] or { 'inv', 'invite' }
end

MODULES.Options = Options
