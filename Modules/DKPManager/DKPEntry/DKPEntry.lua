local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;

local Guild;

local entry = {}

local GetServerTime = GetServerTime
local tsort, tonumber, pairs, type, tinsert = table.sort, tonumber, pairs, type, tinsert

local core_details = { 'reason', 'dkp_change', 'officer', 'names' }

local _BOSS_KILL = 'Boss Kill'
local _ITEM_WIN = 'Item Win'
local _OTHER = 'Other'

entry.__index = entry

function entry:new(entry_details)
    local self = {}
    setmetatable(self, entry); -- Set the metatable so we used entry's __index

    Guild = MODULES.GuildManager;

    --- Core Entry Details
    self.id = entry_details['id'] or GetServerTime()
    self.reason = entry_details['reason'] or 'No Valid Reason'
    self.dkp_change = entry_details['dkp_change'] or 0
    self.dkp_change = tonumber(self.dkp_change)

    self.officer = entry_details['officer']
    self.names = entry_details['names']
    self.pugNames = entry_details['pugNames'] or {}

    self.entry_type = entry_details['entry_type'] or nil

    -- Dependent Entry Details
    self.boss = entry_details['boss'] or nil
    self.raid = entry_details['raid'] or self:_GetRaid()

    self.edited = entry_details['edited'] or false

    self.deleted = entry_details['deleted'] or false
    self.deletedBy = entry_details['deletedBy'] or ''

    self.item = entry_details['item'] or 'Not linked'
    self.other_text = entry_details['other_text'] or ''
    self.edited_time = entry_details['edited_time'] or nil

    self.hash = entry_details['hash'] or nil
    self.previousTotals = entry_details['previousTotals'] or {}


    self.members = {}
    self.sd = {} -- Save Details

    self.lockoutsChecked = false

    -- Grab the members, and non-members in the entry for later use.
    self:GetMembers()

    --- Local Entry Details
    self.wday = Utils:GetWDay(self.id)
    self.yday = Utils:GetYDay(self.id)
    self.weekNumber = Utils:GetWeekNumber(self.id)

    self.formattedNames = self:_GetFormattedNames()
    self.formattedOfficer = self:_GetFormattedOfficer()
    self.change_text = self:_GetChangeText()
    self.historyText = self:_GetHistoryText()
    self.formattedID = Utils:Format12HrDateTime(self.id)
    self.collapsedHistoryText = self:_GetCollapsedHistoryText()

    self.edited_fields = entry_details['edited_fields'] or {}

    return self;
end

function entry:Save(updateTable, exportEntry, skipLockouts)
    wipe(self.sd)

    exportEntry = exportEntry or false
    skipLockouts = skipLockouts or false

    self:GetSaveDetails()

    if exportEntry == false then
        MODULES.DKPManager:AddNewEntryToDB(self, updateTable, skipLockouts)
    elseif PDKP.canEdit and exportEntry then
        MODULES.DKPManager:ExportEntry(self)
    end
end

function entry:GetSaveDetails()
    wipe(self.sd)

    self.sd['id'] = self.id or GetServerTime()
    self.sd['reason'] = self.reason or 'No Valid Reason'
    self.sd['dkp_change'] = self.dkp_change or 0
    self.sd['officer'] = self.officer
    self.sd['names'] = self.names
    self.sd['hash'] = self.hash or nil

    if self.reason == _BOSS_KILL then
        self.sd['boss'] = self.boss
    elseif self.reason == _ITEM_WIN then
        self.sd['item'] = self.item
    elseif self.reason == _OTHER then
        self.sd['other_text'] = self.other_text
    end

    local dependants = {
        ['previousTotals'] = self.previousTotals,
        ['pugNames'] = self.pugNames,
    }

    for name, val in pairs(dependants) do
        if type(val) == "table" then
            if val and next(val) ~= nil then
                self.sd[name] = val
            end
        end
    end

    if self.deleted then
        self.sd['deleted'] = self.deleted
        self.sd['deletedBy'] = self.deletedBy
    end

    return self.sd
end

function entry:GetMembers()
    wipe(self.members)

    for _, name in pairs(self.names) do
        local member = Guild:GetMemberByName(name)
        if member ~= nil then
            tinsert(self.members, member)
        else
            tinsert(self.pugNames, name)
        end
    end
    return self.members, self.pugNames
end

function entry:MarkAsDeleted(deletedBy)
    self.deleted = true
    self.deletedBy = deletedBy
end

