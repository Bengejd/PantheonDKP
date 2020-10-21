local _, core = ...;
local _G = _G;
local L = core.L;

local Loot = core.Loot;
local Settings = core.Settings;
local Util = core.Util;
local Defaults = core.Defaults;

local UnitGUID, UnitName = UnitGUID, UnitName
local GetLootMethod, GetLootSlotInfo, GetNumLootItems, GetLootInfo, GetItemInfo, GetLootSlotLink = GetLootMethod, GetLootSlotInfo, GetNumLootItems, GetLootInfo, GetItemInfo, GetLootSlotLink
local select = select
local GetServerTime = GetServerTime

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

    if mob_loot_info ~= nil and #mob_loot_info >= 1 then
        Loot.lastLootInfo = mob_loot_info
        Loot.records[mob_uid] = mob_loot_info
    end

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

function PDKP_SetToolTipPrio(tt)
    local itemName, _ = tt:GetItem()
    if not itemName then return end

    local prio = Loot:GetPriority(itemName)

    if prio ~= nil then
        tt:AddLine(' ')
        tt:AddLine(Util:FormatFontTextColor('ffff00', 'Pantheon Prio'))
        tt:AddLine(prio)
    end
end

function Loot:GetPriority(itemName)
    local prio = Loot.priority[itemName]
    if prio == nil then
        local name = select(1, GetItemInfo(itemName))
        prio = Loot.priority[name]
        if prio == nil then return nil end
    end

    prio = prio[1]

    -- Make it look pretty
    for key, value in pairs(Defaults.class_colors) do
        local color = Util:FormatFontTextColor(value, key)
        local newPrio, _ = string.gsub(prio, key, color, 3)
        prio = newPrio
    end
    local newPrio, _ = string.gsub(prio, 'LC', '|cffE71D36LC|r', 1)
    prio = newPrio

    return prio
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
Loot.priority = {
    ["Anubisath Warhammer"]={"Warrior"},
    ["Ritssyn's Ring of Chaos"]={"Mage"},
    ["Gloves of the Immortal"]={"MS>OS"},
    ["Neretzek, The Blood Drinker"]={"MS>OS"},
    ["Gloves of the Redeemed Prophecy"]={"MS>OS"},
    ["Shard of the Fallen Star"]={"MS>OS"},
    ["Qiraji Bindings of Command"]={"Rogue = Warrior = Shadow Priest"},
    ["Qiraji Bindings of Dominance"]={"Warlock = Mage = Ret Paladin"},
    ["Vek'lor's Diadem"]={"Rogue = Ret Paladin"},
    ["Vek'nilash's Circlet"]={"Warlock = Shadow Priest = Mage = Warrior (Tank)"},
    ["Ouro's Intact Hide"]={"Warrior = Rogue"},
    ["Skin of the Great Sandworm"]={"Ret Paladin > MS>OS"},
    ["Carapace of the Old God"]={"Rogue = Warrior = Ret Paladin = Hunter*  Hunter must have at least two pieces of gear that justify breaking T2 set."},
    ["Husk of the Old God"]={"Mage"},
    ["Imperial Qiraji Armaments"]={"Rogue = Warrior > Hunter"},
    ["Imperial Qiraji Regalia"]={"Druid (Feral) > Warlock = MS>OS"},
    ["Staff of the Qiraji Prophets"]={"Warlock"},
    ["Leggings of Immersion"]={"MS>OS"},
    ["Barrage Shoulders"]={"Hunter > MS>OS"},
    ["Pendant of the Qiraji Guardian"]={"MS>OS"},
    ["Cloak of Concentrated Hatred"]={"Warrior (Tank) = Druid (Feral) = Rogue > Ret Paladin > Warrior"},
    ["Hammer of Ji'zhi"]={"MS>OS"},
    ["Boots of the Redeemed Prophecy"]={"MS>OS"},
    ["Boots of Unwavering Will"]={"MS>OS"},
    ["Ring of Swarming Thought"]={"MS>OS"},
    ["Breastplate of Annihilation"]={"Warrior (DPS)"},
    ["Boots of the Fallen Hero"]={"Warrior (Tank) > Warrior (DPS)"},
    ["Gloves of Ebru"]={"MS>OS"},
    ["Angelista's Charm"]={"MS>OS"},
    ["Mantle of the Desert Crusade"]={"MS>OS"},
    ["Mantle of the Desert's Fury"]={"MS>OS"},
    ["Mantle of Phrenic Power"]={"Mage"},
    ["Wand of Qiraji Nobility"]={"Warlock = Shadow Priest = Mage > Priest"},
    ["Vest of the Swift Execution"]={"Druid (Feral)"},
    ["Ring of the Devoured"]={"MS>OS"},
    ["Petrified Scarab"]={"MS>OS"},
    ["Triad Girdle"]={"MS>OS"},
    ["Guise of the Devourer"]={"Druid (Feral)"},
    ["Ternary Mantle"]={"Priest"},
    ["Angelista's Touch"]={"MS>OS"},
    ["Cape of the Trinity"]={"MS>OS"},
    ["Sartura's Might"]={"Druid (Resto) = Priest = Paladin"},
    ["Legplates of Blazing Light "]={"Paladin"},
    ["Creeping Vine Helm"]={"Druid (Resto)"},
    ["Badge of the Swarmguard"]={"MS>OS"},
    ["Gloves of Enforcement"]={"Druid (Feral) > Rogue > Warrior (DPS)"},
    ["Robes of the Battleguard"]={"MS>OS"},
    ["Silithid Claw"]={"Hunter"},
    ["Gauntlet's of Steadfast Dominance"]={"Warrior (Tank)"},
    ["Thick Qirajihide Belt"]={"MS>OS"},
    ["Leggings of the Festering Swarm"]={"MS>OS"},
    ["Barb of the Sandreaver"]={"Hunter"},
    ["Pauldrons of the Unrelenting"]={"MS>OS"},
    ["Hive Tunneler's Boots"]={"MS>OS"},
    ["Fetish of the Sandreaver"]={"MS>OS"},
    ["Ancient Qiraji Ripper"]={"Rogue = Warrior (DPS)"},
    ["Robes of the Guardian Saint"]={"Druid (Resto) = Priest = Paladin"},
    ["Barbed Choker"]={"MS>OS"},
    ["Mantle of Wicked Revenge"]={"Druid (Feral)"},
    ["Libram of Grace"]={"Free Roll"},
    ["Sharpened Silithid Femur"]={"Warlock = Mage"},
    ["Gauntlets of the Righteous Champion"]={"MS>OS"},
    ["Gauntlets of Kalimdor"]={"MS>OS"},
    ["Scarab Brooch"]={"MS>OS"},
    ["Ring of the Qiraji Fury"]={"Hunter > MS>OS"},
    ["Idol of Health"]={"Free Roll"},
    ["Huhuran's Stinger"]={"MS>OS"},
    ["Wasphide Gauntlets"]={"Druid (Resto)"},
    ["Hive Defiler Wristguards"]={"MS>OS"},
    ["Gloves of the Messiah"]={"MS>OS"},
    ["Ring of the Martyr"]={"Druid (Resto) = Priest = Paladin"},
    ["Cloak of the Golden Hive"]={"Warrior (Tank) = Druid (Feral) > MS>OS"},
    ["Royal Qiraji Belt"]={"MS>OS"},
    ["Royal Scepter of Vek'lor"]={"Warlock = Mage > Shadow Priest"},
    ["Vek'lor's Gloves of Devastation"]={"MS>OS"},
    ["Boots of Epiphany"]={"Shadow Priest"},
    ["Ring of Emperor Vek'lor"]={"Druid (Feral) = Warrior (Tank) > MS>OS"},
    ["Qiraji Execution Bracers"]={"Druid (Feral) = Rogue > Warrior"},
    ["Bracelets of Royal Redemption"]={"Druid (Resto) = Paladin r Priest"},
    ["Gloves of the Hidden Temple"]={"Druid (Feral)"},
    ["Belt of the Fallen Emperor"]={"MS>OS"},
    ["Amulet of Vek'nilash"]={"Warlock = Mage"},
    ["Grasp of the Fallen Emperor"]={"MS>OS"},
    ["Regenerating Belt of Vek'nilash"]={"MS>OS"},
    ["Kalimdor's Revenge"]={"Ret Paladin"},
    ["Wormscale Blocker"]={"MS>OS"},
    ["Burrower Bracers"]={"MS>OS"},
    ["Don Rigoberto's Lost hat"]={"Priest = Druid (Resto) = Paladin"},
    ["Larvae of the Great Worm"]={"Hunter = Warrior"},
    ["The Burrower's Shell"]={"MS>OS"},
    ["Jom Gabbar"]={"Hunter = Rogue"},
    ["Eye of C'thun"]={"Heals & Casters > MS>OS"},
    ["Dark Edge of Insanity"]={"MS>OS"},
    ["Vanquished Tentacle of C'thun"]={"MS>OS"},
    ["Gauntlets of Annihalation"]={"Warrior = Paladin (Ret)"},
    ["Grasp of the Old God"]={"MS>OS"},
    ["Cloak of Clarity"]={"MS>OS"},
    ["Dark Storm Gauntlets"]={"Warlock = Mage = Shadow Priest"},
    ["Belt of Never-ending Agony"]={"Rogue = Druid (Feral)* > Hunter  *Druids must have 1.5x DKP of the next highest rogue shroud"},
    ["Ring of the Godslayer"]={"Hunter > MS>OS"},
    ["Scepter of the False Prophet"]={"MS>OS"},
    ["Eyestalk Waist Cord"]={"Warlock = Mage"},
    ["Cloak of the Devoured"]={"Warlock = Mage = Shadow Priest"},
    ["Mark of C'thun"]={"Druid (Feral) = Warrior (Tank)"},
    ["Band of Dark Dominion"]={"Warlock = Shadow Priest"},
    ["Boots of Pure Thought"]={"MS>OS"},
    ["Cloak of Draconic Might"]={"Warrior (DPS) = Ret Paladin = Warrior (Tank) > Rogue > MS>OS >"},
    ["Doom's Edge"]={"Warrior (Tank) = Warrior (DPS) > MS>OS"},
    ["Draconic Avenger (PVP)"]={"MS>OS"},
    ["Draconic Maul (PVP)"]={"Druid (Feral) > MS>OS"},
    ["Essence Gatherer"]={"Priest > MS>OS"},
    ["Interlaced Shadow Jerkin (PVP)"]={"MS>OS"},
    ["Ringo's Blizzard Boots"]={"Mage > MS>OS"},
    ["Elementium Ore"]={"Guild Bank"},
    ["Gloves of Rapid Evolution"]={"Mage = Warlock = Shadow Priest > MS>OS"},
    ["Mantle of the Blackwing Cabal"]={"MS>OS"},
    ["Spineshatter"]={"MS>OS"},
    ["The Untamed Blade"]={"MS>OS"},
    ["Dragonfang Blade"]={"Rogue = Warrior"},
    ["Helm of Endless Rage "]={"Warrior (Tank) > Warrior (DPS) > MS>OS"},
    ["Pendant of the Fallen Dragon"]={"MS>OS"},
    ["Red Dragonscale Protector"]={"Paladin > MS>OS"},
    ["Black Brood Pauldrons "]={"MS>OS"},
    ["Bracers of Arcane Accuracy"]={"Mage = Warlock = Shadow Priest > MS>OS"},
    ["Heartstriker (PVP)"]={"MS>OS"},
    ["Maladath, Runed Blade of the Black Flight"]={"Rogue (Sword) = Warrior (Tank) = Warrior (DPS) > MS>OS"},
    ["Black Ash Robe"]={"MS>OS"},
    ["Claw of the Black Drake"]={"MS>OS"},
    ["Cloak of Firemaw"]={"Rogue = Hunter > Warrior (Tank) = Warrior (DPS) = Paladin (Ret) > MS>O"},
    ["Firemaw's Clutch"]={"Shadow Priest = Warlock = Mage = Druid (Boom) > MS>OS"},
    ["Legguards of the Fallen Crusader"]={"Paladin (Ret) = Warrior (DPS) > Warrior (Tank) > MS>OS"},
    ["Band of Forced Concentration"]={"Mage = Warlock = Shadow Priest = Druid (Boom) > MS>OS"},
    ["Dragonbreath Hand Cannon"]={"Warrior (Tank) > MS>OS"},
    ["Ebony Flame Gloves"]={"Warlock = Shadow Priest > MS>OS"},
    ["Malfurion's Blessed Bulwark"]={"Druid (Feral) > Warrior (DPS) > MS>OS"},
    ["Drake Fang Talisman"]={"Warrior (Tank) = Druid (Feral) = Warrior (DPS) = Rogue = Hunter*  *Hunters must have 1.5x DKP of the next highest shrou"},
    ["Emberweave Leggings"]={"Hunter > Warrior (Tank) > MS>OS"},
    ["Shroud of Pure Thought"]={"MS>OS"},
    ["Herald of Woe "]={"Paladin (Ret) > MS>OS"},
    ["Dragon's Touch "]={"Caster DPS > MS>OS"},
    ["Styleen's Impeding Scarab"]={"Warrior (Tank) > MS>OS"},
    ["Circle of Applied Force "]={"Warrior (Tank) = Druid (Feral) = Paladin (Ret) = Warrior (DPS) > MS>OS"},
    ["Drake Talon Cleaver "]={"MS>OS"},
    ["Drake Talon Pauldrons"]={"Warrior (DPS) = Warrior (Tank) = Paladin (Ret) > MS>OS"},
    ["Ring of Blackrock"]={"Caster DPS > MS>OS"},
    ["Shadow Wing Focus Staff"]={"Mage = Warlock = Druid = Shadow Priest > MS>OS"},
    ["Taut Dragonhide Belt"]={"Druid (Feral) > MS>OS"},
    ["Rejuvenating Gem"]={"MS>OS"},
    ["Angelista's Grasp"]={"Caster DPS"},
    ["Chromatic Boots"]={"Warrior (DPS) = Warrior (Tank) = Paladin (Ret) > MS>OS"},
    ["Claw of Chromaggus"]={"Caster DPS > MS>OS"},
    ["Elementium Threaded Cloak"]={"Druid (Feral) > Warrior (Tank) > MS>OS"},
    ["Empowered Leggings"]={"MS>OS"},
    ["Girdle of the Fallen Crusader "]={"Paladin (Ret) > MS>OS"},
    ["Taut Dragonhide Gloves "]={"Paladin (Holy) > Druid ( Resto)"},
    ["Taut Dragonhide Shoulderpads"]={"Druid (Feral) > MS>OS"},
    ["Shimmering Geta"]={"MS>OS"},
    ["Ashjre'thul, Crossbow of Smiting"]={"Hunter > MS>OS"},
    ["Chromatically Tempered Sword"]={"Warrior (DPS) = Rogue (Sword) > MS>OS"},
    ["Elementium Reinforced Bulwark"]={"Warrior (Tank) > MS>OS"},
    ["Ashkandi, Greatsword of the Brotherhood"]={"Warrior(PvP) = Hunter(PvP) = Paladin (Ret) > MS>OS"},
    ["Archimtiros' Ring of Reckoning"]={"Druid (Feral) > Warrior (Tank) > MS>OS"},
    ["Boots of the Shadow Flame"]={"Druid (Feral) = Rogue > Warrior (DPS) > MS>OS"},
    ["Cloak of the Brood Lord"]={"Caster DPS > MS>OS"},
    ["Head of Nefarian"]={"MS>OS"},
    ["Mish'undare, Circlet of the Mindflayer"]={"Mage = Warlock = Paladin (Holy)   = Shadow Priest"},
    ["Prestor's Talisman of Connivery"]={"Hunter = Druid (Feral) = Rogue > Warrior (DPS) > MS>OS"},
    ["Pure Elementium Band"]={"MS>OS"},
    ["Therazane's Link"]={"MS>OS"},
    ["Neltharion's Tear"]={"Caster DPS > MS>OS"},
    ["Lok'amir il Romathis"]={"Paladin = Druid (Resto)   = Shadow Priest > Priest > MS>OS"},
    ["Staff of the Shadow Flame"]={"Warlock = Mage   = Druid (Boom) > MS>OS"},
    ["Crimson Shocker"]={"MS>OS"},
    ["Flamewaker Legplates"]={"MS>OS"},
    ["Heavy Dark Iron Ring"]={"Druid (Feral) > MS>OS"},
    ["Helm of the Lifegiver"]={"MS>OS"},
    ["Manastorm Leggings"]={"MS>OS"},
    ["Ring of Spell Power"]={"Mage = Warlock = Druid (Boom) = Shadow Priest > MS>OS"},
    ["Robes of Volatile Power"]={"Mage = Warlock = Druid (Boom) = Paladin"},
    ["Salamander Scale Pants"]={"Druid (Resto) = Paladin"},
    ["Sorcerous Dagger"]={"MS>OS"},
    ["Wristguards of Stability"]={"Druid (Feral) = Warrior (DPS)"},
    ["Aged Core Leather Gloves"]={"Rogue (dag) > Warrior"},
    ["Fire Runed Grimoire"]={"Mage = Warlock > MS>OS"},
    ["Flameguard Gauntlets"]={"MS>OS"},
    ["Magma Tempered Boots"]={"MS>OS"},
    ["Mana Igniting Cord"]={"Mage = Druid (Boom) = Warlock > Paladin"},
    ["Obsidian Edged Blade"]={"MS>OS"},
    ["Quick Strike Ring"]={"Warrior > Hunter = Druid (Feral) = Rogue"},
    ["Sabatons of the Flamewalker"]={"MS>OS"},
    ["Talisman of Ephemeral Power"]={"Mage = Warlock = Shadow Priest = Druid (Boom) > MS>OS"},
    ["Choker of Enlightenment"]={"Mage = Warlock = Shadow Priest > MS>OS"},
    ["Earthshaker"]={"MS>OS"},
    ["Eskhandar's Right Claw"]={"MS>OS"},
    ["Medallion of Steadfast Might"]={"MS>OS"},
    ["Striker's Mark"]={"Rogue = Warrior > MS>OS"},
    ["Aurastone Hammer"]={"Druid (Resto) = Paladin > MS>OS"},
    ["Brutality Blade"]={"Rogue = Warrior (DPS) = Hunter"},
    ["Drillborer Disk"]={"MS>OS"},
    ["Gutgore Ripper"]={"Rogue > MS>OS"},
    ["Seal of the Archmagus"]={"MS>OS"},
    ["Shadowstrike"]={"MS>OS"},
    ["Azuresong Mageblade"]={"Mage = Warlock = Paladin > MS>OS"},
    ["Blastershot Launcher (PVP)"]={"Warrior (Tank) = Warrior (DPS) > Rogue > Hunter"},
    ["Staff of Dominance"]={"Mage = Warlock = Druid (Boom)"},
    ["Ancient Petrified Leaf"]={"Sinew > No Sinew"},
    ["Cauterizing Band"]={"MS>OS"},
    ["Core Forged Greaves"]={"Warrior (Tank) > MS>OS"},
    ["Core Hound Tooth"]={"MS>OS"},
    ["Finkle's Lava Dredger"]={"MS>OS"},
    ["Fireguard Shoulders"]={"Warrior (Tank) = Druid (Feral) > MS>OS"},
    ["Fireproof Cloak"]={"Warrior (Tank) = Druid (Feral) > MS>OS"},
    ["Gloves of the Hypnotic Flame"]={"Mage = Warlock"},
    ["Sash of Whispered Secrets"]={"Shadow Priest > Warlock > MS>OS"},
    ["The Eye of Divinity"]={"EOS > No EOS"},
    ["Wild Growth Spaulders"]={"Druid (Resto) = Paladin > MS>OS"},
    ["Wristguards of True Flight"]={"Warrior (Tank) = Warrior (DPS) = Hunter > MS>OS"},
    ["Band of Accuria"]={"Warrior (Tank) = Druid (Feral) = Hunter = Rogue = Warrior (DPS)"},
    ["Band of Sulfuras"]={"MS>OS"},
    ["Bonereaver's Edge"]={"Warrior PvP > MS>OS  R7 min"},
    ["Choker of the Fire Lord"]={"Mage = Warlock = Shadow Priest = Druid (Boom)"},
    ["Cloak of the Shrouded Mists"]={"Hunter = Warrior (Tank) > Rogue > MS>OS"},
    ["Crown of Destruction"]={"Hunter = Warrior (DPS) = Paladin (ret)"},
    ["Dragon's Blood Cape"]={"Warrior (Tank) = Druid (Feral) > MS>OS"},
    ["Essence of the Pure Flame"]={"Warrior (Tank) > MS>OS"},
    ["Malistar's Defender"]={"MS>OS"},
    ["Onslaught Girdle"]={"Warrior (Tank) = Warrior (DPS) > Paladin (ret)"},
    ["Perdition's Blade"]={"Rogue (dag) > Warrior (Dag) > MS>OS"},
    ["Shard of the Flame"]={"MS>OS"},
    ["Spinal Reaper"]={"MS>OS"},
    ["Ancient Cornerstone Grimoire"]={"MS>OS"},
    ["Eskhandar's Collar"]={"Druid (Feral) > MS>OS"},
    ["Deathbringer"]={"Warrior (Tank) = Warrior (DPS)"},
    ["Death's Sting"]={'LC: Rogue (Daggers) = Warrior (Daggers)'},
    ["Head of Onyxia"]={"MS>OS"},
    ["Sapphiron Drape "]={"MS>OS"},
    ["Shard of the Scale"]={"Paladin = Priest = Druid (Resto)"},
    ["Ring of Binding"]={"Druid (Feral) > MS>OS"},
    ["Vis'kag the Bloodletter"]={"Rogue = Warrior (DPS)"},
    ["Sinew"]={"Leaf > No Leaf"},
    ["Garb of Royal Ascension"]={'LC: Warlock (Tank)'},
    ["Beetle Scale Wristguards"]={'LC: Druid (Feral) = Rogue'},
    ["Amulet of Foul Warding"]={'LC: Warrior (Tank) = Druid (Feral) = Rogue'},
    ["Ooze-ridden Gauntlets"]={'LC: Warrior (Tank)'},
    ["Bile-covered Gauntlets"]={'LC: Druid (Feral) > Rogue'},
    ["Ukko's Ring of Darkness"]={'LC: Warlock'},
    ["Robes of the Triumvirate"]={'LC: MS>OS'},
    ["Recomposed Boots"]={'LC: MS>OS'},
    ["Necklace of Purity"]={'LC: MS>OS'},
    ["Cloak of Untold Secrets"]={'LC: Warlock'},
    ["Silithid Carapace Chestguard"]={'LC: MS>OS'},
}