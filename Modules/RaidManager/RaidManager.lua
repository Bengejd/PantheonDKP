local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Raid = {}

local tinsert = tinsert

function Raid:Initialize()
    self.settings_DB = MODULES.Database:Settings()
    local db = self.settings_DB

    self.ignore_from = db['ignore_from']
    self.invite_commands = db['invite_commands']
    self.ignore_pugs = db['ignore_pugs'] or false
    self.invite_spam_text = "[TIME] [RAID] invites going out. Pst for Invite"

    if Utils:tEmpty(self.invite_commands) then
        self.settings_DB['invite_commands'] = {'inv', 'invite'}
    end
end

function Raid:GetClassMemberNames(class)
    local names = {}
    local classNames = MODULES.GroupManager.classes[class]

    for i=1, #classNames do
        tinsert(names, classNames[i])
    end
    return names
end

-- TODO: Implement this.
function Raid:PromoteLeadership()
    print('TODO: Promote Leadership')
end

-- TODO: Implement this.
function Raid:SetLootCommon()
    print('TODO: SetLootCommon')
end

MODULES.RaidManager = Raid