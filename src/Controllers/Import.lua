local _, core = ...;
local _G = _G;
local L = core.L;

local Import = core.Import;
local Util = core.Util;

Import.__index = Import

local SYNC_TYPES = {'push-overwrite', 'push-merge', 'push-delete', 'push-add'}

function Import:New(prefix, data, sender)
    print(prefix, 'received from', sender)


    --if sync_type == nil  or not tContains(SYNC_TYPES, sync_type) then
    --    Util:Debug("Error: No Import Type found for", sync_type)
    --    return
    --end
    --Util:Debug('Preparing Data for:', sync_type)
    --
    --local self = {};
    --setmetatable(self, Import); -- Set the metatable so we used Import's __index
    --
    --self.type = sync_type
    --self.details = {};
    --self.entry = entry;
    --
    ----- Overwrite
    --if self.type == 'push-overwrite' then
    --
    --    --- Merge
    --elseif self.type == 'push-merge' then
    --
    --    --- Delete
    --elseif self.type == 'push-delete' then
    --
    --    --- Add
    --elseif self.type == 'push-add' then
    --
    --end
    --
    --return self
end