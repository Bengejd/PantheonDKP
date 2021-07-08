local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local GuildBank = { _opened = false }

function GuildBank:Initialize()
    if Utils:GetMyName() ~= "Neekio" then return end

    self.db = MODULES.Database:GuildBank()

    local f = CreateFrame("Frame", "PDKP_Bank_Events")
    f:RegisterEvent("BANKFRAME_OPENED")
    f:RegisterEvent("BANKFRAME_CLOSED")
    f:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    f:RegisterEvent("BAG_UPDATE")

    f:SetScript("OnEvent", function(_, eventName, arg1, ...)
        if eventName == 'BANKFRAME_CLOSED' or eventName == 'BANKFRAME_OPENED' then
            self._opened = not self._opened
            return
        end

        if self._opened then
            local numBags, _ = GetNumBankSlots(); -- Purchased bank slots.
            for i=5, numBags+5 do
                local bagID = i
                local invSlot = ContainerIDToInventoryID(bagID)
                local bagSlots = GetContainerNumSlots(bagID)

                print(invSlot, bagSlots)

                --for slotID=1, bagSlots do
                --    local ItemLink = GetContainerItemLink(invSlot, slotID)
                --    if i == 0 and slotID <= 2 then
                --        local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(invSlot, slotID);
                --        print(ItemLink)
                --    end
                --end

            end
        end

    end)
end

MODULES.GuildBank = GuildBank