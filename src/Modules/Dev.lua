local _G = _G;
local _, core = ...;

local PDKP = core.PDKP

local Dev, Defaults, Util, Guild, Comms = PDKP:GetInst('Dev', 'Defaults', 'Util', 'Guild', 'Comms')

Dev.commands = {
    ['dev']=function() end,
    ['create_large_db']=function()
        Dev:CreateLargeTestDB()
    end,
    ['dev_database']=function()
        Dev:TestDatabase()
    end
}

function Dev:Print(...)
    local string = strjoin(" ", tostringall(...))
    if Defaults.development or Defaults.debug then
        PDKP:Print(Util:FormatTextColor(string, Util.info))
    end
end

function Dev:ClockSpeed(isEnd, funcName)
    if not isEnd then
        Dev.clockStartTime = time()
    end
    if isEnd then
        local total_time = time() - Dev.clockStartTime
        Util.start = nil
        Dev:Print(funcName, 'took', total_time, 'seconds to run')
    end
end

function Dev:HandleCommands(msg)
    if not Defaults.development then return end
    local cmd = PDKP:GetArgs(msg)

    if Dev.commands[cmd] then return Dev.commands[cmd]() end
end

function Dev:TestDatabase()
    Dev:Print('Testing Database')

    local db = PDKP.db;
    local testDB = db['testDB']

    Dev:ClockSpeed(false, 'EncodeTestDB')
    local testDataEncoded = Comms:DataEncoder(testDB)
    Dev:ClockSpeed(true, 'EncodeTestDB')

    PDKP.db['pugDB'] = testDataEncoded

    Dev:ClockSpeed(false, 'PDKP.db[\'pugDB\']')
    local testDataDecoded = Comms:DataDecoder(PDKP.db['pugDB'])
    Dev:ClockSpeed(true, 'PDKP.db[\'pugDB\']')

    print(type(testDataDecoded))

    for k, v in pairs(testDataDecoded['members']) do
        print(k, v)
    end
end

