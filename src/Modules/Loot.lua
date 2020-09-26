local _, core = ...;
local _G = _G;
local L = core.L;

local Loot = core.Loot;
local Setup = core.Setup;

Loot.timer = 8

local UnitGUID = UnitGUID
local SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"

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
    local f = CreateFrame("Frame", "$parent_boss_loot", adjust_frame)
    f:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    f:SetHeight(200);
    f:SetWidth(200);
    f:SetPoint("BOTTOMRIGHT", adjust_frame, "BOTTOMRIGHT", 0, 0)

    local t = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    t:SetPoint("TOPLEFT", 0, 15)
    t:SetText("Boss Loot")
    t:SetParent(f)

    f.loot = {};
    f.loot_frames = {};


    f.getVisible = function ()
        local visible_frames = {}
        for _, frame in pairs(f.loot_frames) do

            if not f:IsVisible() then
                return f.loot_frames
            end
            if frame:IsVisible() then table.insert(visible_frames, frame) end
        end
        return visible_frames
    end

    f:SetScript("OnShow", function()
        local boss_loot = Loot:GetBossLoot()
        for _, l in pairs(boss_loot) do table.insert(f.loot, l) end

        for key, item in pairs(f.loot) do
            local i_frame = CreateFrame("Frame", "$parent_item_" .. key .. '_' .. item, f)
            i_frame:SetHeight(25)
            i_frame:SetWidth(200)

            -- Set them appropriately.
            if key == 1 or #f.loot_frames == 0 then
                i_frame:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -50)
            else
                i_frame:SetPoint("TOPLEFT", f.loot_frames[key - 1], "TOPLEFT", 0, -20)
            end

            -- Create the item font-string.
            local is = i_frame:CreateFontString(i_frame, "OVERLAY", 'GameFontNormal')
            is:SetPoint("TOPLEFT", 0, 20)
            local cb = Setup:CreateCloseButton(i_frame, true)

            cb:SetScript("OnClick", function()
                cb:GetParent():Hide()

            end)

            -- Create a close button.
            cb:SetSize(15, 15) -- width, height
            cb:SetPoint("RIGHT", -10, 25)
            cb:SetFrameLevel(i_frame:GetFrameLevel() + 4)

            --- check box
            local check = CreateFrame("CheckButton", '$parent_item_'..key..'_check', i_frame, "ChatConfigCheckButtonTemplate")
            check:SetPoint("RIGHT", cb, "LEFT", -5, 0)

            -- Set the font-string.
            is:SetText(item)

            i_frame:SetScript("OnHide", function ()
                local visible_items = f.getVisible()
                for key, i_frame in pairs(visible_items) do
                    i_frame:ClearAllPoints()
                    if key == 1 then
                        i_frame:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -50)
                    else
                        i_frame:SetPoint("TOPLEFT", visible_items[key -1], "TOPLEFT", 0, -20)
                    end
                end
            end)

            i_frame:Show()

            i_frame.item = item;
            i_frame.check = check;

            table.insert(f.loot_frames, i_frame)
        end
    end)

    f:SetScript("OnHide", function()
        local i_frames = f.loot_frames;
    end)

    f:Show()

    return f
end

function Loot:GetBossLoot()
    local boss_loot = {}
    for _, i_name in pairs({'Light Mail Boots', 'Light Mail Leggings', 'Light Mail Bracers', 'Cudgel', 'Dull Heater Shield'}) do
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