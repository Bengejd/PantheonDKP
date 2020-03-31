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
local Import = core.Import;

--[[
--
--  MESSAGE TYPES: "PARTY", "RAID", "GUILD", "OFFICER", "BATTLEGROUND", "WHISPER"
--
 ]]

local SAFE_COMMS = {
    ['pdkpPushRequest']=true,
    ['pdkpLastEditReq']=true,
    ['pdkpLastEditRec']=true,
    ['pdkpBusyTryAgai']=true,
};

local UNSAFE_COMMS = {
    ['pdkpPushReceive']=true,
    ['pdkpBusyTryAgai']=true,
    ['pdkpEntryDelete']=true,
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
        return PDKP:SendCommMessage('pdkpBusyTryAgai', PDKP:Serialize('Busy'), 'WHISPER', sender, 'BULK')
    end

    if sender == Util:GetMyName() then return end; -- Don't need to respond to our own messages...

    Comms.processing = true

    local data = Comms:Deserialize(message) -- deserialize it.

    if SAFE_COMMS[prefix] then Comms:OnSafeCommReceived(prefix, data, distribution, sender);
    elseif UNSAFE_COMMS[prefix] then Comms:OnUnsafeCommReceived(prefix, data, distribution, sender);
    else
        print("Unknown Prefix " .. prefix, " found in request...")
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

    if prefix == 'pdkpBusyTryAgai' then PDKP:Print(sender .. ' is currently busy, please try again later')
    elseif prefix == 'pdkpLastEditReq' then -- Send them back your lastEdit time
        PDKP:SendCommMessage('pdkpLastEditRec', PDKP:Serialize(DKP.dkpDB.lastEdit), 'WHISPER', sender, 'BULK')
    elseif prefix == 'pdkpLastEditRec' then -- Process their lastEdit time
        Comms:LastEditReceived(sender, message)
    elseif prefix == 'pdkpPushRequest' then -- Someone Sent you a push request
        Util:Debug("Preparing data to push to " .. sender .. ' This may take a few minutes...')
        local lastTwoWeeks = message
        local data = Comms:PrepareDatabase(lastTwoWeeks, false)
        data = PDKP:Serialize(data)
        PDKP:SendCommMessage('pdkpPushReceive', data, 'WHISPER', sender, 'BULK')
    end

--    print('Prefix', prefix, ' message', message, ' distro', distribution, 'sender', sender)
end

---------------------------
--   UNSAFE FUNCTIONS    --
---------------------------
function Comms:OnUnsafeCommReceived(prefix, message, distribution, sender)

    -- We received a communication that we shouldn't have...
    if not UNSAFE_COMMS[prefix] or not Guild:CanMemberEdit(sender) then return Comms:ThrowError(prefix, sender) end

    if prefix == 'pdkpBusyTryAgai' then PDKP:Print(sender .. ' is currently busy, please try again later') end

    if prefix == 'pdkpPushReceive' then -- When a member requests a DKP push from an officer.
        PDKP:Print("DKP Update received from " .. sender .. ' updating your DKP tables...')
        Import:AcceptData(message)
    end

    if prefix == 'pdkpEntryDelete' then -- When an entry is deleted
        DKP:DeleteEntry(message)
    end

    -- We've finished processing the comms.
    Comms.processing = false
end

function Comms:SendGuildPush()
    Util:Debug("Preparing data to push to GUILD this may take a few minutes...")
    local data = Comms:PrepareDatabase(nil, false)
    data = PDKP:Serialize(data)
    PDKP:SendCommMessage('pdkpPushReceive', data, 'GUILD', nil, 'BULK')
end

function Comms:SendGuildUpdate(histEntry)
    local data = {
        lastEdit = DKP.dkpDB.lastEdit,
        history = {}
    }
    table.insert(data.history, histEntry)
    data = PDKP:Serialize(data)
    PDKP:SendCommMessage('pdkpPushReceive', data, 'GUILD', nil, nil)
end


function Comms:PrepareDatabase(twoWeeksAgo, full)

    local database

    if full then -- Full overwrite.
        database = {
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
    else -- Partial Merge
        database = {
            lastEdit=DKP.dkpDB.lastEdit,
            history=DKP.dkpDB.history,
        }
    end
    return database;
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