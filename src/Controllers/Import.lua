local _, core = ...;
local _G = _G;
local L = core.L;

local Import = core.Import;
local Util = core.Util;
local DKP = core.DKP;
local Guild = core.Guild;
local DKP_Entry = core.DKP_Entry;
local GUI = core.GUI;

local dkpHistory = nil;

Import.__index = Import;

local SYNC_TYPES = {'push-overwrite', 'push-merge', 'push-delete', 'push-add'}

function Import:New(prefix, data, sender)
    if not tContains(SYNC_TYPES, data['type']) then
        Util:Debug('Improper Data Import found', prefix, sender)
        return
    end

    local self = {};
    setmetatable(self, Import); -- Set the metatable so we used Export's __index
    dkpHistory = core.PDKP.dkpDB['history']

    self.data_details = data;

    if prefix == 'pdkpSyncSmall' then -- Adds or Deletes.
        local entry_data = self.data_details['data']['entry']
        local entryNew = self:IsEntryNew(entry_data['id'])
        local entryDeleted = self:IsEntryAlreadyDeleted(entry_data['id'])

        print('PDKP update received from:', sender)

        if self.data_details.type == 'push-add' and entryNew then
            self:ProcessAdd(entry_data)
        elseif self.data_details.type == 'push-delete' and not entryDeleted then
            self:ProcessDelete(entry_data)
        else
        end
    elseif prefix == 'pdkpSyncLarge' then -- Merges or Overwrites.
        print('Sync received from', sender)

        if self.data_details.type == 'push-overwrite' then
            local data_history = self.data_details['data']['history']
            core.PDKP.dkpDB['history']['all'] = data_history['all']
            core.PDKP.dkpDB['history']['deleted'] = data_history['deleted']
            wipe(DKP.history_entries)

            for name, member in pairs(self.data_details['data']['members']) do
                local g_member = Guild:GetMemberByName(name)
                if g_member and member then
                    g_member:OverwriteDKP(member)
                end
            end
        elseif self.data_details.type == 'push-merge' then
            local data_history = self.data_details['data']['history']
            if data_history ~= nil then
                local data_all = data_history['all']
                local data_deleted = data_history['deleted']

                --- Process Entries
                for e_id, entry in pairs(data_all) do
                    local entryNew = self:IsEntryNew(e_id)
                    local entryDeleted = self:IsEntryAlreadyDeleted(e_id)
                    if entryNew and not entryDeleted then
                        self:ProcessAdd(entry)
                    end
                end

                --- Process Deleted Entries
                for _, id in pairs(data_deleted) do
                    if not self:IsEntryNew(id) then
                        local deleted_entry = core.PDKP.dkpDB['history']['all'][id]
                        if deleted_entry ~= nil then
                            self:ProcessDelete(deleted_entry)
                        end
                    end
                end
            end
        end
    end
    GUI:RefreshTables(true)
    GUI:UpdateEasyStats()
end

function Import:ProcessAdd(new_entry)
    local entry = DKP_Entry:New(new_entry)
    if entry ~= nil and entry['names'] ~= nil and #entry['names'] > 0 then
        for _, name in pairs(entry['names']) do
            local member = Guild:GetMemberByName(name)
            if member ~= nil then
                member:NewEntry(entry)
            end
        end
        entry:Save()
    end

    if entry['id'] > DKP.lastEdit then
        core.PDKP.dkpDB['lastEdit'] = entry['id']
        DKP.lastEdit = entry['id']
    end

    DKP:GetEntries(false, entry['id'], 'Molten Core')
end

function Import:ProcessDelete(entry)
    core.PDKP.dkpDB['history']['all'][entry['id']]['deleted']=true -- Mark the entry as having been deleted.
    for _, name in pairs(entry['names']) do
        local member = Guild:GetMemberByName(name)
        member:DeleteEntry(entry)
    end
    tremove(core.PDKP.dkpDB['history']['all'], entry['id'])
    core.PDKP.dkpDB['history']['all'][entry['id']] = nil;
    tinsert(core.PDKP.dkpDB['history']['deleted'], entry['id'])
    DKP.history_entries[entry['id']] = nil;
    entry['deleted'] = true

    if entry['id'] > DKP.lastEdit then
        core.PDKP.dkpDB['lastEdit'] = entry['id']
        DKP.lastEdit = entry['id']
    end
    if entry['edited_time'] ~= nil and entry['edited_time'] > DKP.lastEdit then
        core.PDKP.dkpDB['lastEdit'] = entry['edited_time']
        DKP.lastEdit = entry['edited_time']
    end

    DKP:GetEntries(false, entry['id'])
end

function Import:IsEntryNew(id)
    return dkpHistory['all'][id] == nil
end

function Import:IsEntryAlreadyDeleted(entryId)
    return tContains(dkpHistory['deleted'], entryId)
end