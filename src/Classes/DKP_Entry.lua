local _, core = ...;
local _G = _G;
local L = core.L;

local PDKP = core.PDKP;
local Guild = core.Guild; -- Uppercase is the file
local Util = core.Util;

local success = '22bb33'
local warning = 'E71D36'

local DKP_Entry = core.DKP_Entry;

DKP_Entry.__index = DKP_Entry

function DKP_Entry:New(entry_details)
    local self = {};
    setmetatable(self, DKP_Entry); -- Set the metatable so we used DKP_Entry's __index

    self.reason = entry_details['reason'] or 'No Valid Reason'
    self.dkp_change = entry_details['dkp_change'] or 0
    self.boss = entry_details['boss'] or ''
    self.raid = entry_details['raid'] or 'Molten Core'
    self.adjust_type = entry_details['adjust_type'] or ''
    self.edited = entry_details['edited'] or false;
    self.deleted = entry_details['deleted'] or false;
    self.officer = entry_details['officer']
    self.item = entry_details['item'] or 'None Linked'
    self.id = entry_details['id'] or GetServerTime()
    self.other_text = entry_details['other'] or ''
    self.names = entry_details['names']
    self.previousTotals = entry_details['previousTotals'] or self:GetPreviousTotals()
    self.formattedNames = self:GetFormattedNames()
    self.change_text = self:GetChangeText()
    self.historyText = self:GetHistoryText()
    self.formattedOfficer = self:GetFormattedOfficer()

    return self
end

function DKP_Entry:Save()

    local save_details = {
        ['reason']=self.reason,
        ['dkp_change']=self.dkp_change,
        ['boss']=self.boss,
        ['adjust_type'] = self.adjust_type,
        ['edited']=self.edited,
        ['deleted']=self.deleted,
        ['officer']=self.officer,
        ['id']=self.id,
        ['raid']=self.raid,
        ['names']=self.names,
        ['previousTotals']=self.previousTotals,
    }

    if self.other_text ~= '' and self.other_text ~= nil and self.other_text ~= 0 then
        save_details['other_text']=self.other_text
    end

    if self.reason == 'Item Win' then
        save_details['item'] = self.item
    end

    core.PDKP.dkpDB['history']['all'][self.id] = save_details
end

function DKP_Entry:GetFormattedOfficer()
    local officer = Guild:GetMemberByName(self.officer)
    return officer.formattedName
end

function DKP_Entry:GetFormattedNames()
    local formattedNames = ''

    local function compare(a,b)
        local a_member = Guild:GetMemberByName(a)
        local b_member = Guild:GetMemberByName(b)
        if b_member.class == a_member.class then
            return b_member.name > a_member.name
        else
            return b_member.class > a_member.class
        end
    end
    table.sort(self.names, compare)

    for key, name in pairs(self.names) do
        local member = Guild:GetMemberByName(name)
        formattedNames = formattedNames .. member.formattedName
        if key ~= #self.names then formattedNames = formattedNames .. ', ' end
    end

    return formattedNames
end

function DKP_Entry:GetHistoryText()
    local texts = {
        ['On Time Bonus']= self.raid .. ' - ' .. self.reason,
        ['Completion Bonus']= self.raid .. ' - ' .. self.reason,
        ['Unexcused Absence']= self.raid .. ' - ' .. self.reason,
        ['Boss Kill']= self.raid .. ' - ' .. self.boss,
        ['Item Win']= 'Item Win - ',
        ['Other']= 'Other - ' .. self.other_text,
    }
    local text = texts[self.reason]

    if self.dkp_change > 0 then
        return Util:FormatFontTextColor(success, text)
    else
        return Util:FormatFontTextColor(warning, text)
    end
end

function DKP_Entry:GetChangeText()
    if self.dkp_change > 0 then
        return Util:FormatFontTextColor(success, self.dkp_change .. ' DKP')
    else
        return Util:FormatFontTextColor(warning, self.dkp_change .. ' DKP')
    end
end

function DKP_Entry:GetPreviousTotals()
    local previous_totals = {}
    for _, name in pairs(self.names) do
        local member = Guild:GetMemberByName(name)
        local dkp = member:GetDKP(self.raid, 'total')
        previous_totals[name]=dkp
    end
    return previous_totals
end
