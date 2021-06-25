local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local Raid = {}

function Raid:Initialize()

end

function Raid:GetClassMemberNames(class)
    local names = {}

    if class == 'Paladin' and PDKP:IsDev() then
        table.insert(names, 'Lariese')
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