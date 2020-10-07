local _, core = ...;
local _G = _G;
local L = core.L;

local Loot = core.Loot;
local Setup = core.Setup;

local UnitGUID, UnitName = UnitGUID, UnitName
local GetLootMethod, GetLootSlotInfo, GetNumLootItems, GetLootInfo, GetItemInfo, GetLootSlotLink = GetLootMethod, GetLootSlotInfo, GetNumLootItems, GetLootInfo, GetItemInfo, GetLootSlotLink
local select = select
local GetServerTime = GetServerTime
local SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"

Loot.timer = 8
Loot.frame = nil;
Loot.lastLootInfo = {};
Loot.records = {};

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
            print(event, arg1, args)
        end,
        -- TODO: Update Boss Kill List.
        ['LOOT_SLOT_CLEARED']=function() -- lootSlot
            print(event, arg1, args)
        end,
        -- TODO: Maybe do something with "Forgotten Loot" where loot wasn't given to anyone, later on?
        ['CHAT_MSG_LOOT']=function() -- https://wow.gamepedia.com/CHAT_MSG_LOOT
            print(event, args)
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
    for i=1, GetNumLootItems() do
        local item = GetLootSlotLink(i)
        if item then
            local itemName = select(1, GetItemInfo(item))
            local itemLink = select(2, GetItemInfo(item))
            local itemId = select(2, strsplit(":", itemLink, 3))
            local itemRarity = select(3, GetItemInfo(item))
            local itemTime = GetServerTime()
            --local itemLevel = select(4, GetItemInfo(item))
            --local itemReqLevel = select(5, GetItemInfo(item))
            --local itemType = select(6, GetItemInfo(item))
            --local itemSubType = select(7, GetItemInfo(item))
            --local itemPrice = select(11, GetItemInfo(item))

            local item_info = {
                ['name']=itemName,
                ['link']=itemLink,
                ['quality']=itemRarity,
                ['id']=itemId,
                ['time']=itemTime,
            }
            table.insert(mob_loot_info['loot'], item_info)
        end
    end

    Loot.lastLootInfo = mob_loot_info
    Loot.records[mob_uid] = mob_loot_info
    return mob_loot_info
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
        print('Loot frame deleted')
    end
end

function Loot:ClearLootFrame()
    print('Clearing Loot Frame')
end

-- Report the loot, only if you're the master looter, if the master looter is dead, the raid leader reports.
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

