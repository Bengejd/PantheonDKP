local _, core = ...;
local _G = _G;
local L = core.L;

local Shroud = core.Shroud;
local Raid = core.Raid;
local Guild = core.Guild;
local PDKP = core.PDKP;
local Util = core.Util;
local Settings = core.Settings;
local GUI = core.GUI;
local Comms = core.Comms;

local trim, lower = strtrim, strlower

local shroud_commands = {'shroud', 'thirst'}
local SHROUD_EVENTS = {'CHAT_MSG_WHISPER', 'CHAT_MSG_RAID', 'CHAT_MSG_RAID_LEADER'}

Shroud.events_frame = nil;

Shroud.shrouders = {};

function PDKP_Shroud_OnEvent(self, event, arg1, ...)
    if not Raid:InRaid() or not Raid:IsDkpOfficer() then return end

    local msg, _, _, _, name, _, _, _, _, _, _, _, _, _, _, _, _ = arg1, ...
    msg = lower(trim(msg))

    if not tContains(shroud_commands, msg) then return end -- Not a shrouding message.

    Shroud:NewShrouder(name)
end

function Shroud:NewShrouder(name) -- Only the DKP Officer gets this.
    local shroud_data = {};
    if name ~= nil then
        local shroud_member = Guild:GetMemberByName(name)
        shroud_data['name']=name
        shroud_data['dkp']=shroud_member:GetShroudDKP()
    end
    shroud_data['raid']=Settings.current_raid
    return Comms:SendCommsMessage('pdkpUpdateShroud', shroud_data, 'RAID', nil, nil, nil)
end

function Shroud:UpdateShrouders(shrouder_data)
    local name = shrouder_data['name']
    local dkp = shrouder_data['dkp']
    local raid = shrouder_data['raid']

    if name ~= nil and dkp ~= nil then
        Shroud.shrouders[name] = dkp;
    end

    local shroud_box = GUI.shroud_box;
    local scrollContent = shroud_box.scrollContent;

    scrollContent:WipeChildren() -- Wipe previous shrouding children frames.

    local shroud_keys = {}; -- Member names in a list we can sort.
    for key, _ in pairs(Shroud.shrouders) do table.insert(shroud_keys,key) end

    local compare = function(a, b)
        local a_mem, b_mem = Shroud.shrouders[a], Shroud.shrouders[b]
        return a_mem[raid] > b_mem[raid]
    end
    table.sort(shroud_keys, compare)

    local createShroudStringFrame = function()
        local f = CreateFrame("Frame", nil, scrollContent, nil)
        f:SetSize(scrollContent:GetWidth(), 18)
        f.name = f:CreateFontString(f, "OVERLAY", "GameFontHighlightLeft")
        f.total = f:CreateFontString(f, 'OVERLAY', 'GameFontNormalRight')
        f.name:SetHeight(18)
        f.total:SetHeight(18)
        f.name:SetPoint("LEFT")
        f.total:SetPoint("RIGHT")
        return f
    end

    for i=1, #shroud_keys do
        if i == 1 then
            local winner_frame = createShroudStringFrame()
            local winner_text = Util:FormatFontTextColor('00FF96', '[WINNER]')
            winner_frame.name:SetText(winner_text)
            scrollContent:AddChild(winner_frame)
        end
        if i == 2 then
            local losers_frame = createShroudStringFrame()
            local loser_text = Util:FormatFontTextColor('FF3F40', '[SHROUDERS]')
            losers_frame.name:SetText(loser_text)
            scrollContent:AddChild(losers_frame)
        end

        local shroud_name = shroud_keys[i]
        local shrouder = Shroud.shrouders[shroud_name]
        local shroud_frame = createShroudStringFrame()
        shroud_frame.name:SetText(shroud_name)
        shroud_frame.total:SetText(shrouder[raid])
        scrollContent:AddChild(shroud_frame)
    end

    local raid_text = raid .. ' Shrouds'
    GUI.shroud_box.title:SetText(raid_text)

    GUI.shroud_box:Show()
end

function Shroud:ClearShrouders()
    print('Clearing shrouders')
    GUI.shroud_box.scrollContent:WipeChildren()
    Shroud.shrouders = {};
    wipe(Shroud.shrouders)
    GUI.shroud_box:Hide()
end