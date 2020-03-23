local _, core = ...;
local _G = _G;
local L = core.L;

local DKP = core.DKP;
local GUI = core.GUI;
local Util = core.Util;
local PDKP = core.PDKP;
local Raid = core.Raid;
local Guild = core.Guild;
local Shroud = core.Shroud;
local Defaults = core.defaults;
local Import = core.import;

local dkpDB;

local success = '22bb33'
local warning = 'E71D36'
local pdkp_boss_kill_dkp = 10

DKP.bankID = nil

--[[
--  RAID DB LAYOUT
--      {members} -- Array
--           [memberName] -- String / Object
--              dkpTotal -- int
--      {history} - Array of the history
--          [all] -- Array
--              [historyID] - Identifier of latest history item
--                  [entry1] - History changes.
--
--          [memberName] -- String / Array
--              [date] -- Array - UTC string of the date the entry was made.
--                  {entry1} -
--                      raidName -- String (MC)
--                      bossKills -- Int (10)
--
]]

local MonolithData = {
    {["name"]="Adjora",["dkp"]=230},
    {["name"]="Advanty",["dkp"]=502},
    {["name"]="Aku",["dkp"]=567},
    {["name"]="Angelyheth",["dkp"]=233},
    {["name"]="Apolyne",["dkp"]=378},
    {["name"]="Arkleis",["dkp"]=295},
    {["name"]="Artorion",["dkp"]=118},
    {["name"]="Astlan",["dkp"]=360},
    {["name"]="Athico",["dkp"]=468},
    {["name"]="Awwswitch",["dkp"]=0},
    {["name"]="Ballour",["dkp"]=988},
    {["name"]="Bigbootyhoho",["dkp"]=763},
    {["name"]="Blanebites",["dkp"]=129},
    {["name"]="Bruhtato",["dkp"]=400},
    {["name"]="Bubblè",["dkp"]=777},
    {["name"]="Bugaboom",["dkp"]=355},
    {["name"]="Buldur",["dkp"]=0},
    {["name"]="Bunsoffury",["dkp"]=210},
    {["name"]="Bádtothebow",["dkp"]=830},
    {["name"]="Calixta",["dkp"]=355},
    {["name"]="Captnutsack",["dkp"]=101},
    {["name"]="Capybara",["dkp"]=531},
    {["name"]="Celestaes",["dkp"]=565},
    {["name"]="Cenarios",["dkp"]=0},
    {["name"]="Chaintoker",["dkp"]=100},
    {["name"]="Cheeza",["dkp"]=110},
    {["name"]="Chipgizmo",["dkp"]=362},
    {["name"]="Claireamy",["dkp"]=0},
    {["name"]="Coldjuice",["dkp"]=222},
    {["name"]="Corseau",["dkp"]=275},
    {["name"]="Crazymarbles",["dkp"]=214},
    {["name"]="Curseberry",["dkp"]=72},
    {["name"]="Cyndr",["dkp"]=609},
    {["name"]="Cyskul",["dkp"]=628},
    {["name"]="Dalia",["dkp"]=808},
    {["name"]="Danatelo",["dkp"]=20},
    {["name"]="Dasmook",["dkp"]=306},
    {["name"]="Deathfrenzy",["dkp"]=504},
    {["name"]="Deeprider",["dkp"]=255},
    {["name"]="Dolamroth",["dkp"]=183},
    {["name"]="Drrl",["dkp"]=430},
    {["name"]="Dwindle",["dkp"]=780},
    {["name"]="Edgyboi",["dkp"]=360},
    {["name"]="Ellara",["dkp"]=225},
    {["name"]="Emmyy",["dkp"]=638},
    {["name"]="Eolith",["dkp"]=1505},
    {["name"]="Erectdwarf",["dkp"]=0},
    {["name"]="Evangelina",["dkp"]=718},
    {["name"]="Fawntine",["dkp"]=662},
    {["name"]="Finrir",["dkp"]=192},
    {["name"]="Finryr",["dkp"]=347},
    {["name"]="Fiz",["dkp"]=0},
    {["name"]="Flatulent",["dkp"]=822},
    {["name"]="Forerunner",["dkp"]=376},
    {["name"]="Fradge",["dkp"]=1038},
    {["name"]="Galagus",["dkp"]=961},
    {["name"]="Gartog",["dkp"]=349},
    {["name"]="Getcrit",["dkp"]=236},
    {["name"]="Ghettonaga",["dkp"]=100},
    {["name"]="Girlslayer",["dkp"]=460},
    {["name"]="Gneissguy",["dkp"]=417},
    {["name"]="Gnomenuts",["dkp"]=100},
    {["name"]="Goobimus",["dkp"]=443},
    {["name"]="Goossepoop",["dkp"]=0},
    {["name"]="Gorthaurr",["dkp"]=0},
    {["name"]="Gregord",["dkp"]=0},
    {["name"]="Grymmlock",["dkp"]=443},
    {["name"]="Hazie",["dkp"]=99},
    {["name"]="Healsonweelz",["dkp"]=100},
    {["name"]="Hew",["dkp"]=170},
    {["name"]="Hititnquitit",["dkp"]=89},
    {["name"]="Holychaos",["dkp"]=0},
    {["name"]="Holycritpal",["dkp"]=605},
    {["name"]="Holyfingerer",["dkp"]=55},
    {["name"]="Honeypot",["dkp"]=493},
    {["name"]="Hotdogbroth",["dkp"]=525},
    {["name"]="Huenolairc",["dkp"]=0},
    {["name"]="Ihurricanel",["dkp"]=588},
    {["name"]="Inebriated",["dkp"]=681},
    {["name"]="Inigma",["dkp"]=675},
    {["name"]="Insub",["dkp"]=648},
    {["name"]="Ithgar",["dkp"]=413},
    {["name"]="Itsbritneyb",["dkp"]=80},
    {["name"]="Jakemeoff",["dkp"]=337},
    {["name"]="Jeabus",["dkp"]=0},
    {["name"]="Jellytime",["dkp"]=0},
    {["name"]="Jumbognome",["dkp"]=300},
    {["name"]="Junglemain",["dkp"]=233},
    {["name"]="Kalijah",["dkp"]=199},
    {["name"]="Kalita",["dkp"]=636},
    {["name"]="Katherra",["dkp"]=0},
    {["name"]="Kharlin",["dkp"]=240},
    {["name"]="Killerdwarf",["dkp"]=0},
    {["name"]="Killionaire",["dkp"]=189},
    {["name"]="Kinter",["dkp"]=387},
    {["name"]="Kithala",["dkp"]=20},
    {["name"]="Kittysnake",["dkp"]=501},
    {["name"]="Knifeyspoony",["dkp"]=0},
    {["name"]="Kuckuck",["dkp"]=130},
    {["name"]="Laird",["dkp"]=82},
    {["name"]="Landlubbers",["dkp"]=253},
    {["name"]="Lawduk",["dkp"]=544},
    {["name"]="Lemonz",["dkp"]=153},
    {["name"]="Limeybeard",["dkp"]=120},
    {["name"]="Lindo",["dkp"]=863},
    {["name"]="Littledubs",["dkp"]=179},
    {["name"]="Littleshiv",["dkp"]=409},
    {["name"]="Lixx",["dkp"]=0},
    {["name"]="Luckerdawg",["dkp"]=510},
    {["name"]="Lööpsbröther",["dkp"]=0},
    {["name"]="Madmartagen",["dkp"]=456},
    {["name"]="Mallix",["dkp"]=632},
    {["name"]="Mariku",["dkp"]=322},
    {["name"]="Maryjohanna",["dkp"]=291},
    {["name"]="Maryse",["dkp"]=0},
    {["name"]="Mcstaberson",["dkp"]=641},
    {["name"]="Mihai",["dkp"]=297},
    {["name"]="Minifridge",["dkp"]=0},
    {["name"]="Moldyrag",["dkp"]=240},
    {["name"]="Mongous",["dkp"]=1178},
    {["name"]="Moonblazer",["dkp"]=191},
    {["name"]="Morphintyme",["dkp"]=921},
    {["name"]="Mozzarella",["dkp"]=489},
    {["name"]="Mujinn",["dkp"]=380},
    {["name"]="Mystile",["dkp"]=629},
    {["name"]="Natgeo",["dkp"]=160},
    {["name"]="Neckbeardo",["dkp"]=525},
    {["name"]="Neekio",["dkp"]=779},
    {["name"]="Neonlight",["dkp"]=130},
    {["name"]="Neotemplar",["dkp"]=0},
    {["name"]="Nightshelf",["dkp"]=229},
    {["name"]="Nubslayer",["dkp"]=146},
    {["name"]="Odin",["dkp"]=884},
    {["name"]="Oldmanmike",["dkp"]=110},
    {["name"]="Ones",["dkp"]=678},
    {["name"]="Oragan",["dkp"]=202},
    {["name"]="Oxford",["dkp"]=800},
    {["name"]="Pamplemousse",["dkp"]=112},
    {["name"]="Papasquach",["dkp"]=954},
    {["name"]="Partywolf",["dkp"]=100},
    {["name"]="Phasetwoscum",["dkp"]=152},
    {["name"]="Philonious",["dkp"]=806},
    {["name"]="Priesticuffs",["dkp"]=432},
    {["name"]="Primera",["dkp"]=739},
    {["name"]="Puffhead",["dkp"]=390},
    {["name"]="Puffypoose",["dkp"]=130},
    {["name"]="Qew",["dkp"]=138},
    {["name"]="Raspütin",["dkp"]=241},
    {["name"]="Regaskogena",["dkp"]=60},
    {["name"]="Reina",["dkp"]=642},
    {["name"]="Retkin",["dkp"]=681},
    {["name"]="Rez",["dkp"]=572},
    {["name"]="Rollnfatties",["dkp"]=71},
    {["name"]="Savos",["dkp"]=308},
    {["name"]="Schnazzy",["dkp"]=321},
    {["name"]="Scudd",["dkp"]=485},
    {["name"]="Shadowheals",["dkp"]=280},
    {["name"]="Shinynickels",["dkp"]=294},
    {["name"]="Shixx",["dkp"]=0},
    {["name"]="Sicarrio",["dkp"]=0},
    {["name"]="Sjada",["dkp"]=20},
    {["name"]="Slipperyjohn",["dkp"]=504},
    {["name"]="Snaildaddy",["dkp"]=522},
    {["name"]="Sneakattac",["dkp"]=85},
    {["name"]="Solana",["dkp"]=170},
    {["name"]="Solidsix",["dkp"]=401},
    {["name"]="Solten",["dkp"]=0},
    {["name"]="Sparklenips",["dkp"]=238},
    {["name"]="Spellbender",["dkp"]=840},
    {["name"]="Sprocket",["dkp"]=20},
    {["name"]="Squach",["dkp"]=208},
    {["name"]="Squidprophet",["dkp"]=325},
    {["name"]="Sretsam",["dkp"]=123},
    {["name"]="Stellâ",["dkp"]=544},
    {["name"]="Stikyiki",["dkp"]=1268},
    {["name"]="Stitchess",["dkp"]=522},
    {["name"]="Stoleurbike",["dkp"]=0},
    {["name"]="Straton",["dkp"]=151},
    {["name"]="Suprarz",["dkp"]=337},
    {["name"]="Talisker",["dkp"]=165},
    {["name"]="Tankdaddy",["dkp"]=243},
    {["name"]="Thelora",["dkp"]=275},
    {["name"]="Thenight",["dkp"]=338},
    {["name"]="Thepurple",["dkp"]=870},
    {["name"]="Tokentoken",["dkp"]=452},
    {["name"]="Trickster",["dkp"]=330},
    {["name"]="Tripodd",["dkp"]=30},
    {["name"]="Ttoken",["dkp"]=292},
    {["name"]="Tuggernuts",["dkp"]=250},
    {["name"]="Tuggspeedman",["dkp"]=0},
    {["name"]="Turbodeeps",["dkp"]=359},
    {["name"]="Turbohealz",["dkp"]=350},
    {["name"]="Ugro",["dkp"]=459},
    {["name"]="Urkh",["dkp"]=255},
    {["name"]="Varix",["dkp"]=535},
    {["name"]="Vehicle",["dkp"]=404},
    {["name"]="Veriandra",["dkp"]=471},
    {["name"]="Wahcha",["dkp"]=465},
    {["name"]="Walterpayton",["dkp"]=426},
    {["name"]="Weapoñ",["dkp"]=290},
    {["name"]="Webroinacint",["dkp"]=0},
    {["name"]="Wernstrum",["dkp"]=431},
    {["name"]="Winancy",["dkp"]=298},
    {["name"]="Xamina",["dkp"]=382},
    {["name"]="Xyen",["dkp"]=525},
    {["name"]="Zeeksa",["dkp"]=114},
    {["name"]="Ziggi",["dkp"]=149},
    {["name"]="Zukohere",["dkp"]=670},
}


