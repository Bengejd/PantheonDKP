local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Options = {}

local strlower = string.lower

function Options:Initialize()
    self.db = MODULES.Database:Settings()
    self:_InitializeDBDefaults()
end

function Options:_InitializeDBDefaults()
    self.db['ignore_from'] = self.db['ignore_from'] or {}
    self.db['minimap'] = self.db['minimap'] or 207
    self.db['sync'] = self.db['sync'] or {}
end

function Options:IsPlayerIgnored(playerName)
    for _, name in pairs(self.db['ignore_from']) do
        if strlower(playerName) == strlower(name) then
            return true
        end
    end
    return false
end

function Options:GetInviteCommands()
    return self.db['invite_cmds'] or { 'inv', 'invite' }
end

MODULES.Options = Options