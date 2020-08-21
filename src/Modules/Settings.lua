local _, core = ...;
local _G = _G;
local L = core.L;

local Settings = core.Settings;

Settings.bank_name = 'PantheonBank';
Settings.current_raid = 'Molten Core';

function Settings:ChangeCurrentRaid(raid)
    if raid == 'Onyxia\'s Lair' then
        raid = 'Molten Core'
    end
    Settings.current_raid = raid;
end



