local _, core = ...;
local _G = _G;
local L = core.L;

local PDKP = core.PDKP;
local Guild = core.Guild; -- Uppercase is the file
local Util = core.Util;

local DKP_Entry = core.DKP_Entry;

DKP_Entry.__index = DKP_Entry

function DKP_Entry:New(entry_details)
    local self = {};
    local server_time = GetServerTime()

    setmetatable(self, DKP_Entry); -- Set the metatable so we used DKP_Entry's __index

    self.reason = entry_details['reason'] or 'No Valid Reason'
    self.dkp_change = entry_details['amount'] or 0
    self.boss = entry_details['boss'] or ''
    self.raid = entry_details['raid']
    self.adjust_type = entry_details['adjust_type'] or ''
    self.edited = false;
    self.deleted = false;
    self.officer = entry_details['officer']
    self.id = server_time
    self.names = PDKP.memberTable.selected
    self.previousTotals = self:GetPreviousTotals()

    return self
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
