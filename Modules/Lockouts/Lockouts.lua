local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Lockouts = {}

function Lockouts:Initialize()

    self.weekNumber = Utils:GetWeekNumber(GetServerTime())
    self.db = MODULES.Database:Lockouts()
    self.newWeek = false

    if self.db[self.weekNumber] == nil then
        self.newWeek = true
        self.db = MODULES.Database:ResetLockouts()
        self.db[self.weekNumber] = {}
    end
end

function Lockouts:AddMemberLockouts(entry)
    local no_lockout_members = {}

    if entry.weekNumber == self.weekNumber then
        if self.db[self.weekNumber][entry.boss] == nil then
            self.db[self.weekNumber][entry.boss] = {}
        end
        for _, memberName in pairs(entry.names) do
            if not tContains(self.db[self.weekNumber][entry.boss], memberName) then
                table.insert(self.db[self.weekNumber][entry.boss], memberName)
                table.insert(no_lockout_members, memberName)
            else
                PDKP.CORE:Print(memberName, 'Is ineligible for DKP on this boss')
                entry:RemoveMember(memberName)
            end
        end
    end
    return no_lockout_members
end

function Lockouts:CheckForMemberLockouts(memberName, bossName)
    if self.db[self.weekNumber] == nil then
        return false
    end
    if self.db[self.weekNumber][bossName] == nil then
        return false
    end
    return tContains(self.db[self.weekNumber][bossName], memberName)
end

MODULES.Lockouts = Lockouts