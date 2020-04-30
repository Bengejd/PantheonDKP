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
    local prio = item.priority[itemName]
    if prio == nil then
        local name = item:GetItemInfo(itemName)
        prio = item.priority[name]
        if prio == nil then return nil end
    end

    -- Make it look pretty
    for key, value in pairs(Defaults.class_colors) do
        local color = Util:FormatFontTextColor(value.hex, key)
        local newPrio, subs = string.gsub(prio, key, color, 3)
        prio = newPrio
    end
    return prio
end

function item:GetItemInfo(itemLink)
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
    itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID,
    isCraftingReagent = GetItemInfo(itemLink)
    return itemName;
end

item.priority = {

-- MOLTEN CORE LOOT --

    -- Flamewalker shared Loot --

    ['Crimson Shocker'] = 'MS > OS' ,
    ['Flamewaker Legplates'] = 'MS > OS',
    ['Heavy Dark Iron Ring'] =  'Druid (Feral) > MS > OS',
    ['Helm of the Lifegiver'] =  'MS > OS',
    ['Manastorm Leggings'] =  'MS > OS',
    ['Ring of Spell Power'] =  'Mage = Warlock = Druid (Boom) = Shadow Priest > MS > OS',
    ['Robe of Volatile Power'] = 'Mage = Warlock = Druid (Boom) > Paladin',
    ['Salamander Scale Pants'] =  'Druid (Resto) = Paladin',
    ['Sorcerous Dagger'] =  'MS > OS',
    ['Wristguards of Stability'] =  'Druid (Feral) = Warrior (DPS)',

    -- Elementals shared Loot --

    ['Aged Core Leather Gloves'] =  'Rogue (Dagger) > Warrior',
    ['Fire Runed Grimoire'] =  'Mage = Warlock > MS>OS',
    ['Flameguard Gauntlets'] =  'MS > OS',
    ['Magma Tempered Boots'] =  'MS > OS',
    ['Mana Igniting Cord'] =  'Mage = Druid (Boom) = Warlock > Paladin',
    ['Obsidian Edged Blade'] =  'MS > OS',
    ['Quick Strike Ring'] =  'Warrior = Hunter = Druid (Feral) = Rogue',
    ['Sabatons of the Flamewalker'] =  'MS > OS',
    ['Talisman of Ephemeral Power'] =  'Mage = Warlock = Shadow Priest = Druid (Boom) > MS>OS',

    -- Lucifron Loot --

    ['Choker of Enlightenment'] =  'Mage = Warlock = Shadow Priest > MS>OS',

    -- Magmadar Loot --

    ['Earthshaker'] =  'MS > OS',
    ['Eskhandar\'s Right Claw'] =  'MS > OS',
    ['Medallion of Steadfast Might'] =  'MS > OS',
    ['Striker\'s Mark'] =  'Rogue = Warrior > MS>OS',

    -- Garr Loot --
    ['Aurastone Hammer'] =  'Druid (Resto) = Paladin > MS>OS',
    ['Brutality Blade'] =  'Rogue = Warrior (DPS) = Hunter',
    ['Drillborer Disk'] =  'MS > OS',
    ['Gutgore Ripper'] =  'Rogue > MS>OS',

    -- Baron Geddon Loot --

    ['Seal of the Archmagus'] =  'MS > OS',

    -- Sulfuron Harbinger Loot --

    ['Shadowstrike'] =  'Vendor',

    -- Golemagg The Incinerator Loot --

    ['Azuresong Mageblade'] =  'Mage = Warlock = MS>OS',
    ['Blastershot Launcher'] =  'Warrior (Tank) = Warrior (DPS) > Rogue > Hunter',
    ['Staff of Dominance'] =  'Mage = Warlock = Druid (Boom)',

    -- Majordomo Executus Loot --

    ['Ancient Petrified Leaf'] =  'Sinew > No Sinew',
    ['Cauterizing Band'] =  'MS > OS',
    ['Core Forged Greaves'] =  'Warrior (Tank) > MS>OS',
    ['Core Hound Tooth'] =  'MS > OS',
    ['Finkle\'s Lava Dredger'] =  'MS > OS',
    ['Fireguard Shoulders'] =  'Warrior (Tank) = Druid (Feral) > MS>OS',
    ['Fireproof Cloak'] =  'Warrior (Tank) = Druid (Feral) > MS>OS',
    ['Gloves of the Hypnotic Flame'] =  'Mage = Warlock',
    ['Sash of Whispered Secrets'] =  'Shadow Priest > Warlock > MS>OS',
    ['The Eye of Divinity'] =  'EOS > No EOS',
    ['Wild Growth Spaulders'] =  'Druid (Resto) = Paladin > MS>OS',
    ['Wristguards of True Flight'] =  'Warrior (Tank) = Warrior (DPS) = Hunter > MS>OS',

    -- Ragnaros Loot --

    ['Band of Accuria'] =  'Warrior (Tank) = Druid (Feral) = Hunter = Rogue = Warrior (DPS)',
    ['Band of Sulfuras'] =  'MS > OS',
    ['Bonereaver\'s Edge'] =  'Warrior PvP Rank 7 > MS>OS',
    ['Choker of the Fire Lord'] =  'Mage = Warlock = Shadow Priest = Druid (Boom)',
    ['Cloak of the Shrouded Mists'] =  'Hunter > Rogue = Warrior (Tank) > MS>OS',
    ['Crown of Destruction'] =  'Hunter = Warrior (DPS) = Paladin (Ret)',
    ['Dragon\'s Blood Cape'] =  'Warrior (Tank) = Druid (Feral) > MS>OS',
    ['Essence of the Pure Flame'] =  'Warrior (Tank) > MS>OS',
    ['Malistar\'s Defender'] =  'MS > OS',
    ['Onslaught Girdle'] =  'Warrior (Tank) = Warrior (DPS) > Paladin (ret)',
    ['Perdition\'s Blade'] =  'Rogue (Dag) > Warrior (Dag) > MS>OS',
    ['Shard of the Flame'] =  'MS > OS',
    ['Spinal Reaper'] =  'MS > OS',

    -- ONYXIA LOOT --

    ['Ancient Cornerstone Grimoire'] =  'MS > OS',
    ['Eskhandar\'s Collar'] =  'Druid (Feral) > MS>OS',
    ['Deathbringer'] =  'MS > OS',
    ['Head of Onyxia'] =  'MS > OS',
    ['Sapphiron Drape'] =  'MS > OS',
    ['Shard of the Scale'] =  'Paladin = Priest = Druid (Resto)',
    ['Ring of Binding'] =  'Druid (Feral) > MS>OS',
    ['Vis\'kag the Bloodletter'] =  'Rogue = Warrior (DPS)',
    ['Sinew'] =  'Leaf > No Leaf',

    -- MISC Loot --

    ['Band of Dark Dominion'] =  'Warlock = Shadow Priest',
    ['Boots of Pure Thought'] =  'MS > OS',
    ['Cloak of Draconic Might'] =  'Warrior (DPS) = Ret Paladin = Warrior (Tank) > Rogue > MS>OS',
    ['Doom\'s Edge'] =  'Warrior (Tank) = Warrior (DPS) > MS>OS',
    ['Draconic Avenger'] =  'MS > OS',
    ['Draconic Maul'] =  'Druid (Feral) > MS>OS',
    ['Essence Gatherer'] =  'Priest > MS>OS',
    ['Interlaced Shadow Jerkin'] =  'MS > OS',
    ['Ringo\'s Blizzard Boots'] =  'Mage > MS>OS',

    ['Gloves of Rapid Evolution'] =  'Mage = Warlock = Shadow Priest > MS>OS',
    ['Mantle of the Blackwing Cabal'] =  'MS > OS',
    ['Spineshatter'] =  'MS > OS',
    ['The Untamed Blade'] =  'MS > OS',

    ['Dragonfang Blade'] =  'Rogue = Warrior',
    ['Helm of Endless Rage'] =  'Warrior (Tank) > Warrior (DPS) > MS>OS',
    ['Pendant of the Fallen Dragon'] =  'MS > OS',
    ['Red Dragonscale Protector'] =  'Paladin > MS>OS',

    ['Black Brood Pauldrons'] =  'MS > OS',
    ['Bracers of Arcane Accuracy'] =  'Mage = Warlock = Shadow Priest > MS>OS',
    ['Heartstriker'] =  'MS > OS',
    ['Maladath, Runed Blade of the Black Flight'] =  'Rogue (Sword) = Warrior (Tank) = Warrior (DPS) > MS>OS',
    ['Lifegiving Gem'] =  'Warrior (Tank) > MS>OS',
    ['Black Ash Robe'] =  'MS > OS',
    ['Claw of the Black Drake'] =  'MS > OS',
    ['Cloak of Firemaw'] =  'Rogue = Hunter > Warrior (Tank) = Warrior (DPS) = Paladin (Ret) > MS>OS',
    ['Firemaw\'s Clutch'] =  'Shadow Priest = Warlock = Mage = Druid (Boom) > MS>OS',
    ['Legguards of the Fallen Crusader'] =  'Paladin (Ret) = Warrior (DPS) > Warrior (Tank) > MS>OS',

    ['Band of Forced Concentration'] =  'Mage = Warlock = Shadow Priest = Druid (Boom) > MS>OS',
    ['Dragonbreath Hand Cannon'] =  'Warrior (Tank) > MS>OS',
    ['Ebony Flame Gloves'] =  'Warlock = Shadow Priest > MS>OS',
    ['Malfurion\'s Blessed Bulwark'] =  'Druid (Feral) > Warrior (DPS) > MS>OS',
    ['Drake Fang Talisman'] =  'Warrior (Tank) = Druid (Feral) = Warrior (DPS) = Rogue = Hunter',

    ['Emberweave Leggings'] =  'Hunter > Warrior (Tank) > MS>OS',
    ['Shroud of Pure Thought'] =  'MS > OS',
    ['Herald of Woe'] =  'Paladin (Ret) > MS>OS',
    ['Dragon\'s Touch'] =  'Caster DPS > MS>OS',
    ['Styleen\'s Impeding Scarab'] =  'Warrior (Tank) > MS>OS',
    ['Circle of Applied Force'] =  'Warrior (Tank) = Druid (Feral) = Paladin (Ret) = Warrior (DPS) > MS>OS',

    ['Drake Talon Cleaver'] =  'MS > OS',
    ['Drake Talon Pauldrons'] =  'Warrior (DPS) = Warrior (Tank) = Paladin (Ret) > MS>OS',
    ['Ring of Blackrock'] =  'Caster DPS > MS>OS',
    ['Shadow Wing Focus Staff'] =  'Mage = Warlock = Druid = Shadow Priest > MS>OS',
    ['Taut Dragonhide Belt'] =  'Druid (Feral) > MS>OS',
    ['Rejuvenating Gem'] =  'MS > OS',

    ['Angelista\'s Grasp'] =  'Caster DPS',
    ['Chromatic Boots'] =  'Warrior (DPS) = Warrior (Tank) = Paladin (Ret) > MS>OS',
    ['Claw of Chromaggus'] =  'Caster DPS > MS>OS',
    ['Elementium Threaded Cloak'] =  'Druid (Feral) > Warrior (Tank) > MS>OS',
    ['Empowered Leggings'] =  'MS > OS',
    ['Girdle of the Fallen Crusader'] =  'Paladin (Ret) > MS>OS',
    ['Taut Dragonhide Gloves'] =  'Paladin (Holy) > Druid ( Resto)',
    ['Taut Dragonhide Shoulderpads'] =  'Druid (Feral) > MS>OS',
    ['Shimmering Geta'] =  'MS > OS',
    ['Ashjre\'thul, Crossbow of Smiting'] =  'Hunter > MS>OS',
    ['Chromatically Tempered Sword'] =  'Warrior (DPS) = Rogue (Sword)',
    ['Elementium Reinforced Bulwark'] =  'Warrior (Tank) > MS>OS',
    ['Ashkandi, Greatsword of the Brotherhood'] =  'Warrior PvP Rank 7 > Hunter PvP Rank 7 > MS>OS',
    ['Archimtiros\' Ring of Reckoning'] =  'Druid (Feral) > Warrior (Tank) > MS>OS',
    ['Boots of the Shadow Flame'] =  'Druid (Feral) = Rogue > Warrior (DPS) > MS>OS',
    ['Cloak of the Brood Lord'] =  'Caster DPS > MS>OS',
    ['Crul\'shorukh, Edge of Chaos'] =  'Warrior (Tank) = Warrior (DPS)',
    ['Head of Nefarian'] =  'MS > OS',
    ['Mish\'undare, Circlet of the Mind Flayer'] =  'Mage = Warlock = Paladin (Holy) = Shadow Priest',
    ['Prestor\'s Talisman of Connivery'] =  'Hunter = Druid (Feral) = Rogue > Warrior (DPS) > MS>OS',
    ['Pure Elementium Band'] =  'MS > OS',
    ['Therazane\'s Link'] =  'MS > OS',
    ['Neltharion\'s Tear'] =  'Caster DPS > MS>OS',
    ['Lok\'amir il Romathis'] =  'Paladin = Druid (Resto) = Shadow Priest = Priest > MS>OS',
    ['Staff of the Shadow Flame'] =  'Warlock = Mage = Druid (Boom) > MS>OS',
    ['REPLACE_ME'] =  'MS > OS',
}