local dkpDBDefaults = {
    profile = {
        currentDB = 'Molten Core',
        members = {},
        lastEdit = {},
        history = {
            all = {}
        },
    }
}

function DKP:InitDKPDB()
    Util:Debug('DKPDB init');
    core.DKP.db = LibStub("AceDB-3.0"):New("pdkp_dkpHistory", dkpDBDefaults, true)
    dkpDB = core.DKP.db.profile
    DKP.dkpDB = dkpDB;

    print('Current raid DKP shown: ', dkpDB.currentDB);
end

--[[
--
--     HISTORY IDEA:
--  Keep a generalized History object in the database, which houses all of the DKP history changes.
--  Give that DKP object a Unique ID, whatever members are being edited using that object, add the object ID to their
--  Personal "History" table.
--
--  HistoryDB -> History -> Array of Object details: [UID] -> Details
--  Members -> Members -> History -> Array of UUID's -> ID1, ID2, ID67
--  This would make it a lot easier to merge the tables because you would be able to tell if an edit was missing from
--  one or the other! Also, keep a list of "Deleted" entries, so that if list 1 is more up to date, and deletes an entry
--  than list 2 still has that entry, list 2 knows to delete that entry as well.
 ]]

-- cheaty way to update dkp via the boss kill event.
function DKP:BossKill(charObj)

    local name = charObj.name

    if Guild:IsMember(name) == false then return end;

    local dDate, tTime, server_time, datetime = Util:GetDateTimes()
    local boss = Raid.bossIDS[Raid.recentBossKillID];
    local raid = Raid:GetCurrentRaid()

    local dkpChangeText = Util:FormatFontTextColor(success, 10 .. ' DKP')
    local historyText = raid .. ' - ' .. boss;
    historyText = Util:FormatFontTextColor(success, historyText)

    local historyEntry = {
        ['text'] = historyText,
        ['reason'] = 'Boss Kill',
        ['bossKill'] = boss,
        ['raid'] = raid,
        ['dkpChange'] = pdkp_boss_kill_dkp,
        ['dkpChangeText'] = dkpChangeText,
        ['officer'] = Util:GetMyNameColored(),
        ['item']= nil,
        ['date']= dDate,
        ['time']=tTime,
        ['serverTime']=server_time,
        ['datetime']=datetime
    }

    if not dkpDB.history[name] then
