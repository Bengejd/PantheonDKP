local _G = _G;
local AddonName, core = ...;

local GetGuildInfo = GetGuildInfo

local PDKP = core.PDKP
local Character, Util, Defaults, Dev = PDKP:GetInst('Character', 'Util', 'Defaults', 'Dev')

function Character:init()
    Dev:Print('Character:init()')

    Character.name, Character.server = UnitName("PLAYER")
    Character.class = UnitClass("PLAYER") -- Character class name
    Character.class_color = Defaults.class_colors[Character.class]
    Character.colored_name = Util:FormatTextColor(Character.class_color, Character.name) -- Character name, colored.
    Character.playerUID = UnitGUID("PLAYER") -- Unique Blizzard Player ID
    Character.isInGuild = IsInGuild()  -- Boolean
    Character.faction = englishFaction -- Alliance or Horde
end

-- Returns the player's guild info
function Character:GetGuildInfo()
    local guildName, guildRankName, guildRankIndex, realmName = GetGuildInfo('PLAYER');
    return guildName, guildRankName, guildRankIndex, realmName;
end