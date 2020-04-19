local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Raid = core.Raid;
local item = core.Item;

local raidHistory;

Raid.RaidInfo = {};

-- Start raid, select a time for the raid on-time bonus to go out.
-- Auto pop up raid boss kills when they occur
-- Auto award the completion bonus when the finalboss is killed.

Raid.bossIDS = {

    -- Molten Core
    [663] = "Lucifron",
    [664] = 'Magmadar',
    [665] = 'Gehennas',
    [666] = 'Garr',
    [667] = 'Shazzrah',
    [668] = 'Baron Geddon',
    [669] = 'Sulfuron Harbinger',
    [670] = 'Golemagg the Incinerator',
    [671] = 'Majordomo Executus',
    [672] = 'Ragnaros',

    -- Onyxia's Lair
    [1084]='Onyxia',

    -- Blackwing Lair
    [610] = "Razorgore the Untamed",
    [611] = "Vaelastrasz the Corrupt",
    [612] = "Broodlord Lashlayer",
    [613] = "Firemaw",
    [614] = "Ebonroc",
    [615] = "Flamegor",
    [616] =  "Chromaggus",
    [617] = "Nefarian",
}

Raid.recentBossKillID = nil
Raid.MasterLooter = nil

--[[ RAID DATABASE LAYOUT

   raids
        [raidID1] -- Unique Raid ID / Object
            partyLeader -- (String)
            masterLooter -- (String)
            raidDate -- (String)
            raidStart -- (String)
            raidEnd -- (String)
            raidTime -- (String)
            {members} -- (Array)
                memberName1, memberName2... -- (String)
            {bossKills} -- (Array)
                [bossID] -- (int / Object)
                    {members} -- (Array)
                        memberName1, memberName2... -- (String) -- to track who was there when the boss was killed.
                    bossLootUID -- (int) -- Unique loot history database ID
]]

function Raid:GetCurrentRaid()
    Raid.recentBossKillID = 663
    for raidName, table in pairs(core.bossIDS) do
        if table[Raid.recentBossKillID] then
            return raidName
        end
    end
end

local raidDBDefaults = {
    profile = {
        raids = {},
        lastRaidID = nil,
        lastRaidDate = nil,
    }
}

function PDKP:InitRaidDB()
    Util:Debug('RaidDB init');
    core.raidHistory = LibStub("AceDB-3.0"):New("pdkp_raidHistory", raidDBDefaults, true);
    raidHistory = core.raidHistory.db.profile;
end

-- Boolean to check if we're in a raid group or not.
function Raid:IsInRaid()
    return IsInRaid()
end

function PDKP:GetSavedRaids()
    local
    name,
    id,
    reset,
    difficulty,
    locked,
    extended,
    instanceIDMostSig,
    isRaid,
    maxPlayers,
    difficultyName,
    numEncounters,
    encounterProgress = GetSavedInstanceInfo(index)
end

function Raid:GetRaidInfo()
    local raidInfo = {}
    for i = 1, 40 do
        local name,
        rank, --2 for Raid leader, 1 for assistant, 0 otherwise.
        subgroup, -- which raid group they're in.
        level,
        class,
        fileName, -- string representation of char's class.
        zone, -- zone they are currently in
        online,
        isDead,
        role, -- The player's role within the raid ("maintank" or "mainassist")
        isML, -- Returns 1 if the raid member is master looter, nil otherwise
        combatRole -- user's combat Role if selected ( I think this is a retail thing though?)
        = GetRaidRosterInfo(i)
        if name then -- if you're out of bounds, GetRaidRosterInfo will return a nil Object. So check one of the vals.
            table.insert(raidInfo, {
                ['name']=name,
                ['level']=level,
                ['class']=class,
                ['zone']=zone,
                ['online']=online,
                ['isDead']=isDead,
                ['isML']=isML,
                ['isAssist']=rank == 1,
                ['isLeader']=rank == 2,
            })
            if isML then
                Raid.MasterLooter = name;
            end
        end
    end
    Raid.RaidInfo = raidInfo;
    return raidInfo;
end

function Raid:BossKill(bossID, bossName)
    if not core.canEdit then return end; -- If you can't edit, then you shoudln't be here.
    if Raid.bossIDS[bossID] == nil then return end; -- Isn't a raid boss that we care about.

    if not Raid:isMasterLooter() then return end;

    local popup = StaticPopupDialogs["PDKP_RAID_BOSS_KILL"];
    popup.text = bossName .. ' was killed! Award 10 DKP?'
    popup.bossID = bossID;
    popup.bossName = bossName;
    StaticPopup_Show('PDKP_RAID_BOSS_KILL')
end

function Raid:AcceptDKPUpdate(bossID)
    local raid = Raid:GetRaidInfo();
    Raid.recentBossKillID = bossID

    for i=1, #raid do
        local charObj = raid[i];
        if charObj.online then
            DKP:BossKill(charObj)
        end
    end

    -- Possibly have to rebuild the data to get it to reflect the change? Seems clunky...
    PDKP:BuildAllData()
    pdkp_dkp_table_filter()
end

function Raid:isMasterLooter()
    Raid:GetRaidInfo()
    return Raid.MasterLooter == Util:GetMyName()
end

function Raid:AnnounceLoot()
    local shouldContinue = false

    if Defaults.debug then shouldContinue = true
    elseif Raid:isMasterLooter() and Raid:IsInRaid() then
        shouldContinue = true
    else
    end

    if shouldContinue then
        local numLootItems = GetNumLootItems();
        local items = {};

        for i=1, numLootItems do
            local _, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem,
            questID, isActive = GetLootSlotInfo(i)
            -- TODO: Implement the commented out code here instead of using GetLootInfo().
        end
        --        local info = GetLootInfo()
--        local items = {}
--
--        for i=1, #info do
--            local lootItem = info[1]
--            lootItem.name = lootItem.item
--            local itemLink = GetLootSlotLink(i)
--            if lootItem.quality >= 3 or Defaults.debug then
--                lootItem.link = itemLink
--                lootItem.prio = item:GetPriority(lootItem.name)
--                table.insert(items, lootItem)
--            end
--        end
--
--        for i=1, #items do
--            local lootItem = items[i]
--            SendChatMessage(lootItem.link .. ' PRIO: ' .. lootItem.prio, 'RAID', 'Common', 'Neekio')
--        end
    end
end

