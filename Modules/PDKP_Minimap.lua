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
local Import = core.Import;
local Setup = core.Setup;
local Comms = core.Comms;
local Minimap = core.Minimap;

Minimap.db = nil;

local miniDB;

local success = '22bb33'
local warning = 'E71D36'
local info = 'F4A460'

local clickText = Util:FormatFontTextColor(info, 'Click') .. ' to open PDKP. '
local shiftClickText = Util:FormatFontTextColor(info, 'Shift-Click') ..  ' to request a push.'
local altShiftText = Util:FormatFontTextColor(info, 'Alt-Shift-Click') .. ' to wipe your tables.'
local shiftRightClickText = Util:FormatFontTextColor(info, 'Right-Shift-Click') .. ' to open Officer push'

local minimapDBDefaults = {
    profile = {
        minimap = {
            hide = false,
        },
    }
}

Minimap.canRequestPush = true

function Minimap:InitMapDB()
    Util:Debug('Map DB init');
    core.Minimap.db = LibStub("AceDB-3.0"):New("pdkp_minimap", minimapDBDefaults, true)
    miniDB = core.Minimap.db.profile
    core.Minimap.miniDB = miniDB;

    Minimap.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("PantheonDKP", {
        type="launcher",
        text='PantheonDKP',
        icon = "Interface\\AddOns\\PantheonDKP\\icons\\icon.tga",
        OnTooltipShow = function(tooltip)
            tooltip:SetText(Minimap:GetAddonVersion())
            tooltip:AddLine('Sync Status: '..Minimap:GetDKPState(), 1, 1, 1, 1)  -- text, r, g, b, flag to wrap text.
            tooltip:AddLine(' ', 1, 1, 1, 1)
            tooltip:AddLine(clickText, 1, 1, 1)

            local canRequestSync, _, nextSyncAvailable  = DKP:CanRequestSync()

            if canRequestSync then
                tooltip:AddLine(shiftClickText, 1, 1, 1)
            else
                local nextSyncText = 'Next ' ..
                        Util:FormatFontTextColor(info, 'Sync') ..
                        ' available in: ' .. tostring(nextSyncAvailable) .. ' min(s).'
                tooltip:AddLine(nextSyncText, 1, 1, 1)
            end
--            tooltip:AddLine(altShiftText, 1, 1, 1, 1)

            if core.canEdit then
                tooltip:AddLine(shiftRightClickText, 1, 1, 1)
            end
            tooltip:Show()
        end,
        OnClick = function(_, button)
            Minimap:HandleIconClicks(button)
        end
    })
    local icon = LibStub("LibDBIcon-1.0")
    icon:Register('PantheonDKP', Minimap.LDB, miniDB)
end

function Minimap:GetAddonVersion()
    return "PantheonDKP "..Defaults.addon_version
end

function Minimap:GetDKPState()
    local dkpLastEdit = DKP.dkpDB.lastEdit
    local bankLastEdit = tonumber(DKP.bankID)

    if dkpLastEdit and bankLastEdit then -- Found them both.
        if dkpLastEdit >= bankLastEdit then
           return Util:FormatFontTextColor(success, 'Up to date')
        elseif bankLastEdit > dkpLastEdit then
            return Util:FormatFontTextColor(warning, 'Out of date')
        end
    else -- Could not find the bank or DKP last edits
        return 'Unknown' -- We don't know the status of the bank
    end
end

function Minimap:HandleIconClicks(buttonType)

    local hasCtrl, hasShift, hasAlt = IsAltKeyDown(), IsShiftKeyDown(), IsAltKeyDown()
    local canRequestSync, minsSinceSync = DKP:CanRequestSync()

    if buttonType == 'LeftButton' then -- Left button capabilities.
        if hasShift and hasAlt then -- Table wipe
            -- Popup notifying them that this cannot be reversed.
            -- Letting them know that they will have to reload their UI after this is finished.
            Util:Debug('ShiftAlt click')
        elseif hasShift then
            local canRequestSync, minsSinceSync, nextSyncAvailable = DKP:CanRequestSync()
            if canRequestSync then
                local _, _, server_time, _ = Util:GetDateTimes()
                Comms:SendCommsMessage('pdkpSyncReq', server_time, 'GUILD', nil, 'BULK', nil)
            else
                PDKP:Print('Next sync available in: ' .. tostring(nextSyncAvailable) .. ' mins')
            end
        else
            if GUI.pdkp_frame and GUI.pdkp_frame:IsVisible() then
                GUI:Hide()
            else
                PDKP:Show()
            end
        end
    elseif buttonType == 'RightButton' and hasShift then
        StaticPopup_Show('PDKP_OFFICER_PUSH_CONFIRM')
    end
end