function Dev:CreateLargeTestDB()
    Dev:Print('Creating a large Test DB')

    local db = PDKP.db;
    local testDB = db['testDB']

    Dev:ClockSpeed(false, 'CreateLargeTestDB')

    local test_data = {
        ["members"] = {
            ["Banktopman"] = {
            },
            ["Cheezdisease"] = {
            },
            ["Corseau"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 337,
                    ["total"] = 347,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 216,
                    ["total"] = 226,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 457,
                    ["total"] = 517,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 804,
                    ["total"] = 814,
                    ["entries"] = {
                    },
                },
            },
            ["Makinfatsacs"] = {
            },
            ["Rez"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1005,
                    ["total"] = 1015,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 275,
                    ["total"] = 281,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 150,
                    ["total"] = 155,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1411,
                    ["total"] = 1421,
                    ["entries"] = {
                    },
                },
            },
            ["Hellboom"] = {
            },
            ["Sparkletiits"] = {
            },
            ["Holyfingerer"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 554,
                    ["total"] = 554,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Grymmlock"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 563,
                    ["total"] = 563,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Intarsia"] = {
            },
            ["Shinynickels"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1203,
                    ["total"] = 1213,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 207,
                    ["total"] = 217,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 742,
                    ["total"] = 747,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1122,
                    ["total"] = 1027,
                    ["entries"] = {
                    },
                },
            },
            ["Kindell"] = {
            },
            ["Prosechoe"] = {
            },
            ["Zaina"] = {
            },
            ["Porchrecon"] = {
            },
            ["Korseau"] = {
            },
            ["Littledubs"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1104,
                    ["total"] = 1114,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 871,
                    ["total"] = 881,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 599,
                    ["total"] = 659,
                    ["entries"] = {
                    },
                },
            },
            ["Ihurricanel"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1448,
                    ["total"] = 1458,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 341,
                    ["total"] = 351,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 158,
                    ["total"] = 148,
                    ["entries"] = {
                    },
                },
            },
            ["Nikosummons"] = {
            },
            ["Hammeretto"] = {
            },
            ["Logaen"] = {
            },
            ["Biggdam"] = {
            },
            ["Neonlight"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 130,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Tranquilam"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 196,
                    ["total"] = 206,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 618,
                    ["total"] = 628,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Sorrycaps"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Veriandra"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 878,
                    ["total"] = 883,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 139,
                    ["total"] = 145,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 863,
                    ["total"] = 873,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 555,
                    ["total"] = 565,
                    ["entries"] = {
                    },
                },
            },
            ["Tuggsummoner"] = {
            },
            ["Goatlawdy"] = {
            },
            ["Anklefreezer"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 128,
                    ["total"] = 138,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 373,
                    ["total"] = 383,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Taedrius"] = {
            },
            ["Mlady"] = {
            },
            ["Zeuk"] = {
            },
            ["Primea"] = {
            },
            ["Xerö"] = {
            },
            ["Clickbotthre"] = {
            },
            ["Xyen"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 676,
                    ["total"] = 338,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 408,
                    ["total"] = 414,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 818,
                    ["total"] = 823,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1284,
                    ["total"] = 1294,
                    ["entries"] = {
                    },
                },
            },
            ["Chipgizmo"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1170,
                    ["total"] = 1180,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 438,
                    ["total"] = 448,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 115,
                    ["total"] = 105,
                    ["entries"] = {
                    },
                },
            },
            ["Baglass"] = {
            },
            ["Qqmypewpew"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 447,
                    ["total"] = 457,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 84,
                    ["total"] = 89,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 242,
                    ["total"] = 252,
                    ["entries"] = {
                    },
                },
            },
            ["Edgyheals"] = {
            },
            ["Charlimurfee"] = {
            },
            ["Cömmünïsm"] = {
            },
            ["Needsummbody"] = {
            },
            ["Mystilé"] = {
            },
            ["Errorduk"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1662,
                    ["total"] = 1672,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1065,
                    ["total"] = 1135,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 520,
                    ["total"] = 580,
                    ["entries"] = {
                    },
                },
            },
            ["Wilocu"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1526,
                    ["total"] = 1536,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 169,
                    ["total"] = 179,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 334,
                    ["total"] = 344,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 306,
                    ["total"] = 316,
                    ["entries"] = {
                    },
                },
            },
            ["Bugadoom"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 2023,
                    ["total"] = 2033,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 934,
                    ["total"] = 944,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 233,
                    ["total"] = 238,
                    ["entries"] = {
                    },
                },
            },
            ["Shankmaster"] = {
            },
            ["Shvou"] = {
            },
            ["Notcool"] = {
            },
            ["Shuundip"] = {
            },
            ["Retlock"] = {
            },
            ["Hotbish"] = {
            },
            ["Squidproquo"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 562,
                    ["total"] = 572,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 12,
                    ["total"] = 18,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 229,
                    ["total"] = 239,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 433,
                    ["total"] = 443,
                    ["entries"] = {
                    },
                },
            },
            ["Warrihore"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 191,
                    ["total"] = 100,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 30,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
            },
            ["Crucifer"] = {
            },
            ["Azayll"] = {
            },
            ["Adelina"] = {
            },
            ["Puffhead"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 593,
                    ["total"] = 603,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = -42,
                    ["total"] = -36,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1600,
                    ["total"] = 1605,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1203,
                    ["total"] = 1213,
                    ["entries"] = {
                    },
                },
            },
            ["Bankerror"] = {
            },
            ["Walu"] = {
            },
            ["Falcone"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Angelyheth"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 579,
                    ["total"] = 599,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Flatulentt"] = {
            },
            ["Pööpbälls"] = {
            },
            ["Straton"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 266,
                    ["total"] = 286,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 290,
                    ["total"] = 300,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
            },
            ["Düümlaut"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Throatgoatt"] = {
            },
            ["Cognitive"] = {
            },
            ["Jakemeoof"] = {
            },
            ["Rickjamesbch"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Holyduk"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 61,
                    ["total"] = 61,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Reina"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 660,
                    ["total"] = 670,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 474,
                    ["total"] = 480,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 311,
                    ["total"] = 321,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1158,
                    ["total"] = 1168,
                    ["entries"] = {
                    },
                },
            },
            ["Boofedretau"] = {
            },
            ["Theplaid"] = {
            },
            ["Drunkhealer"] = {
            },
            ["Cheesedogs"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1270,
                    ["total"] = 1280,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1373,
                    ["total"] = 1379,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 514,
                    ["total"] = 519,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 820,
                    ["total"] = 830,
                    ["entries"] = {
                    },
                },
            },
            ["Draenmyballs"] = {
            },
            ["Fardon"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Cthemanager"] = {
            },
            ["Fistdacuff"] = {
            },
            ["Stellâ"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 440,
                    ["total"] = 445,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 72,
                    ["total"] = 78,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 591,
                    ["total"] = 591,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 521,
                    ["total"] = 531,
                    ["entries"] = {
                    },
                },
            },
            ["Gingervitïs"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 180,
                    ["total"] = 190,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 30,
                    ["total"] = 40,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Littlerocket"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1482,
                    ["total"] = 1492,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 632,
                    ["total"] = 642,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 244,
                    ["total"] = 234,
                    ["entries"] = {
                    },
                },
            },
            ["Mightyrage"] = {
            },
            ["Sahaquiel"] = {
            },
            ["Karatekitty"] = {
            },
            ["Knittie"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1048,
                    ["total"] = 1058,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 346,
                    ["total"] = 352,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                        1621569665, -- [4]
                        1621570325, -- [5]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 549,
                    ["total"] = 554,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 883,
                    ["total"] = 893,
                    ["entries"] = {
                    },
                },
            },
            ["Moonsparkles"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Zukohere"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 509,
                    ["total"] = 519,
                    ["entries"] = {
                        1602818633, -- [1]
                        1604025750, -- [2]
                        1604638648, -- [3]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                        1604984335, -- [1]
                    },
                    ["previousTotal"] = 1044,
                    ["total"] = 1044,
                    ["entries"] = {
                        1604637922, -- [1]
                        1604638630, -- [2]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 328,
                    ["total"] = 338,
                    ["entries"] = {
                        1602646246, -- [1]
                        1602646783, -- [2]
                        1602647342, -- [3]
                        1602647561, -- [4]
                        1602648170, -- [5]
                        1602649070, -- [6]
                        1602651479, -- [7]
                        1602653272, -- [8]
                        1602654269, -- [9]
                        1602654272, -- [10]
                        1602644454, -- [11]
                        1603249760, -- [12]
                        1603251228, -- [13]
                        1603251900, -- [14]
                        1603252698, -- [15]
                        1603252701, -- [16]
                        1603253230, -- [17]
                        1603255370, -- [18]
                        1603256642, -- [19]
                        1603256738, -- [20]
                        1603257291, -- [21]
                        1603258217, -- [22]
                        1603258221, -- [23]
                        1603862314, -- [24]
                    },
                },
            },
            ["Danzic"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1390,
                    ["total"] = 1400,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1080,
                    ["total"] = 1090,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 173,
                    ["total"] = 183,
                    ["entries"] = {
                    },
                },
            },
            ["Oldmanjerry"] = {
            },
            ["Owelikecheez"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1115,
                    ["total"] = 1125,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 564,
                    ["total"] = 570,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 413,
                    ["total"] = 423,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 641,
                    ["total"] = 651,
                    ["entries"] = {
                    },
                },
            },
            ["Bugabanker"] = {
            },
            ["Holdsstuff"] = {
            },
            ["Tyroanbigums"] = {
            },
            ["Rumpleminz"] = {
            },
            ["Magelawdy"] = {
            },
            ["Shnail"] = {
            },
            ["Kamariä"] = {
            },
            ["Shàdow"] = {
            },
            ["Rachelmae"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 414,
                    ["total"] = 424,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 21,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 122,
                    ["total"] = 127,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 382,
                    ["total"] = 392,
                    ["entries"] = {
                    },
                },
            },
            ["Gartog"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1388,
                    ["total"] = 1398,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1264,
                    ["total"] = 1274,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 326,
                    ["total"] = 316,
                    ["entries"] = {
                    },
                },
            },
            ["Dispelled"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 249,
                    ["total"] = 259,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 136,
                    ["total"] = 206,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Claytonbigsß"] = {
            },
            ["Flatbtmgirl"] = {
            },
            ["Crisane"] = {
            },
            ["Abnevillus"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 138,
                    ["total"] = 218,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Black Temple"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                        1622386680, -- [1]
                    },
                },
            },
            ["Flatulent"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 998,
                    ["total"] = 1008,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 26,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 573,
                    ["total"] = 578,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 889,
                    ["total"] = 959,
                    ["entries"] = {
                    },
                },
            },
            ["Michaell"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 295,
                    ["total"] = 305,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 255,
                    ["total"] = 265,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Rektin"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 597,
                    ["total"] = 607,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 410,
                    ["total"] = 416,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 156,
                    ["total"] = 78,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 503,
                    ["total"] = 513,
                    ["entries"] = {
                    },
                },
            },
            ["Edgyleaf"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Hekatah"] = {
            },
            ["Katrena"] = {
            },
            ["Toroshema"] = {
            },
            ["Sooya"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 174,
                    ["total"] = 194,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 351,
                    ["total"] = 361,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 62,
                    ["total"] = 72,
                    ["entries"] = {
                    },
                },
            },
            ["Autotosixty"] = {
            },
            ["Bugabam"] = {
            },
            ["Orrik"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 110,
                    ["total"] = 120,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 50,
                    ["total"] = 60,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
            },
            ["Xorms"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 500,
                    ["total"] = 510,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 265,
                    ["total"] = 275,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Mozzarella"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 2026,
                    ["total"] = 2036,
                    ["entries"] = {
                        1605840015, -- [1]
                        1605840115, -- [2]
                        1605841083, -- [3]
                        1605841697, -- [4]
                        1605841763, -- [5]
                        1605842752, -- [6]
                        1605842929, -- [7]
                        1605843325, -- [8]
                        1605843845, -- [9]
                        1607050045, -- [10]
                        1607050313, -- [11]
                        1607051280, -- [12]
                        1607051943, -- [13]
                        1607053101, -- [14]
                        1607053297, -- [15]
                        1607053691, -- [16]
                        1607054319, -- [17]
                        1608007692, -- [18]
                        1608007924, -- [19]
                        1608008900, -- [20]
                        1608009564, -- [21]
                        1608010677, -- [22]
                        1608010858, -- [23]
                        1608011302, -- [24]
                        1608011801, -- [25]
                        1608011835, -- [26]
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                        1607157259, -- [1]
                    },
                    ["previousTotal"] = 26,
                    ["total"] = 40,
                    ["entries"] = {
                        1607157239, -- [1]
                        1607157391, -- [2]
                        1607454997, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 460,
                    ["total"] = 470,
                    ["entries"] = {
                        1605674851, -- [1]
                        1605675108, -- [2]
                        1605678577, -- [3]
                        1606277074, -- [4]
                        1605675595, -- [5]
                        1605673875, -- [6]
                        1605676438, -- [7]
                        1605673210, -- [8]
                        1605679296, -- [9]
                        1605679391, -- [10]
                        1605678145, -- [11]
                        1605674337, -- [12]
                        1606278721, -- [13]
                        1606279167, -- [14]
                        1606279645, -- [15]
                        1606279918, -- [16]
                        1606280415, -- [17]
                        1606281330, -- [18]
                        1606284024, -- [19]
                        1606285737, -- [20]
                        1606283432, -- [21]
                        1606283906, -- [22]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1313,
                    ["total"] = 1323,
                    ["entries"] = {
                        1605845263, -- [1]
                        1605845590, -- [2]
                        1608013886, -- [3]
                        1608014291, -- [4]
                    },
                },
            },
            ["Josegamer"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 182,
                    ["total"] = 192,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 260,
                    ["total"] = 270,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 9,
                    ["entries"] = {
                    },
                },
            },
            ["Tylrswftmend"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1057,
                    ["total"] = 1067,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 494,
                    ["total"] = 504,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 830,
                    ["total"] = 820,
                    ["entries"] = {
                    },
                },
            },
            ["Kuu"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 77,
                    ["total"] = 87,
                    ["entries"] = {
                        1608007692, -- [1]
                        1608007924, -- [2]
                        1608008900, -- [3]
                        1608009003, -- [4]
                        1608009564, -- [5]
                        1608010677, -- [6]
                        1608010858, -- [7]
                        1608011302, -- [8]
                        1608011801, -- [9]
                        1608011835, -- [10]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Leyva"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1023,
                    ["total"] = 1033,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 21,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 442,
                    ["total"] = 452,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1006,
                    ["total"] = 1016,
                    ["entries"] = {
                    },
                },
            },
            ["Healsmee"] = {
            },
            ["Turboboom"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 347,
                    ["total"] = 353,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
            },
            ["Teholbeddict"] = {
            },
            ["Aseus"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Broadside"] = {
            },
            ["Laharl"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 331,
                    ["total"] = 341,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 263,
                    ["total"] = 273,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Jellytime"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 105,
                    ["total"] = 110,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 12,
                    ["total"] = 18,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 852,
                    ["total"] = 862,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 557,
                    ["total"] = 567,
                    ["entries"] = {
                    },
                },
            },
            ["Mujinn"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 360,
                    ["total"] = 370,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 960,
                    ["total"] = 970,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
            },
            ["Katania"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 895,
                    ["total"] = 905,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 422,
                    ["total"] = 428,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 390,
                    ["total"] = 395,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1564,
                    ["total"] = 1574,
                    ["entries"] = {
                    },
                },
            },
            ["Randalsavage"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 212,
                    ["total"] = 222,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 50,
                    ["total"] = 60,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 12,
                    ["total"] = 18,
                    ["entries"] = {
                    },
                },
            },
            ["Huntardation"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 549,
                    ["total"] = 599,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 324,
                    ["total"] = 334,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 40,
                    ["total"] = 30,
                    ["entries"] = {
                    },
                },
            },
            ["Renault"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 224,
                    ["total"] = 230,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 128,
                    ["total"] = 138,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 96,
                    ["total"] = 96,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Squabble"] = {
            },
            ["Thurfin"] = {
            },
            ["Jaquard"] = {
            },
            ["Coneofcool"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 401,
                    ["total"] = 411,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Eviee"] = {
            },
            ["Vorex"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                        1602822780, -- [1]
                    },
                    ["previousTotal"] = 173,
                    ["total"] = 183,
                    ["entries"] = {
                        1602542657, -- [1]
                        1602818607, -- [2]
                        1602819691, -- [3]
                        1602819948, -- [4]
                        1602820828, -- [5]
                        1602821394, -- [6]
                        1602822294, -- [7]
                        1602822473, -- [8]
                        1602822480, -- [9]
                        1602823235, -- [10]
                        1602823238, -- [11]
                        1602823319, -- [12]
                        1602542657, -- [13]
                        1602818607, -- [14]
                        1603479250, -- [15]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 214,
                    ["total"] = 224,
                    ["entries"] = {
                        1602221444, -- [1]
                        1602225055, -- [2]
                        1602225061, -- [3]
                        1602224083, -- [4]
                        1602221034, -- [5]
                        1602222114, -- [6]
                        1602220616, -- [7]
                        1602222889, -- [8]
                        1602222079, -- [9]
                        1602223706, -- [10]
                        1602222553, -- [11]
                        1602224478, -- [12]
                        1602825199, -- [13]
                        1602824722, -- [14]
                        1602827561, -- [15]
                        1602827831, -- [16]
                        1602826066, -- [17]
                        1602828630, -- [18]
                        1602827897, -- [19]
                        1602826365, -- [20]
                        1602829184, -- [21]
                        1602826665, -- [22]
                        1602825407, -- [23]
                        1602825080, -- [24]
                        1602829180, -- [25]
                        1602825946, -- [26]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
            },
            ["Tokentoken"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 24,
                    ["total"] = 30,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1900,
                    ["total"] = 1910,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 871,
                    ["total"] = 881,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 183,
                    ["total"] = 193,
                    ["entries"] = {
                    },
                },
            },
            ["Macson"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 332,
                    ["total"] = 342,
                    ["entries"] = {
                        1608007692, -- [1]
                        1608007924, -- [2]
                        1608008900, -- [3]
                        1608009564, -- [4]
                        1608010677, -- [5]
                        1608010858, -- [6]
                        1608011302, -- [7]
                        1608011801, -- [8]
                        1608011835, -- [9]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 190,
                    ["total"] = 195,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 26,
                    ["total"] = 40,
                    ["entries"] = {
                        1607157239, -- [1]
                        1607157391, -- [2]
                        1607454939, -- [3]
                    },
                },
            },
            ["Captnutsack"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1158,
                    ["total"] = 1168,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 31,
                    ["total"] = 37,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 413,
                    ["total"] = 418,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 903,
                    ["total"] = 913,
                    ["entries"] = {
                    },
                },
            },
            ["Thenight"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 308,
                    ["total"] = 318,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 21,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 967,
                    ["total"] = 977,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1617,
                    ["total"] = 1627,
                    ["entries"] = {
                    },
                },
            },
            ["Galeb"] = {
            },
            ["Gunnyhartman"] = {
            },
            ["Waui"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 90,
                    ["total"] = 45,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Beardthicco"] = {
            },
            ["Razledazle"] = {
            },
            ["Zebeulah"] = {
            },
            ["Justfortoday"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 243,
                    ["total"] = 253,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 512,
                    ["total"] = 522,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 323,
                    ["total"] = 313,
                    ["entries"] = {
                    },
                },
            },
            ["Drevlin"] = {
            },
            ["Forgoatsake"] = {
            },
            ["Málpractice"] = {
            },
            ["Roarkh"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 565,
                    ["total"] = 545,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 714,
                    ["total"] = 724,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Webroinacint"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 696,
                    ["total"] = 706,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 293,
                    ["total"] = 299,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 528,
                    ["total"] = 533,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1561,
                    ["total"] = 1571,
                    ["entries"] = {
                    },
                },
            },
            ["Rashootin"] = {
            },
            ["Getcrit"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 120,
                    ["total"] = 130,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                        1604984335, -- [1]
                    },
                    ["previousTotal"] = 568,
                    ["total"] = 568,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 95,
                    ["total"] = 85,
                    ["entries"] = {
                        1603855763, -- [1]
                        1603855764, -- [2]
                        1603855797, -- [3]
                        1603855762, -- [4]
                        1603855805, -- [5]
                    },
                },
            },
            ["Wafflefires"] = {
            },
            ["Jackolyn"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Clarg"] = {
            },
            ["Adonias"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 461,
                    ["total"] = 415,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 159,
                    ["total"] = 169,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Gorthaurr"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 50,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Pootwotoo"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 173,
                    ["total"] = 173,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Shorud"] = {
            },
            ["Leegankinz"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 131,
                    ["total"] = 141,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 199,
                    ["total"] = 209,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Ablunkin"] = {
                ["Gruul's Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                        1622385727, -- [1]
                        1622385784, -- [2]
                    },
                },
                ["Black Temple"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                        1622386874, -- [1]
                    },
                },
            },
            ["Helnar"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 378,
                    ["total"] = 388,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 480,
                    ["total"] = 490,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 85,
                    ["total"] = 95,
                    ["entries"] = {
                    },
                },
            },
            ["Kinter"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 205,
                    ["total"] = 184,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
            },
            ["Mujin"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
            },
            ["Joeyduk"] = {
            },
            ["Neufchâtel"] = {
            },
            ["Flatulhunt"] = {
            },
            ["Xxplosion"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 386,
                    ["total"] = 396,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 605,
                    ["total"] = 605,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 342,
                    ["total"] = 347,
                    ["entries"] = {
                        1608264505, -- [1]
                        1608265999, -- [2]
                        1608266660, -- [3]
                        1608267217, -- [4]
                        1608267540, -- [5]
                        1608268185, -- [6]
                        1608269569, -- [7]
                        1608272175, -- [8]
                        1608273303, -- [9]
                        1608274510, -- [10]
                        1608274513, -- [11]
                    },
                },
            },
            ["Dioscorides"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 329,
                    ["total"] = 339,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Ugrosmule"] = {
            },
            ["Kóbe"] = {
            },
            ["Tibi"] = {
            },
            ["Nottz"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Whisp"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 966,
                    ["total"] = 976,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1030,
                    ["total"] = 1040,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 729,
                    ["total"] = 719,
                    ["entries"] = {
                    },
                },
            },
            ["Gneissguy"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 714,
                    ["total"] = 724,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 573,
                    ["total"] = 579,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 624.5,
                    ["total"] = 634.5,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1139,
                    ["total"] = 1149,
                    ["entries"] = {
                    },
                },
            },
            ["Oldmcfarmer"] = {
            },
            ["Varix"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1229,
                    ["total"] = 729,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 41,
                    ["total"] = 45,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 504,
                    ["total"] = 509,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1284,
                    ["total"] = 1294,
                    ["entries"] = {
                    },
                },
            },
            ["Donttellmom"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 152,
                    ["total"] = 162,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 150,
                    ["total"] = 160,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 100,
                    ["total"] = 90,
                    ["entries"] = {
                    },
                },
            },
            ["Annaliese"] = {
            },
            ["Whiteknite"] = {
            },
            ["Sward"] = {
            },
            ["Bubbleoseveñ"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 170,
                    ["total"] = 180,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Athigoat"] = {
            },
            ["Cloverduk"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1064,
                    ["total"] = 1074,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 428,
                    ["total"] = 434,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1076,
                    ["total"] = 1081,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 357,
                    ["total"] = 367,
                    ["entries"] = {
                    },
                },
            },
            ["Funkorama"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 720,
                    ["total"] = 730,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 770,
                    ["total"] = 780,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 347,
                    ["total"] = 337,
                    ["entries"] = {
                    },
                },
            },
            ["Lovepistol"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 123,
                    ["total"] = 123,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Ripnrun"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 366,
                    ["total"] = 376,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 419,
                    ["total"] = 419,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 25,
                    ["total"] = 15,
                    ["entries"] = {
                    },
                },
            },
            ["Thepink"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 469,
                    ["total"] = 479,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 5,
                    ["total"] = 11,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1045,
                    ["total"] = 1055,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 676,
                    ["total"] = 686,
                    ["entries"] = {
                    },
                },
            },
            ["Kresto"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 317,
                    ["total"] = 327,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 211,
                    ["total"] = 217,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 684,
                    ["total"] = 694,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1279,
                    ["total"] = 1289,
                    ["entries"] = {
                    },
                },
            },
            ["Greasydogs"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 141,
                    ["total"] = 151,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Squirtsbig"] = {
            },
            ["Bubblè"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 234,
                    ["total"] = 244,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 556,
                    ["total"] = 566,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1069,
                    ["total"] = 1079,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 525,
                    ["total"] = 530,
                    ["entries"] = {
                    },
                },
            },
            ["Honeybuckett"] = {
            },
            ["Maryjainus"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                        1604984335, -- [1]
                    },
                    ["previousTotal"] = 184,
                    ["total"] = 184,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Parrtynow"] = {
            },
            ["Cindderfella"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 86,
                    ["total"] = 96,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 293,
                    ["total"] = 303,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Turbohealz"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 581,
                    ["total"] = 591,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 314,
                    ["total"] = 281,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 535,
                    ["total"] = 545,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 750,
                    ["total"] = 760,
                    ["entries"] = {
                    },
                },
            },
            ["Malorthroot"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 383,
                    ["total"] = 393,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Blasphemi"] = {
            },
            ["Fartulent"] = {
            },
            ["Korona"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 9,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 264,
                    ["total"] = 127,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Snaildaddy"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 839,
                    ["total"] = 849,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 577,
                    ["total"] = 583,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 630,
                    ["total"] = 635,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1260,
                    ["total"] = 1270,
                    ["entries"] = {
                    },
                },
            },
            ["Athico"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 801,
                    ["total"] = 811,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 259,
                    ["total"] = 265,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 708,
                    ["total"] = 718,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 950,
                    ["total"] = 960,
                    ["entries"] = {
                    },
                },
            },
            ["Metabeardo"] = {
            },
            ["Walterpeyton"] = {
            },
            ["Airok"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 110,
                    ["total"] = 100,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 14,
                    ["total"] = 5,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 302,
                    ["total"] = 292,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Squach"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 214,
                    ["total"] = 224,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 611,
                    ["total"] = 621,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Peanutbuter"] = {
            },
            ["Cheytac"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 239,
                    ["total"] = 249,
                    ["entries"] = {
                    },
                },
            },
            ["Lundo"] = {
            },
            ["Olerando"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 553,
                    ["total"] = 563,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 987,
                    ["total"] = 997,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 373,
                    ["total"] = 378,
                    ["entries"] = {
                    },
                },
            },
            ["Cantfeelany"] = {
            },
            ["Whal"] = {
            },
            ["Ninjassassìn"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 334,
                    ["total"] = 344,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1033,
                    ["total"] = 1043,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 25,
                    ["total"] = 15,
                    ["entries"] = {
                    },
                },
            },
            ["Kuuhaku"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 399,
                    ["total"] = 409,
                    ["entries"] = {
                        1607050045, -- [1]
                        1607050313, -- [2]
                        1607051280, -- [3]
                        1607051943, -- [4]
                        1607053101, -- [5]
                        1607053297, -- [6]
                        1607053691, -- [7]
                        1607054319, -- [8]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 443,
                    ["total"] = 443,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Astlan"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 127,
                    ["total"] = 137,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 221,
                    ["total"] = 231,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Dalia"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 667,
                    ["total"] = 677,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 120,
                    ["total"] = 130,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 755,
                    ["total"] = 765,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 894,
                    ["total"] = 904,
                    ["entries"] = {
                    },
                },
            },
            ["Dingusshaman"] = {
            },
            ["Odin"] = {
            },
            ["Mcstaberson"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1033,
                    ["total"] = 1053,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1571,
                    ["total"] = 1581,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Corruptus"] = {
            },
            ["Iamahealer"] = {
            },
            ["Alexinchains"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1068,
                    ["total"] = 1078,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 26,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 213,
                    ["total"] = 218,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 266,
                    ["total"] = 276,
                    ["entries"] = {
                    },
                },
            },
            ["Valleygirl"] = {
            },
            ["Aquafresh"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 93,
                    ["total"] = 69,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                        1621569628, -- [4]
                        1621571797, -- [5]
                    },
                },
            },
            ["Bleego"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Ttoken"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 527,
                    ["total"] = 537,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Wilocutwo"] = {
            },
            ["Richjoji"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 646,
                    ["total"] = 656,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 291,
                    ["total"] = 301,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 276,
                    ["total"] = 286,
                    ["entries"] = {
                    },
                },
            },
            ["Junifer"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Hierarch"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 90,
                    ["total"] = 110,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 275,
                    ["total"] = 285,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Boromiir"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 230,
                    ["total"] = 240,
                    ["entries"] = {
                    },
                },
            },
            ["Mulanrouge"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 30,
                    ["total"] = 40,
                    ["entries"] = {
                    },
                },
            },
            ["Mercer"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 166,
                    ["total"] = 176,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Forerunner"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 660,
                    ["total"] = 670,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 21,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 51,
                    ["total"] = 111,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1125,
                    ["total"] = 1135,
                    ["entries"] = {
                    },
                },
            },
            ["Philonious"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1269,
                    ["total"] = 1279,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1271,
                    ["total"] = 1281,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 125,
                    ["total"] = 115,
                    ["entries"] = {
                    },
                },
            },
            ["Mikehoochie"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Mcderby"] = {
            },
            ["Priesticuffs"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 819,
                    ["total"] = 829,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 21,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 476,
                    ["total"] = 486,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 644,
                    ["total"] = 654,
                    ["entries"] = {
                    },
                },
            },
            ["Lunarra"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 182,
                    ["total"] = 192,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 198,
                    ["total"] = 208,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Ballour"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 682,
                    ["total"] = 692,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 240,
                    ["total"] = 246,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1675,
                    ["total"] = 1680,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1214,
                    ["total"] = 1224,
                    ["entries"] = {
                    },
                },
            },
            ["Shotduk"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 90,
                    ["total"] = 100,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Calixta"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1838,
                    ["total"] = 1848,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 21,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 415,
                    ["total"] = 420,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1341,
                    ["total"] = 1351,
                    ["entries"] = {
                    },
                },
            },
            ["Bearbaçk"] = {
            },
            ["Vilir"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Cuttysark"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 480,
                    ["total"] = 490,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 600,
                    ["total"] = 670,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Jakemehoff"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1508,
                    ["total"] = 1518,
                    ["entries"] = {
                        1608007692, -- [1]
                        1608007924, -- [2]
                        1608008900, -- [3]
                        1608009564, -- [4]
                        1608010677, -- [5]
                        1608010858, -- [6]
                        1608011302, -- [7]
                        1608011801, -- [8]
                        1608011835, -- [9]
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 409,
                    ["total"] = 204,
                    ["entries"] = {
                        1608177674, -- [1]
                        1608177798, -- [2]
                        1608178628, -- [3]
                        1608179106, -- [4]
                        1608179806, -- [5]
                        1608180583, -- [6]
                        1608181071, -- [7]
                        1608181601, -- [8]
                        1608183439, -- [9]
                        1608184437, -- [10]
                        1608185948, -- [11]
                        1608187506, -- [12]
                        1608189076, -- [13]
                        1608189079, -- [14]
                        1608355851, -- [15]
                        1608361642, -- [16]
                        1608614403, -- [17]
                        1608614406, -- [18]
                        1608614599, -- [19]
                        1608695589, -- [20]
                        1608696412, -- [21]
                        1608696847, -- [22]
                        1608697685, -- [23]
                        1608697762, -- [24]
                        1608698318, -- [25]
                        1608698615, -- [26]
                        1608699845, -- [27]
                        1608700899, -- [28]
                        1608702148, -- [29]
                        1608703132, -- [30]
                        1609216373, -- [31]
                        1609220516, -- [32]
                        1609213483, -- [33]
                        1609388217, -- [34]
                        1609388914, -- [35]
                        1609389299, -- [36]
                        1609390526, -- [37]
                        1609391612, -- [38]
                        1609392880, -- [39]
                        1609393823, -- [40]
                        1609818866, -- [41]
                        1609820884, -- [42]
                        1609822076, -- [43]
                        1609991705, -- [44]
                        1609992511, -- [45]
                        1609992898, -- [46]
                        1609993466, -- [47]
                        1609994206, -- [48]
                        1609994553, -- [49]
                        1609995011, -- [50]
                        1609995069, -- [51]
                        1609996788, -- [52]
                        1609997782, -- [53]
                        1610000781, -- [54]
                        1610001653, -- [55]
                        1610001672, -- [56]
                        1610005872, -- [57]
                        1610165581, -- [58]
                        1610170012, -- [59]
                        1610170035, -- [60]
                        1610170138, -- [61]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 367,
                    ["total"] = 372,
                    ["entries"] = {
                        1608264505, -- [1]
                        1608265999, -- [2]
                        1608266660, -- [3]
                        1608267217, -- [4]
                        1608267540, -- [5]
                        1608268185, -- [6]
                        1608269569, -- [7]
                        1608272175, -- [8]
                        1608273303, -- [9]
                        1608274510, -- [10]
                        1608274513, -- [11]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1003,
                    ["total"] = 1013,
                    ["entries"] = {
                        1608616402, -- [1]
                        1608616835, -- [2]
                        1610172172, -- [3]
                    },
                },
            },
            ["Advanty"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 640,
                    ["total"] = 650,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 410,
                    ["total"] = 416,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1035,
                    ["total"] = 1045,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1909,
                    ["total"] = 1919,
                    ["entries"] = {
                    },
                },
            },
            ["Huntriss"] = {
            },
            ["Woobiedoobs"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Yeander"] = {
            },
            ["Phasetwoscum"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 932,
                    ["total"] = 942,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 875,
                    ["total"] = 885,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Neckbeardo"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 2017,
                    ["total"] = 2027,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 275,
                    ["total"] = 281,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 668,
                    ["total"] = 673,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 495,
                    ["total"] = 505,
                    ["entries"] = {
                    },
                },
            },
            ["Mistblade"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 634,
                    ["total"] = 644,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1769,
                    ["total"] = 1839,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Mothaduka"] = {
            },
            ["Entrophia"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 517,
                    ["total"] = 527,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 21,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 341,
                    ["total"] = 351,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 140,
                    ["total"] = 150,
                    ["entries"] = {
                    },
                },
            },
            ["Sicarrio"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 614,
                    ["total"] = 624,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 430,
                    ["total"] = 440,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Stridder"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 49,
                    ["total"] = 59,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Traviscott"] = {
            },
            ["Bigdukenergy"] = {
            },
            ["Shadowheals"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 387,
                    ["total"] = 397,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 207,
                    ["total"] = 217,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 25,
                    ["total"] = 15,
                    ["entries"] = {
                    },
                },
            },
            ["Bronciol"] = {
            },
            ["Aku"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1156,
                    ["total"] = 1166,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 181,
                    ["total"] = 187,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 301,
                    ["total"] = 306,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 2867,
                    ["total"] = 2877,
                    ["entries"] = {
                    },
                },
            },
            ["Turbodeeps"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 151,
                    ["total"] = 161,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 513,
                    ["total"] = 523,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Lilduder"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1241,
                    ["total"] = 1251,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1161,
                    ["total"] = 1171,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 394,
                    ["total"] = 399,
                    ["entries"] = {
                    },
                },
            },
            ["Cheezwhizard"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 72,
                    ["total"] = 64,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Eredrius"] = {
            },
            ["Magenori"] = {
            },
            ["Hordecheck"] = {
            },
            ["Kalgren"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Viabletank"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 231,
                    ["total"] = 207,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 30,
                    ["total"] = 40,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 59,
                    ["total"] = 65,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
            },
            ["Ixxl"] = {
            },
            ["Leejenkins"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 856,
                    ["total"] = 866,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 333,
                    ["total"] = 339,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 751,
                    ["total"] = 756,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1272,
                    ["total"] = 1282,
                    ["entries"] = {
                    },
                },
            },
            ["Eolith"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 442,
                    ["total"] = 452,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 351,
                    ["total"] = 351,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Gankdalf"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 230,
                    ["total"] = 240,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Frostitutez"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Lariese"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 105,
                    ["total"] = 95,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 405,
                    ["total"] = 406,
                    ["entries"] = {
                    },
                },
            },
            ["Kholric"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Then"] = {
            },
            ["Acehart"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 622,
                    ["total"] = 632,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 781,
                    ["total"] = 791,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 261,
                    ["total"] = 266,
                    ["entries"] = {
                    },
                },
            },
            ["Yeshmin"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 187,
                    ["total"] = 197,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 101,
                    ["total"] = 111,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 13,
                    ["total"] = 11,
                    ["entries"] = {
                    },
                },
            },
            ["Herberr"] = {
            },
            ["Kowsh"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 100,
                    ["total"] = 110,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Dunthad"] = {
            },
            ["Toysfordots"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Triendl"] = {
            },
            ["Donde"] = {
            },
            ["Suprarz"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 480,
                    ["total"] = 490,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 521,
                    ["total"] = 531,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 670,
                    ["total"] = 730,
                    ["entries"] = {
                    },
                },
            },
            ["Daggny"] = {
            },
            ["Finrir"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 88,
                    ["total"] = 98,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 213,
                    ["total"] = 213,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Brandadd"] = {
            },
            ["Shadowrouge"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Galagus"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 80,
                    ["total"] = 90,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 170,
                    ["total"] = 180,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 44,
                    ["total"] = -49,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                        1621571778, -- [4]
                    },
                },
            },
            ["Tinah"] = {
            },
            ["Dudebrochill"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 236,
                    ["total"] = 246,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 321,
                    ["total"] = 331,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Fady"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Mongous"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 973,
                    ["total"] = 983,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 21,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 130,
                    ["total"] = 120,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 694,
                    ["total"] = 704,
                    ["entries"] = {
                    },
                },
            },
            ["Elythrien"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Retkin"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 497,
                    ["total"] = 507,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 480,
                    ["total"] = 490,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 955,
                    ["total"] = 960,
                    ["entries"] = {
                    },
                },
            },
            ["Phanteon"] = {
            },
            ["Metaboi"] = {
            },
            ["Croché"] = {
            },
            ["Baltine"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 249,
                    ["total"] = 259,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 239,
                    ["total"] = 249,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Dullnips"] = {
            },
            ["Sibbie"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 338,
                    ["total"] = 348,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 35,
                    ["total"] = 25,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 287,
                    ["total"] = 297,
                    ["entries"] = {
                    },
                },
            },
            ["Evalyns"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Trajanmagnus"] = {
            },
            ["Terek"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
            },
            ["Oneonetoken"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 382,
                    ["total"] = 392,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 605,
                    ["total"] = 585,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Dopieone"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Adorae"] = {
            },
            ["Shellshôck"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Maroz"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1508,
                    ["total"] = 1518,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 291,
                    ["total"] = 297,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 450,
                    ["total"] = 455,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 543,
                    ["total"] = 553,
                    ["entries"] = {
                    },
                },
            },
            ["Mystile"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1187,
                    ["total"] = 1197,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 276,
                    ["total"] = 282,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1169,
                    ["total"] = 1174,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1527,
                    ["total"] = 1537,
                    ["entries"] = {
                    },
                },
            },
            ["Sadvanty"] = {
            },
            ["Fluffbutt"] = {
            },
            ["Qew"] = {
            },
            ["Gonehuntingg"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Rhextar"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Kiljordin"] = {
            },
            ["Dyinbryan"] = {
            },
            ["Jeroes"] = {
            },
            ["Dolamroth"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 312,
                    ["total"] = 318,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 617,
                    ["total"] = 627,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 234,
                    ["total"] = 244,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 260,
                    ["total"] = 265,
                    ["entries"] = {
                    },
                },
            },
            ["Chiantoker"] = {
            },
            ["Eesha"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
            },
            ["Fairisle"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 352,
                    ["total"] = 362,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 244,
                    ["total"] = 254,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Asgardian"] = {
            },
            ["Landlubbers"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 393,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Goatingalong"] = {
            },
            ["Zebulina"] = {
            },
            ["Freehongkòng"] = {
            },
            ["Fistula"] = {
            },
            ["Turbototemz"] = {
            },
            ["Oxfir"] = {
            },
            ["Maebelle"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 30,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1,
                    ["total"] = 5,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 389,
                    ["total"] = 399,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 361,
                    ["total"] = 371,
                    ["entries"] = {
                    },
                },
            },
            ["Sbinnala"] = {
            },
            ["Drxenon"] = {
            },
            ["Zepler"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 145,
                    ["total"] = 155,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 443,
                    ["total"] = 453,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 163,
                    ["total"] = 173,
                    ["entries"] = {
                    },
                },
            },
            ["Dallascowboy"] = {
            },
            ["Corseauxx"] = {
            },
            ["Kaput"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 585,
                    ["total"] = 595,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 378,
                    ["total"] = 388,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Lindo"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 507,
                    ["total"] = 517,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 40,
                    ["total"] = 40,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 718,
                    ["total"] = 728,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 663,
                    ["total"] = 673,
                    ["entries"] = {
                    },
                },
            },
            ["Titanup"] = {
            },
            ["Turboblaster"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Noinfo"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 144,
                    ["total"] = 154,
                    ["entries"] = {
                    },
                },
            },
            ["Neekio"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1564,
                    ["total"] = 1574,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 377,
                    ["total"] = 383,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 552,
                    ["total"] = 562,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1224,
                    ["total"] = 1234,
                    ["entries"] = {
                    },
                },
            },
            ["Leezugginz"] = {
            },
            ["Klassick"] = {
            },
            ["Babie"] = {
            },
            ["Trippystixx"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 331,
                    ["total"] = 341,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 925,
                    ["total"] = 935,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 293,
                    ["total"] = 283,
                    ["entries"] = {
                    },
                },
            },
            ["Shinynick"] = {
            },
            ["Mitcheril"] = {
            },
            ["Simpmagnet"] = {
            },
            ["Jayyhawk"] = {
            },
            ["Shiftingduk"] = {
            },
            ["Zapzoombam"] = {
            },
            ["Eryx"] = {
            },
            ["Goatedhell"] = {
            },
            ["Xeroxis"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 149,
                    ["total"] = 159,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 60,
                    ["total"] = 50,
                    ["entries"] = {
                    },
                },
            },
            ["Sneakyslut"] = {
            },
            ["Genjiro"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 226,
                    ["total"] = 203,
                    ["entries"] = {
                        1605846293, -- [1]
                        1605847576, -- [2]
                        1605847834, -- [3]
                        1605848772, -- [4]
                        1605849423, -- [5]
                        1605850619, -- [6]
                        1605850867, -- [7]
                        1605851339, -- [8]
                        1605851429, -- [9]
                        1605851956, -- [10]
                        1605852013, -- [11]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 297,
                    ["total"] = 297,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Eolithena"] = {
            },
            ["Shinygoat"] = {
            },
            ["Wooper"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 279,
                    ["total"] = 285,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621567090, -- [2]
                        1621567914, -- [3]
                        1621568768, -- [4]
                        1621569573, -- [5]
                    },
                },
            },
            ["Griffindor"] = {
            },
            ["Goobis"] = {
            },
            ["Pantheonbets"] = {
            },
            ["Jacobmeoff"] = {
            },
            ["Defcon"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 80,
                    ["total"] = 80,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 89,
                    ["total"] = 80,
                    ["entries"] = {
                        1608007692, -- [1]
                        1608007924, -- [2]
                        1608008309, -- [3]
                        1608008900, -- [4]
                        1608009564, -- [5]
                        1608010516, -- [6]
                        1608010677, -- [7]
                        1608010858, -- [8]
                        1608011302, -- [9]
                        1608011801, -- [10]
                        1608011835, -- [11]
                        1608011848, -- [12]
                    },
                },
            },
            ["Summonyobish"] = {
            },
            ["Scudd"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 936,
                    ["total"] = 946,
                    ["entries"] = {
                        1603414839, -- [1]
                        1603417003, -- [2]
                        1603417278, -- [3]
                        1603417694, -- [4]
                        1603418278, -- [5]
                        1603420210, -- [6]
                        1603422637, -- [7]
                        1603422846, -- [8]
                        1603423275, -- [9]
                        1603423811, -- [10]
                        1603423838, -- [11]
                        1604021061, -- [12]
                        1604021793, -- [13]
                        1604021844, -- [14]
                        1604025750, -- [15]
                        1604041499, -- [16]
                        1604630530, -- [17]
                        1604631311, -- [18]
                        1604632164, -- [19]
                        1604633462, -- [20]
                        1604634542, -- [21]
                        1604634712, -- [22]
                        1604635164, -- [23]
                        1604635695, -- [24]
                        1604638648, -- [25]
                        1605235224, -- [26]
                        1605235413, -- [27]
                        1605236840, -- [28]
                        1605237782, -- [29]
                        1605237927, -- [30]
                        1605237956, -- [31]
                        1605238273, -- [32]
                        1605238722, -- [33]
                        1605238770, -- [34]
                        1605240800, -- [35]
                        1605840015, -- [36]
                        1605840115, -- [37]
                        1605841083, -- [38]
                        1605841697, -- [39]
                        1605841763, -- [40]
                        1605842752, -- [41]
                        1605842929, -- [42]
                        1605843325, -- [43]
                        1605843845, -- [44]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                        1604984335, -- [1]
                    },
                    ["previousTotal"] = 649,
                    ["total"] = 659,
                    ["entries"] = {
                        1604637922, -- [1]
                        1604638630, -- [2]
                        1605239997, -- [3]
                        1605240506, -- [4]
                        1605845263, -- [5]
                        1605845590, -- [6]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                        1603936796, -- [1]
                        1603937488, -- [2]
                    },
                    ["previousTotal"] = 672,
                    ["total"] = 662,
                    ["entries"] = {
                        1603933394, -- [1]
                        1603935133, -- [2]
                        1603935799, -- [3]
                        1603936434, -- [4]
                        1603937414, -- [5]
                        1603937525, -- [6]
                        1603938855, -- [7]
                        1603941053, -- [8]
                        1603943820, -- [9]
                        1603944961, -- [10]
                        1603944975, -- [11]
                        1603855763, -- [12]
                        1603855763, -- [13]
                        1603855764, -- [14]
                        1603855764, -- [15]
                        1603855797, -- [16]
                        1603855797, -- [17]
                        1603855762, -- [18]
                        1603855762, -- [19]
                        1603855805, -- [20]
                        1603855805, -- [21]
                    },
                },
            },
            ["Fín"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 416,
                    ["total"] = 416,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Thepuple"] = {
            },
            ["Alexeiá"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Necroo"] = {
            },
            ["Algebraical"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 269,
                    ["total"] = 279,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 220,
                    ["total"] = 230,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Beartholemew"] = {
            },
            ["Iszell"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1355,
                    ["total"] = 1435,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1049,
                    ["total"] = 1055,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 116,
                    ["total"] = 126,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 960,
                    ["total"] = 970,
                    ["entries"] = {
                    },
                },
            },
            ["Warslutx"] = {
            },
            ["Rendskar"] = {
            },
            ["Livpod"] = {
            },
            ["Woopdescoop"] = {
            },
            ["Mystilè"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 34,
                    ["total"] = 40,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
            },
            ["Ezcheezy"] = {
            },
            ["Wankles"] = {
            },
            ["Sneakattac"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 113,
                    ["total"] = 101,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 453,
                    ["total"] = 463,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Ugro"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 2422,
                    ["total"] = 2432,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 569,
                    ["total"] = 575,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 420,
                    ["total"] = 430,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 454,
                    ["total"] = 464,
                    ["entries"] = {
                    },
                },
            },
            ["Bilzen"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 200,
                    ["total"] = 200,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Jillmeoff"] = {
            },
            ["Bearjoo"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 495,
                    ["total"] = 505,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 755,
                    ["total"] = 765,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Inebriated"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 354,
                    ["total"] = 364,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1001,
                    ["total"] = 1011,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 414,
                    ["total"] = 419,
                    ["entries"] = {
                    },
                },
            },
            ["Wordsalad"] = {
            },
            ["Pailor"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 279,
                    ["total"] = 299,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 25,
                    ["total"] = 31,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 345,
                    ["total"] = 335,
                    ["entries"] = {
                    },
                },
            },
            ["Praisehelix"] = {
            },
            ["Thatsjuslike"] = {
            },
            ["Luckerdawg"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 742,
                    ["total"] = 752,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 273,
                    ["total"] = 283,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 354,
                    ["total"] = 359,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1849,
                    ["total"] = 1859,
                    ["entries"] = {
                    },
                },
            },
            ["Conflikt"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 571,
                    ["total"] = 581,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 379,
                    ["total"] = 389,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 35,
                    ["total"] = 25,
                    ["entries"] = {
                    },
                },
            },
            ["Soçialism"] = {
            },
            ["Dessiola"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 757,
                    ["total"] = 767,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 34,
                    ["total"] = 38,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 935,
                    ["total"] = 955,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 509,
                    ["total"] = 519,
                    ["entries"] = {
                    },
                },
            },
            ["Theyellow"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 664,
                    ["total"] = 674,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1351,
                    ["total"] = 1361,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Catwater"] = {
            },
            ["Gneissfemale"] = {
            },
            ["Jakemeoff"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 6,
                    ["total"] = 12,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 671,
                    ["total"] = 691,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 671,
                    ["total"] = 681,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 592,
                    ["total"] = 602,
                    ["entries"] = {
                    },
                },
            },
            ["Theazul"] = {
            },
            ["Hearted"] = {
            },
            ["Luckergoat"] = {
            },
            ["Sarcasmo"] = {
            },
            ["Humantoken"] = {
            },
            ["Slipperyjohn"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1323,
                    ["total"] = 1333,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1227,
                    ["total"] = 1227,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Wîtch"] = {
            },
            ["Helldinca"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 25,
                    ["total"] = 15,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = -105,
                    ["total"] = -99,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 265,
                    ["total"] = 275,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 552,
                    ["total"] = 562,
                    ["entries"] = {
                    },
                },
            },
            ["Spatulla"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 92,
                    ["total"] = 82,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 134,
                    ["total"] = 140,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 83,
                    ["total"] = 88,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 409,
                    ["total"] = 419,
                    ["entries"] = {
                    },
                },
            },
            ["Mascarpone"] = {
            },
            ["Laird"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1996,
                    ["total"] = 2006,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 37,
                    ["total"] = -34,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                        1621570373, -- [4]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 587,
                    ["total"] = 592,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1034,
                    ["total"] = 1044,
                    ["entries"] = {
                    },
                },
            },
            ["Cannabear"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 98,
                    ["total"] = 88,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 127,
                    ["total"] = 137,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 78,
                    ["total"] = 88,
                    ["entries"] = {
                    },
                },
            },
            ["Zawaz"] = {
            },
            ["Dotslash"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 662,
                    ["total"] = 672,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 177,
                    ["total"] = 187,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Spellbender"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 100,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 840,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["PlayerTJBJSY"] = {
            },
            ["Bigbootyhoho"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 212,
                    ["total"] = 272,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 169,
                    ["total"] = 175,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1531,
                    ["total"] = 1541,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 632,
                    ["total"] = 642,
                    ["entries"] = {
                    },
                },
            },
            ["Jdogg"] = {
            },
            ["Cheezybank"] = {
            },
            ["Vrynne"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1109,
                    ["total"] = 1119,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 882,
                    ["total"] = 892,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 427,
                    ["total"] = 417,
                    ["entries"] = {
                    },
                },
            },
            ["Hew"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 316,
                    ["total"] = 326,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 802,
                    ["total"] = 812,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Olmanjenkins"] = {
            },
            ["Macladinleaf"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 356,
                    ["total"] = 366,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 484,
                    ["total"] = 494,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 616,
                    ["total"] = 621,
                    ["entries"] = {
                    },
                },
            },
            ["Aierasella"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Nairb"] = {
            },
            ["Colwyn"] = {
            },
            ["Inigma"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 2061,
                    ["total"] = 1030,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 408,
                    ["total"] = 414,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 849,
                    ["total"] = 854,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1166,
                    ["total"] = 1176,
                    ["entries"] = {
                    },
                },
            },
            ["Eguita"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 220,
                    ["total"] = 270,
                    ["entries"] = {
                        1602542657, -- [1]
                        1602542657, -- [2]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 106,
                    ["total"] = 116,
                    ["entries"] = {
                        1598596533, -- [1]
                        1598597430, -- [2]
                        1598672987, -- [3]
                        1598596944, -- [4]
                        1599630242, -- [5]
                        1598596995, -- [6]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
            },
            ["Ones"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 988,
                    ["total"] = 998,
                    ["entries"] = {
                        1605846293, -- [1]
                        1605847576, -- [2]
                        1605847834, -- [3]
                        1605848772, -- [4]
                        1605849423, -- [5]
                        1605850619, -- [6]
                        1605850867, -- [7]
                        1605851339, -- [8]
                        1605851956, -- [9]
                        1606450977, -- [10]
                        1606451884, -- [11]
                        1606452144, -- [12]
                        1606453878, -- [13]
                        1606455033, -- [14]
                        1606455277, -- [15]
                        1606455856, -- [16]
                        1606456411, -- [17]
                        1607057071, -- [18]
                        1607057318, -- [19]
                        1607058433, -- [20]
                        1607059084, -- [21]
                        1607059121, -- [22]
                        1607060297, -- [23]
                        1607060468, -- [24]
                        1607060998, -- [25]
                        1607061676, -- [26]
                        1607062111, -- [27]
                        1608007692, -- [28]
                        1608007924, -- [29]
                        1608008900, -- [30]
                        1608009564, -- [31]
                        1608009807, -- [32]
                        1608010677, -- [33]
                        1608010858, -- [34]
                        1608011302, -- [35]
                        1608011801, -- [36]
                        1608011835, -- [37]
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 21,
                    ["total"] = 26,
                    ["entries"] = {
                        1607157239, -- [1]
                        1607157391, -- [2]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 477,
                    ["total"] = 482,
                    ["entries"] = {
                        1606277074, -- [1]
                        1606278721, -- [2]
                        1606279167, -- [3]
                        1606279645, -- [4]
                        1606279918, -- [5]
                        1606280415, -- [6]
                        1606281330, -- [7]
                        1606285737, -- [8]
                        1606283432, -- [9]
                        1606283906, -- [10]
                        1606882047, -- [11]
                        1606883776, -- [12]
                        1606884333, -- [13]
                        1606884937, -- [14]
                        1606885227, -- [15]
                        1606885293, -- [16]
                        1606885711, -- [17]
                        1606886730, -- [18]
                        1606889833, -- [19]
                        1606889893, -- [20]
                        1606890445, -- [21]
                        1606891969, -- [22]
                        1606892050, -- [23]
                        1608264505, -- [24]
                        1608265999, -- [25]
                        1608266660, -- [26]
                        1608267217, -- [27]
                        1608267540, -- [28]
                        1608268185, -- [29]
                        1608269569, -- [30]
                        1608272175, -- [31]
                        1608273303, -- [32]
                        1608274510, -- [33]
                        1608274513, -- [34]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1287,
                    ["total"] = 1297,
                    ["entries"] = {
                        1608013886, -- [1]
                        1608014291, -- [2]
                    },
                },
            },
            ["Gneissman"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 129,
                    ["total"] = 139,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 35,
                    ["total"] = 45,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Rogueish"] = {
            },
            ["Kuckuck"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = -75,
                    ["total"] = -69,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 90,
                    ["total"] = 81,
                    ["entries"] = {
                    },
                },
            },
            ["Brensduk"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 178,
                    ["total"] = 307,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 618,
                    ["total"] = 628,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Vaelrith"] = {
            },
            ["Wowitsdoug"] = {
            },
            ["Barnnagus"] = {
            },
            ["Rumil"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 131,
                    ["total"] = 141,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
            },
            ["Idotyou"] = {
            },
            ["Raspütin"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1074,
                    ["total"] = 1084,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 78,
                    ["total"] = 84,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 615,
                    ["total"] = 620,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 790,
                    ["total"] = 800,
                    ["entries"] = {
                    },
                },
            },
            ["Pantheonbank"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 27,
                    ["total"] = 27,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 30,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 15,
                    ["total"] = 25,
                    ["entries"] = {
                    },
                },
            },
            ["Lawduk"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1746,
                    ["total"] = 1756,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 297,
                    ["total"] = 303,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 714,
                    ["total"] = 719,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 770,
                    ["total"] = 780,
                    ["entries"] = {
                    },
                },
            },
            ["Bádtothebow"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 905,
                    ["total"] = 915,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 18,
                    ["total"] = 28,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 240,
                    ["total"] = 230,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 335,
                    ["total"] = 345,
                    ["entries"] = {
                    },
                },
            },
            ["Kalijah"] = {
            },
            ["Shellc"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 100,
                    ["total"] = 110,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Dougdimadome"] = {
            },
            ["Edgyboi"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 410,
                    ["total"] = 490,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 380,
                    ["total"] = 386,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 728,
                    ["total"] = 733,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1302,
                    ["total"] = 1312,
                    ["entries"] = {
                    },
                },
            },
            ["Gandallf"] = {
            },
            ["Apotheosys"] = {
            },
            ["Pootootwo"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 271,
                    ["total"] = 281,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 981,
                    ["total"] = 981,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Delryn"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Bankofkresto"] = {
            },
            ["Richierich"] = {
            },
            ["Banklawdy"] = {
            },
            ["Flayy"] = {
            },
            ["Stikyiki"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 25,
                    ["total"] = 15,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 652,
                    ["total"] = 672,
                    ["entries"] = {
                    },
                },
            },
            ["Tuggernuts"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 539,
                    ["total"] = 549,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 420,
                    ["total"] = 420,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 25,
                    ["total"] = 15,
                    ["entries"] = {
                    },
                },
            },
            ["Kerrela"] = {
            },
            ["Papabeer"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 266,
                    ["total"] = 276,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 117,
                    ["total"] = 105,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 308,
                    ["total"] = 313,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 700,
                    ["total"] = 710,
                    ["entries"] = {
                    },
                },
            },
            ["Imbiambajoms"] = {
            },
            ["Ollieduk"] = {
            },
            ["Melmund"] = {
            },
            ["Onionion"] = {
            },
            ["Snackysnack"] = {
            },
            ["Drniko"] = {
            },
            ["Athica"] = {
            },
            ["Edgelawdy"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 758,
                    ["total"] = 808,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 391,
                    ["total"] = 397,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 194,
                    ["total"] = 199,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 875,
                    ["total"] = 885,
                    ["entries"] = {
                    },
                },
            },
            ["Trapjr"] = {
            },
            ["Yougrow"] = {
            },
            ["Shamalah"] = {
            },
            ["Garter"] = {
            },
            ["Morphintyme"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1418,
                    ["total"] = 1428,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 958,
                    ["total"] = 968,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 344,
                    ["total"] = 334,
                    ["entries"] = {
                    },
                },
            },
            ["Thecorner"] = {
            },
            ["Aquamane"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 386,
                    ["total"] = 396,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 343,
                    ["total"] = 353,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 245,
                    ["total"] = 235,
                    ["entries"] = {
                    },
                },
            },
            ["Solana"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 409,
                    ["total"] = 409,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Squirtsalot"] = {
            },
            ["Omorlin"] = {
            },
            ["Metalawdy"] = {
            },
            ["Finryr"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 706,
                    ["total"] = 716,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 999,
                    ["total"] = 999,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 100,
                    ["total"] = 90,
                    ["entries"] = {
                    },
                },
            },
            ["Savos"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 376,
                    ["total"] = 386,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 238,
                    ["total"] = 119,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Hanse"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 228,
                    ["total"] = 238,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Goobimus"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 973,
                    ["total"] = 993,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 440,
                    ["total"] = 209,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 586,
                    ["total"] = 591,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1155,
                    ["total"] = 1165,
                    ["entries"] = {
                    },
                },
            },
            ["Honkforheals"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                        1605821654, -- [1]
                        1605823580, -- [2]
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
            },
            ["Arkleis"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 90,
                    ["total"] = 110,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 90,
                    ["total"] = 100,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 118,
                    ["total"] = 108,
                    ["entries"] = {
                    },
                },
            },
            ["Blaneus"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Thealabaster"] = {
            },
            ["Shadeslinger"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 721,
                    ["total"] = 731,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 543,
                    ["total"] = 553,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Bigthicc"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 340,
                    ["total"] = 390,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 90,
                    ["total"] = 100,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Shampagné"] = {
            },
            ["Paladindrome"] = {
            },
            ["Dwarfbro"] = {
            },
            ["Minerva"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 60,
                    ["total"] = 70,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
            },
            ["Jaybreezy"] = {
            },
            ["Orcgasma"] = {
            },
            ["Epicduk"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 632,
                    ["total"] = 642,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1057,
                    ["total"] = 1067,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 748,
                    ["total"] = 758,
                    ["entries"] = {
                    },
                },
            },
            ["Honeypot"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 724,
                    ["total"] = 734,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 390,
                    ["total"] = 396,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 518,
                    ["total"] = 523,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1891,
                    ["total"] = 1901,
                    ["entries"] = {
                    },
                },
            },
            ["Pootootoot"] = {
            },
            ["Irishlady"] = {
            },
            ["Killerdwarf"] = {
            },
            ["Pamplemousse"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1530,
                    ["total"] = 1540,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 243,
                    ["total"] = 249,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 337,
                    ["total"] = 342,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 958,
                    ["total"] = 968,
                    ["entries"] = {
                    },
                },
            },
            ["Kelthazar"] = {
            },
            ["Zimmi"] = {
            },
            ["Benthulin"] = {
            },
            ["Dyingwood"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 69,
                    ["total"] = 79,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Blanebites"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1121,
                    ["total"] = 1131,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 799,
                    ["total"] = 809,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Papasquach"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 896,
                    ["total"] = 906,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 553,
                    ["total"] = 563,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 348,
                    ["total"] = 338,
                    ["entries"] = {
                    },
                },
            },
            ["Kittoo"] = {
            },
            ["Yerblok"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 12,
                    ["total"] = 18,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
            },
            ["Toomanydicks"] = {
            },
            ["Ithgar"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 2089,
                    ["total"] = 2099,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1385,
                    ["total"] = 1395,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 546,
                    ["total"] = 551,
                    ["entries"] = {
                    },
                },
            },
            ["Babygroot"] = {
            },
            ["Oragan"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 2081,
                    ["total"] = 2101,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1903,
                    ["total"] = 1913,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 602,
                    ["total"] = 592,
                    ["entries"] = {
                    },
                },
            },
            ["Septra"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 180,
                    ["total"] = 200,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 153,
                    ["total"] = 163,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 25,
                    ["total"] = 15,
                    ["entries"] = {
                    },
                },
            },
            ["Oxford"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 584,
                    ["total"] = 590,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 277,
                    ["total"] = 297,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1164,
                    ["total"] = 1174,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 493,
                    ["total"] = 553,
                    ["entries"] = {
                    },
                },
            },
            ["Bubbabear"] = {
            },
            ["Gunsrpeople"] = {
            },
            ["Dimmer"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 25,
                    ["total"] = 15,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 120,
                    ["total"] = 130,
                    ["entries"] = {
                    },
                },
            },
            ["Avemaria"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
            },
            ["Garrettm"] = {
            },
            ["Mariku"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 899,
                    ["total"] = 909,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 86,
                    ["total"] = 92,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 594,
                    ["total"] = 599,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1489,
                    ["total"] = 1499,
                    ["entries"] = {
                    },
                },
            },
            ["Beardedfury"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Stitchess"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 906,
                    ["total"] = 916,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 2183,
                    ["total"] = 2193,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 262,
                    ["total"] = 252,
                    ["entries"] = {
                    },
                },
            },
            ["Sugalumps"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 453,
                    ["total"] = 463,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 21,
                    ["total"] = 26,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 474,
                    ["total"] = 479,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 908,
                    ["total"] = 978,
                    ["entries"] = {
                    },
                },
            },
            ["Notouching"] = {
            },
            ["Leebad"] = {
            },
            ["Tripodd"] = {
            },
            ["Danatelo"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 50,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 333,
                    ["total"] = 343,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Doormann"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 310,
                    ["total"] = 320,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 235,
                    ["total"] = 235,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Vermilingua"] = {
            },
            ["Velysara"] = {
            },
            ["Leesummons"] = {
            },
            ["Brotems"] = {
            },
            ["Bellibombs"] = {
            },
            ["Toobigtofail"] = {
            },
            ["Bruhtato"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 400,
                    ["total"] = 400,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Gieves"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 46,
                    ["total"] = 56,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Guilan"] = {
            },
            ["Neckbreado"] = {
            },
            ["Kholgrim"] = {
            },
            ["Karenbaskins"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 90,
                    ["total"] = 189,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 45,
                    ["total"] = 22,
                    ["entries"] = {
                    },
                },
            },
            ["Moobigus"] = {
            },
            ["Evangelina"] = {
            },
            ["Qtlbr"] = {
            },
            ["Craiger"] = {
            },
            ["Neilyoung"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 636,
                    ["total"] = 646,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 417,
                    ["total"] = 427,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Iskandor"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 110,
                    ["total"] = 120,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 229,
                    ["total"] = 249,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Phasesixscum"] = {
            },
            ["Poppit"] = {
            },
            ["Pwotootoo"] = {
            },
            ["Furrywurry"] = {
            },
            ["Almyra"] = {
            },
            ["Hamickle"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 51,
                    ["total"] = 61,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 269,
                    ["total"] = 289,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 30,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
            },
            ["Kittysnake"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 40,
                    ["total"] = 50,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 237,
                    ["total"] = 243,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 951,
                    ["total"] = 961,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1855,
                    ["total"] = 1865,
                    ["entries"] = {
                    },
                },
            },
            ["Primera"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 945,
                    ["total"] = 955,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 486,
                    ["total"] = 492,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 523,
                    ["total"] = 528,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 946,
                    ["total"] = 956,
                    ["entries"] = {
                    },
                },
            },
            ["Damayanti"] = {
            },
            ["Mugatwo"] = {
            },
            ["Rittlelocket"] = {
            },
            ["Pharmz"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 183,
                    ["total"] = 193,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Supraalt"] = {
            },
            ["Haia"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                        1605821654, -- [1]
                        1605823580, -- [2]
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
            },
            ["Blietzche"] = {
            },
            ["Huntswomann"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 720,
                    ["total"] = 730,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 12,
                    ["total"] = 18,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 304,
                    ["total"] = 309,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 366,
                    ["total"] = 376,
                    ["entries"] = {
                    },
                },
            },
            ["Dwindle"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 261,
                    ["total"] = 271,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 35,
                    ["total"] = 40,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 80,
                    ["total"] = 85,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 810,
                    ["total"] = 820,
                    ["entries"] = {
                    },
                },
            },
            ["Gneissbro"] = {
            },
            ["Pxndx"] = {
            },
            ["Turbobandit"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 350,
                    ["total"] = 360,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Kenkoy"] = {
            },
            ["Taylorswifty"] = {
                ["Naxxramas"] = {
                    ["deleted"] = {
                        1605821654, -- [1]
                        1605823580, -- [2]
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
            },
            ["Xezandria"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 10,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
            },
            ["Wazzoo"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 816,
                    ["total"] = 826,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                },
            },
            ["Stratmeister"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 342,
                    ["total"] = 342,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Sparklenips"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 703,
                    ["total"] = 713,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1848,
                    ["total"] = 1858,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 95,
                    ["total"] = 100,
                    ["entries"] = {
                    },
                },
            },
            ["Azmoden"] = {
            },
            ["Cptncold"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 122,
                    ["total"] = 132,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Marifer"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 160,
                    ["total"] = 170,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 140,
                    ["total"] = 150,
                    ["entries"] = {
                    },
                },
            },
            ["Lotuslawdy"] = {
            },
            ["Critplus"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                        1606453857, -- [1]
                    },
                    ["previousTotal"] = 127,
                    ["total"] = 137,
                    ["entries"] = {
                        1606450977, -- [1]
                        1606451884, -- [2]
                        1606452144, -- [3]
                        1606453314, -- [4]
                        1606453878, -- [5]
                        1606455033, -- [6]
                        1606455277, -- [7]
                        1606455856, -- [8]
                        1606456411, -- [9]
                        1607057071, -- [10]
                        1607057318, -- [11]
                        1607058433, -- [12]
                        1607059084, -- [13]
                        1607060297, -- [14]
                        1607060468, -- [15]
                        1607060998, -- [16]
                        1607061230, -- [17]
                        1607061676, -- [18]
                        1607061706, -- [19]
                        1607062111, -- [20]
                    },
                },
            },
            ["Luckercat"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 30,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 496,
                    ["total"] = 506,
                    ["entries"] = {
                    },
                },
            },
            ["Huntnori"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 606,
                    ["total"] = 616,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 675,
                    ["total"] = 685,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 272,
                    ["total"] = 262,
                    ["entries"] = {
                    },
                },
            },
            ["Thepinkish"] = {
            },
            ["Fawntine"] = {
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1285,
                    ["total"] = 1295,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 110,
                    ["total"] = 116,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1255,
                    ["total"] = 1265,
                    ["entries"] = {
                    },
                },
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1039,
                    ["total"] = 1049,
                    ["entries"] = {
                    },
                },
            },
            ["Prfx"] = {
            },
            ["Blkmamba"] = {
            },
            ["Delv"] = {
            },
            ["Jeffry"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 998,
                    ["total"] = 1008,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 506,
                    ["total"] = 512,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 371,
                    ["total"] = 381,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 514,
                    ["total"] = 524,
                    ["entries"] = {
                    },
                },
            },
            ["Nikodin"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1956,
                    ["total"] = 1966,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1207,
                    ["total"] = 1217,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 738,
                    ["total"] = 728,
                    ["entries"] = {
                    },
                },
            },
            ["Leezuggins"] = {
            },
            ["Bankeyy"] = {
            },
            ["Sretsam"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 270,
                    ["total"] = 280,
                    ["entries"] = {
                        1605235224, -- [1]
                        1605235413, -- [2]
                        1605236840, -- [3]
                        1605237782, -- [4]
                        1605237927, -- [5]
                        1605238273, -- [6]
                        1605238722, -- [7]
                        1605240800, -- [8]
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                        1604984335, -- [1]
                    },
                    ["previousTotal"] = 294,
                    ["total"] = 294,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 30,
                    ["total"] = 20,
                    ["entries"] = {
                        1603855763, -- [1]
                        1603855763, -- [2]
                        1603855764, -- [3]
                        1603855764, -- [4]
                        1603855797, -- [5]
                        1603855797, -- [6]
                        1603855762, -- [7]
                        1603855762, -- [8]
                        1603855805, -- [9]
                        1603855805, -- [10]
                    },
                },
            },
            ["Eitak"] = {
            },
            ["Kiljordyn"] = {
            },
            ["Nightshelf"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 649,
                    ["total"] = 659,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 202,
                    ["total"] = 208,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 710,
                    ["total"] = 715,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1327,
                    ["total"] = 1337,
                    ["entries"] = {
                    },
                },
            },
            ["Hadeon"] = {
            },
            ["Whooper"] = {
            },
            ["Bildad"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 426,
                    ["total"] = 436,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 522,
                    ["total"] = 532,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 250,
                    ["total"] = 255,
                    ["entries"] = {
                    },
                },
            },
            ["Zeeksa"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 474,
                    ["total"] = 484,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1587,
                    ["total"] = 1597,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Seabear"] = {
            },
            ["Walterpayton"] = {
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 346,
                    ["total"] = 352,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
            },
            ["Sorcerus"] = {
            },
            ["Bugaboom"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 1588,
                    ["total"] = 1598,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 140,
                    ["total"] = 146,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 715,
                    ["total"] = 720,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 576,
                    ["total"] = 586,
                    ["entries"] = {
                    },
                },
            },
            ["Faradette"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Zeltrix"] = {
            },
            ["Apolyne"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 378,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Waterspec"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 0,
                    ["total"] = 0,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Spcegoatpurp"] = {
            },
            ["Veltrix"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 704,
                    ["total"] = 714,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 289,
                    ["total"] = 295,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 314,
                    ["total"] = 157,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 2056,
                    ["total"] = 2066,
                    ["entries"] = {
                    },
                },
            },
            ["Qtr"] = {
            },
            ["Shamwoo"] = {
            },
            ["Hoadley"] = {
            },
            ["Thepurple"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 435,
                    ["total"] = 445,
                    ["entries"] = {
                    },
                },
                ["Naxxramas"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 108,
                    ["total"] = 114,
                    ["entries"] = {
                        1621566589, -- [1]
                        1621568768, -- [2]
                        1621569573, -- [3]
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 552,
                    ["total"] = 557,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 986,
                    ["total"] = 996,
                    ["entries"] = {
                    },
                },
            },
            ["Moussemouse"] = {
            },
            ["Clicktheport"] = {
            },
            ["Huntduk"] = {
            },
            ["Zerina"] = {
            },
            ["Moonlips"] = {
            },
            ["Darci"] = {
            },
            ["Necroduk"] = {
            },
            ["Woobear"] = {
            },
            ["Turbotank"] = {
            },
            ["Skarl"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 30,
                    ["total"] = 20,
                    ["entries"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 312,
                    ["total"] = 284,
                    ["entries"] = {
                    },
                },
            },
            ["Mystíle"] = {
            },
            ["Restosexuál"] = {
            },
            ["Skimpy"] = {
                ["Blackwing Lair"] = {
                    ["deleted"] = {
                    },
                },
                ["Molten Core"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 71,
                    ["total"] = 81,
                    ["entries"] = {
                    },
                },
                ["Ahn'Qiraj"] = {
                    ["deleted"] = {
                    },
                    ["previousTotal"] = 20,
                    ["total"] = 10,
                    ["entries"] = {
                    },
                },
            },
            ["Fearlone"] = {
            },
        },
        ["all"] = {
            [1621571797] = {
                ["deleted"] = false,
                ["id"] = 1621571797,
                ["dkp_change"] = -24,
                ["reason"] = "Item Win",
                ["names"] = {
                    "Aquafresh", -- [1]
                },
                ["boss"] = "",
                ["item"] = "Not Linked",
                ["edited"] = false,
                ["raid"] = "Naxxramas",
                ["previousTotals"] = {
                    ["Aquafresh"] = 237,
                },
                ["adjust_type"] = "",
                ["officer"] = "Snaildaddy",
            },
            [1622386680] = {
                ["deleted"] = false,
                ["id"] = 1622386680,
                ["dkp_change"] = 10,
                ["reason"] = "Boss Kill",
                ["boss"] = "",
                ["names"] = {
                    "Abnevillus", -- [1]
                },
                ["edited"] = false,
                ["raid"] = "Black Temple",
                ["previousTotals"] = {
                    ["Abnevillus"] = 0,
                },
                ["adjust_type"] = "",
                ["officer"] = "Neekio",
            },
            [1621570373] = {
                ["deleted"] = false,
                ["id"] = 1621570373,
                ["dkp_change"] = -71,
                ["reason"] = "Item Win",
                ["names"] = {
                    "Laird", -- [1]
                },
                ["boss"] = "",
                ["item"] = "Not Linked",
                ["adjust_type"] = "",
                ["previousTotals"] = {
                    ["Laird"] = 141,
                },
                ["raid"] = "Naxxramas",
                ["edited"] = false,
                ["officer"] = "Viabletank",
            },
            [1621568768] = {
                ["deleted"] = false,
                ["id"] = 1621568768,
                ["dkp_change"] = 6,
                ["reason"] = "Boss Kill",
                ["boss"] = "Grand Widow Faerlina",
                ["names"] = {
                    "Spatulla", -- [1]
                    "Turboboom", -- [2]
                    "Athico", -- [3]
                    "Helldinca", -- [4]
                    "Huntswomann", -- [5]
                    "Jellytime", -- [6]
                    "Primera", -- [7]
                    "Stellâ", -- [8]
                    "Ugro", -- [9]
                    "Aquafresh", -- [10]
                    "Laird", -- [11]
                    "Oxford", -- [12]
                    "Xyen", -- [13]
                    "Advanty", -- [14]
                    "Kuckuck", -- [15]
                    "Leejenkins", -- [16]
                    "Pailor", -- [17]
                    "Squidproquo", -- [18]
                    "Viabletank", -- [19]
                    "Ballour", -- [20]
                    "Honeypot", -- [21]
                    "Katania", -- [22]
                    "Mystilè", -- [23]
                    "Pamplemousse", -- [24]
                    "Puffhead", -- [25]
                    "Inigma", -- [26]
                    "Iszell", -- [27]
                    "Knittie", -- [28]
                    "Mariku", -- [29]
                    "Raspütin", -- [30]
                    "Thepurple", -- [31]
                    "Walterpayton", -- [32]
                    "Galagus", -- [33]
                    "Nightshelf", -- [34]
                    "Wooper", -- [35]
                    "Wooper", -- [36]
                },
                ["edited"] = false,
                ["raid"] = "Naxxramas",
                ["previousTotals"] = {
                    ["Huntswomann"] = 6,
                    ["Mystilè"] = 135,
                    ["Aquafresh"] = 252,
                    ["Spatulla"] = 246,
                    ["Raspütin"] = 143,
                    ["Xyen"] = 201,
                    ["Turboboom"] = 177,
                    ["Yerblok"] = 131,
                    ["Thepurple"] = 396,
                    ["Pailor"] = 79,
                    ["Oxford"] = 518,
                    ["Athico"] = 233,
                    ["Mariku"] = 299,
                    ["Galagus"] = 174,
                    ["Katania"] = 469,
                    ["Walterpayton"] = 203,
                    ["Helldinca"] = 162,
                    ["Stellâ"] = 330,
                    ["Viabletank"] = 95,
                    ["Ballour"] = 302,
                    ["Squidproquo"] = 6,
                    ["Nightshelf"] = 312,
                    ["Leejenkins"] = 368,
                    ["Laird"] = 129,
                    ["Jellytime"] = 20,
                    ["Wooper"] = 219,
                    ["Puffhead"] = 250,
                    ["Knittie"] = 301,
                    ["Kuckuck"] = 146,
                    ["Ugro"] = 354,
                    ["Advanty"] = 628,
                    ["Inigma"] = 396,
                    ["Primera"] = 443,
                    ["Pamplemousse"] = 171,
                    ["Iszell"] = 401,
                    ["Honeypot"] = 224,
                },
                ["adjust_type"] = "",
                ["officer"] = "Viabletank",
            },
            [1621566589] = {
                ["deleted"] = false,
                ["id"] = 1621566589,
                ["dkp_change"] = 6,
                ["reason"] = "Boss Kill",
                ["boss"] = "Anub'Rekhan",
                ["names"] = {
                    "Spatulla", -- [1]
                    "Turboboom", -- [2]
                    "Athico", -- [3]
                    "Helldinca", -- [4]
                    "Huntswomann", -- [5]
                    "Jellytime", -- [6]
                    "Primera", -- [7]
                    "Stellâ", -- [8]
                    "Ugro", -- [9]
                    "Aquafresh", -- [10]
                    "Laird", -- [11]
                    "Oxford", -- [12]
                    "Xyen", -- [13]
                    "Advanty", -- [14]
                    "Kuckuck", -- [15]
                    "Leejenkins", -- [16]
                    "Pailor", -- [17]
                    "Squidproquo", -- [18]
                    "Viabletank", -- [19]
                    "Ballour", -- [20]
                    "Honeypot", -- [21]
                    "Katania", -- [22]
                    "Mystilè", -- [23]
                    "Pamplemousse", -- [24]
                    "Puffhead", -- [25]
                    "Inigma", -- [26]
                    "Iszell", -- [27]
                    "Knittie", -- [28]
                    "Mariku", -- [29]
                    "Raspütin", -- [30]
                    "Thepurple", -- [31]
                    "Walterpayton", -- [32]
                    "Galagus", -- [33]
                    "Nightshelf", -- [34]
                    "Wooper", -- [35]
                    "Wooper", -- [36]
                },
                ["edited"] = false,
                ["raid"] = "Naxxramas",
                ["previousTotals"] = {
                    ["Huntswomann"] = 0,
                    ["Mystilè"] = 129,
                    ["Aquafresh"] = 246,
                    ["Spatulla"] = 240,
                    ["Iszell"] = 395,
                    ["Xyen"] = 195,
                    ["Turboboom"] = 171,
                    ["Yerblok"] = 125,
                    ["Thepurple"] = 390,
                    ["Pailor"] = 73,
                    ["Oxford"] = 512,
                    ["Athico"] = 227,
                    ["Mariku"] = 293,
                    ["Galagus"] = 168,
                    ["Katania"] = 463,
                    ["Walterpayton"] = 197,
                    ["Helldinca"] = 156,
                    ["Stellâ"] = 324,
                    ["Viabletank"] = 89,
                    ["Ballour"] = 296,
                    ["Squidproquo"] = 0,
                    ["Nightshelf"] = 306,
                    ["Leejenkins"] = 362,
                    ["Laird"] = 123,
                    ["Jellytime"] = 14,
                    ["Wooper"] = 231,
                    ["Puffhead"] = 244,
                    ["Knittie"] = 295,
                    ["Raspütin"] = 137,
                    ["Ugro"] = 348,
                    ["Inigma"] = 390,
                    ["Advanty"] = 622,
                    ["Primera"] = 437,
                    ["Pamplemousse"] = 165,
                    ["Kuckuck"] = 140,
                    ["Honeypot"] = 218,
                },
                ["adjust_type"] = "",
                ["officer"] = "Viabletank",
            },
            [1621570325] = {
                ["deleted"] = false,
                ["id"] = 1621570325,
                ["dkp_change"] = 6,
                ["reason"] = "Boss Kill",
                ["boss"] = "Noth the Plaguebringer",
                ["names"] = {
                    "Knittie", -- [1]
                },
                ["adjust_type"] = "",
                ["previousTotals"] = {
                    ["Knittie"] = 281,
                },
                ["raid"] = "Naxxramas",
                ["edited"] = false,
                ["officer"] = "Viabletank",
            },
            [1621569665] = {
                ["deleted"] = false,
                ["id"] = 1621569665,
                ["dkp_change"] = -32,
                ["reason"] = "Item Win",
                ["names"] = {
                    "Knittie", -- [1]
                },
                ["boss"] = "",
                ["item"] = "Not Linked",
                ["edited"] = false,
                ["raid"] = "Naxxramas",
                ["previousTotals"] = {
                    ["Knittie"] = 313,
                },
                ["adjust_type"] = "",
                ["officer"] = "Viabletank",
            },
            [1621567914] = {
                ["deleted"] = false,
                ["id"] = 1621567914,
                ["dkp_change"] = 6,
                ["reason"] = "Boss Kill",
                ["boss"] = "Grand Widow Faerlina",
                ["names"] = {
                    "Wooper", -- [1]
                },
                ["edited"] = false,
                ["raid"] = "Naxxramas",
                ["previousTotals"] = {
                    ["Wooper"] = 213,
                },
                ["adjust_type"] = "",
                ["officer"] = "Viabletank",
            },
            [1621569628] = {
                ["deleted"] = false,
                ["id"] = 1621569628,
                ["dkp_change"] = -27,
                ["reason"] = "Item Win",
                ["names"] = {
                    "Aquafresh", -- [1]
                },
                ["boss"] = "",
                ["item"] = "Not Linked",
                ["edited"] = false,
                ["raid"] = "Naxxramas",
                ["previousTotals"] = {
                    ["Aquafresh"] = 264,
                },
                ["adjust_type"] = "",
                ["officer"] = "Viabletank",
            },
            [1621569573] = {
                ["deleted"] = false,
                ["id"] = 1621569573,
                ["dkp_change"] = 6,
                ["reason"] = "Boss Kill",
                ["boss"] = "Maexxna",
                ["names"] = {
                    "Spatulla", -- [1]
                    "Turboboom", -- [2]
                    "Athico", -- [3]
                    "Helldinca", -- [4]
                    "Huntswomann", -- [5]
                    "Jellytime", -- [6]
                    "Primera", -- [7]
                    "Stellâ", -- [8]
                    "Ugro", -- [9]
                    "Aquafresh", -- [10]
                    "Laird", -- [11]
                    "Oxford", -- [12]
                    "Xyen", -- [13]
                    "Advanty", -- [14]
                    "Kuckuck", -- [15]
                    "Leejenkins", -- [16]
                    "Pailor", -- [17]
                    "Squidproquo", -- [18]
                    "Viabletank", -- [19]
                    "Ballour", -- [20]
                    "Honeypot", -- [21]
                    "Katania", -- [22]
                    "Mystilè", -- [23]
                    "Pamplemousse", -- [24]
                    "Puffhead", -- [25]
                    "Inigma", -- [26]
                    "Iszell", -- [27]
                    "Knittie", -- [28]
                    "Mariku", -- [29]
                    "Raspütin", -- [30]
                    "Thepurple", -- [31]
                    "Walterpayton", -- [32]
                    "Galagus", -- [33]
                    "Nightshelf", -- [34]
                    "Wooper", -- [35]
                    "Wooper", -- [36]
                },
                ["edited"] = false,
                ["raid"] = "Naxxramas",
                ["previousTotals"] = {
                    ["Huntswomann"] = 12,
                    ["Mystilè"] = 141,
                    ["Aquafresh"] = 258,
                    ["Spatulla"] = 252,
                    ["Iszell"] = 407,
                    ["Xyen"] = 207,
                    ["Turboboom"] = 183,
                    ["Yerblok"] = 137,
                    ["Thepurple"] = 402,
                    ["Pailor"] = 85,
                    ["Oxford"] = 524,
                    ["Athico"] = 239,
                    ["Mariku"] = 305,
                    ["Galagus"] = 180,
                    ["Katania"] = 475,
                    ["Walterpayton"] = 209,
                    ["Helldinca"] = 168,
                    ["Stellâ"] = 336,
                    ["Viabletank"] = 101,
                    ["Ballour"] = 308,
                    ["Squidproquo"] = 12,
                    ["Nightshelf"] = 318,
                    ["Leejenkins"] = 374,
                    ["Laird"] = 135,
                    ["Jellytime"] = 26,
                    ["Wooper"] = 225,
                    ["Puffhead"] = 256,
                    ["Knittie"] = 307,
                    ["Raspütin"] = 149,
                    ["Ugro"] = 360,
                    ["Inigma"] = 402,
                    ["Advanty"] = 634,
                    ["Primera"] = 449,
                    ["Pamplemousse"] = 177,
                    ["Kuckuck"] = 152,
                    ["Honeypot"] = 230,
                },
                ["adjust_type"] = "",
                ["officer"] = "Viabletank",
            },
            [1622385784] = {
                ["deleted"] = false,
                ["id"] = 1622385784,
                ["dkp_change"] = 10,
                ["reason"] = "Boss Kill",
                ["boss"] = "",
                ["names"] = {
                    "Ablunkin", -- [1]
                },
                ["adjust_type"] = "",
                ["previousTotals"] = {
                    ["Ablunkin"] = 0,
                },
                ["raid"] = "Gruul's Lair",
                ["edited"] = false,
                ["officer"] = "Pantheonbank",
            },
            [1621567090] = {
                ["deleted"] = false,
                ["id"] = 1621567090,
                ["dkp_change"] = -24,
                ["reason"] = "Item Win",
                ["names"] = {
                    "Wooper", -- [1]
                },
                ["boss"] = "",
                ["item"] = "Not Linked",
                ["edited"] = false,
                ["raid"] = "Naxxramas",
                ["previousTotals"] = {
                    ["Wooper"] = 237,
                },
                ["adjust_type"] = "",
                ["officer"] = "Viabletank",
            },
            [1622386874] = {
                ["deleted"] = false,
                ["id"] = 1622386874,
                ["dkp_change"] = 10,
                ["reason"] = "Boss Kill",
                ["boss"] = "",
                ["names"] = {
                    "Ablunkin", -- [1]
                },
                ["adjust_type"] = "",
                ["previousTotals"] = {
                    ["Ablunkin"] = 0,
                },
                ["raid"] = "Black Temple",
                ["edited"] = false,
                ["officer"] = "Neekio",
            },
            [1621571778] = {
                ["deleted"] = false,
                ["id"] = 1621571778,
                ["dkp_change"] = -93,
                ["reason"] = "Item Win",
                ["names"] = {
                    "Galagus", -- [1]
                },
                ["boss"] = "",
                ["item"] = "Not Linked",
                ["adjust_type"] = "",
                ["previousTotals"] = {
                    ["Galagus"] = 186,
                },
                ["raid"] = "Naxxramas",
                ["edited"] = false,
                ["officer"] = "Snaildaddy",
            },
            [1622385727] = {
                ["deleted"] = false,
                ["id"] = 1622385727,
                ["dkp_change"] = 10,
                ["reason"] = "Boss Kill",
                ["boss"] = "",
                ["names"] = {
                    "Ablunkin", -- [1]
                },
                ["adjust_type"] = "",
                ["previousTotals"] = {
                    ["Ablunkin"] = 0,
                },
                ["raid"] = "Gruul's Lair",
                ["edited"] = false,
                ["officer"] = "Pantheonbank",
            },
        }
    }

    local server_time = GetServerTime()

    for i=1, 500 do
        testDB[server_time+i] = test_data
    end

    Dev:ClockSpeed(true, 'CreateLargeTestDB')
end