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
local Comms = core.Comms;

local raidHistory;

Raid.RaidInfo = {};

-- Start raid, select a time for the raid on-time bonus to go out.
-- Auto pop up raid boss kills when they occur
-- Auto award the completion bonus when the finalboss is killed.

Raid.recentBossKillID = nil
Raid.MasterLooter = nil
Raid.dkpOfficer = nil;
Raid.spamText = nil;

Raid.lockedInstances = {}
Raid.lockedRaids = {}

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

    local popup = StaticPopupDialogs["PDKP_RAID_BOSS_KILL"];
    popup.text = bk.name .. ' was killed! Award 10 DKP?'
    popup.bossInfo = bk;
    StaticPopup_Show('PDKP_RAID_BOSS_KILL')
end

function Raid:AcceptBossKillDKPUpdate(bossInfo)
    Util:Debug('Initiating Boss Kill DKP')

    local success = '22bb33';

    local raidRoster = Raid:GetRaidInfo();

    local dkpChange = 10;
    local dDate, tTime, server_time, datetime = Util:GetDateTimes()
    local reason, raid, boss, historyText, dkpChangeText = 'Boss Kill', bossInfo.raid, bossInfo.name, nil, nil

    historyText = raid .. ' - ' .. bossInfo.name

    dkpChangeText = Util:FormatFontTextColor(success, dkpChange .. ' DKP')
    historyText = Util:FormatFontTextColor(success, historyText)

    if raid == 'Onyxia\'s Lair' then -- Fix for Onyxia.
        raid = 'Molten Core'
    end

    local memberNames = {};
    local charNames = '';
    local charObjs = {};

    local function compareClass(a,b) return a.class < b.class end
    table.sort(raidRoster, compareClass)

    for key, raidMember in pairs(raidRoster) do
        local member = Guild:GetMemberByName(raidMember.name)
        table.insert(memberNames, member.name)
        charNames = charNames..member['formattedName']
        if key < #raidRoster then charNames = charNames .. ', ' end
        charObjs[member.name] = member;
    end

    local historyEntry = {
        ['id']=server_time,
        ['text'] = historyText,
        ['reason'] = reason,
        ['bossKill'] = boss,
        ['raid'] = raid,
        ['dkpChange'] = dkpChange,
        ['dkpChangeText'] = dkpChangeText,
        ['officer'] = Util:GetMyNameColored(),
        ['item']= nil,
        ['date']= dDate,
        ['time']=tTime,
        ['serverTime']=server_time,
        ['datetime']=datetime,
        ['names']=charNames,
        ['members']= memberNames,
        ['deleted']=false,
        ['edited']=false
    }

    for _, charMember in pairs(charObjs) do
        local member = Guild.members[charMember.name];
        local dkp = member.dkp[raid];

        if dkp.entries == nil then member.dkp[raid].entries = {} end
        table.insert(dkp.entries, server_time)

        dkp.previousTotal = dkp.total
        dkp.total = dkp.total + dkpChange

        if member.bName then -- update the player, visually.
            local dkpText = _G[member.bName ..'_col3'];
            dkpText:SetText(dkp.total)
        end
        member:Save() -- Update the database locally.
    end

    local dkpDB = DKP.dkpDB;

    dkpDB.history['all'][server_time] = historyEntry;
    dkpDB.lastEdit = server_time
    Guild:UpdateBankNote(server_time)
    DKP.bankID = server_time

    if GUI.pdkp_frame and GUI.pdkp_frame:IsVisible() then
        GUI:UpdateEasyStats()

        -- Update the slider max (if needed)
        GUI:UpdateDKPSliderMax();
        -- Re-run the table filters.
        pdkp_dkp_table_filter()

        GUI.pdkp_dkp_amount_box:SetText('');
    end

    Comms:SendGuildUpdate(historyEntry)
end

function Raid:isMasterLooter()
    Raid:GetRaidInfo()
    return Raid.MasterLooter == Util:GetMyName()
end

function Raid:isRaidLeader()
    Raid:GetRaidInfo()
    return Raid.RaidLeader == Util:GetMyName()
end

function Raid:MemberIsInRaid(name)
    Raid:GetRaidInfo()
    for _, member in pairs(Raid.RaidInfo) do
        if member.name == name then
            return true
        end
    end
    return false
end

function Raid:IsInRaidInstance()
    local _, type, difficultyIndex, maxPlayers = Raid:GetInstanceInfo()
    return type ~= 'raid' and difficultyIndex >= 1;
end

function Raid:IsInBattleGrounds()
    local _, type, _, _ = Raid:GetInstanceInfo()
    return type ~= 'pvp'
end

function Raid:IsInInstance()
    local _, type, difficultyIndex, maxPlayers = Raid:GetInstanceInfo()
    return type ~= 'party' and difficultyIndex >= 1;
end

function Raid:GetInstanceInfo()
    local name, type, difficultyIndex, difficultyName, maxPlayers,
    dynamicDifficulty, isDynamic, instanceMapId, lfgID = GetInstanceInfo()

    -- if difficultyIndex is >= 1 then you're in an instance (5, 10 or 40 man)
    return name, type, difficultyIndex, maxPlayers
end

function Raid:GetLockedInfo()
    -- Reset these
    Raid.lockedInstances = {}
    Raid.lockedRaids = {}
    local numInstances = GetNumSavedInstances()

    for i=1, numInstances do
        local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers,
        _, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
        -- reset is the amount of time in seconds until it resets. Let's make it more readable.
        local reset_display = Util:displayTime(reset)
        local raidObj = {
            name=name,
            desc=name .. ' reset: ' .. Util:FormatFontTextColor('1E90FF', reset_display),
            id=id,
            reset=reset,
            locked=locked,
            reset_display = reset_display,
        }
        if isRaid and maxPlayers >= 20 then -- It's a raid we care about
            table.insert(Raid.lockedRaids, raidObj)
        else -- This is an instance or an instance raid.
            table.insert(Raid.lockedInstances, raidObj)
        end
    end
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

    if Defaults:IsDebug() then shouldContinue = true
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

