local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Dialogs = {}

local StaticPopupDialogs, StaticPopup_Show, StaticPopup_Hide = StaticPopupDialogs, StaticPopup_Show, StaticPopup_Hide

function Dialogs:Initialize()
    self.popups = {
        ["PDKP_RAID_BOSS_KILL"] = {
            text = "%s was killed! Award %d DKP?",
            button1 = "Award DKP",
            button2 = "Cancel",
            OnAccept = function(self, data, data2)
                MODULES.DKPManager:AwardBossKill(data)
            end,
            OnCancel = function()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = false,
            preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
        },
        ['PDKP_OFFICER_PUSH_CONFIRM'] = {
            text = "MANUAL DKP PUSH \n This will broadcast all of your entries to the guild. May cause brief lag spikes.",
            button1 = "Merge",
            button2 = 'Cancel',
            --button2 = "Merge",
            OnAccept = function(...)
                -- First (Overwrite)
                local DKP = MODULES.DKPManager
                local entries, total = DKP.currentLoadedWeekEntries, DKP.numCurrentLoadedWeek
                local transmission_data = { ['total'] = total, ['entries'] = entries }
                MODULES.CommsManager:SendCommsMessage('SyncLarge', transmission_data)
            end,
            OnCancel = function(...)
                -- Second (Merge)
                --local _, _, clickType = ...
                --if clickType == 'clicked' then
                --    PDKP.CORE:Print('TODO: push-merge');
                --    --Export:New('push-merge')
                --end
            end,
            OnAlt = function(...)
                -- Third (Cancel)
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = false,
            preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
        },
        ['PDKP_DKP_ENTRY_POPUP'] = {

        },
        ['PDKP_CONFIRM_DKP_ENTRY_DELETE'] = {

        },
        ['PDKP_RELOAD_UI'] = {

        },
    }

    for popupName, value in pairs(self.popups) do
        StaticPopupDialogs[popupName] = value
    end

    if (false) then
        PDKP_POPUP_DIALOG_SETTINGS = {
            ['PDKP_DKP_ENTRY_POPUP'] = {
                text = "What would you like to do to this entry?",
                button1 = "Edit (Disabled)",
                button3 = 'Cancel',
                button2 = "Delete",
                OnAccept = function(self)
                    -- Edit
                    --print('Edit Clicked')
                end,
                OnCancel = function(self)
                    -- Delete
                    StaticPopup_Show('PDKP_CONFIRM_DKP_ENTRY_DELETE')

                    --StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_CONFIRM'].text = 'Are you sure you want to DELETE this entry?'
                    --local entry = StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_POPUP'].entry
                    --StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_CONFIRM'].entry = entry;
                    --StaticPopup_Show('PDKP_EDIT_DKP_ENTRY_CONFIRM')
                end,
                OnAlt = function(self)
                    -- Cancel
                    print('Cancel clicked')
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = false,
                preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            }, -- TODO: Hook this up eventually
            ['PDKP_CONFIRM_DKP_ENTRY_DELETE'] = {
                text = "Are you sure you want to DELETE this entry?",
                button1 = "Confirm",
                button2 = "Cancel",
                OnAccept = function(self)
                    -- Confirm
                    local id = DKP:DeleteEntry()
                    PDKP_History_EntryDeleted(id)
                end,
                OnCancel = function()
                    -- Cancel
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = false,
                preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            }, -- TODO: Hook this up eventually
            ['PDKP_RELOAD_UI'] = {
                text = "You are on a fresh version of PantheonDKP. Please Reload to continue.",
                button1 = "Reload",
                button2 = "Cancel",
                OnAccept = function(self)
                    -- Confirm
                    ReloadUI()
                end,
                OnCancel = function()
                    -- Cancel
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = false,
                preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            },
        }
    end

end

function Dialogs:Show(dialogName, textTable, data)
    local dialog
    if type(textTable) == "table" then
        dialog = StaticPopup_Show(dialogName, unpack(textTable))
    else
        dialog = StaticPopup_Show(dialogName, textTable)
    end
    if dialog then
        dialog.data = data
    end
end

function Dialogs:Hide(dialogName)
    StaticPopup_Hide(dialogName)
end

GUI.Dialogs = Dialogs;