--        table.insert(dkpDB.history, name);
        dkpDB.history[name] = {};
    end

    table.insert(dkpDB.history[name], historyEntry);

    DKP:Add(name, pdkp_boss_kill_dkp);

    GUI:UpdateEasyStats()
    -- Update the slider max (if needed)
    GUI:UpdateDKPSliderMax();
    -- Re-run the table filters.

    DKP:UpdateEntryRaidDkpTotal(raid, name, pdkp_boss_kill_dkp);

    if charObj.bName then
        local dkpText = _G[charObj.bName .. '_col3'];
        dkpText:SetText(charObj.dkpTotal);
    end
end

function DKP:ConfirmChange()
    local dkpChange = GUI.pdkp_dkp_amount_box:GetNumber();
    if dkpChange == 0 then return end; -- Don't need to change anything.

    if dkpChange > 0 then
        dkpChange = Util:FormatFontTextColor(Util.success, dkpChange)
    else
        dkpChange = Util:FormatFontTextColor(Util.warning, dkpChange)
    end

    local text = ''
    local chars = {};

    for _, charObj in pairs(GUI.selected) do
        if charObj.name then
           table.insert(chars, charObj)
        end
    end

    local function compare(a,b) return a.class < b.class end

    table.sort(chars, compare)

    for i=1, #chars do
        local char = chars[i];
        text = text..char['formattedName'];
        if i < #chars then text = text.. ', ' end
    end

    local titleText = 'Are you sure you\'d like to give '..dkpChange..' DKP to the following players: \n \n'..text

    StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].text = titleText
    StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].data = chars;
    StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].charNames = text
    StaticPopup_Show('PDKP_CONFIRM_DKP_CHANGE')
