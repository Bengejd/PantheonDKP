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
    ['pdkpPushRequest']=true,
    ['pdkpLastEditReq']=true,
    ['pdkpLastEditRec']=true,
    ['pdkpBusyTryAgain']=true,
};

local UNSAFE_COMMS = {
    ['pdkpPushReceived']=true,
}

Comms.processing = false

---------------------------
--   GENERIC Functions   --
---------------------------

function Comms:RegisterCommCommands()
    for key, _ in pairs(SAFE_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end
    for key, _ in pairs(UNSAFE_COMMS) do PDKP:RegisterComm(key, OnCommReceived) end
end

function Comms:Serialize(data)
    return PDKP:Serialize(data);
end

function pdkp_serialize(data)
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

function OnCommReceived(prefix, message, distribution, sender)
    if Comms.processing then -- If we're processing a com, don't overload yourself.
        return PDKP:SendCommMessage('pdkpBusyTryAgain', PDKP:Serialize('Busy'), 'WHISPER', sender, 'BULK')
    end

    Comms.processing = true

    local data = Comms:Deserialize(message) -- deserialize it.

    if SAFE_COMMS[prefix] then Comms:OnSafeCommReceived(prefix, data, distribution, sender);
    elseif UNSAFE_COMMS[prefix] then Comms:OnUnsafeCommReceived(prefix, data, distribution, sender);
    end

    Comms.processing = false
end

function Comms:ThrowError(prefix, sender)
    local errMsg = sender .. ' is attempting to use an unsafe communication method: ' .. prefix .. ' Please contact'
    errMsg = errMsg .. ' an Officer.'
    return Util:ThrowError(errMsg)
end

---------------------------
--    SAFE FUNCTIONS     --
---------------------------

function Comms:OnSafeCommReceived(prefix, message, distribution, sender)
    -- We received a communication that we shouldn't have...
    if not SAFE_COMMS[prefix] then return Comms:ThrowError(prefix, sender) end

    --['pdkpPushRequest']=true,

    if prefix == 'pdkpBusyTryAgain' then PDKP:Print(sender .. ' is currently busy, please try again later')
    elseif prefix == 'pdkpLastEditReq' then -- Send them back your lastEdit time
        PDKP:SendCommMessage('pdkpLastEditRec', PDKP:Serialize(DKP.dkpDB.lastEdit), 'WHISPER', sender, 'BULK')
    elseif prefix == 'pdkpLastEditRec' then -- Process their lastEdit time
        Comms:LastEditReceived(sender, message)
    elseif prefix == 'pdkpPushRequest' then -- Someone Sent you a push request
    end

--    print('Prefix', prefix, ' message', message, ' distro', distribution, 'sender', sender)
end

---------------------------
--   UNSAFE FUNCTIONS    --
---------------------------
function Comms:OnUnsafeCommReceived(prefix, message, distribution, sender)
    -- We received a communication that we shouldn't have...
    if not UNSAFE_COMMS[prefix] or not Guild:CanMemberEdit(sender) then return Comms:ThrowError(prefix, sender) end

    if prefix == 'pdkpBusyTryAgain' then PDKP:Print(sender .. ' is currently busy, please try again later') end

    if prefix == 'pdkpPushRequest' then
        print('pdkpPushRequest received!');
    end

    print('Prefix', prefix, ' message', Comms:Deserialize(message), ' distro', distribution, 'sender', sender)

    -- We've finished processing the comms.
    Comms.processing = false
end

function Comms:pdkp_send_comm(data)
--    local msg = data or {love=true} -- Testing purposes.
--    PDKP:SendCommMessage('pdkpTestingCom', PDKP:Serialize(msg), 'WHISPER', 'PantheonBank', 'BULK');
end


function Comms:PrepareDatabase()
    local database = {
        guildDB = {
            numOfMembers = Guild.db.numOfMembers,
            members = Guild.db.members
        },
        dkpDB = {
            lastEdit=DKP.dkpDB.lastEdit,
            history=DKP.dkpDB.history,
            members=DKP.dkpDB.members,
            currentDB=DKP.dkpDB.currentDB
        }
    }
    PDKP:SendCommMessage('pdkpTestingCom', PDKP:Serialize(database), 'WHISPER', 'PantheonBank', 'BULK');
end

function Comms:RequestOfficersLastEdit()
    Guild:GetGuildData() -- Retrieve up to date guild data.

    local officers = Guild.officers;
    for i=1, #officers do
        local officer = officers[i]
        officer['lastEdit'] = -1
        if officer['online'] then
            Util:Debug('sending lastEdit request to '..officer['name'])
            PDKP:SendCommMessage('pdkpLastEditReq', PDKP:Serialize(''), 'WHISPER', officer['name'], 'BULK')
        end
    end
end

function Comms:LastEditReceived(sender, message)
    Util:Debug('Received Last Edit from '..sender)
    for i=1, #Guild.officers do
        local officer = Guild.officers[i];
        if officer['name'] == sender then
           officer['lastEdit'] = message
        end
    end
    GUI:UpdatePushFrame()
end