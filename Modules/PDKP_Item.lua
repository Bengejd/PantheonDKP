local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local item = core.Item;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;

item.linkedItem = nil;

function PDKP:InitItemDB()
    core.itemHistory = LibStub("AceDB-3.0"):New("pdkp_itemHistory").char
end

function item:LinkItem()
    local item = Item:CreateFromItemID(18832)
    item:ContinueOnItemLoad(function()
        PDKP:Print(item:GetItemLink())
    end)
end

function item:GetItemByName(itemName)
    local _, iLink = GetItemInfo(itemName)
    return iLink;
end

function item:UpdateLinked(item)
    core.Item.linkedItem = item;
end

function item:ClearLinked()
    core.Item.linkedItem = nil;
end

function item:GetPriority(itemName)

end

--    { prio = false },
--
--    {   prio: true,
--        1 = ['']
--        2 = ['']
--        3 = ['']
--        4 = ['']
--        5 = ['']
--    }

item.priority = {
    ['Crimson Shocker'] = { prio = false },
    ['Flamewaker Legplates'] = { prio = false },
    ['Heavy Dark Iron Ring'] =  {},
}