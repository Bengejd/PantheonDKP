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

            end,
            OnCancel = function()
                -- TODO: Cancel Raid Boss Kill Award
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = false,
            preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
        },
        ['PDKP_OFFICER_PUSH_CONFIRM'] = {
            text = "WARNING THIS IS GUILD WIDE \n Overwrite is permanent and cannot be reversed. Merge is a safer option.",
            button1 = "Overwrite",
            button3 = 'Cancel',
            button2 = "Merge",
            OnAccept = function(...) -- First (Overwrite)
                PDKP.CORE:Print('TODO: Push-overwrite');
                --Export:New('push-overwrite')
            end,
            OnCancel = function(...) -- Second (Merge)
                local _, _, clickType = ...
                if clickType == 'clicked' then
                    PDKP.CORE:Print('TODO: push-merge');
                    --Export:New('push-merge')
                end
            end,
            OnAlt = function(...) -- Third (Cancel)
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
            ['PDKP_DKP_ENTRY_POPUP']={
                text = "What would you like to do to this entry?",
                button1 = "Edit (Disabled)",
                button3 = 'Cancel',
                button2 = "Delete",
                OnAccept = function(self) -- Edit
                    --print('Edit Clicked')
                end,
                OnCancel = function(self) -- Delete
                    StaticPopup_Show('PDKP_CONFIRM_DKP_ENTRY_DELETE')

                    --StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_CONFIRM'].text = 'Are you sure you want to DELETE this entry?'
                    --local entry = StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_POPUP'].entry
                    --StaticPopupDialogs['PDKP_EDIT_DKP_ENTRY_CONFIRM'].entry = entry;
                    --StaticPopup_Show('PDKP_EDIT_DKP_ENTRY_CONFIRM')
                end,
                OnAlt = function(self) -- Cancel
                    print('Cancel clicked')
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = false,
                preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            }, -- TODO: Hook this up eventually
            ['PDKP_CONFIRM_DKP_ENTRY_DELETE']={
                text = "Are you sure you want to DELETE this entry?",
                button1 = "Confirm",
                button2 = "Cancel",
                OnAccept = function(self) -- Confirm
                    local id = DKP:DeleteEntry()
                    PDKP_History_EntryDeleted(id)
                end,
                OnCancel = function() -- Cancel
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
                OnAccept = function(self) -- Confirm
                    ReloadUI()
                end,
                OnCancel = function() -- Cancel
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = false,
                preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            },

            ['PDKP_Placeholder']={
                text = "This method is under construction",
                button1 = "OK",
                OnAccept = function()
                end,
                OnCancel = function()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            }, -- TODO: NOT USED
            ['PDKP_CONFIRM_DKP_ENTRY_POPUP']={

            }, -- TODO: NOT USED
            ['PDKP_CONFIRM_DKP_CHANGE'] = {
                text = "",
                button1 = "Confirm",
                button2 = "Cancel",
                OnAccept = function()
                    DKP:UpdateEntries()
                end,
                OnCancel = function()
                    StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].text = ''
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = false,
                preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            }, -- TODO: NOT USED
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