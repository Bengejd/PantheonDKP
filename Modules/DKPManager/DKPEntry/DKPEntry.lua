local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local entry = {}

local GetServerTime = GetServerTime

entry.__index = entry

function entry:new(entry_details)
    --- Core Entry Details
    self.id = entry_details['id'] or GetServerTime()
    self.reason = entry_details['reason'] or 'No Valid Reason'
    self.dkp_change = entry_details['dkp_change'] or 0
    self.dkp_change = tonumber(self.dkp_change)

    self.officer = entry_details['officer']
    self.names = entry_details['names']

    --- Hashing info: Year_Week_Day
    --self.week_day = self.w .. "_"

    self.entry_type = entry_details['entry_type'] or nil

    -- Dependent Entry Details
    self.boss = entry_details['boss'] or nil
    self.raid = entry_details['raid'] or nil

    self.edited = entry_details['edited'] or false
    self.deleted = entry_details['deleted'] or false
    self.item = entry_details['item'] or 'Not linked'
    self.other_text = entry_details['other_text'] or ''
    self.edited_time = entry_details['edited_time'] or nil

    --- Local Entry Details
    -- self.yday = nil
    -- self.wday = nil

    --self.save_details = {}
    --
    --self.hash = nil
    --self.previousTotals = entry_details['previousTotals'] or self:GetPreviousTotals()

    self.formattedNames = self:_GetFormattedNames()
    self.formattedOfficer = self:_GetFormattedOfficer()
    self.change_text = self:_GetChangeText()
    self.historyText = self:_GetHistoryText()

    --self.collapsedHistoryText = self:GetCollapsedHistoryText()

    --self.formattedID = Util:Format12HrDateTime(self.id)
    self.edited_fields = entry_details['edited_fields'] or {}

    return self;
end

function entry:Save()
    local save_details = {
        ['r'] = self.reason, -- reason
        ['dc'] = self.dkp_change, -- dkp_change
        ['o'] = self.officer, -- officer
        ['t'] = nil, -- type
        ['n'] = self.names, -- names
    }

    --self.id = entry_details['id'] or GetServerTime()
    --self.reason = entry_details['reason'] or 'No Valid Reason'
    --self.dkp_change = entry_details['dkp_change'] or 0
    --self.officer = entry_details['officer']
    --self.names = entry_details['names']
    --self.save_details = {}
end

function entry:IsValid()
    local isValid = true
    local core_details = { 'reason', 'dkp_change', 'officer', 'names' }

    for i = 1, #core_details do
        local detail = self[core_details[i]]
        if type(detail) == "string" then
            hasCore = hasCore and not (Utils:IsEmpty(detail))
        elseif type(detail) == "table" then
            hasCore = hasCore and not (Utils:tEmpty(detail))
        end
    end

    if self.reason == 'Boss Kill' then
        local hasRaid = not Utils:IsEmpty(self.raid)
        local hasBoss = not Utils:IsEmpty(self.boss)
        isValid = isValid and hasRaid and hasBoss
    end

    return isValid
end

function entry:_GetFormattedNames()
    local Guild = MODULES.GuildManager
    local memberTable = {}
    for _, name in ipairs(self.names) do
        local member = Guild:GetMemberByName(name)
        if member ~= nil then
            table.insert(memberTable, member)
        end
    end

    table.sort(memberTable, function(a,b)
        if b.class == a.class then
            return b.name > a.name
        else
            return b.class > a.class
        end
    end)

    local formattedNames = ''
    for key, member in pairs(memberTable) do
        if key ~= 1 then formattedNames = formattedNames .. ', ' end
        formattedNames = formattedNames .. member.formattedName
    end

    ----overwrite self.names with memberTable and remove non-members from the end
    --local index = 1
    --while index <= #memberTable do
    --    self.names[index] = memberTable[index].name
    --    index = index + 1
    --end
    --
    --local size = #self.names
    --while size >= index do -- index is one past the last item
    --    size = size - 1
    --end

    return formattedNames
end

function entry:_GetChangeText()
    local color = Utils:ternaryAssign(self.dkp_change > 0, MODULES.Constants.SUCCESS, MODULES.Constants.WARNING)
    return Utils:FormatTextColor(self.dkp_change .. ' DKP', color)
end

function entry:_GetHistoryText()
    if self.reason == 'Boss Kill' and (self.raid == nil or self.boss == nil) then
        return Utils:FormatTextColor('Boss Kill: None Selected', MODULES.Constants.WARNING)
    end

    local text;
    if self.reason == 'Boss Kill' then
        text = self.raid .. ' - ' .. self.boss
    elseif self.reason == 'Item Win' then
        text = 'Item Win - ' .. self.item
    elseif self.reason == 'Other' then
        text = Utils:ternaryAssign(not(Utils:IsEmpty(self.other_text)), 'Other - ' .. self.other_text, 'Other')
    end

    local color = Utils:ternaryAssign(self.dkp_change > 0, MODULES.Constants.SUCCESS, MODULES.Constants.WARNING)
    return Utils:FormatTextColor(text, color)
end

function entry:_GetFormattedOfficer()
    local officer = MODULES.GuildManager:GetMemberByName(self.officer)
    return officer.formattedName
end

MODULES.DKPEntry = entry