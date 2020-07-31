local _, core = ...;
local _G = _G;
local L = core.L;

local Loot = core.Loot;

Loot.timer = 8

-local UnitGUID = UnitGUID

local Loot = core.Loot;


function Loot:Report()
    local guid = UnitGUID("target")

    if guid and UnitIsDead("target") then
        -- Add if missing?
    end

    for i = 1, GetNumLootItems() do
       if LootSlotHasItem(i) then
           local itemLink = GetLootSlotLink(i)

           if itemLink then
               local _, _, _, _, rarity = GetLootSlotInfo(i)

               if rarity > GetLootThreshold() then
--                  local itemLinkSplit =

                   if IsInGroup() then

                   end
               end
           end
       end
    end
end


local LOOT_EVENTS = {
    'CHAT_MSG_LOOT', 'LOOT_BIND_CONFIRM', 'OPEN_MASTER_LOOT_LIST', 'UPDATE_MASTER_LOOT_LIST', 'LOOT_SLOT_CHANGED',
    'LOOT_OPENED',
}