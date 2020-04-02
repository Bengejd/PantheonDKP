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
local Comms = core.Comms;


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
    {["name"]="Acehart",["dkp"]=150},
    {["name"]="Adjora",["dkp"]=316},
    {["name"]="Advanty",["dkp"]=466},
    {["name"]="Aeropress",["dkp"]=0},
    {["name"]="Aku",["dkp"]=697},
    {["name"]="Angelyheth",["dkp"]=169},
    {["name"]="Apolyne",["dkp"]=378},
    {["name"]="Arkleis",["dkp"]=295},
    {["name"]="Artorion",["dkp"]=118},
    {["name"]="Astlan",["dkp"]=360},
    {["name"]="Athico",["dkp"]=548},
    {["name"]="Awwswitch",["dkp"]=0},
    {["name"]="Ballour",["dkp"]=1208},
    {["name"]="Bigbootyhoho",["dkp"]=528},
    {["name"]="Blanebites",["dkp"]=355},
    {["name"]="Bojack",["dkp"]=0},
    {["name"]="Bruhtato",["dkp"]=400},
    {["name"]="Bubblè",["dkp"]=1057},
    {["name"]="Bugaboom",["dkp"]=735},
    {["name"]="Buldur",["dkp"]=0},
    {["name"]="Bunsoffury",["dkp"]=210},
    {["name"]="Bádtothebow",["dkp"]=470},
    {["name"]="Calixta",["dkp"]=635},
    {["name"]="Captnutsack",["dkp"]=369},
    {["name"]="Capybara",["dkp"]=531},
    {["name"]="Celestaes",["dkp"]=414},
    {["name"]="Cenarios",["dkp"]=0},
    {["name"]="Chaintoker",["dkp"]=100},
    {["name"]="Cheeza",["dkp"]=110},
    {["name"]="Chipgizmo",["dkp"]=502},
    {["name"]="Chutter",["dkp"]=140},
    {["name"]="Claireamy",["dkp"]=0},
    {["name"]="Coldjuice",["dkp"]=222},
    {["name"]="Coneofcool",["dkp"]=186},
    {["name"]="Corseau",["dkp"]=275},
    {["name"]="Cptncold",["dkp"]=194},
    {["name"]="Crazymarbles",["dkp"]=214},
    {["name"]="Curseberry",["dkp"]=72},
    {["name"]="Cyndr",["dkp"]=609},
    {["name"]="Cyskul",["dkp"]=888},
    {["name"]="Dalia",["dkp"]=1158},
    {["name"]="Danatelo",["dkp"]=166},
    {["name"]="Dasmook",["dkp"]=306},
    {["name"]="Deathfrenzy",["dkp"]=504},
    {["name"]="Deeprider",["dkp"]=255},
    {["name"]="Dolamroth",["dkp"]=283},
    {["name"]="Drrl",["dkp"]=430},
    {["name"]="Dwindle",["dkp"]=780},
    {["name"]="Edgyboi",["dkp"]=470},
    {["name"]="Ellara",["dkp"]=225},
    {["name"]="Emmyy",["dkp"]=444},
    {["name"]="Eolith",["dkp"]=948},
    {["name"]="Erectdwarf",["dkp"]=0},
    {["name"]="Evangelina",["dkp"]=499},
    {["name"]="Fardon",["dkp"]=0},
    {["name"]="Fawntine",["dkp"]=531},
    {["name"]="Finrir",["dkp"]=246},
    {["name"]="Finryr",["dkp"]=347},
    {["name"]="Fiz",["dkp"]=0},
    {["name"]="Flatulent",["dkp"]=318},
    {["name"]="Forerunner",["dkp"]=434},
    {["name"]="Fradge",["dkp"]=1038},
    {["name"]="Galagus",["dkp"]=1221},
    {["name"]="Galeb",["dkp"]=10},
    {["name"]="Gartog",["dkp"]=379},
    {["name"]="Getcrit",["dkp"]=221},
    {["name"]="Ghettonaga",["dkp"]=100},
    {["name"]="Girlslayer",["dkp"]=590},
    {["name"]="Gneissguy",["dkp"]=303},
    {["name"]="Gnomenuts",["dkp"]=100},
    {["name"]="Goobimus",["dkp"]=603},
    {["name"]="Goossepoop",["dkp"]=0},
    {["name"]="Gorthaurr",["dkp"]=50},
    {["name"]="Gregord",["dkp"]=0},
    {["name"]="Grymmlock",["dkp"]=563},
    {["name"]="Hamickle",["dkp"]=95},
    {["name"]="Hazie",["dkp"]=99},
    {["name"]="Healsonweelz",["dkp"]=100},
    {["name"]="Hew",["dkp"]=103},
    {["name"]="Hititnquitit",["dkp"]=89},
    {["name"]="Holychaos",["dkp"]=0},
    {["name"]="Holycritpal",["dkp"]=605},
    {["name"]="Holyfingerer",["dkp"]=224},
    {["name"]="Honeypot",["dkp"]=773},
    {["name"]="Hotdogbroth",["dkp"]=805},
    {["name"]="Huenolairc",["dkp"]=0},
    {["name"]="Ihurricanel",["dkp"]=498},
    {["name"]="Inebriated",["dkp"]=761},
    {["name"]="Inigma",["dkp"]=494},
    {["name"]="Insub",["dkp"]=928},
    {["name"]="Iszell",["dkp"]=270},
    {["name"]="Ithgar",["dkp"]=633},
    {["name"]="Itsbritneyb",["dkp"]=380},
    {["name"]="Jakemeoff",["dkp"]=477},
    {["name"]="Jeabus",["dkp"]=0},
    {["name"]="Jeffry",["dkp"]=58},
    {["name"]="Jellytime",["dkp"]=20},
    {["name"]="Joreid",["dkp"]=176},
    {["name"]="Jumbognome",["dkp"]=300},
    {["name"]="Junglemain",["dkp"]=233},
    {["name"]="Kalijah",["dkp"]=199},
    {["name"]="Kalita",["dkp"]=825},
    {["name"]="Katherra",["dkp"]=0},
    {["name"]="Kharlin",["dkp"]=240},
    {["name"]="Killerdwarf",["dkp"]=0},
    {["name"]="Killionaire",["dkp"]=189},
    {["name"]="Kinter",["dkp"]=293},
    {["name"]="Kithala",["dkp"]=20},
    {["name"]="Kittysnake",["dkp"]=410},
    {["name"]="Knifeyspoony",["dkp"]=0},
    {["name"]="Knittie",["dkp"]=163},
    {["name"]="Kuckuck",["dkp"]=130},
    {["name"]="Laird",["dkp"]=135},
    {["name"]="Landlubbers",["dkp"]=393},
    {["name"]="Lawduk",["dkp"]=744},
    {["name"]="Lemonz",["dkp"]=153},
    {["name"]="Leovold",["dkp"]=120},
    {["name"]="Limeybeard",["dkp"]=120},
    {["name"]="Lindo",["dkp"]=1103},
    {["name"]="Littledubs",["dkp"]=579},
    {["name"]="Littleshiv",["dkp"]=409},
    {["name"]="Lixx",["dkp"]=0},
    {["name"]="Luckerdawg",["dkp"]=450},
    {["name"]="Lööpsbröther",["dkp"]=0},
    {["name"]="Madmartagen",["dkp"]=716},
    {["name"]="Maebelle",["dkp"]=0},
    {["name"]="Mallix",["dkp"]=632},
    {["name"]="Mariku",["dkp"]=431},
    {["name"]="Maryjohanna",["dkp"]=641},
    {["name"]="Maryse",["dkp"]=0},
    {["name"]="Mcstaberson",["dkp"]=701},
    {["name"]="Mihai",["dkp"]=427},
    {["name"]="Minifridge",["dkp"]=0},
    {["name"]="Moldyrag",["dkp"]=240},
    {["name"]="Mongous",["dkp"]=1458},
    {["name"]="Moonblazer",["dkp"]=191},
    {["name"]="Morphintyme",["dkp"]=406},
    {["name"]="Mozzarella",["dkp"]=449},
    {["name"]="Mujinn",["dkp"]=650},
    {["name"]="Mystile",["dkp"]=604},
    {["name"]="Natgeo",["dkp"]=160},
    {["name"]="Neckbeardo",["dkp"]=795},
    {["name"]="Neekio",["dkp"]=1049},
    {["name"]="Neonlight",["dkp"]=130},
    {["name"]="Neotemplar",["dkp"]=0},
    {["name"]="Nightshelf",["dkp"]=416},
    {["name"]="Nubslayer",["dkp"]=146},
    {["name"]="Odin",["dkp"]=672},
    {["name"]="Oldmanmike",["dkp"]=110},
    {["name"]="Ones",["dkp"]=870},
    {["name"]="Oragan",["dkp"]=402},
    {["name"]="Oxford",["dkp"]=1260},
    {["name"]="Pamplemousse",["dkp"]=112},
    {["name"]="Pantheonbank",["dkp"]=0},
    {["name"]="Papasquach",["dkp"]=974},
    {["name"]="Partywolf",["dkp"]=100},
    {["name"]="Phasetwoscum",["dkp"]=212},
    {["name"]="Philonious",["dkp"]=806},
    {["name"]="Pootootwo",["dkp"]=200},
    {["name"]="Priesticuffs",["dkp"]=572},
    {["name"]="Primera",["dkp"]=1019},
    {["name"]="Puffhead",["dkp"]=650},
    {["name"]="Puffypoose",["dkp"]=130},
    {["name"]="Qew",["dkp"]=343},
    {["name"]="Raspütin",["dkp"]=481},
    {["name"]="Regaskogena",["dkp"]=83},
    {["name"]="Reina",["dkp"]=942},
    {["name"]="Retkin",["dkp"]=595},
    {["name"]="Rez",["dkp"]=772},
    {["name"]="Rollnfatties",["dkp"]=71},
    {["name"]="Savos",["dkp"]=308},
    {["name"]="Schnazzy",["dkp"]=321},
    {["name"]="Scudd",["dkp"]=403},
    {["name"]="Shadowheals",["dkp"]=344},
    {["name"]="Shinynickels",["dkp"]=157},
    {["name"]="Shixx",["dkp"]=0},
    {["name"]="Sicarrio",["dkp"]=130},
    {["name"]="Sjada",["dkp"]=20},
    {["name"]="Slipperyjohn",["dkp"]=724},
    {["name"]="Snaildaddy",["dkp"]=722},
    {["name"]="Sneakattac",["dkp"]=160},
    {["name"]="Softfondle",["dkp"]=260},
    {["name"]="Solana",["dkp"]=170},
    {["name"]="Solidsix",["dkp"]=401},
    {["name"]="Solten",["dkp"]=0},
    {["name"]="Sparklenips",["dkp"]=518},
    {["name"]="Spellbender",["dkp"]=840},
    {["name"]="Sprocket",["dkp"]=20},
    {["name"]="Squach",["dkp"]=201},
    {["name"]="Squidprophet",["dkp"]=325},
    {["name"]="Sretsam",["dkp"]=239},
    {["name"]="Stellâ",["dkp"]=824},
    {["name"]="Stikyiki",["dkp"]=864},
    {["name"]="Stitchess",["dkp"]=496},
    {["name"]="Stoleurbike",["dkp"]=0},
    {["name"]="Straton",["dkp"]=281},
    {["name"]="Stridder",["dkp"]=150},
    {["name"]="Suprarz",["dkp"]=617},
    {["name"]="Talisker",["dkp"]=220},
    {["name"]="Tankdaddy",["dkp"]=243},
    {["name"]="Thelora",["dkp"]=275},
    {["name"]="Thenight",["dkp"]=608},
    {["name"]="Thepink",["dkp"]=115},
    {["name"]="Thepurple",["dkp"]=870},
    {["name"]="Tokentoken",["dkp"]=812},
    {["name"]="Toysfordots",["dkp"]=0},
    {["name"]="Trickster",["dkp"]=590},
    {["name"]="Tripodd",["dkp"]=40},
    {["name"]="Ttoken",["dkp"]=31},
    {["name"]="Tuggernuts",["dkp"]=250},
    {["name"]="Tuggspeedman",["dkp"]=0},
    {["name"]="Turboboom",["dkp"]=114},
    {["name"]="Turbodeeps",["dkp"]=263},
    {["name"]="Turbohealz",["dkp"]=380},
    {["name"]="Ugro",["dkp"]=704},
    {["name"]="Urkh",["dkp"]=255},
    {["name"]="Varix",["dkp"]=458},
    {["name"]="Vehicle",["dkp"]=404},
    {["name"]="Veltrix",["dkp"]=0},
    {["name"]="Veriandra",["dkp"]=731},
    {["name"]="Wahcha",["dkp"]=427},
    {["name"]="Walterpayton",["dkp"]=303},
    {["name"]="Weapoñ",["dkp"]=290},
    {["name"]="Webroinacint",["dkp"]=0},
    {["name"]="Wernstrum",["dkp"]=651},
    {["name"]="Winancy",["dkp"]=298},
    {["name"]="Xamina",["dkp"]=382},
    {["name"]="Xyen",["dkp"]=388},
    {["name"]="Zeeksa",["dkp"]=114},
    {["name"]="Ziggi",["dkp"]=149},
    {["name"]="Zukohere",["dkp"]=551},
}