function entry:RemoveMember(name)
    local memberIndex;

    for i = 1, #self.names do
        if self.names[i] == name then
            memberIndex = i
        end
    end

    table.remove(self.names, memberIndex)

    self:GetMembers()
    self.formattedNames = self:_GetFormattedNames()

    if self.previousTotals[name] ~= nil then
        self.previousTotals[name] = nil
    end
end

function entry:IsMemberInEntry(name)
    return tContains(self.names, name)
end

function entry:IsValid()
    local isValid = true

    for i = 1, #core_details do
        local detail = self[core_details[i]]
        if type(detail) == "string" then
            isValid = isValid and not (Utils:IsEmpty(detail))
        elseif type(detail) == "table" then
            isValid = isValid and not (Utils:tEmpty(detail))
        end
    end

    if self.reason == _BOSS_KILL then
        local hasRaid = not Utils:IsEmpty(self.raid)
        local hasBoss = not Utils:IsEmpty(self.boss)
        isValid = isValid and hasRaid and hasBoss
    end

    return isValid
end

function entry:_GetRaid()
    if self.boss == nil then
        return nil
    end
    self.raid = MODULES.Constants.BOSS_TO_RAID[self.boss]
    return self.raid
end

function entry:_GetFormattedNames()
    tsort(self.members, function(a, b)
        if b.class == a.class then
            return b.name > a.name
        else
            return b.class > a.class
        end
    end)

    local formattedNames = ''
    for key, member in pairs(self.members) do
        if key ~= 1 then
            formattedNames = formattedNames .. ', '
        end
        formattedNames = formattedNames .. member.formattedName
    end

    tsort(self.pugNames, function(a,b)
        return a < b
    end)

    for _, nonMember in pairs(self.pugNames) do
        if nonMember ~= nil then
            formattedNames = formattedNames .. ', '
            --formattedNames = formattedNames .. nonMember .. ' (PUG)'
            formattedNames = formattedNames .. '|cffE71D36' .. nonMember .. ' (P)' .. "|r"
        end
    end

    return formattedNames
end

function entry:_GetChangeText()
    local color = Utils:ternaryAssign(self.dkp_change >= 0, MODULES.Constants.SUCCESS, MODULES.Constants.WARNING)

    if self.reason == 'Decay' then
        return Utils:FormatTextColor('10% DKP', MODULES.Constants.WARNING)
    else
        return Utils:FormatTextColor(self.dkp_change .. ' DKP', color)
    end
end

function entry:_GetHistoryText()
    if self.reason == _BOSS_KILL and (self.raid == nil or self.boss == nil) then
        return Utils:FormatTextColor('Boss Kill: None Selected', MODULES.Constants.WARNING)
    end

    local text;
    if self.reason == _BOSS_KILL then
        text = self.raid .. ' - ' .. self.boss
    elseif self.reason == 'Item Win' then
        text = 'Item Win - ' .. self.item
    elseif self.reason == 'Other' then
        text = Utils:ternaryAssign(not (Utils:IsEmpty(self.other_text)), 'Other - ' .. self.other_text, 'Other')
    elseif self.reason == 'Decay' then
        text = 'Weekly Decay'
        return Utils:FormatTextColor('Weekly Decay', MODULES.Constants.WARNING)
    end

    local color = Utils:ternaryAssign(self.dkp_change > 0, MODULES.Constants.SUCCESS, MODULES.Constants.WARNING)
    return Utils:FormatTextColor(text, color)
end

function entry:_GetCollapsedHistoryText()
    local texts = {
        ['On Time Bonus'] = self.reason,
        ['Completion Bonus'] = self.reason,
        ['Unexcused Absence'] = self.reason,
        ['Boss Kill'] = self.boss,
        ['Item Win'] = 'Item Win - ' .. self.item,
        ['Other'] = Utils:ternaryAssign(self.other_text ~= '', 'Other - ' .. self.other_text, 'Other'),
        ['Decay'] = 'Weekly Decay'
    }
    local text = texts[self.reason]

    if self.reason == 'Decay' then
        return Utils:FormatTextColor('Weekly Decay', MODULES.Constants.WARNING)
    end

    local color = Utils:ternaryAssign(self.dkp_change > 0, MODULES.Constants.SUCCESS, MODULES.Constants.WARNING)
    return Utils:FormatTextColor(text, color)
end

function entry:_GetFormattedOfficer()
    local officer = MODULES.GuildManager:GetMemberByName(self.officer)

    if officer == nil then
        return '|CFF' .. 'E71D36' .. self.officer .. '|r'
    end

    return officer.formattedName
end

MODULES.DKPEntry = entry