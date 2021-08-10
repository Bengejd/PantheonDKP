local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;

local Guild, DKPManager, Lockouts, Ledger, DKP_DB, CommsManager;

local entry = {}

local GetServerTime = GetServerTime
local tsort, tonumber, pairs, type, tinsert = table.sort, tonumber, pairs, type, tinsert
local ceil = math.ceil

local core_details = { 'reason', 'dkp_change', 'officer', 'names' }

local _BOSS_KILL = 'Boss Kill'
local _ITEM_WIN = 'Item Win'
local _OTHER = 'Other'
local _DECAY = 'Decay'
local _PHASE = 'Phase'

local _DECAY_AMOUNT = 0.9;
local _DECAY_REVERSAL = 1.111;
local _PHASE_AMOUNT = 0.5;
local _PHASE_REVERSAL = 2.0;

-- Internal: Total * 0.9;
-- Display: Math.floor(internal)
-- Reversal: Math.Ceil(Total * _DECAY_REVERSAL;

entry.__index = entry

function entry:new(entry_details)
    local self = {}
    setmetatable(self, entry); -- Set the metatable so we used entry's __index

    if entry_details == nil or entry_details['reason'] == nil then return end

    self:SetupModules();

    self.entry_initiated = false

    self.adler = nil;

    --- Core Entry Details
    self.id = entry_details['id'] or GetServerTime()
    self.reason = entry_details['reason'] or 'No Valid Reason'
    self.dkp_change = entry_details['dkp_change'] or 0
    self.dkp_change = tonumber(self.dkp_change)

    self.officer = entry_details['officer']
    self.names = entry_details['names']
    self.pugNames = entry_details['pugNames'] or {}

    -- Dependent Entry Details
    self.boss = entry_details['boss'] or nil
    self.raid = entry_details['raid'] or self:_GetRaid()

    self.edited = entry_details['edited'] or false

    self.deleted = entry_details['deleted'] or false
    self.deletedBy = entry_details['deletedBy'] or ''

    self.item = entry_details['item'] or 'Not linked'
    self.other_text = entry_details['other_text'] or ''

    self.hash = entry_details['hash'] or nil
    self.previousTotals = entry_details['previousTotals'] or {}

    self.decayAmounts = {}
    self.decayReversal = entry_details['decayReversal'] or false
    self.previousDecayId = entry_details['previousDecayId'] or nil;

    self.members = {}
    self.removedMembers = entry_details['removedMembers'] or {};
    self.sd = {} -- Save Details

    self.lockoutsChecked = false
    self.adEntry = entry_details['adEntry'] or false

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

    if self.reason == 'Decay' then
        self:CalculateDecayAmounts()
    end

    self.edited_fields = entry_details['edited_fields'] or {}

    self.entry_initiated = true

    return self;
end

------------------------
--- START DKP Changes --
------------------------


function entry:ReverseDKPChange()
    local members, _ = self:GetMembers();

    for _, member in pairs(members) do
        local memberDKP = member:GetDKP(); --
        local dkp_change = self.dkp_change; --

        if self.reason == 'Decay' then
            dkp_change = memberDKP - (memberDKP * _DECAY_REVERSAL)
        end

        dkp_change = dkp_change * -1;
        member:RemoveEntry(self.id);
        member:UpdateDKP(dkp_change);
        member:Save();
    end

    PDKP:PrintD("Entry has been rolled back", self.id);
end

function entry:ApplyDKPChange()
    local members, _ = self:GetMembers();
    for _, member in pairs(members) do
        local memberDKP = member:GetDKP();
        local dkp_change = self.dkp_change;
        if self.reason == 'Decay' then
            -- Never update a decay that has been deleted already?
            if self.decayReversal and not self.deleted then -- Normal decay entry.
                dkp_change = Utils:RoundToDecimal(memberDKP * _DECAY_AMOUNT, 1); -- Reversal ID;
            else
                dkp_change = ceil(memberDKP * _DECAY_REVERSAL)
            end
        end

        member:AddEntry(self.id);
        member:UpdateDKP(dkp_change);
        member:Save();
    end

    PDKP:PrintD("Entry has been Applied", self.id);
end

-----------------------
--- END DKP Changes ---
-----------------------

function entry:Save(updateTable, exportEntry, skipLockouts)

    wipe(self.sd)

    exportEntry = exportEntry or false
    skipLockouts = skipLockouts or false

    self:GetSaveDetails()

    if exportEntry == false then
        MODULES.DKPManager:AddNewEntryToDB(self, updateTable, skipLockouts)
    elseif PDKP.canEdit and exportEntry then
        entry.exportedBy = Utils:GetMyName()
        MODULES.DKPManager:ExportEntry(self)
    end
end

function entry:CalculateDecayAmounts(refresh)
    refresh = refresh or false

    PDKP:PrintD("entry:CalculateDecayAmounts(): Refresh: ", refresh, self.id);

    wipe(self.decayAmounts)

    if refresh then
        wipe(self.members)
        self:GetMembers()
        wipe(self.decayAmounts)
    end

    for _, member in pairs(self.members) do
        if next(self.decayAmounts) == nil or self.decayAmounts[member.name] == nil then
            self['decayAmounts'][member.name] = 0
            local member_previous = self['previousTotals'][member.name]
            if member_previous == nil or refresh then
                member_previous = member:GetDKP()
            end
            local member_decay_amount = math.floor(member_previous) - math.floor( (member_previous * 0.9) )
            self['decayAmounts'][member.name] = member_decay_amount * -1
        end
    end
end

MODULES.DKPEntry2 = entry