end

function DKP:UpdateEntries()
    local dkpChange = GUI.pdkp_dkp_amount_box:GetNumber();
    if dkpChange == 0 then return end; -- Don't need to change anything.

    local dDate, tTime, server_time, datetime = Util:GetDateTimes()

    local reasonDrop = GUI.reasonDropdown
    local dropdowns = GUI.adjustDropdowns

    local reason = reasonDrop.text:GetText()
    local raid, boss, historyText, dkpChangeText;

    local reasonVal = reasonDrop:GetValue();

    if reasonVal >= 1 and reasonVal <= 5 then
        raid = dropdowns[2].text:GetText();
        if reasonVal >= 1 and reasonVal <= 3 or reasonVal == 5 then -- Ontime, Signup, Benched, Unexcused Absence
            historyText = raid .. ' - ' .. reason;
        end

        if reasonVal == 4 then
            boss = dropdowns[3].text:GetText();
            historyText = raid .. ' - ' .. boss;
        end
    elseif reasonVal == 6 then -- item Win
        historyText = 'Item Win -';
    elseif reasonVal == 7 then -- Other selected
        local otherBox = getglobal('pdkp_other_entry_box')
        historyText = 'Other - ' .. otherBox:GetText();
    end

    if dkpChange > 0 then
        dkpChangeText = Util:FormatFontTextColor(success, dkpChange .. ' DKP')
        historyText = Util:FormatFontTextColor(success, historyText)
    elseif dkpChange < 0 then
        dkpChangeText = Util:FormatFontTextColor(warning, dkpChange .. ' DKP')
        historyText = Util:FormatFontTextColor(warning, historyText)
    end

    if reasonVal == 6 then -- item win
        local buttonText = _G['pdkp_item_link_text']
        historyText = historyText .. buttonText:GetText()
    end

    if raid == nil then
        raid = DKP.dkpDB.currentDB
        print('No raid found, setting raid to '.. raid)
    end

    local charObjs = StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].data -- Grab the data from our popup.
    local charNames = StaticPopupDialogs['PDKP_CONFIRM_DKP_CHANGE'].charNames -- The char name string.

    local historyEntry = {
        ['id']=server_time,
        ['text'] = historyText,
        ['reason'] = reason,
        ['bossKill'] = boss,
        ['raid'] = raid,
        ['dkpChange'] = dkpChange,
        ['dkpChangeText'] = dkpChangeText,
        ['officer'] = Util:GetMyNameColored(),
        ['item']= nil,
        ['date']= dDate,
        ['time']=tTime,
        ['serverTime']=server_time,
        ['datetime']=datetime,
        ['names']=charNames
    }

    for i=1, #charObjs do
        local char = charObjs[i]
        local name = char['name'];
        local member = dkpDB.members[name]
        if member.entries == nil then member.entries = {} end
        table.insert(member.entries, server_time)

        -- Determine if we're adding or subtracting
        if dkpChange > 0 then char.dkpTotal = DKP:Add(char.name, dkpChange);
        elseif dkpChange < 0 then char.dkpTotal = DKP:Subtract(char.name, dkpChange);
        end

        -- Now update the visual text
        if char.bName then
            local dkpText = _G[char.bName .. '_col3'];
            dkpText:SetText(char.dkpTotal);
        end

        DKP:UpdateEntryRaidDkpTotal(raid, name, dkpChange);
    end

    dkpDB.history['all'][server_time] = historyEntry;
    dkpDB.lastEdit = server_time

    GUI:UpdateEasyStats()

    -- Update the slider max (if needed)
    GUI:UpdateDKPSliderMax();
    -- Re-run the table filters.
    pdkp_dkp_table_filter()

    Guild:UpdateBankNote(server_time)
    DKP.bankID = server_time

    GUI.pdkp_dkp_amount_box:SetText('');
