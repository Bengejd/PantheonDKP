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

Raid.recentBossKillID = nil
Raid.MasterLooter = nil
Raid.dkpOfficer = nil;
Raid.spamText = nil;

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
                ['role']=role,
                ['isAssist']=rank == 1,
                ['isLeader']=rank == 2,
                ['isDkpOfficer']=name == Guild.dkpOfficer
            })
            if isML then
                Raid.MasterLooter = name;
            end
            if rank == 2 then
               Raid.RaidLeader = name;
            end
        end
    end
    Raid.RaidInfo = raidInfo;
    return raidInfo;
end

function Raid:IsAssist()
    Raid:GetRaidInfo()
    for _, member in pairs(Raid.RaidInfo) do
        if member.name == Util:GetMyName() and (member.isAssist or member.isLeader) then
            return true
        end
    end
    return false
end

function Raid:BossKill(bossID, bossName)
    if not core.canEdit then return end; -- If you can't edit, then you shoudln't be here.

    local bk
    for raidName, raidObj in pairs(core.bossIDS) do
        if bk == nil then
            for pdkpBossID, pdkpBossName in pairs(raidObj) do
                if pdkpBossID == bossID or pdkpBossName == bossName then
                    bk = {
                        name=pdkpBossName,
                        id=pdkpBossID,
                        raid=raidName,
                    }
                    break
                end;
            end
        end
    end

    if bk == nil then return end; -- We should have found the boss kill by now.

    -- You are the DKP Officer
    -- There is no dkp Officer, but you're the master looter

    local dkpOfficer = Raid.dkpOfficer

    if (dkpOfficer and Raid:IsDkpOfficer()) then
    elseif not dkpOfficer and Raid:isMasterLooter() then
    else
        Util:Debug('You are not the master looter, and not dkpOffcier, so fuck off')
        return
    end

    Util:Debug('Starting up the boss kill stuff')
    print(bk.name, bk.id, bk.raid)

--    local popup = StaticPopupDialogs["PDKP_RAID_BOSS_KILL"];
--    popup.text = bossName .. ' was killed! Award 10 DKP?'
--    popup.bossID = bossID;
--    popup.bossName = bossName;
--    StaticPopup_Show('PDKP_RAID_BOSS_KILL')

    --
    --    local popup = StaticPopupDialogs["PDKP_RAID_BOSS_KILL"];
    --    popup.text = bossName .. ' was killed! Award 10 DKP?'
    --    popup.bossID = bossID;
    --    popup.bossName = bossName;
    --    StaticPopup_Show('PDKP_RAID_BOSS_KILL')
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

function Raid:isRaidLeader()
    Raid:GetRaidInfo()
    return Raid.RaidLeader == Util:GetMyName()
end

function Raid:IsDkpOfficer()
    if Raid.dkpOfficer then -- We have established who the DKP officer is.
        return Raid.dkpOfficer == Util:GetMyName()
    else
        return false
    end
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
            local _, lootName, _, _, lootQuality, _, _, _, _ = GetLootSlotInfo(i)
            -- TODO: Implement the commented out code here instead of using GetLootInfo().
            if lootQuality >= 3 then -- The item is blue or above in quality.
                local lootLink = item:GetItemByName(lootName)
                local lootPrio = item:GetPriority(lootName)
                if lootPrio ~= nil then -- We have a defined loot item.
                    local lootItem = {
                        name=lootName,
                        link=lootLink,
                        prio=lootPrio
                    }
                    table.insert(items, lootItem)
                end
            end
        end

        for i=1, #items do
            local lootItem = items[i]
            SendChatMessage(lootItem.link .. ' PRIO: ' .. lootItem.prio, 'RAID', 'Common')
        end
    end
end

