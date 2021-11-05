local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils;

local LibStub = LibStub
local IsControlKeyDown, IsShiftKeyDown, IsAltKeyDown = IsControlKeyDown, IsShiftKeyDown, IsAltKeyDown
local unpack, tinsert = unpack, table.insert

local map = {}

local info = 'F4A460'

local clickText = Utils:FormatTextColor('Click', info) .. ' to open PDKP. '
local shiftRightClickText = Utils:FormatTextColor('Shift-Right-Click', info) .. ' to open Officer push'
local rightClickText = Utils:FormatTextColor('Right-Click', info) .. ' to open settings'
local resetDatabaseText = Utils:FormatTextColor('Ctrl-Alt-Shift-Right-Click', info) .. ' to purge database'
--local hideMiniMapText = Utils:FormatTextColor('Alt-Right-Click', info) .. ' to hide the map icon'

function map:Initialize()
    local settingsDB = MODULES.Database:Settings();
    local miniDB = settingsDB['minimap'];

    self.LDB = LibStub("LibDataBroker-1.1")
    self.broker = self.LDB:NewDataObject('PantheonDKP', {
        type = "launcher",
        text = 'PantheonDKP',
        icon = MODULES.Media.PDKP_ADDON_ICON,
        OnTooltipShow = function(tooltip)
            local texts = map:_GetToolTipTexts()
            for i = 1, #texts do
                tooltip:AddLine(unpack(texts[i]))
            end
            tooltip:Show()
        end,
        OnClick = function(_, button)
            map:HandleIconClicks(button)
        end
    });

    self.icon = LibStub("LibDBIcon-1.0")
    self.icon:Register('PantheonDKP', self.broker, miniDB)

    if miniDB['hide'] then
        self:Hide();
    else
        self:Show()
    end
end

function map:Show()
    self.icon:Show("PantheonDKP")
    self.icon:Show("PantheonDKP")
end

function map:Hide()
    self.icon:Hide("PantheonDKP")
    self.icon:Hide("PantheonDKP")
end

function map:_GetToolTipTexts()
    local title = { "PantheonDKP " .. MODULES.Constants.COLORED_ADDON_VERSION }
    local lineBreak = { " ", 1, 1, 1, 1 }
    local leftClick = { clickText, 1, 1, 1 }
    local rightClick = { rightClickText, 1, 1, 1 }
    local shiftRightClick = { shiftRightClickText, 1, 1, 1 }
    local databaseResetClick = { resetDatabaseText, 1, 1, 1 }

    local texts = { title, lineBreak, leftClick, rightClick }

    if PDKP.canEdit then
        tinsert(texts, lineBreak)
        tinsert(texts, shiftRightClick)
    end

    --tinsert(texts, lineBreak)

    tinsert(texts, lineBreak)
    tinsert(texts, databaseResetClick)

    --tooltip:AddLine('Sync Status: '.. ' Out of date', 1, 1, 1, 1) -- text, r,g,b flag to wrap text.
    --tooltip:AddLine(" ", 1,1,1,1)
    --tooltip:AddLine(clickText, 1,1,1)
    --tooltip:AddLine(rightClickText, 1, 1, 1)

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

    return texts
end

function map:HandleIconClicks(buttonType)
    local hasCtrl, hasShift, hasAlt = IsControlKeyDown(), IsShiftKeyDown(), IsAltKeyDown()
    local clickTypes = {
        ['LeftButton'] = {
            [hasShift and hasAlt and hasCtrl] = function()
            end,
            [hasShift and hasAlt and not hasCtrl] = function()
            end,
            [hasShift and not hasAlt and not hasCtrl] = function()
            end,
            [hasAlt and not hasShift and not hasCtrl] = function()

            end,
            ['default'] = function()
                if pdkp_frame:IsVisible() then
                    pdkp_frame:Hide()
                else
                    pdkp_frame:Show()
                end
            end,
        },
        ['RightButton'] = {
            [hasShift and PDKP.canEdit and not hasAlt and not hasCtrl] = function()
                if PDKP.OfficerSyncFrame ~= nil then
                    PDKP.OfficerSyncFrame:Show();
                end
            end,
            [hasShift and hasAlt and hasCtrl] = function()
                MODULES.Database:ResetAllDatabases()
                ReloadUI()
            end,
            ['default'] = function()
                InterfaceOptionsFrame_Show()
                InterfaceOptionsFrame_OpenToCategory("PantheonDKP")
            end,
        }
    }

    local clickFunc = clickTypes[buttonType][true] or clickTypes[buttonType]['default']
    clickFunc()

    -- TODO: Hook this up eventually.
    --if buttonType == 'LeftButton' then
    --    if hasShift and hasAlt then -- Table wipe.
    --    elseif hasShift then -- Sync request.
    --    else
    --        GUI:TogglePDKP()
    --    end
    --elseif buttonType == 'RightButton' then
    --    if hasShift and PDKP.canEdit then -- Can Edit.
    --        StaticPopup_Show('PDKP_OFFICER_PUSH_CONFIRM') -- Officer Confirm Push.
    --    else
    --        --Open Interface Options.
    --        InterfaceOptionsFrame_OpenToCategory("PantheonDKP");
    --    end
    --end



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
