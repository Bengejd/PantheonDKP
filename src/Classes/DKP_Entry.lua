local _, core = ...;
local _G = _G;
local L = core.L;

local PDKP = core.PDKP;
local Guild = core.Guild; -- Uppercase is the file
local Util = core.Util;

local success = '22bb33'
local warning = 'E71D36'

local DKP_Entry = core.DKP_Entry;

local strreplace = string.gsub

DKP_Entry.__index = DKP_Entry

function DKP_Entry:New(entry_details)
    local self = {};
    setmetatable(self, DKP_Entry); -- Set the metatable so we used DKP_Entry's __index

    -- It is an old entry, so we have to convert it.
    if entry_details['serverTime'] ~= nil then
        --Util:Debug("Old Entry Found, converting to new format")
        entry_details = self:ConvertOldEntry(entry_details)
    end

    self.reason = entry_details['reason'] or 'No Valid Reason'
    self.dkp_change = entry_details['dkp_change'] or 0
    self.boss = entry_details['boss'] or ''
    self.raid = entry_details['raid'] or 'Molten Core'
    self.adjust_type = entry_details['adjust_type'] or ''
    self.edited = entry_details['edited'] or false;
    self.deleted = entry_details['deleted'] or false;
    self.officer = entry_details['officer']
    self.item = entry_details['item'] or 'Not Linked'
    self.id = entry_details['id'] or GetServerTime()
    self.other_text = entry_details['other_text'] or ''
    self.names = entry_details['names']
    self.edited_time = entry_details['edited_time'] or nil
    self.previousTotals = entry_details['previousTotals'] or self:GetPreviousTotals()
    self.formattedNames = self:GetFormattedNames()
    self.change_text = self:GetChangeText()
    self.historyText = self:GetHistoryText()
    self.collapsedHistoryText = self:GetCollapsedHistoryText()
    self.formattedOfficer = self:GetFormattedOfficer()
    self.formattedID = Util:Format12HrDateTime(self.id)
    self.edited_fields = entry_details['edited_fields'] or {}

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
        if string.find(self.item, 'None Linked') then
            strreplace(self.item, 'None Linked', 'Not Linked')
        end

        save_details['item'] = self.item
    end

    core.PDKP.dkpDB['history']['all'][self.id] = save_details
end

function DKP_Entry:PreparePushData()
    if self.deleted == true then return nil end

    local push_details = {
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
        ['item']=self.item,
        ['other_text']=self.other_text,
    }
    if self.reason == 'Item Win' and self.item ~= 'Not Linked' then push_details['item']=self.item end
    if self.other_text ~= nil and self.other_text ~= '' then push_details['other_text']=self.other_text end

    return push_details
end

function DKP_Entry:PrepareDeletedPushData()
    local push_details = {
        ['reason']=self.reason,
        ['dkp_change']=self.dkp_change,
        ['deleted']=true,
        ['officer']=self.officer,
        ['id']=self.id,
        ['edited_time']=GetServerTime(),
        ['raid']=self.raid,
        ['names']=self.names,
        ['previousTotals']=self.previousTotals,
    }
    return push_details
end

function DKP_Entry:GetFormattedOfficer()
    -- Old entries have officer names formatted already.
    if string.match(self.officer, 'cff') then self.officer = Util:RemoveColorFromname(self.officer) end

    local officer = Guild:GetMemberByName(self.officer)
    return officer.formattedName
end

function DKP_Entry:GetFormattedNames()

    -- Old entries have names formatted differently.
    if self.old_entry then
        if type(self.names) == type({}) then
            for key, name in pairs(self.names) do
                if string.match(name, 'cff') then self.names[key] = Util:RemoveColorFromname(name) end
            end
        elseif type(self.names) == type(" ") then
            local name = self.names
            self.names = {}
            if string.match(name, 'cff') then name = Util:RemoveColorFromname(name) end
            table.insert(self.names, name)
        end
    end

    local formattedNames = ''

    local function compare(a,b)
        local a_member = Guild:GetMemberByName(a)
        local b_member = Guild:GetMemberByName(b)

        if a_member == nil then
            return true
        elseif b_member == nil then
            return false
        end

        if a_member == nil or b_member == nil then
            print('ERROR sorting entry names: ', a, b)
            print(a_member.name, b_member.name)
            return false
        end

        if b_member.class == a_member.class then
            return b_member.name > a_member.name
        else
            return b_member.class > a_member.class
        end
        return false
    end
    --pcall(table.sort(self.names, compare))
    table.sort(self.names, compare)

    local remove_names = {};
    for key, name in pairs(self.names) do
        local member = Guild:GetMemberByName(name)

        if member ~= nil then
            formattedNames = formattedNames .. member.formattedName
            if key ~= #self.names then formattedNames = formattedNames .. ', ' end
        else
            remove_names[key] = name
        end
    end

    local function isGreaterThan(a, b) return a > b end
    table.sort(remove_names, isGreaterThan)

    for key, name in pairs(remove_names) do table.remove(self.names, key) end

    return formattedNames
end

function DKP_Entry:GetCollapsedHistoryText()
    local texts = {
        ['On Time Bonus']= self.reason,
        ['Completion Bonus']= self.reason,
        ['Unexcused Absence']= self.reason,
        ['Boss Kill']= self.boss,
        ['Item Win']= 'Item Win - ' .. self.item,
        ['Other'] = tenaryAssign(self.other_text ~= '', 'Other - ' .. self.other_text, 'Other'),
    }
    local text = texts[self.reason]

    if self.dkp_change > 0 then
        return Util:FormatFontTextColor(success, text)
    else
        return Util:FormatFontTextColor(warning, text)
    end
end

function DKP_Entry:GetHistoryText()
    local texts = {
        ['On Time Bonus']= self.raid .. ' - ' .. self.reason,
        ['Completion Bonus']= self.raid .. ' - ' .. self.reason,
        ['Unexcused Absence']= self.raid .. ' - ' .. self.reason,
        ['Boss Kill']= self.raid .. ' - ' .. self.boss,
        ['Item Win']= 'Item Win - ' .. self.item,
        ['Other']= tenaryAssign(self.other_text ~= '', 'Other - ' .. self.other_text, 'Other'),
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
        if member ~= nil then
            local dkp = member:GetDKP(self.raid, 'total')
            previous_totals[name]=dkp
        end
    end
    return previous_totals
end

function DKP_Entry:IsMemberInEntry(name)
    return tContains(self.names, name)
end

function DKP_Entry:ConvertOldEntry(entry_details)
    local ned = {} -- new entry details
    ned['id'] = entry_details['id']
    ned['raid'] = entry_details['raid']
    ned['reason'] = entry_details['reason'] or 'No Valid Reason'
    ned['boss'] = entry_details['bossKill']
    ned['deleted'] = entry_details['deleted'] or false
    ned['edited'] = entry_details['edited'] or false
    ned['other_text'] = ''

    local officer = entry_details['officer']
    if string.match(officer, 'cff') then officer = Util:RemoveColorFromname(officer) end
    ned['officer'] = officer
    ned['dkp_change'] = entry_details['dkpChange'] or 0

    if entry_details['isRoll'] then self.adjust_type = 'roll' end
    if entry_details['isShroud'] then self.adjust_type = 'shroud' end

    if string.match(entry_details['text'], 'Other') then
        local corrected_text = Util:RemoveColorFromname(entry_details['text'])
        ned['other_text'] = corrected_text
    end
    ned['names'] = entry_details['members']
    ned['previousTotals'] = entry_details['previousTotals']
    return ned
end