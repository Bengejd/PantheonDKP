local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local LibStub = LibStub
local IsControlKeyDown, IsShiftKeyDown, IsAltKeyDown = IsControlKeyDown, IsShiftKeyDown, IsAltKeyDown
local StaticPopup_Show = StaticPopup_Show
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory

local map = {}

local success = '22bb33'
local warning = 'E71D36'
local info = 'F4A460'
local system = '1E90FF'

local clickText = Utils:FormatTextColor('Click', info) .. ' to open PDKP. '
local shiftClickText = Utils:FormatTextColor('Shift-Click', info) ..  ' to request a push.'
local altShiftText = Utils:FormatTextColor('Alt-Shift-Click', info) .. ' to wipe your tables.'
local shiftRightClickText = Utils:FormatTextColor('Right-Shift-Click', info) .. ' to open Officer push'
local rightClickText = Utils:FormatTextColor('Right-Click', info) .. ' to open settings'
local disableSyncInRaidText = Utils:FormatTextColor('Push requests disabled', warning)

function map:Initialize()
    local miniDB = MODULES.Database:Settings()

    map.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("PantheonDKP", {
        type="launcher",
        text='PantheonDKP',
        icon = MODULES.Media.PDKP_ADDON_ICON,
        OnTooltipShow = function(tooltip)
            tooltip:SetText("PantheonDKP " .. MODULES.Constants.COLORED_ADDON_VERSION) -- First line
            --tooltip:AddLine('Sync Status: '.. ' Out of date', 1, 1, 1, 1) -- text, r,g,b flag to wrap text.
            tooltip:AddLine(" ", 1,1,1,1)
            tooltip:AddLine(clickText, 1,1,1)
            tooltip:AddLine(rightClickText, 1, 1, 1)

            --
            --Raid:GetLockedInfo()
            --
            --local canRequestSync, _, nextSyncAvailable  = DKP:CanRequestSync()
            --
            --if Defaults:AllowSync() == false then
            --    tooltip:AddLine(disableSyncInRaidText, 1, 1, 1)
            --elseif canRequestSync then
            --    tooltip:AddLine(shiftClickText, 1, 1, 1)
            --else
            --    local nextSyncText = 'Next ' .. Util:FormatFontTextColor(info, 'Sync') ..
            --            ' available in: ' .. tostring(nextSyncAvailable) .. ' min(s).'
            --    tooltip:AddLine(nextSyncText, 1, 1, 1)
            --end
            ----            tooltip:AddLine(altShiftText, 1, 1, 1, 1)
            --
            --if core.canEdit then
            --    tooltip:AddLine(shiftRightClickText, 1, 1, 1)
            --end
            --
            --if #Raid.lockedInstances > 0 then
            --    tooltip:AddLine(' ', 1, 1, 1, 1)
            --    for _, raid in pairs(Raid.lockedInstances) do
            --        tooltip:AddLine(raid.desc, 1, 1, 1)
            --    end
            --end
            --
            --if #Raid.lockedRaids > 0 then
            --    tooltip:AddLine(' ', 1, 1, 1, 1)
            --    for _, raid in pairs(Raid.lockedRaids) do
            --        tooltip:AddLine(raid.desc, 1, 1, 1)
            --    end
            --end

            tooltip:Show()
        end,
        OnClick = function(_, button)
            map:HandleIconClicks(button)
        end
    })
    local icon = LibStub("LibDBIcon-1.0")
    icon:Register('PantheonDKP', map.LDB, miniDB)
end

function map:HandleIconClicks(buttonType)

    local hasCtrl, hasShift, hasAlt = IsControlKeyDown(), IsShiftKeyDown(), IsAltKeyDown()
    if buttonType == 'LeftButton' then
        if hasShift and hasAlt then -- Table wipe. -- TODO: Hook this up.
            -- TODO: Hookup Wipe Request.
        elseif hasShift then -- Sync request.
            -- TODO: Hookup Sync Request.
        else
            GUI:TogglePDKP()
        end
    elseif buttonType == 'RightButton' then
        if hasShift and PDKP.canEdit then -- Can Edit.
            StaticPopup_Show('PDKP_OFFICER_PUSH_CONFIRM') -- Officer Confirm Push.
        else
            --Open Interface Options.
            InterfaceOptionsFrame_OpenToCategory("PantheonDKP");
        end
    end



    --local hasCtrl, hasShift, hasAlt = IsAltKeyDown(), IsShiftKeyDown(), IsAltKeyDown()
    --local canRequestSync, minsSinceSync = DKP:CanRequestSync()
    --
    --if buttonType == 'LeftButton' then -- Left button capabilities.
    --    if hasShift and hasAlt then -- Table wipe
    --        -- Popup notifying them that this cannot be reversed.
    --        -- Letting them know that they will have to reload their UI after this is finished.
    --        Util:Debug('ShiftAlt click')
    --    elseif hasShift then
    --        local canRequestSync, minsSinceSync, nextSyncAvailable = DKP:CanRequestSync()
    --        if canRequestSync and Defaults:AllowSync() then
    --            local _, _, server_time, _ = Util:GetDateTimes()
    --            DKP.lastSync = server_time -- Will prevent people from sending multiple requests accidentally.
    --            Comms:SendCommsMessage('pdkpSyncReq', server_time, 'GUILD', nil, 'BULK', nil)
    --        elseif Defaults:AllowSync() == false then
    --            PDKP:Print('Syncing in raids is currently disabled. You can change this in the PDKP settings.')
    --        else
    --            PDKP:Print('Next sync available in: ' .. tostring(nextSyncAvailable) .. ' mins')
    --        end
    --    else
    --        if GUI.pdkp_frame and GUI.pdkp_frame:IsVisible() then
    --            GUI:Hide()
    --        else
    --            PDKP:Show()
    --        end
    --    end
    --elseif buttonType == 'RightButton' then
    --    if hasShift and core.canEdit then
    --        StaticPopup_Show('PDKP_OFFICER_PUSH_CONFIRM')
    --    else -- No modifiers
    --        -- This has to be called twice in order to properly work. Bug with Blizzard's code.
    --        InterfaceOptionsFrame_OpenToCategory("PantheonDKP");
    --        InterfaceOptionsFrame_OpenToCategory("PantheonDKP");
    --    end
    --end
end

GUI.Minimap = map