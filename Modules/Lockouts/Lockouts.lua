local _, PDKP = ...

local MODULES = PDKP.MODULES
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
    if entry.lockoutsChecked or entry.reason ~= 'Boss Kill' then
        return entry.names
    end
    local no_lockout_members = {}
    entry.lockoutsChecked = true

    local removedNames = {}

    if entry.weekNumber == self.weekNumber then
        if self.db[self.weekNumber][entry.boss] == nil then
            self.db[self.weekNumber][entry.boss] = {}
        end
        for i = #entry.names, 1, -1 do
            local memberName = entry.names[i]
            if not tContains(self.db[self.weekNumber][entry.boss], memberName) then
                table.insert(self.db[self.weekNumber][entry.boss], memberName)
                table.insert(no_lockout_members, memberName)
            else
                table.insert(removedNames, memberName)
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
