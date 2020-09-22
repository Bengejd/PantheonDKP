local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local PDKP = core.PDKP;
local Raid = core.Raid;
local Util = core.Util;
local Comms = core.Comms;
local Setup = core.Setup;
local Guild = core.Guild; -- Uppercase is the file
local guild = core.guild; -- Lowercase is the object
local Shroud = core.Shroud;
local Member = core.Member;
local Import = core.Import;
local Officer = core.Officer;
local Invites = core.Invites;
local Minimap = core.Minimap;
local Defaults = core.Defaults;
local Settings = core.Settings;

function DKP:RaidNotOny(raid)
    return raid ~= 'Onyxia\'s Lair'
end

--- TESTING FUNCTIONS BELOW

function DKP:TestShroud()
    local memberTable = PDKP.memberTable
    local selectedNames = memberTable.selected;
    for _, name in pairs(selectedNames) do
        local member = Guild:GetMemberByName(name)
        local newTotal = member:QuickCalc('Molten Core', nil)
        print('Old total', member:GetDKP('Molten Core', 'total'), 'New total:', newTotal)
        member:UpdateDKPTest('Molten Core', newTotal)
    end
    memberTable:RaidChanged()
end

function DKP:ResetDKP()
    local memberTable = PDKP.memberTable
    local selectedNames = memberTable.selected;
    for _, name in pairs(selectedNames) do
        local member = Guild:GetMemberByName(name)
        member:UpdateDKPTest('Molten Core', member.guildIndex)
    end
    memberTable:RaidChanged()
end