end

function DKP:GetLastEdit()
    return dkpDB.lastEdit
end

function DKP:GetCurrentDB()
    return dkpDB.currentDB
end

function DKP:UpdateEntryRaidDkpTotal(raid, name, dkpChange)
    if dkpChange == 0 or Util:IsEmpty(name) then return end;
    if raid == 'Onyxia\'s Lair' then raid = 'Molten Core' end
    if raid == nil then raid = dkpDB.currentDB; end

    local entry = dkpDB.members[name];
    entry[raid] = entry[raid] or 0;

    entry[raid] = entry[raid] + dkpChange;
    if entry[raid] < 0 then entry[raid] = 0 end
end

function DKP:ChangeDKPSheets(raid)
    if raid == 'Onyxia\'s Lair' then raid = 'Molten Core'; end

    for key, name in ipairs(DKP:GetMembers()) do
        dkpDB.members[name].dkpTotal = dkpDB.members[name][raid];
    end
    dkpDB.currentDB = raid;

    PDKP:BuildAllData()
    GUI:GetTableDisplayData()
    pdkp_dkp_scrollbar_Update()

    if GUI:GetSelectedCount() > 0 then
        GUI:ShowSelectedHistory(GUI.selected[1])
    else
        GUI:ShowSelectedHistory(nil)
    end

