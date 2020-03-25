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

local raidHistory;

Raid.RaidInfo = {};

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

    Raid:GetRaidInfo()
    if Raid.MasterLooter ~= Util:GetMyName() then return end;

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

