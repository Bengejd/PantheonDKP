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
    local sortBy, sortDir;

    local toggleSortDir = function(sortDir)
        if sortDir == 'ASC' then return 'DESC' end
        return 'ASC';
    end

    local sortFunc = function(currentSort, currentDir, sortBy)
        local sortDir;
        if currentSort == sortBy then
            sortDir = toggleSortDir(currentDir)
        else
            sortDir = currentDir or 'ASC';
        end

        local function compare(a,b)
            if a == 0 and b == 0 then return end;
            if sortDir == 'ASC' then return a[sortBy] > b[sortBy] end
            return a[sortBy] < b[sortBy];
        end

        local function compareDKP(a,b)
            if sortDir == 'DES' then return a.dkp['Molten Core'].total > b.dkp['Molten Core'].total end
            return a.dkp['Molten Core'].total < b.dkp['Molten Core'].total
        end

        if sortBy == 'dkp' then
            table.sort(Guild.members, compareDKP)
        else
            table.sort(Guild.members, compare)
        end

        return sortBy, sortDir
    end

    local AceGUI = LibStub("AceGUI-3.0")
    -- Create a container frame
    local f = AceGUI:Create("Frame")
    f:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
--    f:SetTitle("AceGUI-3.0 Example")
--    f:SetStatusText("Status Bar")
    f:SetLayout("Flow")

    local tg = AceGUI:Create("TabGroup")
    tg:SetFullWidth(true)
    local tabs = {
        {value = "name", text = "Name" },
        {value = "class", text = "Class" },
        {value = "dkp", text = "DKP" },
    }
    tg:SetTabs(tabs)
    tg.content:Hide()
    tg.content:ClearAllPoints()
    f:AddChild(tg);


    local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true) -- probably?
    scrollcontainer:SetLayout("Fill") -- important!

    f:AddChild(scrollcontainer)

    local function addScroll()
        local scroll = AceGUI:Create("ScrollFrame")
        scroll:SetLayout("Flow") -- probably?
        scrollcontainer:AddChild(scroll)
        scroll:SetFullWidth(true)

        local function addChildren()
            scroll:PauseLayout()

            local function addLabel(text)
                local label = AceGUI:Create("InteractiveLabel")
                label:SetFullWidth(false)
                label:SetWidth(200)
                label:SetHeight(100)
                label:SetText(text)

                label.frame:ClearAllPoints()
                label.frame:SetPoint("TOPRIGHT", -300, -300)

                label:SetCallback('OnClick', function(self, _, clickType)
                    local group = label.parent;
                    local children = group.children

                    local name = children[1].label:GetText()
                    local class = children[2].label:GetText()
                    local viewDKP = children[3].label:GetText()

                    local member = Guild.members[name]

                    local dkp = member.dkp['Molten Core'].total

                    if clickType == 'LeftButton' then
                        member.dkp['Molten Core'].total = member.dkp['Molten Core'].total + 1
                    end

                    if clickType == 'RightButton' then
                        member.dkp['Molten Core'].total = member.dkp['Molten Core'].total - 1
                    end

                    children[3].label:SetText(dkp)

                    children[1]:SetHighlight(1,1,1,1)

                    local keyset={}
                    local n=0

                    for k,v in pairs(children[1]) do
                        n=n+1
                        keyset[n]=k

                        print(n, k)
                    end

--                    children[1].highlight
                    children[2]:SetHighlight(1,1,1,1)
                    children[3]:SetHighlight(1,1,1,1)

--                    print(member.dkp['Molten Core'].total)

                end)

                return label
            end

            for _, member in pairs(Guild.members) do
                local ig = AceGUI:Create("SimpleGroup")
                ig:SetFullWidth(true)
                ig:SetLayout("Flow") -- probably?

                local l1, l2, l3 = addLabel(member.name), addLabel(member.coloredClass), addLabel(member.dkp['Molten Core'].total)

                ig:AddChild(l1)
                ig:AddChild(l2)
                ig:AddChild(l3)

                scroll:AddChild(ig)
            end
            scroll:ResumeLayout()
        end
        addChildren()
    end

    for _, tab in pairs(tg.tabs) do
        tab:SetScript("OnClick", function()
            PlaySound(841) -- SOUNDKIT.IG_CHARACTER_INFO_TAB
            tab.obj:SelectTab(tab.value)
            tab:SetSelected(false)
            sortBy, sortDir = sortFunc(sortBy, sortDir, tab.value)
            scrollcontainer:ReleaseChildren()
            addScroll()
        end)
    end
    addScroll()


end

