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

local SAFE_COMMS = {
    ['pdkpTestingCom']=true,
    ['pdkpLastEditQry']=true,
    ['pdkpLastEditPost']=true,
};

function Comms:RegisterCommCommands()
    PDKP:RegisterComm('pdkpTestingCom', OnCommReceived)
    PDKP:RegisterComm('pdkpLastEditQry', OnCommReceived)
    PDKP:RegisterComm('pdkpLastEditPost', OnCommReceived)
end

function OnCommReceived(prefix, message, distribution, sender)
    if not Guild:CanMemberEdit(sender) or not SAFE_COMMS[prefix] then -- Sender doesn't have the rights to edit data.
        local errMsg = sender .. ' is attempting to use an unsafe communication method: ' .. prefix .. ' Please contact'
        errMsg = errMsg .. ' an Officer.'
        return Util:ThrowError(errMsg)
    end

    local data = Comms:Deserialize(message)

    if prefix == 'pdkpLastEditQry' then
--        PDKP:SendCommMessage('pdkpLastEditPost', PDKP:Serialize(DKP:GetLastEdit()), 'WHISPER', sender) end;
    end
    if prefix == 'pdkpLastEditPost' then
        local lastEdit = DKP:GetLastEdit()
    end

    print('Prefix', prefix, ' message', Comms:Deserialize(message), ' distro', distribution, 'sender', sender)
end

function Comms:SendShroud()
    local commMethod;
--    PDKP:SendCommMessage('pdkp_shrouding', Util:GetMyName(), 'WHISPER', )
end

function Comms:pdkp_send_comm(data)
    local msg = data or {love=true} -- Testing purposes.
    PDKP:SendCommMessage('pdkpTestingCom', PDKP:Serialize(msg), 'WHISPER', 'PantheonBank', 'BULK');
end

function Comms:EnteringWorld()
    PDKP:SendCommMessage('pdkpTestingCom', PDKP:Serialize(msg), 'WHISPER', 'PantheonBank', 'BULK');
end

function pdkp_serialize(data)
    return PDKP:Serialize(data);
end

function Comms:Serialize(data)
    return PDKP:Serialize(data);
end

function Comms:Deserialize(string)
    local success, data = PDKP:Deserialize(string)

    if success == false or success == nil then
        Util:ThrowError('Deserialization of data...');
        return nil;
    end
    return data;
end

