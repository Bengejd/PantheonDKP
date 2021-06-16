local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI

local CreateFrame = CreateFrame

local Tab = {}

function Tab:Initialize()
    Tab.tabs = {};
    Tab.tab_btns = {};

    local f = CreateFrame("Frame", "$parentRightFrame", pdkp_frame, MODULES.Media.BackdropTemplate)

    f:SetHeight(500)
    f:SetWidth(395)
    f:SetPoint("TOPLEFT", PDKP.memberTable.frame, "TOPRIGHT", 0, 0)
    f:SetPoint("BOTTOMLEFT", PDKP.memberTable.filter_frame, "BOTTOMRIGHT", 0, 0)

    local tab_opts = {
        ['view_adjust_button'] = {
            ['text'] = 'Adjust',
        },
        ['view_history_button'] = {
            ['text'] = 'History',
        },
        ['view_loot_button'] = {
            ['text'] = 'Loot',
        },
        ['view_lockouts_button'] = {
            ['text'] = 'Lockouts',
        },
        ['view_options_button'] = {
            ['text'] = 'Options',
        },
    }
    local tab_names = {'view_adjust_button', 'view_history_button', 'view_loot_button', 'view_lockouts_button', 'view_options_button'}

    local btn_pad = 35

    for i=1, #tab_names do
        local name = tab_names[i]
        local tab_opt = tab_opts[name]
        local tf = CreateFrame("Frame", name .. '_frame', f, MODULES.Media.BackdropTemplate)
        tf:SetBackdrop({
            tile = true, tileSize = 0,
            edgeFile = MODULES.Media.SCROLL_BORDER, edgeSize = 8,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        tf:SetAllPoints(f)

        local b = CreateFrame("Button", "$parent_" .. name, f)
        b:SetSize(100, 30)

        if name == 'view_adjust_button' and PDKP.canEdit and i == 1 then
            b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 0)
        elseif #Tab.tabs == 0 then
            b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 0)
        else
            b:SetPoint("TOPLEFT", Tab.tabs[i - 1], "TOPRIGHT", 0, 0)
            b:SetAlpha(0.5)
        end

        b:SetNormalTexture(MODULES.Media.TAB_TEXTURE)
        b:SetScript("OnClick", function()
            for _, btn in pairs(Tab.tabs) do
                if btn:GetName() ~= b:GetName() then
                    btn.frame:Hide()
                    btn:SetAlpha(0.5)
                end
            end

            b:SetAlpha(1)
            b.frame:Show()
        end)

        local b_text = b:CreateFontString(b, "OVERLAY", "GameFontNormalLeft")
        b_text:SetPoint("CENTER", 0, -5)
        b_text:SetText(tab_opt['text'])
        b:SetWidth(b_text:GetWidth() + btn_pad)

        b.text = b_text
        b.frame = tf

        Tab[name] = b
        Tab.tabs[i] = b
        Tab.tab_btns[i] = b
    end

    Tab.tab_btns[1]:Click()
end

GUI.TabController = Tab