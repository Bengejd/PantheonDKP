local _G = _G;
local PDKP = _G.PDKP

local GetGuildInfo = GetGuildInfo
local Character, Util, Defaults, Dev, Guild = PDKP:GetInst('Character', 'Util', 'Defaults', 'Dev', 'Guild')

function Character:Init()
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

function Character:GetMe()
    return Guild:GetMemberByName(Character.name)
end

function Character:GetMyDKP()
    local member = Character:GetMe()
    if member then
        return member:GetDKP()
    end
    return 0
end