local _, core = ...;
local _G = _G;
local L = core.L;

local Export = core.Export;
local Util = core.Util;
local Settings = core.Settings;
local Character = core.Character;
local DKP = core.DKP;
local Guild = core.Guild;
local Comms = core.Comms;

Export.__index = Export

local EXPORT_TYPES = {'push-overwrite', 'push-merge', 'push-delete', 'push-add'}

function Export:New(sync_type, entry)
    if sync_type == nil  or not tContains(EXPORT_TYPES, sync_type) then
        Util:Debug("Error: No Export Type found for", sync_type)
        return
    end
    if not Settings:CanEdit() then
        Util:Debug('Error: You do not have the proper permissions to send a sync')
        return
    end

    --Settings.smallSyncAvailable = false --- So that we don't try to export too many things at once.
    --Settings.longSyncAvailable = false --- So that we don't try to export too many things at once.

    Util:Debug('Preparing Data for:', sync_type)

    local self = {};
    setmetatable(self, Export); -- Set the metatable so we used Export's __index

    self.type = sync_type
    self.details = {
        ['type']=self.type,
        ['data']= {
            ['entry']={},
            ['history']={
                ['all']={},
                ['deleted']={},
            },
            ['members']= {},
        },
        ['officer']=Character:GetMyName(),
        ['time']=GetServerTime()
    };
    self.entry = entry;
    self.prefix = nil

    if self.type == 'push-overwrite' or self.type == 'push-merge' then
        print("Preparing Export:", sync_type)
        self.details['data']['history']['deleted']=DKP.history['deleted']

        for hist_entry_id, hist_entry in pairs(DKP.history_entries) do
            local entry_push_data = hist_entry:PreparePushData()
            if entry_push_data ~= nil then
                self.details['data']['history']['all'][hist_entry_id] = entry_push_data
            elseif not tContains(self.details['data']['history']['deleted'], hist_entry_id) then
                table.insert(self.details['data']['history']['deleted'], hist_entry_id)
            end
        end

        if self.type == 'push-overwrite' then
            for name, member in pairs(Guild.members) do
                local member_data = member:PreparePushData()
                if not tEmpty(member_data) then self.details['data']['members'][name]=member_data end
            end
        end
        --- Delete
    elseif self.type == 'push-delete' and self.entry ~= nil and self.entry['deleted'] == true then
        local entry_push_data = self.entry:PrepareDeletedPushData()
        self.details['data']['entry']=entry_push_data;
        --- Add
    elseif self.type == 'push-add' and self.entry ~= nil and self.entry['deleted'] == false then
        local entry_push_data = self.entry:PreparePushData()
        self.details['data']['entry']=entry_push_data;
    else
        Util:Debug("Could not find matching Sync Type", self.type, "With Entry", self.entry, "Delete Status:", self.entry['deleted'])
        return
    end

    local prefix = nil
    if self.type == 'push-add' or self.type == 'push-delete' then
        prefix = 'pdkpSyncSmall'
    elseif self.type == 'push-overwrite' or self.type == 'push-merge' then
        prefix = 'pdkpSyncLarge'
    end

    if prefix == nil then
        print('Error occurred while sending data')
        return
    end

    Comms:SendCommsMessage(prefix, self.details, 'GUILD', nil, 'BULK', PDKP_CommsCallback)
end