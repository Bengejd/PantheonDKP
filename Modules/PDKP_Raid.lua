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

local RaidInfo = {};

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
}

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

local raidDBDefaults = {
    char = {
        raids = {},
        lastRaidID = nil,
        lastRaidDate = nil,
    }
}

function PDKP:InitRaidDB()
    Util:Debug('RaidDB init');
    core.raidHistory = LibStub("AceDB-3.0"):New("pdkp_raidHistory", raidDBDefaults);
    raidHistory = core.raidHistory.char;
end

-- Boolean to check if we're in a raid group or not.
function Raid:IsInRaid()
    return IsInRaid()
end

function Raid:GetML()

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
                ['rank']=rank,
                ['level']=level,
                ['class']=class,
                ['zone']=zone,
                ['online']=online,
                ['isDead']=isDead,
                ['isML']=isML,
            })
        end
    end
    RaidInfo = raidInfo;
end

function Raid:BossKill(bossID, bossName)
    if not core.canEdit then return end; -- If you can't edit, then you shoudln't be here.
    if Raid.bossIDS[bossID] == nil then return end; -- Isn't a raid boss that we care about.

    local popup = StaticPopupDialogs["PDKP_RAID_BOSS_KILL"];
    popup.text = bossName .. ' was killed! Award 10 DKP?'
    popup.bossID = bossID;
    popup.bossName = bossName;
    StaticPopup_Show('PDKP_RAID_BOSS_KILL')
end

function Raid:AcceptDKPUpdate(bossID, bossName)
    local raid = Raid:GetRaidInfo();

    for i=1, #raid do
        local charObj = raid[i];
        if charObj.online then
           DKP:Add(charObj.name, 10);
        end
    end
end

