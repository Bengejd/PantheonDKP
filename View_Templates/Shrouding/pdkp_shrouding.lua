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
local Setup = core.Setup;
local Raid = core.Raid;

local AceGUI = LibStub("AceGUI-3.0")

Shroud.window = nil;

Shroud.shrouders = {
    names={},
    table={},
};

local testShrouders = {
    names={
        ['GetCrit']=true,
        ['Momo']=true,
        ['Littledubs']=true,
        ['Dwindle']=true,
        ['Gartog']=true,
        ['Dalia']=true,
        ['Sparklenips']=true,
        ['Flatulent']=true,
        ['Chipgizmo']=true,
        ['Jeffry']=true,
        ['Insub']=true,
        ['Jakemeoff']=true,
    },
    table={
        {name='Getcrit', dkpTotal=100},
        {name='Momo', dkpTotal=42},
        {name='Littledubs', dkpTotal=103},
        {name='Dwindle', dkpTotal=25},
        {name='Gartog', dkpTotal=0},
        {name='Dalia', dkpTotal=124},
        {name='Sparklenips', dkpTotal=125},
        {name='Flatulent', dkpTotal=231},
        {name='Chipgizmo', dkpTotal=457},
        {name='Jeffry', dkpTotal=457},
        {name='Insub', dkpTotal=100},
        {name='Jakemeoff', dkpTotal=100},
    },
};

Shroud.shroudPhrases = {
    ['shrouding']=true,
    ['shroud']=true,
    ['thirst']=true,
    ['thirsting']=true,
}

function Shroud:UpdateWindow()
    if Shroud.window == nil then
        Util:Debug('Setting up shrouding window')
        Setup:ShroudingWindow()
    end

    local scroll = Shroud.window.scroll

    scroll:ReleaseChildren() -- Clear the previous entries.

    Util:Debug('Updating the shrouding window')

    local shrouders = Shroud.shrouders.table

    local function compareDesc(a,b) return a.dkpTotal < b.dkpTotal end
    local function compareAsc(a,b) return a.dkpTotal > b.dkpTotal end
    table.sort(shrouders, compareDesc)

    local br = "\n"
    local labels = { AceGUI:Create("Label"), AceGUI:Create("Label"), AceGUI:Create("Label") }
    local colors = {'00FF96', 'FFF569', 'FF3F40'} -- Winner, Tied, Loser colors
    local text = {'[WINNER]', '[TIED]', br .. '[SHROUDERS]' }

    for i=1, #labels do
        local text = Util:FormatFontTextColor(colors[i], text[i] .. br)
        labels[i]:SetText(text)
    end

    local winnerLabel, tiedLabel, loserLabel = labels[1], labels[2], labels[3]

    local winners, losers = {}, {}

    local maxTotalDKP = shrouders[#shrouders].dkpTotal

    for i=1, #shrouders do
        local member = shrouders[i]
        if member.dkpTotal > 0 then -- Ignore people with 0 DKP. They can't shroud on anything anyway.
            local sg, nameLabel, dkpLabel = AceGUI:Create("SimpleGroup"), AceGUI:Create("Label"), AceGUI:Create("Label")
            sg:SetLayout("Flow")
            sg:SetFullWidth(true)
            nameLabel:SetFullWidth(false)
            dkpLabel:SetFullWidth(false)

            nameLabel:SetWidth(98)
            dkpLabel:SetWidth(30)

            local coloredDKP = Util:FormatFontTextColor('FFDF00', member.dkpTotal)

            nameLabel:SetText(member.name)
            dkpLabel:SetText(coloredDKP)

            sg:AddChild(nameLabel)
            sg:AddChild(dkpLabel)

            if #shrouders == 1 then -- We only have one shrouder. They are the winner by default.
                table.insert(winners, sg)
            else -- we have more than one shrouder...
                local dkpTotal = member.dkpTotal
                if dkpTotal == maxTotalDKP then
                    table.insert(winners, sg)
                elseif dkpTotal < maxTotalDKP then
                    table.insert(losers, sg)
                end
            end
            sg.dkpTotal = member.dkpTotal -- So we can resort the table later on.
        end
    end

    local function AddChildren(label, table)
        scroll:AddChild(label)
        for i=1, #table do scroll:AddChild(table[i]) end
    end

    -- Add the labels.
    if #winners == 1 then AddChildren(winnerLabel, winners) end
    if #winners > 1 then AddChildren(tiedLabel, winners) end
    if #losers > 0 then
        table.sort(losers, compareAsc)
        AddChildren(loserLabel, losers)
    end

    Shroud.window:Show()

end

-- Updates the shrouding table to reflect the ML's DKP totals.
function Shroud:UpdateShrouders(playerName) -- Only the ML should be able to access this, ideally.
--    if Defaults.debug then Shroud.shrouders = testShrouders end
    local shrouders = Shroud.shrouders

    local player = { name=playerName, dkpTotal=DKP:GetPlayerDKP(playerName) }
    if shrouders.names[playerName] == nil then -- player isn't in the table yet.
        Util:Debug('Adding shrouder!');
        table.insert(shrouders.names, playerName)
        table.insert(shrouders.table, player);
    else
        for i=1, #shrouders.table do
            local shrouder = shrouders.table[i];
            if shrouder.name == playerName then shrouder.dkpTotal = DKP:GetPlayerDKP(playerName) end
        end
    end

    shrouders.names[playerName] = true;

    core.Comms:SendShroudTable()
end

-- Resets the shrouding table.
function Shroud:ClearShrouders()
    Shroud.shrouders = {
        names={},
        table={},
    };

    if Shroud.window then Shroud.window:Hide() end

    -- The ML should sent out a comm command that wipes everyones tables after this is closed.
    if Raid:isMasterLooter() then
        Comms:ClearShrouders()
    end
end

function Shroud:Hide()
    Shroud.window:Hide();
end

function Shroud:Announce()
    PDKP:Print("Congrats", UnitName('PLAYER'));
end

function shrouding_template_function_calls(funcName)
    if funcName == 'pdkp_shrouding_hide' then return Shroud:Hide() end;
    if funcName == 'pdkp_announce_winner' then return Shroud:Announce() end;
end