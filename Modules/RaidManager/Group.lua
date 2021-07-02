local _, PDKP = ...
local _G = _G

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Group = {}

local IsInRaid = IsInRaid
local tinsert = table.insert
local GetNumGroupMembers, GetRaidRosterInfo = GetNumGroupMembers, GetRaidRosterInfo
local UnitIsGroupLeader = UnitIsGroupLeader
local ConvertToRaid, InviteUnit = ConvertToRaid, InviteUnit
local strtrim = strtrim

local GuildManager;

function Group:Initialize()
    setmetatable(self, Group); -- Set the metatable so we used Group's __index

    GuildManager = MODULES.GuildManager;

    self.classes = {};
    self.available = true
    self.requestedDKPOfficer = false

    self:_RefreshClasses()

    self:InitializePortrait()

    self.memberNames = {};
    self.player = {}
    self.leadership = {
        assist = {},
        masterLoot = nil,
        dkpOfficer = nil,
        leader = nil,
    }

    self:RegisterEvents();

    self:Refresh()
end

function Group:Refresh()
    if not self.available then return end
    self.available = false

    local numGroupMembers = GetNumGroupMembers()

    self:_RefreshClasses()
    self:_RefreshLeadership()
    self:_RefreshMembers()

    local myName = Utils:GetMyName()

    for i=1, numGroupMembers do
        local name, rank, _, _, class, _, _, _, _, role, isML, _ = GetRaidRosterInfo(i);

        if role == 'MAINTANK' then
            tinsert(self.classes['Tank'], name)
        else
            tinsert(self.classes[class], name)
        end

        tinsert(self.memberNames, name)

        -- leadership
        if rank > 0 then
            tinsert(self.leadership.assist, name)
            if rank == 2 then
                self.leadership.leader = name
            end
        end

        if isML then
            self.leadership.masterLoot = name
        end

        if name == myName then
            self.isML = isML ~= nil
            self.isLeader = rank == 2
            self.isAssist = rank >= 1
            self.isDKP = name == self.leadership.dkpOfficer
        end
    end

    if PDKP.raid_frame ~= nil then
        PDKP.raid_frame:updateClassGroups()
    end

    if self:IsInRaid() and not self:HasDKPOfficer() then
        self:RequestDKPOfficer()
    end

    --if not Raid:InRaid() then return Util:Debug("Not In Raid, Ignoring event") end
    --local raid_size = GetNumGroupMembers()
    --    --local raid_group_events = {
    --    --    ['GROUP_ROSTER_UPDATE']=function(_, _)
    --    --        if not GetRaidRosterInfo(raid_size) then return end
    --    --        Raid.raid:Init()
    --    --        GUI:UpdateInRaidFilter()
    --    --    end,
    --    --    ['BOSS_KILL']=function(arg1, arg2)
    --    --        local bossID, bossName = arg1, arg2
    --    --        Raid:BossKill(bossID, bossName)
    --    --    end,
    --    --    ['ZONE_CHANGED_NEW_AREA']=function()
    --    --        if not UnitIsDeadOrGhost("player") then
    --    --            Raid:CheckCombatLogging()
    --    --        end
    --    --    end
    --    --}
    --    else
    --        ConvertToRaid()
    --    end
    --    InviteUnit(name)
    --end

    self.available = true
end

function Group:InvitePlayer(name)
    if self:CanInvite(name) then
        if self:IsLeader() and GetNumGroupMembers() == 5 then
            ConvertToRaid()
        end
        return InviteUnit(name)
    end
end

function Group:CanInvite(name)
    local ignore_pugs = MODULES.RaidManager.ignore_pugs
    if ignore_pugs and not MODULES.GuildManager:IsGuildMember(name) then
        return false
    end

    self:Refresh()

    return not self:IsInRaid() or self:IsLeader() or self:IsAssist()
end

function Group:RegisterEvents()
    local events = {'GROUP_ROSTER_UPDATE', 'BOSS_KILL' };
    local f = CreateFrame("Frame", "PDKP_Group_EventsFrame");

    for _, eventName in pairs(events) do
        f:RegisterEvent(eventName)
    end
    f:SetScript("OnEvent", function(self, event, arg1, ...)
        Group:_HandleEvent(event, arg1, ...)
    end)
end

function Group:IsInRaid()
    --local isAlone = (not IsInRaid() and GetNumGroupMembers() == 0)
    return IsInRaid() and GetNumGroupMembers() >= 1
end

function Group:IsDKPOfficer()
    return self.isDKP
end

function Group:IsAssist()
    return self.isAssist or false
end

function Group:IsLeader()
    return self.isLeader or UnitIsGroupLeader("PLAYER")
end

function Group:IsMasterLoot()
    return self.isML
end

function Group:IsMemberDKPOfficer(name)
    return self.leadership.dkpOfficer == name
end

function Group:HasDKPOfficer()
    return self.leadership.dkpOfficer ~= nil
end

