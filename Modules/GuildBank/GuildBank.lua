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
            local numSlots, full = GetNumBankSlots();
            print(eventName, numSlots, full)
        end

    end)
end

MODULES.GuildBank = GuildBank