local dkpDBDefaults = {
    profile = {
        currentDB = 'Molten Core',
        members = {},
        lastEdit = 0,
        history = {
            all = {},
            deleted = {}
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

function DKP:DeleteEntry(entry, noBroacast)
    local entryKey = entry['id']

    if dkpDB.history['deleted'][entryKey] then
        PDKP:Print("Already deleted entry")
        return
    end

    local changeAmount = entry['dkpChange']
    local raid = entry['raid']

    -- We have to inverse the amount (make negatives positives, and positives negatives).
    changeAmount = changeAmount * -1;

    local members = dkpDB.members

    for key, obj in pairs(members) do
        local entries = obj['entries']
        local entryIndex;
        if entries then -- Everyone that has history.
           for i=1, #entries do -- check to see if they have the entry.
               local memberEntryKey = entries[i]
               if memberEntryKey == entryKey then -- We found a match!
                   entryIndex = i
                   DKP:UpdateEntryRaidDkpTotal(raid, key, changeAmount);
               end
           end
        end
        if entryIndex ~= nil then entries[entryIndex] = nil end
    end

    dkpDB.history['all'][entryKey] = nil;
    table.insert(dkpDB.history['deleted'], entryKey)
    DKP:ChangeDKPSheets(raid, true)
    GUI:UpdateEasyStats();

    local _, _, server_time, _ = Util:GetDateTimes()
    dkpDB.lastEdit = server_time

    -- Update the slider max (if needed)
    GUI:UpdateDKPSliderMax();
    -- Re-run the table filters.
    pdkp_dkp_table_filter()

    Guild:UpdateBankNote(dkpDB.lastEdit)
    DKP.bankID = dkpDB.lastEdit

    if noBroacast == nil then
        Comms:SendCommsMessage('pdkpEntryDelete', PDKP:Serialize(entry), 'GUILD', nil, 'BULK')
    end
end

function DKP:UpdateEntries()
    local dkpChange = GUI.pdkp_dkp_amount_box:GetNumber();
    if dkpChange == 0 then return end; -- Don't need to change anything.

    local dDate, tTime, server_time, datetime = Util:GetDateTimes()

    local reasonDrop = GUI.reasonDropdown
    local dropdowns = GUI.adjustDropdowns

    local reason = reasonDrop.text:GetText()
    local raid, boss, historyText, dkpChangeText, itemText;

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
        historyText = 'Item Win - ';
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
        itemText = buttonText:GetText();
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
        ['dkpType']=nil,
        ['officer'] = Util:GetMyNameColored(),
        ['item']= itemText,
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

    Comms:SendGuildUpdate(historyEntry)
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

function DKP:ChangeDKPSheets(raid, noUpdate)
    if raid == 'Onyxia\'s Lair' then raid = 'Molten Core'; end

    for key, name in ipairs(DKP:GetMembers()) do
        dkpDB.members[name].dkpTotal = dkpDB.members[name][raid];
    end
    dkpDB.currentDB = raid;

    PDKP:BuildAllData()
    GUI:GetTableDisplayData()
    pdkp_dkp_scrollbar_Update()

    GUI:ClearSelected()

    print('PantheonDKP: Showing ' .. Util:FormatFontTextColor(warning, raid) .. ' DKP table');
end

function DKP:SyncWithGuild()
    Util:Debug('Syncing Guild Data...');
    local guildMembers = Guild:GetMembers();
    local dkpMembers = DKP:GetMembers();

    if #guildMembers + #dkpMembers == 0 then
        StaticPopup_Show('PDKP_RELOAD_UI')
    end

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
            ['entries']={},
            ['previousValues'] = {
                ['Molten Core'] = 0,
                ['Blackwing Lair'] = 0,
            }
        }
    end
end

function DKP:GetPlayerDKP(name)
    local player = dkpDB.members[name]
    if player ~= nil then return player.dkpTotal end
    return 0 -- fallback. We disregard these anyway.
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

function DKP:ValidateTables()
    local type = type

    local members = dkpDB.members;
    local history = dkpDB.history;
    local deleted = history.deleted;
    local all = history.all;

    local function compare(a,b)
        if a == nil and b == nil then return false
        elseif a == nil then return false
        elseif b == nil then return true
        else return a > b
        end
    end

    local function validateEntries(entries, name) -- Ensures that the entries are unique across the board.
        table.sort(entries, compare)
        local nonDuplicates = {}
        for key, value in pairs(entries) do -- remove the duplicates.
            if value ~= nil and value >= 1500000000 and value ~= entries[key + 1] then
                table.insert(nonDuplicates, value)
                for _, deletedEntry in pairs(deleted) do
                    if value == deletedEntry then
                        Util:Debug('Removing deleted entry ' .. value .. ' from ' .. name)
                        table.remove(nonDuplicates, key)
                    end
                end
            end
        end
--        print(name, ' had ', #entries - #nonDuplicates, ' duplicate or corrupt entries')
        return nonDuplicates;
    end

    local function validateDKP(name, member)
        local validBwlDKP = 0
        local validMcDKP = 0

        local mcDKP = member['Molten Core']
        local bwlDKP = member['Blackwing Lair']

        for i=1, #member['entries'] do
            local entryKey = member['entries'][i]
            local histEntry = all[entryKey]
            if histEntry ~= nil then
                local change = histEntry['dkpChange']
                if histEntry['raid'] == 'Blackwing Lair' then
                    validBwlDKP = validBwlDKP + change
                end
            end
        end
        if validBwlDKP ~= bwlDKP then
           print(name, ' validDKP: ', validBwlDKP, 'actual', bwlDKP)
        end
    end

    for key, member in pairs(members) do
        if type(key) == type('') then -- we have an object.
            local entries = member['entries']
            if entries then -- Make sure that the entries are unique.
                entries = validateEntries(entries, key)
                if #entries > 0 then
                    validateDKP(key, member)
                end
            end
        end
    end
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
        end
    end
    print('Finished Import data')
end