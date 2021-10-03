local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;
--local GUI = PDKP.GUI;

local Raid = {}

local tinsert = tinsert
local PromoteToAssistant, GetRaidRosterInfo, SetLootMethod = PromoteToAssistant, GetRaidRosterInfo, SetLootMethod

local GroupManager, GuildManager;

function Raid:Initialize()
    self.settings_DB = MODULES.Database:Settings()
    local db = self.settings_DB

    GroupManager = MODULES.GroupManager
    GuildManager = MODULES.GuildManager

    self.ignore_from = db['ignore_from']
    self.invite_commands = db['invite_commands']
    self.ignore_pugs = db['ignore_pugs']
    self.invite_spam_text = "[TIME] [RAID] invites going out. Pst for Invite"

    if Utils:tEmpty(self.invite_commands) then
        self.settings_DB['invite_commands'] = { 'inv', 'invite' }
    end
end

function Raid:GetClassMemberNames(class)
    local names = {}
    local classNames = MODULES.GroupManager.classes[class]

    if classNames then
        for i = 1, #classNames do
            tinsert(names, classNames[i])
        end
    end

    return names
end

function Raid:PromoteLeadership(justDKPOfficer)
    if justDKPOfficer ~= nil and type(justDKPOfficer) == "string" then
        justDKPOfficer = nil;
    end

    if not GroupManager:IsLeader() then
        return
    end

    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, _, isML, _ = GetRaidRosterInfo(i);
        if name ~= nil then
            local m = GuildManager:GetMemberByName(name)
            if m ~= nil then
                if (m.isInLeadership or isML) and justDKPOfficer == nil then
                    PromoteToAssistant('raid' .. i)
                elseif justDKPOfficer == true and GroupManager:IsMemberDKPOfficer(name) then
                    PromoteToAssistant('raid' .. i)
                    return
                end
            end
        end
    end
end

function Raid:SetLootCommon()
    if not GroupManager:IsInRaid() or not GroupManager:IsLeader() then
        return
    end
    local ml = GroupManager.leadership.masterLoot or Utils:GetMyName()
    SetLootMethod("Master", ml, '1')
    PDKP.CORE:Print("Loot threshold updated to common")
end

function Raid:ProcessRosterEditBox(inputText)
    --Tanks: wuggs, insano, zeon
    --Priest: puff, shvou, aqua, retkin, jeff
    --Warriors: cheese, grisle
    --Mage: veriandra
    --Paladin: web, advanty
    --Rogue: mariku, iszell
    --Warlock: calixta, thepurple, edgy
    --Druid: goob, flat
    --Hunters: woop, ugro
    --Shamans: zeltrix, snail, terb
    --
    --Bench: boltzey

    local text_classes = { strsplit("\n", inputText) }
    local classes = {};
    for _, c in pairs(text_classes) do
        local names = { strsplit(":", c)};
        local class_name = names[1];
        if class_name ~= "Bench" and class_name ~= "bench" then
            classes[class_name] = {};
            for k, n in pairs(names) do
                if k ~= 1 then
                    local char_names = { strsplit(",", n)};
                    classes[class_name] = char_names;
                end
            end
        end
    end

    local search = PDKP.memberTable.searchFrame.editBox
    local clear_btn = PDKP.memberTable.searchFrame.clearButton

    local found_names = {};
    local found_counter = 0;
    local missing_names = {};
    local missing_counter = 0;
    local unknown_matches = {};
    --local distinct_names = {};

    for class_name, class in pairs(classes) do
        for _, name in pairs(class) do
            name = strtrim(name);
            for i=1, #name do
                local chars = name:sub(1, i);
                search:SetText(chars);
                PDKP.memberTable:SearchChanged(chars);

                local displayCount = PDKP.memberTable:GetDisplayCount();
                local isShown, matched_name = PDKP.memberTable:IsMemberShown(name, class_name)

                if (displayCount == 1 or isShown) and found_names[name] == nil then
                    found_names[name] = true;
                    found_counter = found_counter + 1

                    if matched_name == nil then
                        unknown_matches[name] = true;
                    else
                        --distinct_names[name] = true;
                    end
                end
            end
            if found_names[name] == nil then
                missing_names[name] = true;
                missing_counter = missing_counter + 1;
            end
            clear_btn:Click();
        end
        clear_btn:Click();
    end

    --for name, _ in pairs(missing_names) do
    --    print(name, 'Was not able to be located in game');
    --end
    --
    --for name, _ in pairs(unknown_matches) do
    --    print('Was not able to find a distinct match for', name);
    --end

    --PDKP.CORE:Print(missing_counter, "Members missing from the raid");

    -- #PDKP.memberTable:GetDisplayedRows();

    --Utils:StringsMatch(dataObj['name'], super.searchText)
end

MODULES.RaidManager = Raid