--    GUI:ShowSelectedHistory(charObj)

    print('Showing ' .. Util:FormatFontTextColor(warning, raid) .. ' DKP');
end

function DKP:SyncWithGuild()
    Util:Debug('Syncing Guild Data...');
    local guildMembers = Guild:GetMembers();
    local dkpMembers = DKP:GetMembers();
    for i=1, #guildMembers do
        local gMember = guildMembers[i];
        if not dkpMembers[gMember.name] then -- Add a new entry to the database.
            DKP:NewEntry(gMember.name)
        end
    end
end

function DKP:Add(name, dkp)
    dkpDB.members[name].dkpTotal = dkpDB.members[name].dkpTotal + dkp;
    return dkpDB.members[name].dkpTotal;
end

function DKP:Subtract(name, dkp)
    local newTotal = dkpDB.members[name].dkpTotal + dkp; -- Add the negative number.
    if newTotal < 0 then newTotal = 0 end-- It shouldn't be possible for anyone to go negative in this system.
    dkpDB.members[name].dkpTotal = newTotal;
    return dkpDB.members[name].dkpTotal;
end

function DKP:NewEntry(name)
    if Util:IsEmpty(name) then return end;

    local dkpEntry = dkpDB.members[name];

    if dkpEntry then -- Entry already exists!
        Util:Debug("This entry already exists!!")
    else
        Util:Debug("Adding new DKP entry for " .. name)
        table.insert(dkpDB.members, name)
        dkpDB.members[name] = {
            dkpTotal = 0;
            ['Molten Core'] = 0,
            ['Blackwing Lair'] = 0,
        }
    end
end

function DKP:GetPlayerDKP(name)
    local player = dkpDB.members[name]
    if player ~= nil then return player.dkpTotal end
    return 0
end

function DKP:ResetDB()
    core.DKP.db:ResetDB(nil)
end

function DKP:GetDB()
    return dkpDB;
end

function DKP:GetMembers()
    return dkpDB.members;
end

function DKP:GetMemberCount()
    return table.getn(dkpDB.members);
end

function DKP:GetHighestDKP()
    local maxDKP = 0;
    for key, charObj in pairs(DKP:GetMembers()) do
        if charObj.dkpTotal then
            if charObj.dkpTotal > maxDKP then
                if Guild:IsMember(key) then maxDKP = charObj.dkpTotal end
            end
        end
    end

    if maxDKP == 0 and Defaults.debug then return 50 end;
    return maxDKP;
end

function DKP:ImportMonolithData()
    local mono = MonolithData
    local dkp = dkpDB.members
--    local g = Guild.GuildDB.members

    for key,m in pairs(mono) do
        local name = m['name']
        if dkp[name] ~= nil then
            dkp[name]['dkpTotal'] = m['dkp']
            dkp[name]['Molten Core']=m['dkp']
--            dkpDB.members[name].dkpTotal = mono['dkp']
--            dkpDB.members[name]['Molten Core'] = mono['dkp']
        end
    end
    print('Finished Import data')
        --    for i=0, #mono do
--    end
end



-- player, class, DKP, previousDKP, lifetimeGained, lifetimeSpent

