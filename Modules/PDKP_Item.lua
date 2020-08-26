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

local previousItemID = -1

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

function item:ToolTipInit()
    GameTooltip:HookScript( "OnTooltipSetItem", SetToolTipPrio)
end

function SetToolTipPrio(tt)
    local itemName, itemLink = tt:GetItem()
    if not itemName then return end

    local prio = item:GetPriority(itemName)

    if prio ~= nil then
        tt:AddLine(' ')
        tt:AddLine(Util:FormatFontTextColor('ffff00', 'Pantheon Prio'))
        tt:AddLine(prio)
    end
end

item.priority = {

    -- AHN'QIRAJ 40 LOOT --

    -- Trash Drops Loot --

    ['Anubisath Warhammer'] = 'Warrior',
    ['Ritssyn\'s Ring of Chaos'] = 'Mage',
    ['Gloves of the Immortal'] = 'MS > OS',
    ['Garb of Royal Ascension'] = 'LC: Warlock (Tank)',
    ['"Neretzek, The Blood Drinker"'] = 'MS > OS',
    ['Gloves of the Redeemed Prophecy'] = 'MS > OS',
    ['Shard of the Fallen Star'] = 'MS > OS',

    -- Tokens (Most T2.5 LCs will be removed after the first few weeks of AQ40) Loot --

    ['Qiraji Bindings of Command'] = 'Rogue = Warrior = Shadow Priest',
    ['Qiraji Bindings of Dominance'] = 'Warlock = Mage = Ret Paladin',
    ['Vek\'lor\'s Diadem'] = 'Rogue = Ret Paladin',
    ['Vek\'nilash\'s Circlet'] = 'Warlock = Shadow Priest = Mage = Warrior (Tank)',
    ['Ouro\'s Intact Hide'] = 'Warrior = Rogue',
    ['Skin of the Great Sandworm'] = 'Ret Paladin > MS > OS',
    ['Carapace of the Old God'] = 'Rogue = Warrior = Ret Paladin',
    ['Husk of the Old God'] = 'Mage',
    ['Imperial Qiraji Armaments'] = 'Rogue = Warrior > Hunter',
    ['Imperial Qiraji Regalia'] = 'Druid (Feral) > Warlock > MS > OS',

    -- The Prophet Skeram Loot --

    ['Staff of the Qiraji Prophets'] = 'Warlock',
    ['Leggings of Immersion'] = 'MS > OS',
    ['Barrage Shoulders'] = 'Hunter > MS > OS',
    ['Pendant of the Qiraji Guardian'] = 'MS > OS',
    ['Cloak of Concentrated Hatred'] = 'Warrior (Tank) = Druid (Feral) = Rogue > Ret Paladin > Warrior',
    ['Hammer of Ji\'zhi'] = 'MS > OS',
    ['Boots of the Redeemed Prophecy'] = 'MS > OS',
    ['Boots of Unwavering Will'] = 'MS > OS',
    ['Ring of Swarming Thought'] = 'MS > OS',
    ['Beetle Scale Wristguards'] = 'LC: Druid (Feral) = Rogue',
    ['Breastplate of Annihilation'] = 'Warrior (DPS)',
    ['Amulet of Foul Warding'] = 'LC: Warrior (Tank) = Druid (Feral) = Rogue',

    -- Bug Family Loot --

    ['Boots of the Fallen Hero'] = 'Warrior (Tank) > Warrior (DPS)',
    ['Gloves of Ebru'] = 'MS > OS',
    ['Angelista\'s Charm'] = 'MS > OS',
    ['Ooze-ridden Gauntlets'] = 'LC: Warrior (Tank)',
    ['Bile-covered Gauntlets'] = 'LC: Druid (Feral) = Rogue',
    ['Mantle of the Desert Crusade'] = 'MS > OS',
    ['Mantle of the Desert\'s Fury'] = 'Mage',
    ['Mantle of Phrenic Power'] = 'MS > OS',
    ['Ukko\'s Ring of Darkness'] = 'LC: Warlock',
    ['Wand of Qiraji Nobility'] = 'Warlock = Shadow Priest = Mage > Priest',
    ['Vest of the Swift Execution'] = 'Druid (Feral)',
    ['Ring of the Devoured'] = 'MS > OS',
    ['Petrified Scarab'] = 'MS > OS',
    ['Triad Girdle'] = 'MS > OS',
    ['Guise of the Devourer'] = 'Druid (Feral)',
    ['Ternary Mantle'] = 'Priest',
    ['Angelista\'s Touch'] = 'MS > OS',
    ['Robes of the Triumvirate'] = 'LC: MS > OS',
    ['Cape of the Trinity'] = 'MS > OS',

    -- Battleguard Sartura Loot --

    ['Recomposed Boots'] = 'LC: MS > OS',
    ['Sartura\'s Might'] = 'Druid (Resto) = Priest = Paladin',
    ['Legplates of Blazing Light '] = 'Paladin',
    ['Creeping Vine Helm'] = 'Druid (Resto)',
    ['Badge of the Swarmguard'] = 'MS > OS',
    ['Gloves of Enforcement'] = 'Druid (Feral) > Rogue > Warrior (DPS)',
    ['Robes of the Battleguard'] = 'MS > OS',
    ['Silithid Claw'] = 'Hunter',
    ['Gauntlet\'s of Steadfast Dominance'] = 'Warrior (Tank)',
    ['Thick Qirajihide Belt'] = 'MS > OS',
    ['Leggings of the Festering Swarm'] = 'MS > OS',
    ['Necklace of Purity'] = 'LC: MS > OS',

    -- Fankriss the Unyielding Loot --

    ['Cloak of Untold Secrets'] = 'LC: Warlock',
    ['Barb of the Sandreaver'] = 'Hunter',
    ['Pauldrons of the Unrelenting'] = 'MS > OS',
    ['Hive Tunneler\'s Boots'] = 'MS > OS',
    ['Fetish of the Sandreaver'] = 'MS > OS',
    ['Ancient Qiraji Ripper'] = 'Rogue = Warrior (DPS)',
    ['Silithid Carapace Chestguard'] = 'LC: MS > OS',
    ['Robes of the Guardian Saint'] = 'Druid (Resto) = Priest = Paladin',
    ['Barbed Choker'] = 'MS > OS',
    ['Mantle of Wicked Revenge'] = 'Druid (Feral)',
    ['Libram of Grace'] = 'Free Roll',

    -- Viscidus Loot --

    ['Sharpened Silithid Femur'] = 'Warlock = Mage',
    ['Gauntlets of the Righteous Champion'] = 'MS > OS',
    ['Gauntlets of Kalimdor'] = 'MS > OS',
    ['Scarab Brooch'] = 'MS > OS',
    ['Ring of the Qiraji Fury'] = 'Hunter > MS > OS',
    ['Idol of Health'] = 'Free Roll',

    -- Princess Huhuran Loot --

    ['Huhuran\'s Stinger'] = 'MS > OS',
    ['Wasphide Gauntlets'] = 'Druid (Resto)',
    ['Hive Defiler Wristguards'] = 'MS > OS',
    ['Gloves of the Messiah'] = 'MS > OS',
    ['Ring of the Martyr'] = 'Druid (Resto) = Priest = Paladin',
    ['Cloak of the Golden Hive'] = 'Warrior (Tank) = Druid (Feral) > MS > OS',

    -- Twin Emperors Loot --

    ['Royal Qiraji Belt'] = 'MS > OS',
    ['Royal Scepter of Vek\'lor'] = 'Warlock = Mage > Shadow Priest',
    ['Vek\'lor\'s Gloves of Devastation'] = 'MS > OS',
    ['Boots of Epiphany'] = 'Shadow Priest',
    ['Ring of Emperor Vek\'lor'] = 'Druid (Feral) = Warrior (Tank) > MS > OS',
    ['Qiraji Execution Bracers'] = 'Druid (Feral) = Rogue > Warrior',
    ['Bracelets of Royal Redemption'] = 'Druid (Resto) = Paladin > Priest',
    ['Gloves of the Hidden Temple'] = 'Druid (Feral)',
    ['Belt of the Fallen Emperor'] = 'MS > OS',
    ['Amulet of Vek\'nilash'] = 'Warlock = Mage',
    ['Grasp of the Fallen Emperor'] = 'MS > OS',
    ['Regenerating Belt of Vek\'nilash'] = 'MS > OS',
    ['Kalimdor\'s Revenge'] = 'Ret Paladin',

    -- Ouro Loot --

    ['Wormscale Blocker'] = 'MS > OS',
    ['Burrower Bracers'] = 'MS > OS',
    ['Don Rigoberto\'s Lost hat'] = 'Priest = Druid (Resto) = Paladin',
    ['Larvae of the Great Worm'] = 'Hunter = Warrior',
    ['The Burrower\'s Shell'] = 'MS > OS',
    ['Jom Gabbar'] = 'Hunter = Rogue',

    -- C'thun Loot --

    ['Eye of C\'thun'] = '4 Week Caster > 4 Week Healer > MS > OS',
    ['Death\'s Sting'] = 'LC:',
    ['Vanquished Tentacle of C\'thun'] = 'MS > OS',
    ['Gauntlets of Annihalation'] = 'Warrior = Paladin (Ret)',
    ['Grasp of the Old God'] = 'MS > OS',
    ['Cloak of Clarity'] = 'MS > OS',
    ['Dark Storm Gauntlets'] = 'Warlock = Mage = Shadow Priest',
    ['Belt of Never-ending Agony'] = 'Rogue > Druid (Feral) = Hunter',
    ['Ring of the Godslayer'] = 'MS > OS',
    ['Scepter of the False Prophet'] = 'MS > OS',
    ['Eyestalk Waist Cord'] = 'Warlock = Mage',
    ['Cloak of the Devoured'] = 'Warlock = Mage = Shadow Priest',
    ['Mark of C\'thun'] = 'Druid (Feral) = Warrior (Tank)',

    -- BLACKWING LAIR LOOT --
    ['Band of Dark Dominion'] = 'Warlock = Shadow Priest',
    ['Boots of Pure Thought'] = 'MS > OS',
    ['Cloak of Draconic Might'] = 'Warrior (DPS) = Ret Paladin = Warrior (Tank) > Rogue > MS > OS >',
    ['Doom\'s Edge'] = 'Warrior (Tank) = Warrior (DPS) > MS > OS',
    ['Draconic Avenger (PVP)'] = 'MS > OS',
    ['Draconic Maul (PVP)'] = 'Druid (Feral) > MS > OS',
    ['Essence Gatherer'] = 'Priest > MS > OS',
    ['Interlaced Shadow Jerkin (PVP)'] = 'MS > OS',
    ['Ringo\'s Blizzard Boots'] = 'Mage > MS > OS',
    ['Elementium Ore'] = 'Guild Bank',
    ['Gloves of Rapid Evolution'] = 'Mage = Warlock = Shadow Priest > MS > OS',
    ['Mantle of the Blackwing Cabal'] = 'MS > OS',
    ['Spineshatter'] = 'MS > OS',
    ['The Untamed Blade'] = 'MS > OS',
    ['Dragonfang Blade'] = 'Rogue = Warrior',
    ['Helm of Endless Rage '] = 'Warrior (Tank) > Warrior (DPS) > MS > OS',
    ['Pendant of the Fallen Dragon'] = 'MS > OS',
    ['Red Dragonscale Protector'] = 'Paladin > MS > OS',
    ['Black Brood Pauldrons '] = 'MS > OS',
    ['Bracers of Arcane Accuracy'] = 'Mage = Warlock = Shadow Priest > MS > OS',
    ['Heartstriker (PVP)'] = 'MS > OS',
    ['"Maladath, Runed Blade of the Black Flight"'] = 'Rogue (Sword) = Warrior (Tank) = Warrior (DPS) > MS > OS',
    ['Lifegiving Gem'] = 'LC: Warrior (Tank) > MS > OS',
    ['Black Ash Robe'] = 'MS > OS',
    ['Claw of the Black Drake'] = 'MS > OS',
    ['Cloak of Firemaw'] = 'Rogue = Hunter > Warrior (Tank) = Warrior (DPS) = Paladin (Ret) > MS > OS',
    ['Firemaw\'s Clutch'] = 'Shadow Priest = Warlock = Mage = Druid (Boom) > MS > OS',
    ['Legguards of the Fallen Crusader'] = 'Paladin (Ret) = Warrior (DPS) > Warrior (Tank) > MS > OS',
    ['Band of Forced Concentration'] = 'Mage = Warlock = Shadow Priest = Druid (Boom) > MS > OS',
    ['Dragonbreath Hand Cannon'] = 'Warrior (Tank) > MS > OS',
    ['Ebony Flame Gloves'] = 'Warlock = Shadow Priest > MS > OS',
    ['Malfurion\'s Blessed Bulwark'] = 'Druid (Feral) > Warrior (DPS) > MS > OS',
    ['Drake Fang Talisman'] = 'Warrior (Tank) = Druid (Feral) = Warrior (DPS) = Rogue = Hunter',
    ['Emberweave Leggings'] = 'Hunter > Warrior (Tank) > MS > OS',
    ['Shroud of Pure Thought'] = 'MS > OS',
    ['Herald of Woe '] = 'Paladin (Ret) > MS > OS',
    ['Dragon\'s Touch '] = 'Caster DPS > MS > OS',
    ['Styleen\'s Impeding Scarab'] = 'Warrior (Tank) > MS > OS',
    ['Circle of Applied Force '] = 'Warrior (Tank) = Druid (Feral) = Paladin (Ret) = Warrior (DPS) > MS > OS',
    ['Drake Talon Cleaver '] = 'MS > OS',
    ['Drake Talon Pauldrons'] = 'Warrior (DPS) = Warrior (Tank) = Paladin (Ret) > MS > OS',
    ['Ring of Blackrock'] = 'Caster DPS > MS > OS',
    ['Shadow Wing Focus Staff'] = 'Mage = Warlock = Druid = Shadow Priest > MS > OS',
    ['Taut Dragonhide Belt'] = 'Druid (Feral) > MS > OS',
    ['Rejuvenating Gem'] = 'MS > OS',
    ['Angelista\'s Grasp'] = 'Caster DPS',
    ['Chromatic Boots'] = 'Warrior (DPS) = Warrior (Tank) = Paladin (Ret) > MS > OS',
    ['Claw of Chromaggus'] = 'Caster DPS > MS > OS',
    ['Elementium Threaded Cloak'] = 'Druid (Feral) > Warrior (Tank) > MS > OS',
    ['Empowered Leggings'] = 'MS > OS',
    ['Girdle of the Fallen Crusader '] = 'Paladin (Ret) > MS > OS',
    ['Taut Dragonhide Gloves '] = 'Paladin (Holy) > Druid ( Resto)',
    ['Taut Dragonhide Shoulderpads'] = 'Druid (Feral) > MS > OS',
    ['Shimmering Geta'] = 'MS > OS',
    ['"Ashjre\'thul, Crossbow of Smiting"'] = 'Hunter > MS > OS',
    ['Chromatically Tempered Sword'] = 'Warrior (DPS) = Rogue (Sword) > MS > OS',
    ['Elementium Reinforced Bulwark'] = 'Warrior (Tank) > MS > OS',
    ['Archimtiros\' Ring of Reckoning'] = 'Druid (Feral) > Warrior (Tank) > MS > OS',
    ['Boots of the Shadow Flame'] = 'Druid (Feral) = Rogue > Warrior (DPS) > MS > OS',
    ['Cloak of the Brood Lord'] = 'Caster DPS > MS > OS',
    ['"Crul\'shorukh, Edge of Chaos"'] = 'Warrior (Tank) = Warrior (DPS)   c',
    ['Head of Nefarian'] = 'MS > OS',
    ['"Mish\'undare, Circlet of the Mindflayer"'] = 'Mage = Warlock = Paladin (Holy)   = Shadow Priest',
    ['Prestor\'s Talisman of Connivery'] = 'Hunter = Druid (Feral) = Rogue > Warrior (DPS) > MS > OS',
    ['Pure Elementium Band'] = 'MS > OS',
    ['Therazane\'s Link'] = 'MS > OS',
    ['Neltharion\'s Tear'] = 'Caster DPS > MS > OS',
    ['Lok\'amir il Romathis'] = 'Paladin = Druid (Resto)   = Shadow Priest = Priest > MS > OS',
    ['Staff of the Shadow Flame'] = 'Warlock = Mage   = Druid (Boom) > MS > OS',

    -- MOLTEN CORE LOOT --
    ['Crimson Shocker'] = 'MS > OS',
    ['Flamewaker Legplates'] = 'MS > OS',
    ['Heavy Dark Iron Ring'] = 'Druid (Feral) > MS > OS',
    ['Helm of the Lifegiver'] = 'MS > OS',
    ['Manastorm Leggings'] = 'MS > OS',
    ['Ring of Spell Power'] = 'Mage = Warlock = Druid (Boom) = Shadow Priest > MS > OS',
    ['Robes of Volatile Power'] = 'Mage = Warlock = Druid (Boom) = Paladin',
    ['Salamander Scale Pants'] = 'Druid (Resto) = Paladin',
    ['Sorcerous Dagger'] = 'MS > OS',
    ['Wristguards of Stability'] = 'Druid (Feral) = Warrior (DPS)',
    ['Aged Core Leather Gloves'] = 'Rogue (dag) > Warrior',
    ['Fire Runed Grimoire'] = 'Mage = Warlock > MS > OS',
    ['Flameguard Gauntlets'] = 'MS > OS',
    ['Magma Tempered Boots'] = 'MS > OS',
    ['Mana Igniting Cord'] = 'Mage = Druid (Boom) = Warlock > Paladin',
    ['Obsidian Edged Blade'] = 'MS > OS',
    ['Quick Strike Ring'] = 'Warrior = Hunter = Druid (Feral) = Rogue',
    ['Sabatons of the Flamewalker'] = 'MS > OS',
    ['Talisman of Ephemeral Power'] = 'Mage = Warlock = Shadow Priest = Druid (Boom) > MS > OS',
    ['Choker of Enlightenment'] = 'Mage = Warlock = Shadow Priest > MS > OS',
    ['Earthshaker'] = 'MS > OS',
    ['Eskhandar\'s Right Claw'] = 'MS > OS',
    ['Medallion of Steadfast Might'] = 'MS > OS',
    ['Striker\'s Mark'] = 'Rogue = Warrior > MS > OS',
    ['Aurastone Hammer'] = 'Druid (Resto) = Paladin > MS > OS',
    ['Brutality Blade'] = 'Rogue = Warrior (DPS) = Hunter',
    ['Drillborer Disk'] = 'MS > OS',
    ['Gutgore Ripper'] = 'Rogue > MS > OS',
    ['Seal of the Archmagus'] = 'MS > OS',
    ['Shadowstrike'] = 'MS > OS',
    ['Azuresong Mageblade'] = 'Mage = Warlock = Paladin > MS > OS',
    ['Blastershot Launcher (PVP)'] = 'Warrior (Tank) = Warrior (DPS) > Rogue > Hunter',
    ['Staff of Dominance'] = 'Mage = Warlock = Druid (Boom)',
    ['Ancient Petrified Leaf'] = 'Sinew > No Sinew',
    ['Cauterizing Band'] = 'MS > OS',
    ['Core Forged Greaves'] = 'Warrior (Tank) > MS > OS',
    ['Core Hound Tooth'] = 'MS > OS',
    ['Finkle\'s Lava Dredger'] = 'MS > OS',
    ['Fireguard Shoulders'] = 'Warrior (Tank) = Druid (Feral) > MS > OS',
    ['Fireproof Cloak'] = 'Warrior (Tank) = Druid (Feral) > MS > OS',
    ['Gloves of the Hypnotic Flame'] = 'Mage = Warlock',
    ['Sash of Whispered Secrets'] = 'Shadow Priest > Warlock > MS > OS',
    ['The Eye of Divinity'] = 'EOS > No EOS',
    ['Wild Growth Spaulders'] = 'Druid (Resto) = Paladin > MS > OS',
    ['Wristguards of True Flight'] = 'Warrior (Tank) = Warrior (DPS) = Hunter > MS > OS',
    ['Band of Accuria'] = 'Warrior (Tank) = Druid (Feral) = Hunter = Rogue = Warrior (DPS)',
    ['Band of Sulfuras'] = 'MS > OS',
    ['Bonereaver\'s Edge'] = 'Warrior PvP > MS > OS  R7 min',
    ['Choker of the Fire Lord'] = 'Mage = Warlock = Shadow Priest = Druid (Boom)',
    ['Cloak of the Shrouded Mists'] = 'Hunter = Warrior (Tank) > Rogue > MS > OS',
    ['Crown of Destruction'] = 'Hunter = Warrior (DPS) = Paladin (ret)',
    ['Dragon\'s Blood Cape'] = 'Warrior (Tank) = Druid (Feral) > MS > OS',
    ['Essence of the Pure Flame'] = 'Warrior (Tank) > MS > OS',
    ['Malistar\'s Defender'] = 'MS > OS',
    ['Onslaught Girdle'] = 'Warrior (Tank) = Warrior (DPS) > Paladin (ret)',
    ['Perdition\'s Blade'] = 'Rogue (dag) > Warrior (Dag) > MS > OS',
    ['Shard of the Flame'] = 'MS > OS',
    ['Spinal Reaper'] = 'MS > OS',
    ['Ancient Cornerstone Grimoire'] = 'MS > OS',
    ['Eskhandar\'s Collar'] = 'Druid (Feral) > MS > OS',
    ['Deathbringer'] = 'Warrior (Tank) = Warrior (DPS)',
    ['Head of Onyxia'] = 'MS > OS',
    ['Sapphiron Drape '] = 'MS > OS',
    ['Shard of the Scale'] = 'Paladin = Priest = Druid (Resto)',
    ['Ring of Binding'] = 'Druid (Feral) > MS > OS',
    ['Vis\'kag the Bloodletter'] = 'Rogue = Warrior (DPS)',
    ['Sinew'] = 'Leaf > No Leaf',

}