function Group:SetDKPOfficer(data)
    local charName, previous, fromRequest = unpack(data)

    fromRequest = fromRequest or false

    local isDKPOfficer = charName == previous

    if isDKPOfficer and fromRequest and self:IsMemberDKPOfficer(charName) then return end

    if fromRequest then
        isDKPOfficer = false
    end

    self.leadership.dkpOfficer = Utils:ternaryAssign(isDKPOfficer, nil, charName);
    local officerText = Utils:ternaryAssign(isDKPOfficer, 'is no longer the DKP Officer', 'is now the DKP Officer')
    PDKP.CORE:Print(charName .. ' ' .. officerText)
    self.classes['DKP'] = {charName}

    self.isDKP = Utils:GetMyName() == self.leadership.dkpOfficer

    PDKP.raid_frame:updateClassGroups()

    if self:HasDKPOfficer() then
        self.requestedDKPOfficer = true
    end
end

function Group:RequestDKPOfficer()
    if self.requestedDKPOfficer or self:HasDKPOfficer() then return end
    self.requestedDKPOfficer = true
    MODULES.CommsManager:SendCommsMessage('WhoIsDKP', 'request')

    C_Timer.After(5, function()
        if not self:HasDKPOfficer() then
            self.requestedDKPOfficer = false
        end
    end)
end

function Group:GetNumClass(class)
    if class == 'Total' then
        return #self.memberNames
    elseif self.classes[class] then
        return #self.classes[class]
    end
    return 0
end

function Group:GetRaidMemberObjects()
    local members = {}
    for i=1, #self.memberNames do
        local member = GuildManager:GetMemberByName(self.memberNames[i])
        if member then
            tinsert(members, member.name)
        end
    end
    return members
end

function Group:_RefreshClasses()
    local CLASSES = MODULES.Constants.CLASSES
    for i=1, #CLASSES do
        if type(self.classes[CLASSES[i]]) == "table" then
            wipe(self.classes[CLASSES[i]])
        end
        self.classes[CLASSES[i]] = {}
    end
    self.classes['Tank'] = {}
    self.classes['Total'] = {}
    self.classes['DKP'] = {}
end

function Group:_RefreshLeadership()
    for key, val in pairs(self.leadership) do
        if type(val) == "table" then
            wipe(self.leadership[key])
        else
            if key ~= 'dkpOfficer' then
                self.leadership[key] = nil
            elseif key == 'dkpOfficer' and val == nil then
                self.leadership[key] = nil
            end
        end
    end
end

function Group:_RefreshMembers()
    wipe(self.memberNames)
    if type(self.memberNames) ~= "table" then
        self.memberNames = {}
    end
end

function Group:_HandleEvent(event, arg1, ...)
    self:Refresh()
    if not self.available then
        return C_Timer.After(1.5, self:_HandleEvent(event, arg1, ...))
    end
    if event == 'BOSS_KILL' then
        local isDKP = self:HasDKPOfficer() and self:IsDKPOfficer()
        local isMLNoDKP = not self:HasDKPOfficer() and self:IsMasterLoot()
        if isDKP or isMLNoDKP then
            MODULES.DKPManager:BossKillDetected(arg1, ...)
        end
    end
end

function Group:_IsMemberInRaid(name)
    return tContains(self.memberNames, name) or false
    --for i=1, #self.memberNames do
    --    if self.memberNames[i] == name then
    --        return true
    --    end
    --end
    --return false
end

function Group:InitializePortrait()
    if (not PDKP.canEdit) and (not self:IsLeader()) then return end

    local lineSep = _G['UIDropDownMenu_AddSeparator']
    local addBtn = _G['UIDropDownMenu_AddButton']

    local commonSettings = {
        hasArrow = false;
        notCheckable = true;
        iconOnly = false;
        tCoordLeft = 0;
        tCoordRight = 1;
        tCoordTop = 0;
        tCoordBottom = 1;
        tSizeX = 0;
        tSizeY = 8;
        tFitDropDownSizeX = true;
    }
    local titleSettings = {
        text = 'PDKP',
        isTitle = true;
        isUninteractable = true;
    }
    local dkpOfficerSettings = {
        text = '',
        isTitle = false;
        isUninteractable = false;
        keepShownOnClick=false;
        func = nil;
    }

    for key, val in pairs(commonSettings) do
        titleSettings[key] = val
        dkpOfficerSettings[key] = val
    end

    local dropdownList = _G['DropDownList1']
    dropdownList:HookScript('OnShow', function()
        local charName = strtrim(_G['DropDownList1Button1']:GetText())
        local member = GuildManager:GetMemberByName(charName)

        if not (member and self:_IsMemberInRaid(charName) and member.canEdit) then return end

        dkpOfficerSettings.text = Utils:ternaryAssign(self:IsMemberDKPOfficer(charName), 'Demote from DKP Officer', 'Promote to DKP Officer')
        dkpOfficerSettings.func = function(...)
            MODULES.CommsManager:SendCommsMessage('DkpOfficer', {charName, self.leadership.dkpOfficer, false})
        end

        lineSep(1)
        addBtn(titleSettings, 1) -- Title
        addBtn(dkpOfficerSettings, 1)
        lineSep(1)
    end)
end

MODULES.GroupManager = Group