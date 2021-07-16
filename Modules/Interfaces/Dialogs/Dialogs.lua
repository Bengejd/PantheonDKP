local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI

local Dialogs = {}

local StaticPopupDialogs, StaticPopup_Show, StaticPopup_Hide = StaticPopupDialogs, StaticPopup_Show, StaticPopup_Hide

function Dialogs:Initialize()
    self.popups = {
        ["PDKP_RAID_BOSS_KILL"] = {
            text = "%s was killed! Award %d DKP?",
            button1 = "Award DKP",
            button2 = "Cancel",
            OnAccept = function(_, data, _)
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
            text = "MANUAL DKP Merge / Overwrite \n This will broadcast all of your entries to the guild. May cause brief lag spikes.",
            button1 = "Merge",
            button2 = 'Overwrite',
            button3 = "Cancel",
            OnAccept = function(...)
                -- First (Merge)
                local DKP = MODULES.DKPManager
                local entries, total = DKP.currentLoadedWeekEntries, DKP.numCurrentLoadedWeek
                local transmission_data = { ['total'] = total, ['entries'] = entries }
                MODULES.CommsManager:SendCommsMessage('SyncLarge', transmission_data)
            end,
            OnCancel = function(...)
                -- Second (Overwrite)
                local _, _, clickType = ...
                if clickType == 'clicked' then
                    PDKP:PrintD("Preparing Overwrite")
                    MODULES.DKPManager:PrepareOverwriteExport()
                end
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
            text = "Are you sure you want to delete this entry?",
            button1 = "Delete",
            button2 = "Cancel",
            OnAccept = function(_, data, _)
                MODULES.CommsManager:SendCommsMessage('SyncDelete', data)
            end,
            OnCancel = function(_) end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = false,
            preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
        },
        ['PDKP_CONFIRM_DKP_ENTRY_DELETE'] = {

        },
        ['PDKP_RELOAD_UI'] = {

        },
    }

    for popupName, value in pairs(self.popups) do
        StaticPopupDialogs[popupName] = value
    end
end

function Dialogs:Show(dialogName, textTable, data)
    if data ~= nil and data['reason'] ~= nil and data['reason'] == "Decay" and data['decayReversal'] then
        PDKP.CORE:Print("Reversed Decay entries, cannot be deleted. \n Please apply a new decay entry instead.")
        return
    end

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