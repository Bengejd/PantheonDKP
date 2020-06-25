local _, core = ...;
local _G = _G;
local L = core.L;

local Member = core.Member;
Member.__index = Member; -- Set the __index parameter to reference Character

function Member:new(guildIndex)
    local self = {};
    setmetatable(self, Member); -- Set the metatable so we used Members's __index

    -- Variables / Attributes.

    return self
end