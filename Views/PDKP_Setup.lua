local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Item = core.Item;
local PDKP = core.PDKP;
local Raid = core.Raid;
local Util = core.Util;
local Comms = core.Comms;
local Setup = core.Setup;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Member = core.Member;
local Import = core.Import;
local Officer = core.Officer;
local Invites = core.Invites;
local Minimap = core.Minimap;
local Defaults = core.Defaults;

local AceGUI = LibStub("AceGUI-3.0")

local PlaySound = PlaySound

function Setup:MainInterface()
    local AceGUI = LibStub("AceGUI-3.0")
    -- Create a container frame
    local f = AceGUI:Create("Frame")
    f:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    f:SetTitle("AceGUI-3.0 Example")
    f:SetStatusText("Status Bar")
    f:SetLayout("Flow")

    local tg = AceGUI:Create("TabGroup")
    local tabs = {
        {value = "name", text = "Name" },
        {value = "class", text = "Class" },
        {value = "dkp", text = "DKP" },
    }
    tg:SetTabs(tabs)
    f:AddChild(tg);

    for _, tab in pairs(tg.tabs) do
        tab:SetScript("OnClick", function()
            PlaySound(841) -- SOUNDKIT.IG_CHARACTER_INFO_TAB
            tab.obj:SelectTab(tab.value)
        end)
    end

    tg:SetCallback("OnGroupSelected", function(self, _, value)
        print(value)
    end)

--    local sg = AceGUI:Create("SimpleGroup")
--    sg:Set

    -- Add in the labels
--    for _, text in pairs({'Name', 'Class', 'DKP' }) do
--        local label = AceGUI:Create("Label")
--        label:SetText(text)
--        sg:AddChild(label)
--    end
--
--    f:AddChild(sg)


    local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true) -- probably?
    scrollcontainer:SetLayout("Fill") -- important!

    f:AddChild(scrollcontainer)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)




    for _, member in pairs(Guild.members) do
        local label = AceGUI:Create("Label")
        label:SetText(member.name)
        scroll:AddChild(label)
    end

    -- ... add your widgets to "scroll"


end

