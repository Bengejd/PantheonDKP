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
    self.officer = entry_details['officer']
    self.names = entry_details['names']

    self.save_details = {}

    self.hash = nil

    --- Hashing info: Year_Week_Day
    --self.week_day = self.w .. "_"

    self.entry_type = entry_details['entry_type'] or nil

    -- Dependent Entry Details
    self.boss = entry_details['boss'] or nil
    self.raid = entry_details['raid'] or nil
    self.edited = entry_details['edited'] or false
    self.deleted = entry_details['deleted'] or false
    self.item = entry_details['item'] or 'Not linked'
    self.other_text = entry_details['other_text'] or nil
    self.edited_time = entry_details['edited_time'] or nil

    --- Local Entry Details
    -- self.yday = nil
    -- self.wday = nil
    --self.previousTotals = entry_details['previousTotals'] or self:GetPreviousTotals()
    --self.formattedNames = self:GetFormattedNames()
    --self.change_text = self:GetChangeText()
    --self.historyText = self:GetHistoryText()
    --self.collapsedHistoryText = self:GetCollapsedHistoryText()
    --self.formattedOfficer = self:GetFormattedOfficer()
    --self.formattedID = Util:Format12HrDateTime(self.id)
    --self.edited_fields = entry_details['edited_fields'] or {}
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

function entry:GetEntryType()
    if self.dkp_change > 0 then
        self.entry_type = 'increase'
    elseif self.dkp_change < 0 then
        self.entry_type = 'decrease'
    else
        self.entry_type = 'equal'
    end


    if self.reason == 'Boss Kill' then
        return self:SetupBossKillEntry()
    elseif self.reason == 'Item Win' then
        return self:SetupLootEntry()
    elseif self.reason == 'Other' then
        return self:SetupOtherEntry()
    end
end

function entry:SetupLootEntry()

end

function entry:SetupBossKillEntry()

end

function entry:SetupOtherEntry()

end

MODULES.DKPEntry = entry