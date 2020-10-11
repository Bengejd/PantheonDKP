local _, core = ...;
local _G = _G;
local L = core.L;

local Loot = core.Loot;
local Setup = core.Setup;
local Settings = core.Settings;

local UnitGUID, UnitName = UnitGUID, UnitName
local GetLootMethod, GetLootSlotInfo, GetNumLootItems, GetLootInfo, GetItemInfo, GetLootSlotLink = GetLootMethod, GetLootSlotInfo, GetNumLootItems, GetLootInfo, GetItemInfo, GetLootSlotLink
local select = select
local GetServerTime = GetServerTime
local SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"

Loot.timer = 8
Loot.frame = nil;
Loot.lastLootInfo = {};
Loot.records = {};

Loot.ignore_loot_types = {
    'Consumable', 'Key', 'Recipe', 'Projectile', 'Quiver', 'Trade Goods', 'Reagent', 'Miscellaneous', 'Container'
}

function PDKP_OnLootEvent(self, event, arg1, ...)
    local args = ...
    local mob_uid = nil;

    local loot_events = {'CHAT_MSG_LOOT', 'OPEN_MASTER_LOOT_LIST', 'UPDATE_MASTER_LOOT_LIST', 'LOOT_SLOT_CHANGED',
                         'LOOT_OPENED', 'LOOT_SLOT_CLEARED'}


    local loot_event_funcs = {
        -- TODO: Register & Report Loot.
        ['LOOT_OPENED']=function() -- autoLoot, isFromItem
            local loot_info = Loot:RegisterMobLoot()
            for _, item_info in pairs(loot_info['loot']) do
                Loot.frame:addLootItem(item_info)
            end
        end,
        -- TODO: Don't have to do anything here?
        ['LOOT_SLOT_CHANGED']=function() -- lootSlot
            --print(event, arg1, args)
        end,
        -- TODO: Update Boss Kill List.
        ['LOOT_SLOT_CLEARED']=function() -- lootSlot
            Loot:LootRemovedFromSlot(arg1)
        end,
        -- TODO: Maybe do something with "Forgotten Loot" where loot wasn't given to anyone, later on?
        ['CHAT_MSG_LOOT']=function() -- https://wow.gamepedia.com/CHAT_MSG_LOOT
            --print(event, args)
        end,
    }
    if loot_event_funcs[event] then loot_event_funcs[event]() end
end

function Loot:RegisterMobLoot()
    local loot_time = GetServerTime()
    local mob_uid = UnitGUID("target")
    local mob_name = UnitName("target");

    if Loot.records[mob_uid] ~= nil then return Loot.records[mob_uid] end

    local mob_loot_info = {
        ['time']=loot_time,
        ['mob_uid']=mob_uid,
        ['mob_name']=mob_name,
        ['loot']={}
    }

    local function getItemId(itemLink) return select(2, GetItemInfo(":", itemLink, 3)) end

    for i=1, GetNumLootItems() do
        local item = GetLootSlotLink(i)
        if item ~= nil then
            local itemName = select(1, GetItemInfo(item))
            if itemName then
                local itemLink = select(2, GetItemInfo(item))
                local itemId = select(2, strsplit(":", itemLink, 3))
                local itemRarity = select(3, GetItemInfo(item))
                local itemTime = GetServerTime()
                --local itemLevel = select(4, GetItemInfo(item))
                --local itemReqLevel = select(5, GetItemInfo(item))
                local itemType = select(6, GetItemInfo(item))
                local itemSubType = select(7, GetItemInfo(item))
                --local itemPrice = select(11, GetItemInfo(item))

                local item_info = {
                    ['name']=itemName,
                    ['link']=itemLink,
                    ['quality']=itemRarity,
                    ['id']=itemId,
                    ['time']=itemTime,
                    ['type']=itemType,
                    ['subType']=itemSubType,
                    ['slot']=i,
                }

                if Loot:CheckForValidLoot(item_info) then table.insert(mob_loot_info['loot'], item_info) end
            end
        end
    end

    Loot.lastLootInfo = mob_loot_info
    Loot.records[mob_uid] = mob_loot_info
    return mob_loot_info
end

function Loot:CheckForValidLoot(item_info)
    if Settings:IsDebug() then return true  -- Debugging shows all loot seen.
    elseif tContains(Loot.ignore_loot_types, item_info['type']) then return false
    elseif item_info['quality'] >= 4 then return true
    elseif item_info['quality'] == 3 and string.find(item_info['name'], 'Idol') then return false
    elseif item_info['quality'] <= 2 then return false
    end
    return true
end

-- TODO: Determine if I actually need to do this, or if it would just be detrimental.
function Loot:LootRemovedFromSlot(slot)

end

function Loot:LootDeleted(loot_info)
    local loots = Loot.lastLootInfo['loot']
    local delKey = nil;
    for key, info in pairs(loots) do
        if info['id'] == loot_info['id'] then
            delKey = key
        end
    end

    if delKey ~= nil then
        table.remove(loots, delKey)
    end
end

function Loot:ClearLootFrame()
    Loot.lastLootInfo = {}
end

-- Report the loot, only if you're the master looter, if the master looter is dead, the raid leader reports.
--function Loot:Report()
--    local guid = UnitGUID("target")
--
--    if guid and UnitIsDead("target") then
--        -- Add if missing?
--    end
--
--    for i = 1, GetNumLootItems() do
--       if LootSlotHasItem(i) then
--           local itemLink = GetLootSlotLink(i)
--
--           if itemLink then
--               local _, _, _, _, rarity = GetLootSlotInfo(i)
--
--               if rarity > GetLootThreshold() then
----                  local itemLinkSplit =
--
--                   if IsInGroup() then
--
--                   end
--               end
--           end
--       end
--    end
--end

local LOOT_EVENTS = {
    'CHAT_MSG_LOOT', 'LOOT_BIND_CONFIRM', 'OPEN_MASTER_LOOT_LIST', 'UPDATE_MASTER_LOOT_LIST', 'LOOT_SLOT_CHANGED',
    'LOOT_OPENED',
}

--- lOOT PRIO SCREEN TO UPDATE MANUALLY, WITHIN THE ADDON?
local LOOT_PRIO = {

}