function Loot:CreateBossLoot(adjust_frame)
    --local f = CreateFrame("Frame", "$parent_boss_loot", adjust_frame)
    --f:SetBackdrop({
    --    tile = true, tileSize = 0,
    --    edgeFile = SCROLL_BORDER, edgeSize = 8,
    --    insets = { left = 4, right = 4, top = 4, bottom = 4 },
    --})
    --
    --f:SetHeight(200);
    --f:SetWidth(200);
    --f:SetPoint("BOTTOMRIGHT", adjust_frame, "BOTTOMRIGHT", 0, 0)
    --
    --local t = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    --t:SetPoint("TOPLEFT", 0, 15)
    --t:SetText("Boss Loot")
    --t:SetParent(f)
    --
    ----local lootmethod, --String (LootMethod) - "freeforall", "master", "group" and "personalloot"
    ----masterlooterPartyID, -- Number - Returns 0 if player is the mater looter, 1-4 if party member is master looter (corresponding to party1-4) and nil if the master looter isn't in the player's party or master looting is not used.
    ----masterlooterRaidID -- Number - Returns index of the master looter in the raid (corresponding to a raidX unit), or nil if the player is not in a raid or master looting is not used.
    ----= GetLootMethod()
    --
    ----local lootIcon, lootName, lootQuantity, rarity, locked = GetLootSlotInfo(1);
    --
    --local loot_events = {'CHAT_MSG_LOOT', 'LOOT_BIND_CONFIRM', 'OPEN_MASTER_LOOT_LIST', 'UPDATE_MASTER_LOOT_LIST', 'LOOT_SLOT_CHANGED', 'LOOT_OPENED', 'LOOT_SLOT_CLEARED', 'UNIT_TARGET'}
    --for _, eventName in pairs(loot_events) do f:RegisterEvent(eventName) end
    --
    --f:RegisterEvent("LOOT_OPENED")
    --
    --f:SetScript("OnEvent", function(self, event, arg1, ...)
    --    local args = ...
    --
    --    local loot_event_funcs = {
    --        -- TODO: Register & Report Loot.
    --        ['LOOT_OPENED']=function() -- autoLoot, isFromItem
    --            Loot:RegisterMobLoot()
    --        end,
    --        -- TODO: Don't have to do anything here?
    --        ['LOOT_SLOT_CHANGED']=function() -- lootSlot
    --            print(event, arg1, args)
    --        end,
    --        -- TODO: Update Boss Kill List.
    --        ['LOOT_SLOT_CLEARED']=function() -- lootSlot
    --            print(event, arg1, args)
    --        end,
    --        -- TODO: Maybe do something with "Forgotten Loot" where loot wasn't given to anyone, later on?
    --        ['CHAT_MSG_LOOT']=function() -- https://wow.gamepedia.com/CHAT_MSG_LOOT
    --            print(event, args)
    --        end,
    --    }
    --    if loot_event_funcs[event] then loot_event_funcs[event]() end
    --end)


    --f.loot = {};
    --f.loot_frames = {};
    --
    --
    --f.getVisible = function ()
    --    local visible_frames = {}
    --    for _, frame in pairs(f.loot_frames) do
    --
    --        if not f:IsVisible() then
    --            return f.loot_frames
    --        end
    --        if frame:IsVisible() then table.insert(visible_frames, frame) end
    --    end
    --    return visible_frames
    --end

    --f:SetScript("OnShow", function()
    --    --local boss_loot = Loot:GetBossLoot()
    --    --for _, l in pairs(boss_loot) do table.insert(f.loot, l) end
    --    --
    --    --for key, item in pairs(f.loot) do
    --    --    local i_frame = CreateFrame("Frame", "$parent_item_" .. key .. '_' .. item, f)
    --    --    i_frame:SetHeight(25)
    --    --    i_frame:SetWidth(200)
    --    --
    --    --    -- Set them appropriately.
    --    --    if key == 1 or #f.loot_frames == 0 then
    --    --        i_frame:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -50)
    --    --    else
    --    --        i_frame:SetPoint("TOPLEFT", f.loot_frames[key - 1], "TOPLEFT", 0, -20)
    --    --    end
    --    --
    --    --    -- Create the item font-string.
    --    --    local is = i_frame:CreateFontString(i_frame, "OVERLAY", 'GameFontNormal')
    --    --    is:SetPoint("TOPLEFT", 0, 20)
    --    --    local cb = Setup:CreateCloseButton(i_frame, true)
    --    --
    --    --    cb:SetScript("OnClick", function()
    --    --        cb:GetParent():Hide()
    --    --
    --    --    end)
    --    --
    --    --    -- Create a close button.
    --    --    cb:SetSize(15, 15) -- width, height
    --    --    cb:SetPoint("RIGHT", -10, 25)
    --    --    cb:SetFrameLevel(i_frame:GetFrameLevel() + 4)
    --    --
    --    --    --- check box
    --    --    local check = CreateFrame("CheckButton", '$parent_item_'..key..'_check', i_frame, "ChatConfigCheckButtonTemplate")
    --    --    check:SetPoint("RIGHT", cb, "LEFT", -5, 0)
    --    --
    --    --    -- Set the font-string.
    --    --    is:SetText(item)
    --    --
    --    --    i_frame:SetScript("OnHide", function ()
    --    --        local visible_items = f.getVisible()
    --    --        for key, i_frame in pairs(visible_items) do
    --    --            i_frame:ClearAllPoints()
    --    --            if key == 1 then
    --    --                i_frame:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -50)
    --    --            else
    --    --                i_frame:SetPoint("TOPLEFT", visible_items[key -1], "TOPLEFT", 0, -20)
    --    --            end
    --    --        end
    --    --    end)
    --    --
    --    --    i_frame:Show()
    --    --
    --    --    i_frame.item = item;
    --    --    i_frame.check = check;
    --    --
    --    --    table.insert(f.loot_frames, i_frame)
    --    end
    --end)

    --f:SetScript("OnHide", function()
    --    local i_frames = f.loot_frames;
    --end)

    f:Show()

    return f
end

function Loot:GetBossLoot()
    local boss_loot = {}
    for _, i_name in pairs({'Thorbia\'s Gauntlets', 'Stormbringer Belt', 'Light Mail Bracers', 'Cudgel', 'Dull Heater Shield'}) do
        local item = Loot:GetItemByName(i_name)
        table.insert(boss_loot, item)
    end
    return boss_loot;
end

function Loot:GetItemByName(name)
    local iName, iLink = GetItemInfo(name)
    return iName
end

local LOOT_EVENTS = {
    'CHAT_MSG_LOOT', 'LOOT_BIND_CONFIRM', 'OPEN_MASTER_LOOT_LIST', 'UPDATE_MASTER_LOOT_LIST', 'LOOT_SLOT_CHANGED',
    'LOOT_OPENED',
}

--- lOOT PRIO SCREEN TO UPDATE MANUALLY, WITHIN THE ADDON?
local LOOT_PRIO = {

}