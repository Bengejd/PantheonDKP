local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Util = core.Util;
local PDKP = core.PDKP;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Comms = core.Comms;

--[[
--
--  MESSAGE TYPES: "PARTY", "RAID", "GUILD", "OFFICER", "BATTLEGROUND", "WHISPER"
--
 ]]

function Comms:SendShroud()
    local commMethod;
--    PDKP:SendCommMessage('pdkp_shrouding', Util:GetMyName(), 'WHISPER', )
end


function pdkp_comm_sent_test()
    PDKP:SendCommMessage('pdkp_testing_com', pdkp_serialize(), 'WHISPER', 'PantheonBank', 'BULK');
end

function pdkp_serialize()
    return PDKP:Serialize(core.DKP.db.char.members);
end

function pdkp_deserialize(string)
    local success, data = PDKP:Deserialize(string)
    data['Neekio'].dkpTotal = 1000;
    core.DKP.db.char.members = data;
    print(success);
end

function pdkp_comm_received_test(prefix, text, distrbution, target)
    PDKP:Print("Comms received!!!!!!!");
    pdkp_deserialize(text);
end