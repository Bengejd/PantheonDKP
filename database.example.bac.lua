
MonDKP_DB = {
	["MinBidBySlot"] = {
		["Other"] = 1,
		["OneHanded"] = 1,
		["Bracers"] = 1,
		["Neck"] = 1,
		["Belt"] = 1,
		["Hands"] = 1,
		["Boots"] = 1,
		["Ring"] = 1,
		["Cloak"] = 1,
		["Head"] = 1,
		["Trinket"] = 1,
		["Chest"] = 1,
		["OffHand"] = 1,
		["Range"] = 1,
		["TwoHanded"] = 1,
		["Shoulders"] = 1,
		["Legs"] = 1,
	},
	["raiders"] = {
	},
	["bossargs"] = {
		["CurrentRaidZone"] = "Onyxia's Lair",
		["LastKilledBoss"] = "Onyxia",
		["RecentZones"] = {
			"Ironforge", -- [1]
			"Dire Maul", -- [2]
			"Moonglade", -- [3]
			"Onyxia's Lair", -- [4]
			"Wetlands", -- [5]
			"Dun Morogh", -- [6]
			"Darnassus", -- [7]
			"Warsong Gulch", -- [8]
			"Blackrock Spire", -- [9]
			"Searing Gorge", -- [10]
			"Molten Core", -- [11]
			"Blackrock Mountain", -- [12]
			"Stormwind City", -- [13]
			"Deeprun Tram", -- [14]
			"Alterac Valley", -- [15]
		},
		["LastKilledNPC"] = {
			"Onyxia", -- [1]
			"Onyxian Whelp", -- [2]
			"Onyxian Warder", -- [3]
			"Advanced Target Dummy", -- [4]
			"Ragnaros", -- [5]
			"Summoned Skeleton", -- [6]
			"Majordomo Executus", -- [7]
			"Flamewaker Healer", -- [8]
			"Flamewaker Elite", -- [9]
			"Core Rager", -- [10]
			"Golemagg the Incinerator", -- [11]
			"Sulfuron Harbinger", -- [12]
			"Flamewaker Priest", -- [13]
			"Lava Surger", -- [14]
			"Lava Annihilator", -- [15]
		},
	},
	["DKPBonus"] = {
		["IncStandby"] = false,
		["IntervalBonus"] = 15,
		["CompletionBonus"] = 10,
		["OnTimeBonus"] = 10,
		["UnexcusedAbsence"] = -25,
		["NewBossKillBonus"] = 10,
		["BossKillBonus"] = 10,
		["GiveRaidStart"] = false,
		["DecayPercentage"] = 20,
		["BidTimer"] = 20,
	},
	["modes"] = {
		["SameZoneOnly"] = false,
		["ZeroSumBidType"] = "Static",
		["channels"] = {
			["raid"] = true,
			["whisper"] = true,
			["guild"] = true,
		},
		["Inflation"] = 0,
		["rounding"] = 0,
		["ZeroSumBank"] = {
			{
				["loot"] = "|cffffffff|Hitem:9206::::::::60:::::::|h[Elixir of Giants]|h|r",
				["cost"] = 2,
			}, -- [1]
			{
				["loot"] = "|cffffffff|Hitem:3825::::::::60:::::::|h[Elixir of Fortitude]|h|r",
				["cost"] = 1,
			}, -- [2]
			{
				["loot"] = "|cffffffff|Hitem:3825::::::::60:::::::|h[Elixir of Fortitude]|h|r",
				["cost"] = 10,
			}, -- [3]
			["balance"] = 13,
		},
		["mode"] = "Zero Sum",
		["rolls"] = {
			["min"] = 1,
			["AddToMax"] = 0,
			["max"] = 100,
			["UsePerc"] = false,
		},
		["MaximumBid"] = 0,
		["CostSelection"] = "Second Bidder",
		["increment"] = 60,
		["ZeroSumStandby"] = false,
		["AddToNegative"] = false,
		["SubZeroBidding"] = true,
		["AllowNegativeBidders"] = false,
		["costvalue"] = "Integer",
		["AntiSnipe"] = 0,
		["OnlineOnly"] = false,
	},
	["timerpos"] = {
		["y"] = 145.524765014648,
		["x"] = 6.32139873504639,
		["point"] = "BOTTOM",
		["relativePoint"] = "BOTTOM",
	},
	["defaults"] = {
		["DKPHistoryLimit"] = 2500,
		["AutoOpenBid"] = true,
		["MonDKPScaleSize"] = 1,
		["BidTimerSize"] = 1,
		["installed210"] = 1577048719,
		["CurrentGuild"] = {
		},
		["HideChangeLogs"] = 20102,
		["SupressTells"] = true,
		["ChatFrames"] = {
			["General"] = true,
			["Combat Log"] = true,
		},
		["supressNotifications"] = false,
		["TooltipHistoryCount"] = 5,
		["HistoryLimit"] = 2500,
	},
}
MonDKP_Loot = {
	{
		["player"] = "Xamina",
		["loot"] = "|cff1eff00|Hitem:10077::::::881:1656616064:60:::1::::|h[Lord's Breastplate of the Eagle]|h|r",
		["zone"] = "Ironforge",
		["date"] = 1576649200,
		["cost"] = 6,
		["boss"] = "Lucifron",
		["index"] = "Neekio-1576649200",
	}, -- [1]
	{
		["player"] = "Eolith",
		["loot"] = "|cffffffff|Hitem:3825::::::::60:::::::|h[Elixir of Fortitude]|h|r",
		["zone"] = "Ironforge",
		["date"] = 1576648912,
		["boss"] = "Lucifron",
		["cost"] = 10,
		["index"] = "Neekio-1576648912",
	}, -- [2]
	{
		["player"] = "Eolith",
		["loot"] = "|cff1eff00|Hitem:7910::::::::60:::::::|h[Star Ruby]|h|r",
		["zone"] = "Ironforge",
		["date"] = 1576648182,
		["cost"] = 5,
		["boss"] = "Lucifron",
		["index"] = "Neekio-1576648182",
	}, -- [3]
	{
		["player"] = "Neekio",
		["loot"] = "|cff1eff00|Hitem:10077::::::881:1656616064:60:::1::::|h[Lord's Breastplate of the Eagle]|h|r 1",
		["zone"] = "Ironforge",
		["date"] = 1576647866,
		["cost"] = 1,
		["boss"] = "Lucifron",
		["index"] = "Neekio-1576647866",
	}, -- [4]
	{
		["player"] = "Neekio",
		["loot"] = "|cffffffff|Hitem:17056::::::::60:::::::|h[Light Feather]|h|r",
		["zone"] = "Ironforge",
		["date"] = 1576647600,
		["cost"] = 2,
		["boss"] = "Lucifron",
		["index"] = "Neekio-1576647600",
	}, -- [5]
	{
		["player"] = "Sparklenips",
		["loot"] = "|cff0070dd|Hitem:13968::::::::60:::11::::|h[Eye of the Beast]|h|r",
		["zone"] = "Ironforge",
		["date"] = 1576647385,
		["cost"] = 1,
		["boss"] = "Lucifron",
		["index"] = "Neekio-1576647385",
	}, -- [6]
	{
		["player"] = "Neekio",
		["loot"] = "|cffffffff|Hitem:3825::::::::60:::::::|h[Elixir of Fortitude]|h|r",
		["zone"] = "Ironforge",
		["date"] = 1576647276,
		["boss"] = "Lucifron",
		["cost"] = 1,
		["index"] = "Neekio-1576647276",
	}, -- [7]
	{
		["player"] = "Xamina",
		["loot"] = "|cffffffff|Hitem:9206::::::::60:::::::|h[Elixir of Giants]|h|r",
		["zone"] = "Ironforge",
		["date"] = 1576647211,
		["boss"] = "Lucifron",
		["cost"] = 2,
		["index"] = "Neekio-1576647211",
	}, -- [8]
	{
		["player"] = "Sparklenips",
		["loot"] = "|cffa335ee|Hitem:18842:2504:::::::60:::::::|h[Staff of Dominance]|h|r",
		["zone"] = "Ironforge",
		["date"] = 1576647130,
		["cost"] = 3,
		["boss"] = "Lucifron",
		["index"] = "Neekio-1576647130",
	}, -- [9]
	{
		["player"] = "Xamina",
		["loot"] = "|cffffffff|Hitem:6367::::::::60:::::::|h[Big Iron Fishing Pole]|h|r",
		["zone"] = "Ironforge",
		["date"] = 1576646914,
		["cost"] = 5,
		["boss"] = "Lucifron",
		["index"] = "Neekio-1576646914",
	}, -- [10]
	{
		["player"] = "Sparklenips",
		["loot"] = "|cff1eff00|Hitem:10077::::::881:1656616064:60:::1::::|h[Lord's Breastplate of the Eagle]|h|r",
		["zone"] = "Ironforge",
		["date"] = 1576646755,
		["cost"] = 5,
		["boss"] = "Lucifron",
		["index"] = "Neekio-1576646755",
	}, -- [11]
	["seed"] = 0,
}
MonDKP_DKPTable = {
	{
		["previous_dkp"] = 0,
		["dkp"] = 293,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 750,
		["player"] = "Aku",
		["class"] = "ROGUE",
		["spec"] = "Combat (19/32/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [1]
	{
		["previous_dkp"] = 0,
		["dkp"] = 310,
		["class"] = "PRIEST",
		["lifetime_gained"] = 310,
		["role"] = "Healer",
		["lifetime_spent"] = 0,
		["spec"] = "Holy (11/35/5)",
		["player"] = "Apolyne",
		["rankName"] = "None",
		["rank"] = 20,
	}, -- [2]
	{
		["previous_dkp"] = 0,
		["dkp"] = 380,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 400,
		["player"] = "Arkleis",
		["class"] = "PALADIN",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [3]
	{
		["previous_dkp"] = 0,
		["dkp"] = 98,
		["class"] = "PALADIN",
		["lifetime_gained"] = 380,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Artorion",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [4]
	{
		["previous_dkp"] = 0,
		["dkp"] = 340,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 520,
		["player"] = "Astlan",
		["class"] = "PALADIN",
		["spec"] = "Retribution (11/9/31)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [5]
	{
		["previous_dkp"] = 0,
		["dkp"] = 401,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 710,
		["player"] = "Athico",
		["class"] = "HUNTER",
		["spec"] = "Marksmanship (2/31/18)",
		["role"] = "Range DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [6]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "PRIEST",
		["lifetime_gained"] = -32,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Awwswitch",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [7]
	{
		["previous_dkp"] = 0,
		["dkp"] = 681,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 750,
		["player"] = "Ballour",
		["class"] = "PRIEST",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [8]
	{
		["previous_dkp"] = 0,
		["dkp"] = 225,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 710,
		["player"] = "Bigbootyhoho",
		["class"] = "HUNTER",
		["spec"] = "Marksmanship (20/31/0)",
		["role"] = "Range DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [9]
	{
		["previous_dkp"] = 0,
		["dkp"] = 400,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 400,
		["role"] = "No Role Detected",
		["class"] = "WARRIOR",
		["spec"] = "No Spec Reported",
		["player"] = "Bruhtato",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [10]
	{
		["previous_dkp"] = 0,
		["dkp"] = 90,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 720,
		["player"] = "Bugaboom",
		["class"] = "MAGE",
		["spec"] = "Arcane (31/0/20)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [11]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "WARRIOR",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Buldur",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [12]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["class"] = "HUNTER",
		["lifetime_gained"] = 210,
		["role"] = "No Role Detected",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Bunsoffury",
		["dkp"] = 210,
		["rank"] = 20,
	}, -- [13]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 600,
		["role"] = "Range DPS",
		["dkp"] = 346,
		["class"] = "HUNTER",
		["player"] = "Bádtothebow",
		["spec"] = "Marksmanship (0/31/20)",
		["rank"] = 10,
	}, -- [14]
	{
		["previous_dkp"] = 0,
		["dkp"] = 260,
		["class"] = "WARLOCK",
		["lifetime_gained"] = 260,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Calixta",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [15]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "PALADIN",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Captnutsack",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [16]
	{
		["previous_dkp"] = 0,
		["dkp"] = 281,
		["spec"] = "No Spec Reported",
		["lifetime_gained"] = 620,
		["player"] = "Capybara",
		["class"] = "WARLOCK",
		["rankName"] = "Champion",
		["role"] = "No Role Detected",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [17]
	{
		["previous_dkp"] = 0,
		["dkp"] = 94,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 100,
		["player"] = "Celestaes",
		["rankName"] = "None",
		["class"] = "PALADIN",
		["spec"] = "Holy (31/0/20)",
		["role"] = "Healer",
		["rank"] = 10,
	}, -- [18]
	{
		["previous_dkp"] = 0,
		["dkp"] = 100,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 120,
		["player"] = "Chaintoker",
		["class"] = "PALADIN",
		["spec"] = "Holy (31/20/0)",
		["role"] = "Healer",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [19]
	{
		["previous_dkp"] = 0,
		["dkp"] = 110,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 130,
		["player"] = "Cheeza",
		["class"] = "WARRIOR",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [20]
	{
		["previous_dkp"] = 0,
		["dkp"] = 134,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 690,
		["player"] = "Chipgizmo",
		["class"] = "MAGE",
		["spec"] = "Frost (11/0/40)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [21]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "DRUID",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Claireamy",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [22]
	{
		["previous_dkp"] = 0,
		["dkp"] = 222,
		["class"] = "MAGE",
		["lifetime_gained"] = 280,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Coldjuice",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [23]
	{
		["previous_dkp"] = 0,
		["dkp"] = 215,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 260,
		["player"] = "Corseau",
		["class"] = "DRUID",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [24]
	{
		["previous_dkp"] = 0,
		["dkp"] = 42,
		["class"] = "PALADIN",
		["lifetime_gained"] = 153,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Crazymarbles",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [25]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["class"] = "WARLOCK",
		["lifetime_gained"] = 100,
		["role"] = "No Role Detected",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Curseberry",
		["dkp"] = 72,
		["rank"] = 20,
	}, -- [26]
	{
		["previous_dkp"] = 0,
		["dkp"] = 160,
		["class"] = "MAGE",
		["lifetime_gained"] = 160,
		["player"] = "Cyndr",
		["role"] = "Caster DPS",
		["spec"] = "Frost (15/0/36)",
		["rankName"] = "Champion",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [27]
	{
		["previous_dkp"] = 0,
		["dkp"] = 307,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 710,
		["player"] = "Cyskul",
		["class"] = "HUNTER",
		["spec"] = "Marksmanship (5/31/15)",
		["role"] = "Range DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [28]
	{
		["previous_dkp"] = 0,
		["dkp"] = 280,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 570,
		["player"] = "Dalia",
		["class"] = "WARLOCK",
		["spec"] = "Affliction (30/0/21)",
		["role"] = "Caster DPS",
		["rankName"] = "Olympian",
		["rank"] = 2,
	}, -- [29]
	{
		["previous_dkp"] = 0,
		["dkp"] = 361,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 610,
		["player"] = "Dasmook",
		["class"] = "WARLOCK",
		["spec"] = "Destruction (7/5/39)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [30]
	{
		["previous_dkp"] = 0,
		["dkp"] = 450,
		["class"] = "HUNTER",
		["lifetime_gained"] = 450,
		["role"] = "Range DPS",
		["spec"] = "Marksmanship (5/46/0)",
		["lifetime_spent"] = 0,
		["player"] = "Deeprider",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [31]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["class"] = "PALADIN",
		["lifetime_gained"] = 560,
		["role"] = "Melee DPS",
		["spec"] = "Retribution (11/9/31)",
		["lifetime_spent"] = 0,
		["player"] = "Dolamroth",
		["dkp"] = 160,
		["rank"] = 20,
	}, -- [32]
	{
		["previous_dkp"] = 0,
		["dkp"] = 430,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 450,
		["player"] = "Drrl",
		["class"] = "DRUID",
		["spec"] = "Balance (30/0/21)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [33]
	{
		["previous_dkp"] = 0,
		["dkp"] = 220,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 1830,
		["player"] = "Dwindle",
		["class"] = "ROGUE",
		["spec"] = "Combat (15/31/5)",
		["role"] = "Melee DPS",
		["rankName"] = "Demi-god",
		["rank"] = 3,
	}, -- [34]
	{
		["previous_dkp"] = 0,
		["dkp"] = 125,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 145,
		["player"] = "Emmyy",
		["class"] = "DRUID",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [35]
	{
		["previous_dkp"] = 0,
		["dkp"] = 625,
		["lifetime_spent"] = -15,
		["lifetime_gained"] = 715,
		["player"] = "Eolith",
		["class"] = "MAGE",
		["spec"] = "Arcane (31/0/20)",
		["role"] = "Caster DPS",
		["rankName"] = "Demi-god",
		["rank"] = 3,
	}, -- [36]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "PALADIN",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Erectdwarf",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [37]
	{
		["previous_dkp"] = 0,
		["dkp"] = 402,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 740,
		["player"] = "Evangelina",
		["class"] = "PRIEST",
		["spec"] = "Discipline (32/19/0)",
		["role"] = "Healer",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [38]
	{
		["previous_dkp"] = 0,
		["dkp"] = 265,
		["class"] = "PRIEST",
		["lifetime_gained"] = 380,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Fawntine",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [39]
	{
		["previous_dkp"] = 0,
		["dkp"] = 119,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 535,
		["player"] = "Finryr",
		["class"] = "WARRIOR",
		["spec"] = "Fury (17/34/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [40]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "MAGE",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Fiz",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [41]
	{
		["previous_dkp"] = 0,
		["dkp"] = 165,
		["class"] = "MAGE",
		["lifetime_gained"] = 165,
		["player"] = "Flatulent",
		["role"] = "Caster DPS",
		["spec"] = "Frost (19/0/32)",
		["rankName"] = "Champion",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [42]
	{
		["previous_dkp"] = 0,
		["dkp"] = 108,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 120,
		["player"] = "Forerunner",
		["rankName"] = "None",
		["class"] = "PALADIN",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rank"] = 10,
	}, -- [43]
	{
		["previous_dkp"] = 0,
		["dkp"] = 300,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 610,
		["player"] = "Fradge",
		["class"] = "WARRIOR",
		["spec"] = "Fury (17/34/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [44]
	{
		["previous_dkp"] = 0,
		["dkp"] = 630,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 650,
		["player"] = "Galagus",
		["class"] = "WARRIOR",
		["spec"] = "Fury (0/32/19)",
		["role"] = "Melee DPS",
		["rankName"] = "Demi-god",
		["rank"] = 3,
	}, -- [45]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "ROGUE",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Getcrit",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [46]
	{
		["previous_dkp"] = 0,
		["dkp"] = 615,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 710,
		["player"] = "Girlslayer",
		["class"] = "WARRIOR",
		["spec"] = "Fury (0/31/20)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [47]
	{
		["previous_dkp"] = 0,
		["dkp"] = 100,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 120,
		["player"] = "Gnomenuts",
		["class"] = "MAGE",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Demi-god",
		["rank"] = 3,
	}, -- [48]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "PALADIN",
		["lifetime_gained"] = 0,
		["role"] = "Healer",
		["spec"] = "Holy (11/4/0)",
		["lifetime_spent"] = 0,
		["player"] = "Gregord",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [49]
	{
		["previous_dkp"] = 0,
		["dkp"] = 272,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 715,
		["player"] = "Grymmlock",
		["class"] = "WARLOCK",
		["spec"] = "Destruction (9/21/21)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [50]
	{
		["previous_dkp"] = 0,
		["dkp"] = 99,
		["class"] = "HUNTER",
		["lifetime_gained"] = 110,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Hazie",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [51]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 95,
		["player"] = "Hew",
		["class"] = "WARRIOR",
		["role"] = "Melee DPS",
		["spec"] = "Fury (17/34/0)",
		["dkp"] = 90,
		["rank"] = 10,
	}, -- [52]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["class"] = "ROGUE",
		["lifetime_gained"] = 290,
		["role"] = "Melee DPS",
		["spec"] = "Combat (19/32/0)",
		["lifetime_spent"] = 0,
		["player"] = "Hititnquitit",
		["dkp"] = 82,
		["rank"] = 20,
	}, -- [53]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "MAGE",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Holychaos",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [54]
	{
		["previous_dkp"] = 0,
		["dkp"] = 390,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 510,
		["player"] = "Holycritpal",
		["class"] = "PALADIN",
		["spec"] = "Holy (35/13/3)",
		["role"] = "Healer",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [55]
	{
		["previous_dkp"] = 0,
		["dkp"] = 362,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 510,
		["player"] = "Honeypot",
		["class"] = "PRIEST",
		["spec"] = "Holy (21/30/0)",
		["role"] = "Healer",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [56]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "HUNTER",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Huenolairc",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [57]
	{
		["previous_dkp"] = 0,
		["dkp"] = 690,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 710,
		["player"] = "Ihurricanel",
		["class"] = "WARLOCK",
		["spec"] = "Destruction (9/21/21)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [58]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["class"] = "DRUID",
		["lifetime_gained"] = 540,
		["role"] = "Caster DPS",
		["spec"] = "Balance (35/0/16)",
		["lifetime_spent"] = 0,
		["player"] = "Inebriated",
		["dkp"] = 375,
		["rank"] = 20,
	}, -- [59]
	{
		["previous_dkp"] = 0,
		["dkp"] = 220,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 740,
		["player"] = "Inigma",
		["class"] = "ROGUE",
		["spec"] = "Combat (15/31/5)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [60]
	{
		["previous_dkp"] = 0,
		["dkp"] = 20,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 20,
		["player"] = "Insub",
		["rankName"] = "None",
		["role"] = "Healer",
		["spec"] = "Restoration (15/0/36)",
		["class"] = "DRUID",
		["rank"] = 10,
	}, -- [61]
	{
		["previous_dkp"] = 0,
		["dkp"] = 390,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 818,
		["player"] = "Ithgar",
		["class"] = "HUNTER",
		["spec"] = "Marksmanship (20/31/0)",
		["role"] = "Range DPS",
		["rankName"] = "Legend",
		["rank"] = 4,
	}, -- [62]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "PRIEST",
		["lifetime_gained"] = 0,
		["player"] = "Jeabus",
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["rankName"] = "Champion",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [63]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "HUNTER",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Jellytime",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [64]
	{
		["previous_dkp"] = 0,
		["dkp"] = 390,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 410,
		["player"] = "Junglemain",
		["class"] = "DRUID",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [65]
	{
		["previous_dkp"] = 0,
		["dkp"] = 199,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 430,
		["player"] = "Kalijah",
		["class"] = "DRUID",
		["spec"] = "Balance (30/0/21)",
		["role"] = "Caster DPS",
		["rankName"] = "Legend",
		["rank"] = 4,
	}, -- [66]
	{
		["previous_dkp"] = 0,
		["dkp"] = 225,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 460,
		["player"] = "Kalita",
		["class"] = "WARRIOR",
		["spec"] = "Fury (17/34/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [67]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "HUNTER",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Katherra",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [68]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 240,
		["role"] = "Melee DPS",
		["dkp"] = 240,
		["class"] = "ROGUE",
		["player"] = "Kharlin",
		["spec"] = "Combat (20/31/0)",
		["rank"] = 10,
	}, -- [69]
	{
		["previous_dkp"] = 0,
		["dkp"] = 156,
		["spec"] = "Combat (19/32/0)",
		["lifetime_gained"] = 315,
		["player"] = "Killionaire",
		["class"] = "ROGUE",
		["lifetime_spent"] = 0,
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [70]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "MAGE",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Kinter",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [71]
	{
		["previous_dkp"] = 0,
		["dkp"] = 20,
		["class"] = "PALADIN",
		["lifetime_gained"] = 20,
		["player"] = "Kithala",
		["role"] = "Healer",
		["spec"] = "Holy (32/19/0)",
		["rankName"] = "Champion",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [72]
	{
		["previous_dkp"] = 0,
		["dkp"] = 150,
		["class"] = "WARLOCK",
		["lifetime_gained"] = 150,
		["role"] = "Caster DPS",
		["spec"] = "Affliction (30/0/21)",
		["lifetime_spent"] = 0,
		["player"] = "Kittysnake",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [73]
	{
		["previous_dkp"] = 0,
		["dkp"] = 130,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 150,
		["player"] = "Kuckuck",
		["class"] = "PALADIN",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [74]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "MAGE",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Laird",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [75]
	{
		["previous_dkp"] = 0,
		["dkp"] = 5,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 25,
		["player"] = "Landlubbers",
		["class"] = "MAGE",
		["spec"] = "Frost (18/0/33)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [76]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "PALADIN",
		["lifetime_gained"] = 0,
		["player"] = "Lawduk",
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["rankName"] = "Champion",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [77]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 155,
		["role"] = "Tank",
		["dkp"] = 153,
		["class"] = "DRUID",
		["player"] = "Lemonz",
		["spec"] = "Feral Combat (11/33/7)",
		["rank"] = 10,
	}, -- [78]
	{
		["previous_dkp"] = 0,
		["dkp"] = 120,
		["spec"] = "No Spec Reported",
		["lifetime_gained"] = 120,
		["player"] = "Limeybeard",
		["class"] = "MAGE",
		["rankName"] = "Champion",
		["role"] = "No Role Detected",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [79]
	{
		["previous_dkp"] = 0,
		["dkp"] = 217,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 750,
		["player"] = "Lindo",
		["class"] = "WARLOCK",
		["spec"] = "Affliction (30/0/21)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [80]
	{
		["previous_dkp"] = 0,
		["dkp"] = 409,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 472,
		["player"] = "Littleshiv",
		["class"] = "ROGUE",
		["spec"] = "Combat (19/32/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [81]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "ROGUE",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Lixx",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [82]
	{
		["previous_dkp"] = 0,
		["dkp"] = 264,
		["class"] = "WARRIOR",
		["lifetime_gained"] = 350,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Madmartagen",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [83]
	{
		["previous_dkp"] = 0,
		["dkp"] = 279,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 600,
		["player"] = "Mallix",
		["class"] = "HUNTER",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [84]
	{
		["previous_dkp"] = 0,
		["dkp"] = 452,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 530,
		["player"] = "Mariku",
		["class"] = "ROGUE",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [85]
	{
		["previous_dkp"] = 0,
		["dkp"] = 330,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 500,
		["player"] = "Maryjohanna",
		["class"] = "PALADIN",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Legend",
		["rank"] = 4,
	}, -- [86]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["class"] = "ROGUE",
		["lifetime_gained"] = 570,
		["role"] = "Melee DPS",
		["spec"] = "Combat (19/32/0)",
		["lifetime_spent"] = 0,
		["player"] = "Mcstaberson",
		["dkp"] = 331,
		["rank"] = 20,
	}, -- [87]
	{
		["previous_dkp"] = 0,
		["dkp"] = 238,
		["class"] = "WARRIOR",
		["lifetime_gained"] = 260,
		["role"] = "Melee DPS",
		["spec"] = "Fury (17/34/0)",
		["lifetime_spent"] = 0,
		["player"] = "Mihai",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [88]
	{
		["previous_dkp"] = 0,
		["dkp"] = 240,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 260,
		["player"] = "Moldyrag",
		["class"] = "MAGE",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [89]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 580,
		["role"] = "No Role Detected",
		["dkp"] = 374,
		["class"] = "PRIEST",
		["player"] = "Mongous",
		["spec"] = "No Spec Reported",
		["rank"] = 10,
	}, -- [90]
	{
		["previous_dkp"] = 0,
		["dkp"] = 380,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 750,
		["player"] = "Morphintyme",
		["class"] = "DRUID",
		["spec"] = "Restoration (21/0/30)",
		["role"] = "Healer",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [91]
	{
		["previous_dkp"] = 0,
		["dkp"] = 328,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 650,
		["player"] = "Mozzarella",
		["class"] = "ROGUE",
		["spec"] = "Combat (19/32/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Legend",
		["rank"] = 4,
	}, -- [92]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "ROGUE",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Mujinn",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [93]
	{
		["previous_dkp"] = 0,
		["dkp"] = 690,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 700,
		["role"] = "Melee DPS",
		["class"] = "ROGUE",
		["spec"] = "Combat (15/31/5)",
		["player"] = "Mystile",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [94]
	{
		["previous_dkp"] = 0,
		["dkp"] = 417,
		["lifetime_spent"] = -4,
		["lifetime_gained"] = 745,
		["player"] = "Neekio",
		["class"] = "DRUID",
		["spec"] = "Feral Combat (11/33/7)",
		["role"] = "Tank",
		["rankName"] = "Titan",
		["rank"] = 0,
	}, -- [95]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "PALADIN",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Neotemplar",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [96]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["class"] = "WARRIOR",
		["lifetime_gained"] = 410,
		["role"] = "Melee DPS",
		["spec"] = "Fury (17/34/0)",
		["lifetime_spent"] = 0,
		["player"] = "Nightshelf",
		["dkp"] = 370,
		["rank"] = 20,
	}, -- [97]
	{
		["previous_dkp"] = 0,
		["dkp"] = 126,
		["class"] = "WARLOCK",
		["lifetime_gained"] = 140,
		["role"] = "No Role Reported",
		["lifetime_spent"] = 0,
		["spec"] = "No Spec Reported",
		["player"] = "Nubslayer",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [98]
	{
		["previous_dkp"] = 0,
		["dkp"] = 533,
		["spec"] = "Holy (30/21/0)",
		["lifetime_gained"] = 605,
		["player"] = "Odin",
		["class"] = "PALADIN",
		["rankName"] = "Champion",
		["role"] = "Healer",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [99]
	{
		["previous_dkp"] = 0,
		["dkp"] = 110,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 130,
		["player"] = "Oldmanmike",
		["class"] = "DRUID",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [100]
	{
		["previous_dkp"] = 0,
		["dkp"] = 362,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 640,
		["player"] = "Ones",
		["class"] = "PALADIN",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [101]
	{
		["previous_dkp"] = 0,
		["dkp"] = 654,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 730,
		["player"] = "Oragan",
		["class"] = "WARRIOR",
		["spec"] = "Protection (11/5/35)",
		["role"] = "Tank",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [102]
	{
		["previous_dkp"] = 0,
		["dkp"] = 690,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 710,
		["player"] = "Oxford",
		["class"] = "MAGE",
		["spec"] = "Arcane (31/0/20)",
		["role"] = "Caster DPS",
		["rankName"] = "Olympian",
		["rank"] = 2,
	}, -- [103]
	{
		["previous_dkp"] = 0,
		["dkp"] = 112,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 150,
		["player"] = "Pamplemousse",
		["class"] = "PRIEST",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [104]
	{
		["previous_dkp"] = 0,
		["dkp"] = 279,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 560,
		["player"] = "Papasquach",
		["class"] = "PALADIN",
		["spec"] = "Holy (32/0/19)",
		["role"] = "Healer",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [105]
	{
		["previous_dkp"] = 0,
		["dkp"] = 100,
		["class"] = "WARRIOR",
		["lifetime_gained"] = 100,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Partywolf",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [106]
	{
		["previous_dkp"] = 0,
		["dkp"] = 616,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 730,
		["player"] = "Philonious",
		["class"] = "PRIEST",
		["spec"] = "Holy (21/30/0)",
		["role"] = "Healer",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [107]
	{
		["previous_dkp"] = 0,
		["dkp"] = 670,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 690,
		["player"] = "Primera",
		["class"] = "HUNTER",
		["spec"] = "Marksmanship (5/31/15)",
		["role"] = "Range DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [108]
	{
		["previous_dkp"] = 0,
		["dkp"] = 130,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 150,
		["player"] = "Puffypoose",
		["class"] = "ROGUE",
		["spec"] = "Subtlety (21/3/27)",
		["role"] = "Melee DPS",
		["rankName"] = "Demi-god",
		["rank"] = 3,
	}, -- [109]
	{
		["previous_dkp"] = 0,
		["dkp"] = 180,
		["class"] = "WARRIOR",
		["lifetime_gained"] = 180,
		["player"] = "Qew",
		["role"] = "Melee DPS",
		["spec"] = "Fury (19/32/0)",
		["rankName"] = "Champion",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [110]
	{
		["previous_dkp"] = 0,
		["dkp"] = 442,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 735,
		["player"] = "Raspütin",
		["class"] = "WARLOCK",
		["spec"] = "Destruction (9/21/21)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [111]
	{
		["previous_dkp"] = 0,
		["dkp"] = 168,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 490,
		["player"] = "Reina",
		["class"] = "WARRIOR",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [112]
	{
		["previous_dkp"] = 0,
		["dkp"] = 138,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 440,
		["player"] = "Retkin",
		["class"] = "WARRIOR",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [113]
	{
		["previous_dkp"] = 0,
		["dkp"] = 367,
		["class"] = "PRIEST",
		["lifetime_gained"] = 547,
		["role"] = "No Role Detected",
		["lifetime_spent"] = 0,
		["spec"] = "No Spec Reported",
		["player"] = "Rez",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [114]
	{
		["previous_dkp"] = 0,
		["dkp"] = 321,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 590,
		["player"] = "Schnazzy",
		["class"] = "WARRIOR",
		["spec"] = "Fury (17/34/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [115]
	{
		["previous_dkp"] = 0,
		["dkp"] = 130,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 480,
		["player"] = "Shinynickels",
		["class"] = "WARRIOR",
		["spec"] = "Fury (18/33/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [116]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "HUNTER",
		["lifetime_gained"] = 0,
		["player"] = "Sjada",
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["rankName"] = "Champion",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [117]
	{
		["previous_dkp"] = 0,
		["dkp"] = 244,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 690,
		["player"] = "Slipperyjohn",
		["class"] = "ROGUE",
		["spec"] = "Combat (19/32/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [118]
	{
		["previous_dkp"] = 0,
		["dkp"] = 279,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 710,
		["player"] = "Snaildaddy",
		["class"] = "WARRIOR",
		["spec"] = "Fury (17/34/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Demi-god",
		["rank"] = 3,
	}, -- [119]
	{
		["previous_dkp"] = 0,
		["dkp"] = 130,
		["class"] = "MAGE",
		["lifetime_gained"] = 130,
		["role"] = "Caster DPS",
		["lifetime_spent"] = 0,
		["spec"] = "Frost (11/0/40)",
		["player"] = "Solana",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [120]
	{
		["previous_dkp"] = 0,
		["dkp"] = 401,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 520,
		["player"] = "Solidsix",
		["class"] = "PALADIN",
		["spec"] = "Holy (35/11/5)",
		["role"] = "Healer",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [121]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "PRIEST",
		["lifetime_gained"] = -32,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Solten",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [122]
	{
		["previous_dkp"] = 0,
		["dkp"] = 450,
		["lifetime_spent"] = -9,
		["lifetime_gained"] = 600,
		["player"] = "Sparklenips",
		["class"] = "WARLOCK",
		["spec"] = "Destruction (9/21/21)",
		["role"] = "Caster DPS",
		["rankName"] = "Olympian",
		["rank"] = 2,
	}, -- [123]
	{
		["previous_dkp"] = 0,
		["dkp"] = 323,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 640,
		["player"] = "Spellbender",
		["class"] = "MAGE",
		["spec"] = "Frost (11/0/40)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [124]
	{
		["previous_dkp"] = 0,
		["dkp"] = 20,
		["class"] = "MAGE",
		["lifetime_gained"] = 20,
		["player"] = "Sprocket",
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["rankName"] = "Champion",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [125]
	{
		["previous_dkp"] = 0,
		["dkp"] = 205,
		["class"] = "PRIEST",
		["lifetime_gained"] = 410,
		["role"] = "No Role Reported",
		["lifetime_spent"] = 0,
		["spec"] = "No Spec Reported",
		["player"] = "Squidprophet",
		["rankName"] = "None",
		["rank"] = 20,
	}, -- [126]
	{
		["previous_dkp"] = 0,
		["dkp"] = 178,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 385,
		["player"] = "Stikyiki",
		["class"] = "ROGUE",
		["spec"] = "Combat (14/32/5)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [127]
	{
		["previous_dkp"] = 0,
		["dkp"] = 500,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 752,
		["player"] = "Stitchess",
		["class"] = "MAGE",
		["spec"] = "Frost (16/0/35)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [128]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "ROGUE",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Stoleurbike",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [129]
	{
		["previous_dkp"] = 0,
		["dkp"] = 690,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 710,
		["player"] = "Suprarz",
		["class"] = "MAGE",
		["spec"] = "Frost (10/0/41)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [130]
	{
		["previous_dkp"] = 0,
		["dkp"] = 250,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 250,
		["role"] = "No Role Detected",
		["class"] = "WARRIOR",
		["spec"] = "No Spec Reported",
		["player"] = "Tankdaddy",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [131]
	{
		["previous_dkp"] = 0,
		["dkp"] = 550,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 570,
		["player"] = "Thelora",
		["class"] = "MAGE",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [132]
	{
		["previous_dkp"] = 0,
		["dkp"] = 420,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 460,
		["player"] = "Thepurple",
		["class"] = "WARLOCK",
		["spec"] = "Affliction (30/0/21)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [133]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["class"] = "WARRIOR",
		["lifetime_gained"] = 580,
		["role"] = "Tank",
		["spec"] = "Protection (13/5/33)",
		["lifetime_spent"] = 0,
		["player"] = "Tokentoken",
		["dkp"] = 200,
		["rank"] = 20,
	}, -- [134]
	{
		["previous_dkp"] = 0,
		["dkp"] = 375,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 720,
		["player"] = "Trickster",
		["class"] = "ROGUE",
		["spec"] = "Combat (19/32/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [135]
	{
		["previous_dkp"] = 0,
		["dkp"] = 450,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 690,
		["player"] = "Ugro",
		["class"] = "HUNTER",
		["spec"] = "Marksmanship (14/31/6)",
		["role"] = "Range DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [136]
	{
		["previous_dkp"] = 0,
		["dkp"] = 255,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 570,
		["player"] = "Urkh",
		["class"] = "MAGE",
		["spec"] = "No Spec Reported",
		["role"] = "No Role Detected",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [137]
	{
		["previous_dkp"] = 0,
		["dkp"] = 252,
		["class"] = "WARLOCK",
		["lifetime_gained"] = 390,
		["role"] = "Caster DPS",
		["spec"] = "Affliction (30/0/21)",
		["lifetime_spent"] = 0,
		["player"] = "Varix",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [138]
	{
		["previous_dkp"] = 0,
		["dkp"] = 370,
		["spec"] = "Combat (15/31/5)",
		["lifetime_gained"] = 620,
		["player"] = "Vehicle",
		["class"] = "ROGUE",
		["rankName"] = "Champion",
		["role"] = "Melee DPS",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [139]
	{
		["previous_dkp"] = 0,
		["dkp"] = 522,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 730,
		["player"] = "Veriandra",
		["class"] = "MAGE",
		["spec"] = "Arcane (31/0/20)",
		["role"] = "Caster DPS",
		["rankName"] = "Olympian",
		["rank"] = 2,
	}, -- [140]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["class"] = "HUNTER",
		["lifetime_gained"] = 390,
		["role"] = "Range DPS",
		["spec"] = "Marksmanship (0/39/12)",
		["dkp"] = 201,
		["player"] = "Wahcha",
		["lifetime_spent"] = 0,
		["rank"] = 20,
	}, -- [141]
	{
		["previous_dkp"] = 0,
		["dkp"] = 425,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 550,
		["player"] = "Weapoñ",
		["class"] = "WARRIOR",
		["spec"] = "Arms (31/20/0)",
		["role"] = "Melee DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [142]
	{
		["previous_dkp"] = 0,
		["dkp"] = 0,
		["class"] = "PALADIN",
		["lifetime_gained"] = 0,
		["role"] = "No Role Reported",
		["spec"] = "No Spec Reported",
		["lifetime_spent"] = 0,
		["player"] = "Webroinacint",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [143]
	{
		["previous_dkp"] = 0,
		["dkp"] = 162,
		["class"] = "WARLOCK",
		["lifetime_gained"] = 180,
		["player"] = "Winancy",
		["role"] = "Caster DPS",
		["spec"] = "Affliction (37/0/8)",
		["rankName"] = "Champion",
		["lifetime_spent"] = 0,
		["rank"] = 5,
	}, -- [144]
	{
		["previous_dkp"] = 0,
		["dkp"] = 382,
		["lifetime_spent"] = -13,
		["lifetime_gained"] = 1645,
		["player"] = "Xamina",
		["class"] = "PRIEST",
		["spec"] = "Holy (21/30/0)",
		["role"] = "Healer",
		["rankName"] = "Titan",
		["rank"] = 1,
	}, -- [145]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["class"] = "MAGE",
		["lifetime_gained"] = 390,
		["role"] = "Caster DPS",
		["spec"] = "Frost (16/0/35)",
		["lifetime_spent"] = 0,
		["player"] = "Xyen",
		["dkp"] = 290,
		["rank"] = 20,
	}, -- [146]
	{
		["previous_dkp"] = 0,
		["rankName"] = "None",
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 520,
		["role"] = "Melee DPS",
		["dkp"] = 247,
		["class"] = "WARRIOR",
		["player"] = "Ziggi",
		["spec"] = "Fury (17/34/0)",
		["rank"] = 10,
	}, -- [147]
	{
		["previous_dkp"] = 0,
		["dkp"] = 464,
		["lifetime_spent"] = 0,
		["lifetime_gained"] = 670,
		["player"] = "Zukohere",
		["class"] = "MAGE",
		["spec"] = "Arcane (31/0/20)",
		["role"] = "Caster DPS",
		["rankName"] = "Champion",
		["rank"] = 5,
	}, -- [148]
}
MonDKP_DKPHistory = {
	{
		["players"] = "Morphintyme,",
		["index"] = "Veriandra-1580076273",
		["dkp"] = -42,
		["date"] = 1580076273,
		["reason"] = "Other - -10 % roll tier 2 helmet",
	}, -- [1]
	{
		["players"] = "Mallix,",
		["index"] = "Dalia-1580076202",
		["dkp"] = -279,
		["date"] = 1580076202,
		["reason"] = "Other - Ony head Shroud",
	}, -- [2]
	{
		["players"] = "Mallix,",
		["index"] = "Neekio-1580076044",
		["dkp"] = 182,
		["date"] = 1580076044,
		["deletes"] = "Dalia-1580075978",
		["reason"] = "Delete Entry",
	}, -- [3]
	{
		["players"] = "Mallix,",
		["index"] = "Dalia-1580075978",
		["dkp"] = -182,
		["date"] = 1580075978,
		["deletedby"] = "Neekio-1580076044",
		["reason"] = "Other - Ony Head Shroud",
	}, -- [4]
	{
		["players"] = "Winancy,",
		["index"] = "Veriandra-1580075813",
		["dkp"] = -18,
		["date"] = 1580075813,
		["reason"] = "Other - -10% Roll ring of binding",
	}, -- [5]
	{
		["players"] = "Winancy,",
		["index"] = "Neekio-1580075808",
		["dkp"] = -18,
		["date"] = 1580075808,
		["deletes"] = "Veriandra-1580075778",
		["reason"] = "Delete Entry",
	}, -- [6]
	{
		["players"] = "Winancy,",
		["index"] = "Veriandra-1580075778",
		["dkp"] = 18,
		["date"] = 1580075778,
		["deletedby"] = "Neekio-1580075808",
		["reason"] = "Other - -10% Roll ring of binding",
	}, -- [7]
	{
		["players"] = "Fawntine,",
		["index"] = "Neekio-1580075257",
		["dkp"] = -30,
		["date"] = 1580075257,
		["reason"] = "Unexcused Absence",
	}, -- [8]
	{
		["players"] = "Fawntine,",
		["index"] = "Neekio-1580075235",
		["dkp"] = -20,
		["date"] = 1580075235,
		["reason"] = "Correcting Error",
	}, -- [9]
	{
		["players"] = "Tankdaddy,Girlslayer,Snaildaddy,Hew,Weapoñ,Qew,Mcstaberson,Vehicle,Trickster,Dwindle,Athico,Bádtothebow,Primera,Mallix,Stitchess,Veriandra,Eolith,Cyndr,Zukohere,Grymmlock,Dalia,Winancy,Capybara,Philonious,Fawntine,Forerunner,Papasquach,Morphintyme,Emmyy,",
		["index"] = "Neekio-1580075216",
		["dkp"] = 20,
		["date"] = 1580075216,
		["reason"] = "Other - BK Onyxia, Ontime, Signup",
	}, -- [10]
	{
		["players"] = "Trickster,",
		["index"] = "Sparklenips-1580074643",
		["dkp"] = 10,
		["date"] = 1580074643,
		["reason"] = "Molten Core: Ragnaros",
	}, -- [11]
	{
		["players"] = "Trickster,",
		["index"] = "Sparklenips-1580074638",
		["dkp"] = 10,
		["date"] = 1580074638,
		["reason"] = "Molten Core: Majordomo Executus",
	}, -- [12]
	{
		["players"] = "Spellbender,",
		["index"] = "Neekio-1580063688",
		["dkp"] = -284,
		["date"] = 1580063688,
		["reason"] = "Other - Mageblade correction Shroud",
	}, -- [13]
	{
		["players"] = "Trickster,",
		["index"] = "Neekio-1580063506",
		["dkp"] = 20,
		["date"] = 1580063506,
		["reason"] = "Correcting Error",
	}, -- [14]
	{
		["players"] = "Solten,Awwswitch,",
		["index"] = "Neekio-1580061887",
		["dkp"] = 28,
		["date"] = 1580061887,
		["reason"] = "Correcting Error",
	}, -- [15]
	{
		["players"] = "Fiz,Stoleurbike,Erectdwarf,Lixx,Huenolairc,Laird,Gregord,Claireamy,Captnutsack,Webroinacint,",
		["index"] = "Neekio-1580061881",
		["dkp"] = 10,
		["date"] = 1580061881,
		["reason"] = "Correcting Error",
	}, -- [16]
	{
		["players"] = "Mongous,",
		["index"] = "Sparklenips-1580014680",
		["dkp"] = 10,
		["date"] = 1580014680,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [17]
	{
		["players"] = "Bugaboom,",
		["index"] = "Sparklenips-1580014611",
		["dkp"] = -90,
		["date"] = 1580014611,
		["reason"] = "Other - maidens circle",
	}, -- [18]
	{
		["players"] = "Inigma,",
		["index"] = "Sparklenips-1580014535",
		["dkp"] = -220,
		["date"] = 1580014535,
		["reason"] = "Other - tier 2",
	}, -- [19]
	{
		["players"] = "Cyskul,",
		["index"] = "Sparklenips-1580014477",
		["dkp"] = -35,
		["date"] = 1580014477,
		["reason"] = "Other - tier 2",
	}, -- [20]
	{
		["players"] = "Lindo,",
		["index"] = "Sparklenips-1580014286",
		["dkp"] = -217,
		["date"] = 1580014286,
		["reason"] = "Other - saphirron",
	}, -- [21]
	{
		["players"] = "Snaildaddy,",
		["index"] = "Sparklenips-1580014201",
		["dkp"] = -260,
		["date"] = 1580014201,
		["reason"] = "Other - ony head ",
	}, -- [22]
	{
		["players"] = "Aku,Ballour,Bugaboom,Chipgizmo,Cyskul,Deeprider,Evangelina,Flatulent,Fradge,Galagus,Ihurricanel,Inigma,Ithgar,Kalita,Kittysnake,Lindo,Madmartagen,Mystile,Neekio,Odin,Ones,Oxford,Raspütin,Reina,Snaildaddy,Sparklenips,Spellbender,Stikyiki,Suprarz,Tokentoken,Ugro,Insub,",
		["index"] = "Sparklenips-1580014097",
		["dkp"] = 10,
		["date"] = 1580014097,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [23]
	{
		["players"] = "Flatulent,",
		["index"] = "Sparklenips-1580011870",
		["dkp"] = 5,
		["date"] = 1580011870,
		["reason"] = "Other - sign up",
	}, -- [24]
	{
		["players"] = "Odin,",
		["index"] = "Sparklenips-1580011855",
		["dkp"] = 5,
		["date"] = 1580011855,
		["reason"] = "Other - sign up",
	}, -- [25]
	{
		["players"] = "Raspütin,",
		["index"] = "Sparklenips-1580011841",
		["dkp"] = 5,
		["date"] = 1580011841,
		["reason"] = "Other - sign up",
	}, -- [26]
	{
		["players"] = "Aku,Ballour,Bugaboom,Chipgizmo,Cyskul,Deeprider,Evangelina,Fradge,Ihurricanel,Inigma,Ithgar,Kalita,Kittysnake,Lindo,Madmartagen,Mongous,Mystile,Ones,Oxford,Reina,Snaildaddy,Sparklenips,Spellbender,Stikyiki,Suprarz,Tokentoken,Ugro,Insub,",
		["index"] = "Sparklenips-1580011363",
		["dkp"] = 10,
		["date"] = 1580011363,
		["reason"] = "Other - ontime/signup",
	}, -- [27]
	{
		["players"] = "Littleshiv,",
		["index"] = "Sparklenips-1579927721",
		["dkp"] = 42,
		["date"] = 1579927721,
		["reason"] = "Correcting Error",
	}, -- [28]
	{
		["players"] = "Neekio,",
		["index"] = "Neekio-1579832672",
		["dkp"] = -45,
		["date"] = 1579832672,
		["reason"] = "Other - T1 Hands",
	}, -- [29]
	{
		["players"] = "Mystile,",
		["index"] = "Neekio-1579832618",
		["dkp"] = -10,
		["date"] = 1579832618,
		["reason"] = "Correcting Error",
	}, -- [30]
	{
		["players"] = "Ballour,",
		["index"] = "Neekio-1579832597",
		["dkp"] = 9,
		["date"] = 1579832597,
		["deletes"] = "Neekio-1579832281",
		["reason"] = "Delete Entry",
	}, -- [31]
	{
		["players"] = "Junglemain,Morphintyme,Corseau,Drrl,Claireamy,Neekio,Emmyy,Oldmanmike,Kalijah,Cyskul,Mallix,Huenolairc,Ithgar,Saoirlinnis,Craiger,Ugro,Bigbootyhoho,Athico,Primera,Veriandra,Gnomenuts,Landlubbers,Laird,Oxford,Stitchess,Spellbender,Chipgizmo,Suprarz,Fiz,Moldyrag,Urkh,Thelora,Zukohere,Bugaboom,Eolith,Kuckuck,Ones,Maryjohanna,Solidsix,Gregord,Papasquach,Captnutsack,Chaintoker,Astlan,Arkleis,Webroinacint,Erectdwarf,Papashep,Holycritpal,Awwswitch,Philonious,Pamplemousse,Honeypot,Solten,Ballour,Xamina,Evangelina,Stoleurbike,Slipperyjohn,Puffypoose,Stikyiki,Trickster,Aku,Mozzarella,Littleshiv,Killionaire,Dwindle,Lixx,Inigma,Mariku,Lindo,Sparklenips,Ihurricanel,Grymmlock,Thepurple,Dasmook,Dalia,Sinitar,Raspütin,Finryr,Cheeza,Weapoñ,Fradge,Girlslayer,Retkin,Reina,Shinynickels,Galagus,Snaildaddy,Oragan,Kalita,Schnazzy,",
		["index"] = "Neekio-1579832384",
		["dkp"] = -10,
		["date"] = 1579832384,
		["deletes"] = "Neekio-1576641005",
		["reason"] = "Delete Entry",
	}, -- [32]
	{
		["players"] = "Evangelina,Solten,Honeypot,Philonious,Pamplemousse,Awwswitch,Ballour,Xamina,",
		["index"] = "Neekio-1579832354",
		["dkp"] = 32,
		["date"] = 1579832354,
		["deletes"] = "Neekio-1576630708",
		["reason"] = "Delete Entry",
	}, -- [33]
	{
		["players"] = "Evangelina,Solten,Honeypot,Philonious,Pamplemousse,Awwswitch,Ballour,Xamina,",
		["index"] = "Neekio-1579832335",
		["dkp"] = -50,
		["date"] = 1579832335,
		["deletes"] = "Neekio-1576630680",
		["reason"] = "Delete Entry",
	}, -- [34]
	{
		["players"] = "Ballour,",
		["index"] = "Neekio-1579832281",
		["dkp"] = -9,
		["date"] = 1579832281,
		["deletedby"] = "Neekio-1579832597",
		["reason"] = "Correcting Error",
	}, -- [35]
	{
		["players"] = "Veriandra,Winancy,Varix,Stitchess,Spellbender,Snaildaddy,Slipperyjohn,Shinynickels,Raspütin,Qew,Philonious,Papasquach,Oragan,Odin,Neekio,Mozzarella,Morphintyme,Mihai,Mcstaberson,Maryjohanna,Mariku,Madmartagen,Lindo,Junglemain,Ithgar,Inebriated,Grymmlock,Girlslayer,Fawntine,Cyskul,Cyndr,Bádtothebow,Bigbootyhoho,Ballour,Athico,Astlan,Artorion,Arkleis,Aku,",
		["index"] = "Neekio-1579832186",
		["dkp"] = 10,
		["date"] = 1579832186,
		["reason"] = "Molten Core: Majordomo Executus",
	}, -- [36]
	{
		["players"] = "Corseau,",
		["index"] = "Sparklenips-1579766420",
		["dkp"] = -25,
		["date"] = 1579766420,
		["reason"] = "Other - no call/no show",
	}, -- [37]
	{
		["players"] = "Littleshiv,",
		["index"] = "Sparklenips-1579766378",
		["dkp"] = -42,
		["date"] = 1579766378,
		["reason"] = "Other - no call/no show",
	}, -- [38]
	{
		["players"] = "Nubslayer,",
		["index"] = "Sparklenips-1579766355",
		["dkp"] = -14,
		["date"] = 1579766355,
		["reason"] = "Other - no call/no show",
	}, -- [39]
	{
		["players"] = "Solidsix,",
		["index"] = "Sparklenips-1579766151",
		["dkp"] = -46,
		["date"] = 1579766151,
		["reason"] = "Other - no call/no show",
	}, -- [40]
	{
		["players"] = "Hazie,",
		["index"] = "Sparklenips-1579764745",
		["dkp"] = -11,
		["date"] = 1579764745,
		["reason"] = "Other - shoulders ",
	}, -- [41]
	{
		["players"] = "Mongous,",
		["index"] = "Sparklenips-1579764555",
		["dkp"] = -40,
		["date"] = 1579764555,
		["reason"] = "Other - robes of p",
	}, -- [42]
	{
		["players"] = "Dwindle,",
		["index"] = "Sparklenips-1579764487",
		["dkp"] = -210,
		["date"] = 1579764487,
		["reason"] = "Other - shoulders",
	}, -- [43]
	{
		["players"] = "Stikyiki,",
		["index"] = "Sparklenips-1579764439",
		["dkp"] = -168,
		["date"] = 1579764439,
		["reason"] = "Other - nightslayer boots",
	}, -- [44]
	{
		["players"] = "Reina,",
		["index"] = "Sparklenips-1579764366",
		["dkp"] = -157,
		["date"] = 1579764366,
		["reason"] = "Other - breastplate of might",
	}, -- [45]
	{
		["players"] = "Squidprophet,",
		["index"] = "Sparklenips-1579764298",
		["dkp"] = -205,
		["date"] = 1579764298,
		["reason"] = "Other - sash",
	}, -- [46]
	{
		["players"] = "Dolamroth,",
		["index"] = "Sparklenips-1579764232",
		["dkp"] = -160,
		["date"] = 1579764232,
		["reason"] = "Other - quickstrike",
	}, -- [47]
	{
		["players"] = "Fradge,",
		["index"] = "Sparklenips-1579764147",
		["dkp"] = -290,
		["date"] = 1579764147,
		["reason"] = "Other - cht",
	}, -- [48]
	{
		["players"] = "Chipgizmo,",
		["index"] = "Sparklenips-1579764032",
		["dkp"] = -124,
		["date"] = 1579764032,
		["reason"] = "Other - arcanist hands",
	}, -- [49]
	{
		["players"] = "Crazymarbles,",
		["index"] = "Sparklenips-1579763864",
		["dkp"] = -43,
		["date"] = 1579763864,
		["reason"] = "DKP Adjust",
	}, -- [50]
	{
		["players"] = "Tokentoken,",
		["index"] = "Sparklenips-1579763762",
		["dkp"] = -23,
		["date"] = 1579763762,
		["reason"] = "Other - dragons blood",
	}, -- [51]
	{
		["players"] = "Hititnquitit,",
		["index"] = "Sparklenips-1579763617",
		["dkp"] = -83,
		["date"] = 1579763617,
		["reason"] = "Other - perd",
	}, -- [52]
	{
		["players"] = "Bugaboom,Calixta,Celestaes,Chipgizmo,Crazymarbles,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Evangelina,Flatulent,Forerunner,Fradge,Galagus,Hazie,Hititnquitit,Honeypot,Ihurricanel,Inigma,Killionaire,Mallix,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Reina,Rez,Sparklenips,Squidprophet,Stikyiki,Suprarz,Thepurple,Tokentoken,Ugro,Xyen,Ziggi,Zukohere,",
		["index"] = "Sparklenips-1579763418",
		["dkp"] = 10,
		["date"] = 1579763418,
		["reason"] = "Molten Core: Ragnaros",
	}, -- [53]
	{
		["players"] = "Bugaboom,Calixta,Celestaes,Chipgizmo,Crazymarbles,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Evangelina,Flatulent,Forerunner,Fradge,Galagus,Hazie,Hititnquitit,Honeypot,Ihurricanel,Inigma,Killionaire,Mallix,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Reina,Rez,Sparklenips,Squidprophet,Stikyiki,Suprarz,Thepurple,Tokentoken,Ugro,Xyen,Ziggi,Zukohere,",
		["index"] = "Sparklenips-1579762812",
		["dkp"] = 10,
		["date"] = 1579762812,
		["reason"] = "Molten Core: Majordomo Executus",
	}, -- [54]
	{
		["players"] = "Bugaboom,Calixta,Celestaes,Chipgizmo,Crazymarbles,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Evangelina,Flatulent,Forerunner,Fradge,Galagus,Hazie,Hititnquitit,Honeypot,Ihurricanel,Inigma,Killionaire,Mallix,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Reina,Rez,Sparklenips,Squidprophet,Stikyiki,Suprarz,Thepurple,Tokentoken,Ugro,Xyen,Ziggi,Zukohere,",
		["index"] = "Sparklenips-1579761092",
		["dkp"] = 10,
		["date"] = 1579761092,
		["reason"] = "Molten Core: Shazzrah",
	}, -- [55]
	{
		["players"] = "Bugaboom,Calixta,Celestaes,Chipgizmo,Crazymarbles,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Evangelina,Flatulent,Forerunner,Fradge,Galagus,Hazie,Hititnquitit,Honeypot,Ihurricanel,Inigma,Killionaire,Mallix,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Reina,Rez,Sparklenips,Squidprophet,Stikyiki,Suprarz,Thepurple,Tokentoken,Ugro,Xyen,Ziggi,Zukohere,",
		["index"] = "Sparklenips-1579761075",
		["dkp"] = 10,
		["date"] = 1579761075,
		["reason"] = "Molten Core: Sulfuron Harbinger",
	}, -- [56]
	{
		["players"] = "Tokentoken,",
		["index"] = "Sparklenips-1579759431",
		["dkp"] = -164,
		["date"] = 1579759431,
		["reason"] = "Other - sabatons",
	}, -- [57]
	{
		["players"] = "Celestaes,",
		["index"] = "Sparklenips-1579759351",
		["dkp"] = -6,
		["date"] = 1579759351,
		["reason"] = "Other - spaulders",
	}, -- [58]
	{
		["players"] = "Forerunner,",
		["index"] = "Sparklenips-1579759286",
		["dkp"] = -6,
		["date"] = 1579759286,
		["reason"] = "DKP Adjust",
	}, -- [59]
	{
		["players"] = "Forerunner,",
		["index"] = "Sparklenips-1579759207",
		["dkp"] = -6,
		["date"] = 1579759207,
		["reason"] = "DKP Adjust",
	}, -- [60]
	{
		["players"] = "Crazymarbles,",
		["index"] = "Sparklenips-1579759188",
		["dkp"] = 23,
		["date"] = 1579759188,
		["reason"] = "Correcting Error",
	}, -- [61]
	{
		["players"] = "Crazymarbles,",
		["index"] = "Sparklenips-1579759089",
		["dkp"] = -23,
		["date"] = 1579759089,
		["reason"] = "Other - bracers",
	}, -- [62]
	{
		["players"] = "Killionaire,",
		["index"] = "Sparklenips-1579759022",
		["dkp"] = -126,
		["date"] = 1579759022,
		["reason"] = "Other - nightslayer belt",
	}, -- [63]
	{
		["players"] = "Bugaboom,",
		["index"] = "Sparklenips-1579758870",
		["dkp"] = -131,
		["date"] = 1579758870,
		["reason"] = "Other - arcanist boots",
	}, -- [64]
	{
		["players"] = "Zukohere,",
		["index"] = "Sparklenips-1579758801",
		["dkp"] = -46,
		["date"] = 1579758801,
		["reason"] = "Other - arcanist mantle",
	}, -- [65]
	{
		["players"] = "Chipgizmo,",
		["index"] = "Sparklenips-1579758735",
		["dkp"] = -24,
		["date"] = 1579758735,
		["reason"] = "Other - arcanist leggings",
	}, -- [66]
	{
		["players"] = "Ziggi,",
		["index"] = "Sparklenips-1579758659",
		["dkp"] = -24,
		["date"] = 1579758659,
		["reason"] = "Other - flamewaker",
	}, -- [67]
	{
		["players"] = "Ziggi,",
		["index"] = "Sparklenips-1579758564",
		["dkp"] = -26,
		["date"] = 1579758564,
		["reason"] = "Other - dark iron ring",
	}, -- [68]
	{
		["players"] = "Hititnquitit,",
		["index"] = "Sparklenips-1579758441",
		["dkp"] = -125,
		["date"] = 1579758441,
		["reason"] = "Other - gutgore",
	}, -- [69]
	{
		["players"] = "Crazymarbles,",
		["index"] = "Sparklenips-1579758348",
		["dkp"] = -45,
		["date"] = 1579758348,
		["reason"] = "Other - AURASTONHE",
	}, -- [70]
	{
		["players"] = "Bugaboom,Calixta,Celestaes,Chipgizmo,Crazymarbles,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Evangelina,Flatulent,Forerunner,Fradge,Galagus,Hazie,Hititnquitit,Honeypot,Ihurricanel,Inigma,Killionaire,Mallix,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Reina,Rez,Sparklenips,Squidprophet,Stikyiki,Suprarz,Thepurple,Tokentoken,Ugro,Xyen,Ziggi,Zukohere,",
		["index"] = "Sparklenips-1579758109",
		["dkp"] = 10,
		["date"] = 1579758109,
		["reason"] = "Molten Core: Baron Geddon",
	}, -- [71]
	{
		["players"] = "Bugaboom,Calixta,Celestaes,Chipgizmo,Crazymarbles,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Evangelina,Flatulent,Forerunner,Fradge,Galagus,Hazie,Hititnquitit,Honeypot,Ihurricanel,Inigma,Killionaire,Mallix,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Reina,Rez,Sparklenips,Squidprophet,Stikyiki,Suprarz,Thepurple,Tokentoken,Ugro,Xyen,Ziggi,Zukohere,",
		["index"] = "Sparklenips-1579757028",
		["dkp"] = 10,
		["date"] = 1579757028,
		["reason"] = "Molten Core: Garr",
	}, -- [72]
	{
		["players"] = "Bugaboom,Calixta,Chipgizmo,Crazymarbles,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Evangelina,Flatulent,Fradge,Galagus,Hazie,Hititnquitit,Honeypot,Ihurricanel,Inigma,Killionaire,Mallix,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Reina,Rez,Sparklenips,Squidprophet,Stikyiki,Suprarz,Thepurple,Tokentoken,Ugro,Xyen,Ziggi,Zukohere,Forerunner,Celestaes,",
		["index"] = "Sparklenips-1579756110",
		["dkp"] = 10,
		["date"] = 1579756110,
		["reason"] = "Molten Core: Gehennas",
	}, -- [73]
	{
		["players"] = "Bugaboom,Calixta,Chipgizmo,Crazymarbles,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Evangelina,Flatulent,Fradge,Galagus,Hazie,Hititnquitit,Honeypot,Ihurricanel,Inigma,Killionaire,Mallix,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Reina,Rez,Sparklenips,Squidprophet,Stikyiki,Suprarz,Thepurple,Tokentoken,Ugro,Xyen,Ziggi,Zukohere,Forerunner,Celestaes,",
		["index"] = "Sparklenips-1579756105",
		["dkp"] = 10,
		["date"] = 1579756105,
		["reason"] = "Molten Core: Magmadar",
	}, -- [74]
	{
		["players"] = "Bugaboom,Calixta,Chipgizmo,Crazymarbles,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Evangelina,Flatulent,Fradge,Galagus,Hazie,Hititnquitit,Honeypot,Ihurricanel,Inigma,Killionaire,Mallix,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Reina,Rez,Sparklenips,Squidprophet,Stikyiki,Suprarz,Thepurple,Tokentoken,Ugro,Xyen,Ziggi,Zukohere,Forerunner,Celestaes,",
		["index"] = "Sparklenips-1579756097",
		["dkp"] = 10,
		["date"] = 1579756097,
		["reason"] = "Molten Core: Lucifron",
	}, -- [75]
	{
		["players"] = "Philonious,",
		["index"] = "Neekio-1579755051",
		["dkp"] = -60,
		["date"] = 1579755051,
		["reason"] = "Other - Crimson Shocker",
	}, -- [76]
	{
		["players"] = "Aku,",
		["index"] = "Neekio-1579754962",
		["dkp"] = -200,
		["date"] = 1579754962,
		["reason"] = "Other - Nightslayer Chest",
	}, -- [77]
	{
		["players"] = "Dwindle,",
		["index"] = "Sparklenips-1579754945",
		["dkp"] = -260,
		["date"] = 1579754945,
		["reason"] = "Correcting Error",
	}, -- [78]
	{
		["players"] = "Madmartagen,",
		["index"] = "Neekio-1579754801",
		["dkp"] = -26,
		["date"] = 1579754801,
		["reason"] = "Other - Belt of Might",
	}, -- [79]
	{
		["players"] = "Shinynickels,",
		["index"] = "Neekio-1579754784",
		["dkp"] = -15,
		["date"] = 1579754784,
		["reason"] = "Other - Belt of Might",
	}, -- [80]
	{
		["players"] = "Qew,",
		["index"] = "Neekio-1579754770",
		["dkp"] = 75,
		["date"] = 1579754770,
		["deletes"] = "Neekio-1579754543",
		["reason"] = "Delete Entry",
	}, -- [81]
	{
		["players"] = "Shinynickels,",
		["index"] = "Neekio-1579754766",
		["dkp"] = 15,
		["date"] = 1579754766,
		["deletes"] = "Neekio-1579754562",
		["reason"] = "Delete Entry",
	}, -- [82]
	{
		["players"] = "Shinynickels,",
		["index"] = "Neekio-1579754562",
		["dkp"] = -15,
		["date"] = 1579754562,
		["deletedby"] = "Neekio-1579754766",
		["reason"] = "Other - Belt of Might",
	}, -- [83]
	{
		["players"] = "Qew,",
		["index"] = "Neekio-1579754543",
		["dkp"] = -75,
		["date"] = 1579754543,
		["deletedby"] = "Neekio-1579754770",
		["reason"] = "Other - Belt of Might",
	}, -- [84]
	{
		["players"] = "Artorion,",
		["index"] = "Neekio-1579754493",
		["dkp"] = -10,
		["date"] = 1579754493,
		["reason"] = "Other - Lawbringer Belt",
	}, -- [85]
	{
		["players"] = "Grymmlock,",
		["index"] = "Neekio-1579754470",
		["dkp"] = -253,
		["date"] = 1579754470,
		["reason"] = "Other - Nemesis Leggings",
	}, -- [86]
	{
		["players"] = "Shinynickels,",
		["index"] = "Neekio-1579754393",
		["dkp"] = -145,
		["date"] = 1579754393,
		["reason"] = "Other - legplates of Wrath",
	}, -- [87]
	{
		["players"] = "Odin,",
		["index"] = "Neekio-1579754361",
		["dkp"] = -57,
		["date"] = 1579754361,
		["reason"] = "Other - Band of Sulf",
	}, -- [88]
	{
		["players"] = "Artorion,",
		["index"] = "Neekio-1579754313",
		["dkp"] = -98,
		["date"] = 1579754313,
		["reason"] = "Other - Malistar's Defender",
	}, -- [89]
	{
		["players"] = "Aku,Arkleis,Artorion,Astlan,Athico,Ballour,Bigbootyhoho,Bádtothebow,Cyndr,Cyskul,Fawntine,Girlslayer,Grymmlock,Inebriated,Ithgar,Junglemain,Lindo,Madmartagen,Mariku,Maryjohanna,Mcstaberson,Mihai,Morphintyme,Mozzarella,Neekio,Odin,Oragan,Papasquach,Philonious,Qew,Raspütin,Shinynickels,Slipperyjohn,Snaildaddy,Spellbender,Stitchess,Varix,Veriandra,Winancy,",
		["index"] = "Neekio-1579754273",
		["dkp"] = 10,
		["date"] = 1579754273,
		["reason"] = "Molten Core: Ragnaros",
	}, -- [90]
	{
		["players"] = "Mystile,",
		["index"] = "Sparklenips-1579754177",
		["dkp"] = 20,
		["date"] = 1579754177,
		["reason"] = "Other - Signup",
	}, -- [91]
	{
		["players"] = "Celestaes,",
		["index"] = "Sparklenips-1579754121",
		["dkp"] = 10,
		["date"] = 1579754121,
		["reason"] = "Other - Signup",
	}, -- [92]
	{
		["players"] = "Forerunner,",
		["index"] = "Sparklenips-1579754113",
		["dkp"] = 10,
		["date"] = 1579754113,
		["reason"] = "Other - Signup",
	}, -- [93]
	{
		["players"] = "Dolamroth,",
		["index"] = "Sparklenips-1579754084",
		["dkp"] = 10,
		["date"] = 1579754084,
		["reason"] = "Other - Signup",
	}, -- [94]
	{
		["players"] = "Slipperyjohn,",
		["index"] = "Neekio-1579753040",
		["dkp"] = -234,
		["date"] = 1579753040,
		["reason"] = "Other - Nightslayer Shoulder Pads",
	}, -- [95]
	{
		["players"] = "Bigbootyhoho,",
		["index"] = "Neekio-1579753016",
		["dkp"] = -215,
		["date"] = 1579753016,
		["reason"] = "Other - Giantstalker's Epaulets",
	}, -- [96]
	{
		["players"] = "Mallix,",
		["index"] = "Sparklenips-1579752697",
		["dkp"] = 10,
		["date"] = 1579752697,
		["reason"] = "Other - Signup",
	}, -- [97]
	{
		["players"] = "Dasmook,",
		["index"] = "Sparklenips-1579752688",
		["dkp"] = 20,
		["date"] = 1579752688,
		["reason"] = "Other - Signup/ontime",
	}, -- [98]
	{
		["players"] = "Bugaboom,Calixta,Chipgizmo,Crazymarbles,Deeprider,Dwindle,Eolith,Evangelina,Flatulent,Fradge,Galagus,Hazie,Honeypot,Ihurricanel,Inigma,Killionaire,Mongous,Nightshelf,Ones,Oxford,Primera,Reina,Rez,Sparklenips,Squidprophet,Stikyiki,Suprarz,Thepurple,Tokentoken,Ugro,Xyen,Ziggi,Zukohere,",
		["index"] = "Sparklenips-1579752595",
		["dkp"] = 20,
		["date"] = 1579752595,
		["reason"] = "Other - Signup/ontime",
	}, -- [99]
	{
		["players"] = "Ballour,Philonious,Oragan,Girlslayer,Spellbender,Odin,Grymmlock,Veriandra,Snaildaddy,Stitchess,Slipperyjohn,Aku,Neekio,Mariku,Bigbootyhoho,Raspütin,Lindo,Morphintyme,Junglemain,Athico,Arkleis,Ithgar,Inebriated,Astlan,Trickster,Maryjohanna,Mozzarella,Cyskul,Bádtothebow,Mcstaberson,Shinynickels,Fawntine,Madmartagen,Papasquach,Varix,Mihai,Artorion,Qew,Winancy,Cyndr,",
		["index"] = "Neekio-1579752490",
		["dkp"] = 10,
		["date"] = 1579752490,
		["reason"] = "Molten Core: Golemagg the Incinerator",
	}, -- [100]
	{
		["players"] = "Ballour,Philonious,Oragan,Girlslayer,Spellbender,Odin,Grymmlock,Veriandra,Snaildaddy,Stitchess,Slipperyjohn,Aku,Neekio,Mariku,Bigbootyhoho,Raspütin,Lindo,Morphintyme,Junglemain,Athico,Arkleis,Ithgar,Inebriated,Astlan,Trickster,Maryjohanna,Mozzarella,Cyskul,Bádtothebow,Mcstaberson,Shinynickels,Fawntine,Madmartagen,Papasquach,Varix,Mihai,Artorion,Qew,Winancy,Cyndr,",
		["index"] = "Neekio-1579752485",
		["dkp"] = 10,
		["date"] = 1579752485,
		["reason"] = "Molten Core: Sulfuron Harbinger",
	}, -- [101]
	{
		["players"] = "Artorion,",
		["index"] = "Neekio-1579750992",
		["dkp"] = -19,
		["date"] = 1579750992,
		["reason"] = "Other - Lawbringer Helm",
	}, -- [102]
	{
		["players"] = "Slipperyjohn,",
		["index"] = "Neekio-1579750945",
		["dkp"] = -50,
		["date"] = 1579750945,
		["reason"] = "Other - Nightslayer Gloves",
	}, -- [103]
	{
		["players"] = "Mozzarella,",
		["index"] = "Neekio-1579750860",
		["dkp"] = -298,
		["date"] = 1579750860,
		["reason"] = "Other - Brutality Blade Shroud",
	}, -- [104]
	{
		["players"] = "Mihai,",
		["index"] = "Neekio-1579750764",
		["dkp"] = -22,
		["date"] = 1579750764,
		["reason"] = "Other - Flamrwalker Legplates",
	}, -- [105]
	{
		["players"] = "Philonious,",
		["index"] = "Neekio-1579750636",
		["dkp"] = -10,
		["date"] = 1579750636,
		["deletes"] = "Neekio-1579750566",
		["reason"] = "Delete Entry",
	}, -- [106]
	{
		["players"] = "Neekio,Inebriated,Junglemain,Morphintyme,Cyskul,Bigbootyhoho,Bádtothebow,Athico,Ithgar,Veriandra,Cyndr,Spellbender,Stitchess,Odin,Papasquach,Maryjohanna,Astlan,Artorion,Arkleis,Fawntine,Ballour,Philonious,Slipperyjohn,Trickster,Aku,Mcstaberson,Mariku,Mozzarella,Winancy,Grymmlock,Raspütin,Lindo,Varix,Girlslayer,Madmartagen,Shinynickels,Snaildaddy,Oragan,Qew,Mihai,",
		["index"] = "Neekio-1579750602",
		["dkp"] = 10,
		["date"] = 1579750602,
		["reason"] = "Molten Core: Shazzrah",
	}, -- [107]
	{
		["players"] = "Neekio,Inebriated,Junglemain,Morphintyme,Cyskul,Bigbootyhoho,Bádtothebow,Athico,Ithgar,Veriandra,Cyndr,Spellbender,Stitchess,Odin,Papasquach,Maryjohanna,Astlan,Artorion,Arkleis,Fawntine,Ballour,Philonious,Slipperyjohn,Trickster,Aku,Mcstaberson,Mariku,Mozzarella,Winancy,Grymmlock,Raspütin,Lindo,Varix,Girlslayer,Madmartagen,Shinynickels,Snaildaddy,Oragan,Qew,Mihai,",
		["index"] = "Neekio-1579750597",
		["dkp"] = 10,
		["date"] = 1579750597,
		["reason"] = "Molten Core: Baron Geddon",
	}, -- [108]
	{
		["players"] = "Neekio,Inebriated,Junglemain,Morphintyme,Cyskul,Bigbootyhoho,Bádtothebow,Athico,Ithgar,Veriandra,Cyndr,Spellbender,Stitchess,Odin,Papasquach,Maryjohanna,Astlan,Artorion,Arkleis,Fawntine,Ballour,Philonious,Slipperyjohn,Trickster,Aku,Mcstaberson,Mariku,Mozzarella,Winancy,Grymmlock,Raspütin,Lindo,Varix,Girlslayer,Madmartagen,Shinynickels,Snaildaddy,Oragan,Qew,Mihai,",
		["index"] = "Neekio-1579750593",
		["dkp"] = 10,
		["date"] = 1579750593,
		["reason"] = "Molten Core: Garr",
	}, -- [109]
	{
		["players"] = "Neekio,Inebriated,Junglemain,Morphintyme,Cyskul,Bigbootyhoho,Bádtothebow,Athico,Ithgar,Veriandra,Cyndr,Spellbender,Stitchess,Odin,Papasquach,Maryjohanna,Astlan,Artorion,Arkleis,Fawntine,Ballour,Philonious,Slipperyjohn,Trickster,Aku,Mcstaberson,Mariku,Mozzarella,Winancy,Grymmlock,Raspütin,Lindo,Varix,Girlslayer,Madmartagen,Shinynickels,Snaildaddy,Oragan,Qew,Mihai,",
		["index"] = "Neekio-1579750590",
		["dkp"] = 10,
		["date"] = 1579750590,
		["reason"] = "Molten Core: Gehennas",
	}, -- [110]
	{
		["players"] = "Neekio,Inebriated,Junglemain,Morphintyme,Cyskul,Bigbootyhoho,Bádtothebow,Athico,Ithgar,Veriandra,Cyndr,Spellbender,Stitchess,Odin,Papasquach,Maryjohanna,Astlan,Artorion,Arkleis,Fawntine,Ballour,Philonious,Slipperyjohn,Trickster,Aku,Mcstaberson,Mariku,Mozzarella,Winancy,Grymmlock,Raspütin,Lindo,Varix,Girlslayer,Madmartagen,Shinynickels,Snaildaddy,Oragan,Qew,Mihai,",
		["index"] = "Neekio-1579750584",
		["dkp"] = 10,
		["date"] = 1579750584,
		["reason"] = "Molten Core: Magmadar",
	}, -- [111]
	{
		["players"] = "Neekio,Inebriated,Junglemain,Morphintyme,Cyskul,Bigbootyhoho,Bádtothebow,Athico,Ithgar,Veriandra,Cyndr,Spellbender,Stitchess,Odin,Papasquach,Maryjohanna,Astlan,Artorion,Arkleis,Fawntine,Ballour,Philonious,Slipperyjohn,Trickster,Aku,Mcstaberson,Mariku,Mozzarella,Winancy,Grymmlock,Raspütin,Lindo,Varix,Girlslayer,Madmartagen,Shinynickels,Snaildaddy,Oragan,Qew,Mihai,",
		["index"] = "Neekio-1579750581",
		["dkp"] = 10,
		["date"] = 1579750581,
		["reason"] = "Molten Core: Lucifron",
	}, -- [112]
	{
		["players"] = "Philonious,",
		["index"] = "Neekio-1579750566",
		["dkp"] = 10,
		["date"] = 1579750566,
		["deletedby"] = "Neekio-1579750636",
		["reason"] = "Molten Core: Lucifron",
	}, -- [113]
	{
		["players"] = "Ballour,Philonious,Oragan,Mozzarella,Girlslayer,Spellbender,Odin,Slipperyjohn,Grymmlock,Veriandra,Snaildaddy,Stitchess,Aku,Mariku,Neekio,Bigbootyhoho,Raspütin,Lindo,Morphintyme,Junglemain,Athico,Arkleis,Ithgar,Inebriated,Astlan,Trickster,Maryjohanna,Cyskul,Bádtothebow,Mcstaberson,Shinynickels,Fawntine,Madmartagen,Papasquach,Mihai,Varix,Artorion,Winancy,Qew,Cyndr,",
		["index"] = "Neekio-1579746547",
		["dkp"] = 10,
		["date"] = 1579746547,
		["reason"] = "On Time Bonus",
	}, -- [114]
	{
		["players"] = "Ballour,Philonious,Oragan,Mozzarella,Girlslayer,Spellbender,Odin,Slipperyjohn,Grymmlock,Veriandra,Snaildaddy,Stitchess,Aku,Mariku,Neekio,Bigbootyhoho,Raspütin,Lindo,Morphintyme,Junglemain,Athico,Arkleis,Ithgar,Inebriated,Astlan,Trickster,Maryjohanna,Cyskul,Bádtothebow,Mcstaberson,Shinynickels,Fawntine,Madmartagen,Papasquach,Mihai,Varix,Artorion,Winancy,Qew,Cyndr,",
		["index"] = "Neekio-1579746543",
		["dkp"] = 10,
		["date"] = 1579746543,
		["reason"] = "Other - Signup bonus",
	}, -- [115]
	{
		["players"] = "Odin,Astlan,Bruhtato,Partywolf,Corseau,Mozzarella,Wahcha,Hititnquitit,Nubslayer,Drrl,Spellbender,",
		["index"] = "Neekio-1579745273",
		["dkp"] = 60,
		["date"] = 1579745273,
		["reason"] = "Other - Benched player's 50% DKP",
	}, -- [116]
	{
		["players"] = "Suprarz,",
		["index"] = "Neekio-1579736835",
		["dkp"] = -20,
		["date"] = 1579736835,
		["deletes"] = "Neekio-1579668818",
		["reason"] = "Delete Entry",
	}, -- [117]
	{
		["players"] = "Eolith,Oragan,Bugaboom,Ballour,Oxford,Dwindle,Inigma,Stikyiki,Mystile,Littleshiv,Mariku,Thepurple,Flatulent,Deeprider,Athico,Ugro,Ziggi,Mallix,Arkleis,Fradge,Reina,Rez,Killionaire,Mcstaberson,Crazymarbles,Calixta,Nubslayer,Grymmlock,Ihurricanel,Raspütin,Suprarz,Chipgizmo,Ones,Astlan,Bruhtato,Dolamroth,Honeypot,",
		["index"] = "Neekio-1579736764",
		["dkp"] = 10,
		["date"] = 1579736764,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [118]
	{
		["players"] = "Eolith,Oragan,Bugaboom,Ballour,Oxford,Dwindle,Inigma,Stikyiki,Mystile,Littleshiv,Mariku,Thepurple,Flatulent,Deeprider,Athico,Ugro,Ziggi,Mallix,Arkleis,Fradge,Reina,Rez,Killionaire,Mcstaberson,Crazymarbles,Calixta,Nubslayer,Grymmlock,Ihurricanel,Raspütin,Suprarz,Chipgizmo,",
		["index"] = "Neekio-1579736685",
		["dkp"] = 10,
		["date"] = 1579736685,
		["reason"] = "On Time Bonus",
	}, -- [119]
	{
		["players"] = "Chipgizmo,",
		["index"] = "Neekio-1579735843",
		["dkp"] = -142,
		["date"] = 1579735843,
		["reason"] = "Other - Maiden's Circle (Shroud)",
	}, -- [120]
	{
		["players"] = "Ziggi,",
		["index"] = "Neekio-1579735759",
		["dkp"] = -167,
		["date"] = 1579735759,
		["reason"] = "Other - Helm of Wrath (Shroud)",
	}, -- [121]
	{
		["players"] = "Ziggi,",
		["index"] = "Neekio-1579735725",
		["dkp"] = -37,
		["date"] = 1579735725,
		["reason"] = "Other - Ring of Binding",
	}, -- [122]
	{
		["players"] = "Athico,",
		["index"] = "Neekio-1579735696",
		["dkp"] = -250,
		["date"] = 1579735696,
		["reason"] = "Other - Onyxia Head",
	}, -- [123]
	{
		["players"] = "Bádtothebow,",
		["index"] = "Neekio-1579735066",
		["dkp"] = -205.5,
		["date"] = 1579735066,
		["reason"] = "Other - Onyxia Head",
	}, -- [124]
	{
		["players"] = "Suprarz,",
		["index"] = "Neekio-1579668818",
		["dkp"] = 20,
		["date"] = 1579668818,
		["deletedby"] = "Neekio-1579736835",
		["reason"] = "Correcting Error",
	}, -- [125]
	{
		["players"] = "Evangelina,",
		["index"] = "Neekio-1579661069",
		["dkp"] = -300,
		["date"] = 1579661069,
		["reason"] = "Other - Shard of the Scale",
	}, -- [126]
	{
		["players"] = "Evangelina,Philonious,Galagus,Girlslayer,Mozzarella,Weapoñ,Bádtothebow,Odin,Veriandra,Zukohere,Snaildaddy,Stitchess,Aku,Vehicle,Neekio,Bigbootyhoho,Sparklenips,Lindo,Squidprophet,Morphintyme,Mongous,Capybara,Ithgar,Tokentoken,Inebriated,Kalita,Cyskul,Xyen,Papasquach,Mihai,Varix,Solana,Emmyy,Hew,Winancy,Qew,Kithala,Cyndr,",
		["index"] = "Neekio-1579661047",
		["dkp"] = 20,
		["date"] = 1579661047,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [127]
	{
		["players"] = "Philonious,",
		["index"] = "Neekio-1579659574",
		["dkp"] = 10,
		["date"] = 1579659574,
		["reason"] = "Other - MC 10th boss fix.",
	}, -- [128]
	{
		["players"] = "Flatulent,Winancy,Sprocket,",
		["index"] = "Neekio-1579659338",
		["dkp"] = 20,
		["date"] = 1579659338,
		["reason"] = "Other - Onyxia fix",
	}, -- [129]
	{
		["players"] = "Lindo,",
		["index"] = "Neekio-1579659101",
		["dkp"] = 20,
		["date"] = 1579659101,
		["reason"] = "Other - Onyxia fix",
	}, -- [130]
	{
		["players"] = "Trickster,",
		["index"] = "Neekio-1579658631",
		["dkp"] = -225,
		["date"] = 1579658631,
		["reason"] = "Other - Onyxia Head",
	}, -- [131]
	{
		["players"] = "Girlslayer,Tokentoken,Weapoñ,Bruhtato,Schnazzy,Galagus,Snaildaddy,Aku,Killionaire,Mozzarella,Kharlin,Vehicle,Trickster,Littleshiv,Cyskul,Bádtothebow,Ithgar,Primera,Coldjuice,Urkh,Stitchess,Spellbender,Varix,Capybara,Honeypot,Philonious,Evangelina,Papasquach,Astlan,Holycritpal,Odin,Emmyy,Junglemain,Inebriated,Thelora,Eolith,Mariku,Nubslayer,Hew,Qew,Oragan,Retkin,Fradge,Ziggi,Partywolf,Mystile,Dwindle,Inigma,Mcstaberson,Ugro,Wahcha,Bigbootyhoho,Mallix,Deeprider,Bugaboom,Suprarz,Oxford,Xyen,Chipgizmo,Kittysnake,Raspütin,Calixta,Thepurple,Ihurricanel,Sparklenips,Squidprophet,Rez,Ballour,Mongous,Ones,Solidsix,Dolamroth,Morphintyme,",
		["index"] = "Neekio-1579658609",
		["dkp"] = 20,
		["date"] = 1579658609,
		["reason"] = "Other - Onyxia DKP Fixes",
	}, -- [132]
	{
		["players"] = "Ithgar,",
		["index"] = "Xamina-1579155144",
		["dkp"] = -25,
		["date"] = 1579155144,
		["reason"] = "Other - 10% Shoulders",
	}, -- [133]
	{
		["players"] = "Ithgar,",
		["index"] = "Xamina-1579155127",
		["dkp"] = 118,
		["date"] = 1579155127,
		["reason"] = "Other - Refund",
	}, -- [134]
	{
		["players"] = "Bugaboom,Calixta,Chipgizmo,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Finryr,Fradge,Girlslayer,Holycritpal,Honeypot,Ihurricanel,Ithgar,Kittysnake,Littleshiv,Mallix,Mcstaberson,Mystile,Ones,Oxford,Philonious,Primera,Reina,Rez,Snaildaddy,Solana,Solidsix,Stikyiki,Suprarz,Tankdaddy,Tokentoken,Ugro,Varix,Xamina,Xyen,Ziggi,Zukohere,",
		["index"] = "Xamina-1579154918",
		["dkp"] = 10,
		["date"] = 1579154918,
		["reason"] = "Molten Core: Sulfuron Harbinger",
	}, -- [135]
	{
		["players"] = "Ithgar,",
		["index"] = "Xamina-1579154899",
		["dkp"] = -118,
		["date"] = 1579154899,
		["reason"] = "Other - T1 Hunter Shoulders",
	}, -- [136]
	{
		["players"] = "Mcstaberson,",
		["index"] = "Xamina-1579154843",
		["dkp"] = -142,
		["date"] = 1579154843,
		["reason"] = "Other - T1 Bracers Rogue",
	}, -- [137]
	{
		["players"] = "Bugaboom,",
		["index"] = "Xamina-1579153631",
		["dkp"] = -141,
		["date"] = 1579153631,
		["reason"] = "Other - T1 Bracers",
	}, -- [138]
	{
		["players"] = "Finryr,Ziggi,Fradge,Tokentoken,Girlslayer,Reina,Tankdaddy,Snaildaddy,Ihurricanel,Varix,Kittysnake,Dasmook,Calixta,Littleshiv,Mcstaberson,Stikyiki,Mystile,Dwindle,Philonious,Xamina,Rez,Honeypot,Holycritpal,Ones,Dolamroth,Solidsix,Xyen,Suprarz,Bugaboom,Zukohere,Solana,Chipgizmo,Eolith,Oxford,Deeprider,Ugro,Mallix,Ithgar,Primera,",
		["index"] = "Xamina-1579153563",
		["dkp"] = 10,
		["date"] = 1579153563,
		["reason"] = "Molten Core: Baron Geddon",
	}, -- [139]
	{
		["players"] = "Finryr,Ziggi,Fradge,Tokentoken,Girlslayer,Reina,Tankdaddy,Snaildaddy,Ihurricanel,Varix,Kittysnake,Dasmook,Calixta,Littleshiv,Mcstaberson,Stikyiki,Mystile,Dwindle,Philonious,Xamina,Rez,Honeypot,Holycritpal,Ones,Dolamroth,Solidsix,Xyen,Suprarz,Bugaboom,Zukohere,Solana,Chipgizmo,Eolith,Oxford,Deeprider,Ugro,Mallix,Ithgar,Primera,",
		["index"] = "Xamina-1579153544",
		["dkp"] = 10,
		["date"] = 1579153544,
		["reason"] = "Molten Core: Garr",
	}, -- [140]
	{
		["players"] = "Finryr,Ziggi,Fradge,Tokentoken,Girlslayer,Reina,Tankdaddy,Snaildaddy,Ihurricanel,Varix,Kittysnake,Dasmook,Calixta,Littleshiv,Mcstaberson,Stikyiki,Mystile,Dwindle,Philonious,Xamina,Rez,Honeypot,Holycritpal,Ones,Dolamroth,Solidsix,Xyen,Suprarz,Bugaboom,Zukohere,Solana,Chipgizmo,Eolith,Oxford,Deeprider,Ugro,Mallix,Ithgar,Primera,",
		["index"] = "Xamina-1579153529",
		["dkp"] = 10,
		["date"] = 1579153529,
		["reason"] = "Molten Core: Shazzrah",
	}, -- [141]
	{
		["players"] = "Varix,",
		["index"] = "Xamina-1579153516",
		["dkp"] = -53,
		["date"] = 1579153516,
		["reason"] = "Other - T1 Boots",
	}, -- [142]
	{
		["players"] = "Inigma,",
		["index"] = "Neekio-1579153500",
		["dkp"] = -280,
		["date"] = 1579153500,
		["reason"] = "Other - Perditions Blade",
	}, -- [143]
	{
		["players"] = "Cyskul,",
		["index"] = "Neekio-1579153472",
		["dkp"] = -171,
		["date"] = 1579153472,
		["reason"] = "Other - Cloak of the Shrouded Mists",
	}, -- [144]
	{
		["players"] = "Artorion,",
		["index"] = "Neekio-1579153438",
		["dkp"] = -105,
		["date"] = 1579153438,
		["reason"] = "Other - Judgment Pants",
	}, -- [145]
	{
		["players"] = "Dalia,",
		["index"] = "Neekio-1579153408",
		["dkp"] = -270,
		["date"] = 1579153408,
		["reason"] = "Other - Nemesis Leggins",
	}, -- [146]
	{
		["players"] = "Bugaboom,",
		["index"] = "Xamina-1579153386",
		["dkp"] = -28,
		["date"] = 1579153386,
		["reason"] = "Other - T1 Mage Gloves",
	}, -- [147]
	{
		["players"] = "Cyskul,Papasquach,Trickster,Weapoñ,Galagus,Madmartagen,Kalita,Oragan,Mihai,Schnazzy,Shinynickels,Raspütin,Grymmlock,Dalia,Lindo,Capybara,Mariku,Slipperyjohn,Vehicle,Aku,Mozzarella,Inigma,Fawntine,Evangelina,Ballour,Mongous,Squidprophet,Apolyne,Artorion,Urkh,Thelora,Coldjuice,Stitchess,Veriandra,Athico,Bádtothebow,Bigbootyhoho,Inebriated,Neekio,Morphintyme,",
		["index"] = "Neekio-1579153359",
		["dkp"] = 10,
		["date"] = 1579153359,
		["reason"] = "Molten Core: Ragnaros",
	}, -- [148]
	{
		["players"] = "Ones,",
		["index"] = "Xamina-1579152665",
		["dkp"] = -19,
		["date"] = 1579152665,
		["reason"] = "Other - Fireuined",
	}, -- [149]
	{
		["players"] = "Xyen,",
		["index"] = "Xamina-1579152566",
		["dkp"] = -12,
		["date"] = 1579152566,
		["reason"] = "Other - Arcanist Shoulders ",
	}, -- [150]
	{
		["players"] = "Dolamroth,",
		["index"] = "Xamina-1579152251",
		["dkp"] = -150,
		["date"] = 1579152251,
		["reason"] = "Other - Flamguard Gauntlets",
	}, -- [151]
	{
		["players"] = "Reina,",
		["index"] = "Xamina-1579152112",
		["dkp"] = -145,
		["date"] = 1579152112,
		["reason"] = "Other - Drillborer",
	}, -- [152]
	{
		["players"] = "Stikyiki,",
		["index"] = "Xamina-1579152049",
		["dkp"] = -19,
		["date"] = 1579152049,
		["reason"] = "Other - Rogue TI Head",
	}, -- [153]
	{
		["players"] = "Stitchess,",
		["index"] = "Neekio-1579151944",
		["dkp"] = 2,
		["date"] = 1579151944,
		["reason"] = "DKP Adjust",
	}, -- [154]
	{
		["players"] = "Coldjuice,",
		["index"] = "Neekio-1579151780",
		["dkp"] = -21,
		["date"] = 1579151780,
		["reason"] = "Other - Fireproof Cloak",
	}, -- [155]
	{
		["players"] = "Papasquach,",
		["index"] = "Neekio-1579151723",
		["dkp"] = -99,
		["date"] = 1579151723,
		["reason"] = "Other - Wild Growth Spaulders",
	}, -- [156]
	{
		["players"] = "Weapoñ,Mihai,Kalita,Oragan,Shinynickels,Schnazzy,Galagus,Madmartagen,Grymmlock,Lindo,Dalia,Raspütin,Capybara,Inigma,Mozzarella,Trickster,Aku,Vehicle,Slipperyjohn,Mariku,Squidprophet,Mongous,Apolyne,Fawntine,Evangelina,Ballour,Papasquach,Artorion,Thelora,Urkh,Stitchess,Coldjuice,Veriandra,Cyskul,Athico,Bigbootyhoho,Bádtothebow,Neekio,Inebriated,Morphintyme,",
		["index"] = "Neekio-1579151658",
		["dkp"] = 10,
		["date"] = 1579151658,
		["reason"] = "Molten Core: Baron Geddon",
	}, -- [157]
	{
		["players"] = "Weapoñ,Mihai,Kalita,Oragan,Shinynickels,Schnazzy,Galagus,Madmartagen,Grymmlock,Lindo,Dalia,Raspütin,Capybara,Inigma,Mozzarella,Trickster,Aku,Vehicle,Slipperyjohn,Mariku,Squidprophet,Mongous,Apolyne,Fawntine,Evangelina,Ballour,Papasquach,Artorion,Thelora,Urkh,Stitchess,Coldjuice,Veriandra,Cyskul,Athico,Bigbootyhoho,Bádtothebow,Neekio,Inebriated,Morphintyme,",
		["index"] = "Neekio-1579151650",
		["dkp"] = 10,
		["date"] = 1579151650,
		["reason"] = "Molten Core: Lucifron",
	}, -- [158]
	{
		["players"] = "Weapoñ,Mihai,Kalita,Oragan,Shinynickels,Schnazzy,Galagus,Madmartagen,Grymmlock,Lindo,Dalia,Raspütin,Capybara,Inigma,Mozzarella,Trickster,Aku,Vehicle,Slipperyjohn,Mariku,Squidprophet,Mongous,Apolyne,Fawntine,Evangelina,Ballour,Papasquach,Artorion,Thelora,Urkh,Stitchess,Coldjuice,Veriandra,Cyskul,Athico,Bigbootyhoho,Bádtothebow,Neekio,Inebriated,Morphintyme,",
		["index"] = "Neekio-1579151592",
		["dkp"] = 10,
		["date"] = 1579151592,
		["reason"] = "Molten Core: Majordomo Executus",
	}, -- [159]
	{
		["players"] = "Bugaboom,Calixta,Chipgizmo,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Finryr,Fradge,Girlslayer,Holycritpal,Honeypot,Ihurricanel,Ithgar,Kittysnake,Littleshiv,Mallix,Mcstaberson,Mystile,Ones,Oxford,Philonious,Primera,Reina,Rez,Snaildaddy,Solana,Solidsix,Stikyiki,Suprarz,Tankdaddy,Tokentoken,Ugro,Varix,Xamina,Xyen,Ziggi,Zukohere,",
		["index"] = "Xamina-1579151182",
		["dkp"] = 10,
		["date"] = 1579151182,
		["reason"] = "Molten Core: Gehennas",
	}, -- [160]
	{
		["players"] = "Zukohere,",
		["index"] = "Xamina-1579151173",
		["dkp"] = -35,
		["date"] = 1579151173,
		["reason"] = "Other - Crimson Shocker ",
	}, -- [161]
	{
		["players"] = "Rez,",
		["index"] = "Xamina-1579151146",
		["dkp"] = 17,
		["date"] = 1579151146,
		["reason"] = "Other - Crimson Shocker (Return)",
	}, -- [162]
	{
		["players"] = "Rez,",
		["index"] = "Xamina-1579151112",
		["dkp"] = -17,
		["date"] = 1579151112,
		["reason"] = "Other - Crimson Shocker",
	}, -- [163]
	{
		["players"] = "Mcstaberson,",
		["index"] = "Xamina-1579151046",
		["dkp"] = -27,
		["date"] = 1579151046,
		["reason"] = "Other - Rogue Gloves T1",
	}, -- [164]
	{
		["players"] = "Shinynickels,",
		["index"] = "Neekio-1579150955",
		["dkp"] = -140,
		["date"] = 1579150955,
		["reason"] = "Other - Blastershot Launcher",
	}, -- [165]
	{
		["players"] = "Stitchess,",
		["index"] = "Neekio-1579150918",
		["dkp"] = -32,
		["date"] = 1579150918,
		["reason"] = "Other - Arcanist Robes",
	}, -- [166]
	{
		["players"] = "Weapoñ,Mihai,Kalita,Oragan,Shinynickels,Schnazzy,Galagus,Madmartagen,Grymmlock,Lindo,Dalia,Raspütin,Capybara,Inigma,Mozzarella,Trickster,Aku,Vehicle,Slipperyjohn,Mariku,Squidprophet,Mongous,Apolyne,Fawntine,Evangelina,Ballour,Papasquach,Artorion,Thelora,Urkh,Stitchess,Coldjuice,Veriandra,Cyskul,Athico,Bigbootyhoho,Bádtothebow,Neekio,Inebriated,Morphintyme,",
		["index"] = "Neekio-1579150738",
		["dkp"] = 10,
		["date"] = 1579150738,
		["reason"] = "Molten Core: Golemagg the Incinerator",
	}, -- [167]
	{
		["players"] = "Bugaboom,Calixta,Chipgizmo,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Finryr,Fradge,Girlslayer,Holycritpal,Honeypot,Ihurricanel,Ithgar,Kittysnake,Littleshiv,Mallix,Mcstaberson,Mystile,Ones,Oxford,Philonious,Primera,Reina,Rez,Snaildaddy,Solana,Solidsix,Stikyiki,Suprarz,Tankdaddy,Tokentoken,Ugro,Varix,Xamina,Xyen,Ziggi,Zukohere,",
		["index"] = "Xamina-1579150585",
		["dkp"] = 10,
		["date"] = 1579150585,
		["reason"] = "Molten Core: Magmadar",
	}, -- [168]
	{
		["players"] = "Finryr,",
		["index"] = "Xamina-1579150566",
		["dkp"] = -7,
		["date"] = 1579150566,
		["reason"] = "Other - Flamewalker Legs",
	}, -- [169]
	{
		["players"] = "Varix,",
		["index"] = "Xamina-1579150463",
		["dkp"] = -85,
		["date"] = 1579150463,
		["reason"] = "Other - Felheart Pants",
	}, -- [170]
	{
		["players"] = "Kalita,",
		["index"] = "Neekio-1579150337",
		["dkp"] = -60,
		["date"] = 1579150337,
		["reason"] = "Other - Onyxia head ADJUSTED",
	}, -- [171]
	{
		["players"] = "Ithgar,Primera,Mallix,Deeprider,Ugro,Oxford,Suprarz,Xyen,Solana,Bugaboom,Zukohere,Eolith,Chipgizmo,Dolamroth,Ones,Holycritpal,Solidsix,Xamina,Honeypot,Philonious,Rez,Stikyiki,Dwindle,Mystile,Littleshiv,Mcstaberson,Varix,Kittysnake,Ihurricanel,Calixta,Dasmook,Girlslayer,Fradge,Tankdaddy,Ziggi,Tokentoken,Snaildaddy,Finryr,Reina,",
		["index"] = "Xamina-1579150190",
		["dkp"] = 10,
		["date"] = 1579150190,
		["reason"] = "Molten Core: Lucifron",
	}, -- [172]
	{
		["players"] = "Ones,",
		["index"] = "Xamina-1579150177",
		["dkp"] = -18,
		["date"] = 1579150177,
		["reason"] = "Other - Lawrbinger boots",
	}, -- [173]
	{
		["players"] = "Finryr,",
		["index"] = "Xamina-1579150160",
		["dkp"] = -67,
		["date"] = 1579150160,
		["reason"] = "Other - Might Gloves",
	}, -- [174]
	{
		["players"] = "Inebriated,",
		["index"] = "Neekio-1579150091",
		["dkp"] = -165,
		["date"] = 1579150091,
		["reason"] = "Other - Wristguards of Stability",
	}, -- [175]
	{
		["players"] = "Bugaboom,Calixta,Chipgizmo,Dasmook,Deeprider,Dolamroth,Dwindle,Eolith,Finryr,Fradge,Girlslayer,Holycritpal,Honeypot,Ihurricanel,Ithgar,Kittysnake,Littleshiv,Mallix,Mcstaberson,Mystile,Ones,Oxford,Philonious,Primera,Reina,Rez,Snaildaddy,Solana,Solidsix,Stikyiki,Suprarz,Tankdaddy,Tokentoken,Ugro,Varix,Xamina,Xyen,Ziggi,Zukohere,",
		["index"] = "Xamina-1579149936",
		["dkp"] = 20,
		["date"] = 1579149936,
		["reason"] = "Other - Sign up On time",
	}, -- [176]
	{
		["players"] = "Inebriated,Morphintyme,Neekio,Cyskul,Bádtothebow,Bigbootyhoho,Athico,Veriandra,Urkh,Coldjuice,Stitchess,Thelora,Papasquach,Artorion,Evangelina,Apolyne,Fawntine,Ballour,Squidprophet,Mongous,Mozzarella,Trickster,Aku,Slipperyjohn,Mariku,Inigma,Vehicle,Capybara,Raspütin,Dalia,Grymmlock,Lindo,Madmartagen,Schnazzy,Galagus,Shinynickels,Kalita,Oragan,Mihai,Weapoñ,",
		["index"] = "Neekio-1579149830",
		["dkp"] = 10,
		["date"] = 1579149830,
		["reason"] = "Molten Core: Sulfuron Harbinger",
	}, -- [177]
	{
		["players"] = "Lindo,",
		["index"] = "Neekio-1579147734",
		["dkp"] = -22,
		["date"] = 1579147734,
		["reason"] = "Other - Gloves",
	}, -- [178]
	{
		["players"] = "Capybara,",
		["index"] = "Neekio-1579147709",
		["dkp"] = -113,
		["date"] = 1579147709,
		["reason"] = "Other - Felheart Slippers",
	}, -- [179]
	{
		["players"] = "Morphintyme,",
		["index"] = "Neekio-1579147602",
		["dkp"] = -193,
		["date"] = 1579147602,
		["reason"] = "Other - Cenarion Gloves",
	}, -- [180]
	{
		["players"] = "Inebriated,Morphintyme,Neekio,Cyskul,Bádtothebow,Bigbootyhoho,Athico,Veriandra,Urkh,Coldjuice,Stitchess,Thelora,Papasquach,Artorion,Evangelina,Apolyne,Fawntine,Ballour,Squidprophet,Mongous,Mozzarella,Trickster,Aku,Slipperyjohn,Mariku,Inigma,Vehicle,Capybara,Raspütin,Dalia,Grymmlock,Lindo,Madmartagen,Schnazzy,Galagus,Shinynickels,Kalita,Oragan,Mihai,Weapoñ,",
		["index"] = "Neekio-1579147546",
		["dkp"] = 10,
		["date"] = 1579147546,
		["reason"] = "Molten Core: Shazzrah",
	}, -- [181]
	{
		["players"] = "Lindo,",
		["index"] = "Neekio-1579145591",
		["dkp"] = -24,
		["date"] = 1579145591,
		["reason"] = "Other - Felheart Helm",
	}, -- [182]
	{
		["players"] = "Lindo,",
		["index"] = "Neekio-1579145564",
		["dkp"] = 120,
		["date"] = 1579145564,
		["deletes"] = "Neekio-1579145499",
		["reason"] = "Delete Entry",
	}, -- [183]
	{
		["players"] = "Neekio,",
		["index"] = "Neekio-1579145560",
		["dkp"] = -28,
		["date"] = 1579145560,
		["reason"] = "Other - Cenarion Helm",
	}, -- [184]
	{
		["players"] = "Lindo,",
		["index"] = "Neekio-1579145499",
		["dkp"] = -120,
		["date"] = 1579145499,
		["deletedby"] = "Neekio-1579145564",
		["reason"] = "Other - Felheart Horns",
	}, -- [185]
	{
		["players"] = "Inebriated,Morphintyme,Neekio,Cyskul,Bádtothebow,Bigbootyhoho,Athico,Veriandra,Urkh,Coldjuice,Stitchess,Thelora,Papasquach,Artorion,Evangelina,Apolyne,Fawntine,Ballour,Squidprophet,Mongous,Mozzarella,Trickster,Aku,Slipperyjohn,Mariku,Inigma,Vehicle,Capybara,Raspütin,Dalia,Grymmlock,Lindo,Madmartagen,Schnazzy,Galagus,Shinynickels,Kalita,Oragan,Mihai,Weapoñ,",
		["index"] = "Neekio-1579145264",
		["dkp"] = 10,
		["date"] = 1579145264,
		["reason"] = "Molten Core: Garr",
	}, -- [186]
	{
		["players"] = "Mongous,",
		["index"] = "Neekio-1579144363",
		["dkp"] = -165,
		["date"] = 1579144363,
		["reason"] = "Other - Gloves of Prophecy",
	}, -- [187]
	{
		["players"] = "Inebriated,Morphintyme,Neekio,Cyskul,Bádtothebow,Bigbootyhoho,Athico,Veriandra,Urkh,Coldjuice,Stitchess,Thelora,Papasquach,Artorion,Evangelina,Apolyne,Fawntine,Ballour,Squidprophet,Mongous,Mozzarella,Trickster,Aku,Slipperyjohn,Mariku,Inigma,Vehicle,Capybara,Raspütin,Dalia,Grymmlock,Lindo,Madmartagen,Schnazzy,Galagus,Shinynickels,Kalita,Oragan,Mihai,Weapoñ,",
		["index"] = "Neekio-1579144329",
		["dkp"] = 10,
		["date"] = 1579144329,
		["reason"] = "Molten Core: Gehennas",
	}, -- [188]
	{
		["players"] = "Papasquach,",
		["index"] = "Neekio-1579143528",
		["dkp"] = -118,
		["date"] = 1579143528,
		["reason"] = "Other - Lawbringer Belt",
	}, -- [189]
	{
		["players"] = "Urkh,",
		["index"] = "Neekio-1579143485",
		["dkp"] = -155,
		["date"] = 1579143485,
		["reason"] = "Other - Arcanist Leggings",
	}, -- [190]
	{
		["players"] = "Madmartagen,",
		["index"] = "Neekio-1579143462",
		["dkp"] = -60,
		["date"] = 1579143462,
		["reason"] = "Other - Earthshaker",
	}, -- [191]
	{
		["players"] = "Papasquach,",
		["index"] = "Neekio-1579143445",
		["dkp"] = -26,
		["date"] = 1579143445,
		["reason"] = "Other - Lawbringer Legplates",
	}, -- [192]
	{
		["players"] = "Inebriated,Morphintyme,Neekio,Cyskul,Bádtothebow,Bigbootyhoho,Athico,Veriandra,Urkh,Coldjuice,Stitchess,Thelora,Papasquach,Artorion,Evangelina,Apolyne,Fawntine,Ballour,Squidprophet,Mongous,Mozzarella,Trickster,Aku,Slipperyjohn,Mariku,Inigma,Vehicle,Capybara,Raspütin,Dalia,Grymmlock,Lindo,Madmartagen,Schnazzy,Galagus,Shinynickels,Kalita,Oragan,Mihai,Weapoñ,",
		["index"] = "Neekio-1579143330",
		["dkp"] = 10,
		["date"] = 1579143330,
		["reason"] = "Molten Core: Magmadar",
	}, -- [193]
	{
		["players"] = "Lindo,",
		["index"] = "Neekio-1579143025",
		["dkp"] = -250,
		["date"] = 1579143025,
		["reason"] = "Other - Choker of Enlightenment",
	}, -- [194]
	{
		["players"] = "Kalita,",
		["index"] = "Neekio-1579142906",
		["dkp"] = -155,
		["date"] = 1579142906,
		["reason"] = "Other - Gauntlets of Might",
	}, -- [195]
	{
		["players"] = "Inebriated,Morphintyme,Neekio,Cyskul,Bádtothebow,Bigbootyhoho,Athico,Veriandra,Urkh,Coldjuice,Stitchess,Thelora,Papasquach,Artorion,Evangelina,Apolyne,Fawntine,Ballour,Squidprophet,Mongous,Mozzarella,Trickster,Aku,Slipperyjohn,Mariku,Inigma,Vehicle,Capybara,Raspütin,Dalia,Grymmlock,Lindo,Madmartagen,Schnazzy,Galagus,Shinynickels,Kalita,Oragan,Mihai,Weapoñ,",
		["index"] = "Neekio-1579141791",
		["dkp"] = 10,
		["date"] = 1579141791,
		["reason"] = "Other - Signup bonus",
	}, -- [196]
	{
		["players"] = "Inebriated,Morphintyme,Neekio,Cyskul,Bádtothebow,Bigbootyhoho,Athico,Veriandra,Urkh,Coldjuice,Stitchess,Thelora,Papasquach,Artorion,Evangelina,Apolyne,Fawntine,Ballour,Squidprophet,Mongous,Mozzarella,Trickster,Aku,Slipperyjohn,Mariku,Inigma,Vehicle,Capybara,Raspütin,Dalia,Grymmlock,Lindo,Madmartagen,Schnazzy,Galagus,Shinynickels,Kalita,Oragan,Mihai,Weapoñ,",
		["index"] = "Neekio-1579141781",
		["dkp"] = 10,
		["date"] = 1579141781,
		["reason"] = "On Time Bonus",
	}, -- [197]
	{
		["players"] = "Astlan,",
		["index"] = "Neekio-1578891649",
		["dkp"] = -140,
		["date"] = 1578891649,
		["reason"] = "Other - Onyxia Head (Shroud)",
	}, -- [198]
	{
		["players"] = "Mystile,Inigma,",
		["index"] = "Neekio-1578891363",
		["dkp"] = 20,
		["date"] = 1578891363,
		["reason"] = "DKP Adjust",
	}, -- [199]
	{
		["players"] = "Dwindle,",
		["index"] = "Neekio-1578891302",
		["dkp"] = 20,
		["date"] = 1578891302,
		["reason"] = "DKP Adjust",
	}, -- [200]
	{
		["players"] = "Lindo,",
		["index"] = "Neekio-1578776625",
		["dkp"] = 20,
		["date"] = 1578776625,
		["reason"] = "DKP Adjust",
	}, -- [201]
	{
		["players"] = "Bugaboom,",
		["index"] = "Neekio-1578774003",
		["dkp"] = 10,
		["date"] = 1578774003,
		["reason"] = "DKP Adjust",
	}, -- [202]
	{
		["players"] = "Holycritpal,Astlan,Solidsix,Kalijah,Xamina,Ballour,Kittysnake,Capybara,Athico,Deeprider,Mallix,Oragan,Ziggi,Hew,Nightshelf,Slipperyjohn,Vehicle,Mcstaberson,Kharlin,Ihurricanel,Nubslayer,Zukohere,",
		["index"] = "Neekio-1578773768",
		["dkp"] = 20,
		["date"] = 1578773768,
		["reason"] = "Other - 1/10 - Ony  OT / SU / Completion DKP",
	}, -- [203]
	{
		["players"] = "Thelora,Lindo,Inigma,Mystile,",
		["index"] = "Neekio-1578773135",
		["dkp"] = 20,
		["date"] = 1578773135,
		["reason"] = "DKP Adjust",
	}, -- [204]
	{
		["players"] = "Suprarz,",
		["index"] = "Neekio-1578773073",
		["dkp"] = 40,
		["date"] = 1578773073,
		["reason"] = "DKP Adjust",
	}, -- [205]
	{
		["players"] = "Primera,",
		["index"] = "Neekio-1578772510",
		["dkp"] = 20,
		["date"] = 1578772510,
		["reason"] = "DKP Adjust",
	}, -- [206]
	{
		["players"] = "Ones,",
		["index"] = "Neekio-1578720965",
		["dkp"] = -18,
		["date"] = 1578720965,
		["reason"] = "Unexcused Absence",
	}, -- [207]
	{
		["players"] = "Evangelina,Oxford,Dwindle,Dalia,Eolith,Galagus,Morphintyme,Sparklenips,Kalita,Mongous,Littleshiv,Thepurple,Snaildaddy,Neekio,Cyskul,Bugaboom,Kharlin,Chipgizmo,Raspütin,Ithgar,Tokentoken,Artorion,Madmartagen,Xyen,",
		["index"] = "Neekio-1578715748",
		["dkp"] = 10,
		["date"] = 1578715748,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [208]
	{
		["players"] = "Evangelina,Oxford,Dwindle,Dalia,Eolith,Galagus,Morphintyme,Sparklenips,Kalita,Mongous,Littleshiv,Thepurple,Snaildaddy,Neekio,Cyskul,Bugaboom,Kharlin,Chipgizmo,Raspütin,Ithgar,Tokentoken,Artorion,Madmartagen,Xyen,",
		["index"] = "Neekio-1578711569",
		["dkp"] = 10,
		["date"] = 1578711569,
		["reason"] = "Other - Ontime / Signup",
	}, -- [209]
	{
		["players"] = "Retkin,",
		["index"] = "Neekio-1578711205",
		["dkp"] = -127.5,
		["date"] = 1578711205,
		["reason"] = "Other - Head of Onyxia",
	}, -- [210]
	{
		["players"] = "Bádtothebow,",
		["index"] = "Neekio-1578711042",
		["dkp"] = -28,
		["date"] = 1578711042,
		["reason"] = "Other - Hunter helm",
	}, -- [211]
	{
		["players"] = "Schnazzy,",
		["index"] = "Neekio-1578710998",
		["dkp"] = -21,
		["date"] = 1578710998,
		["reason"] = "Other - Helm of Wrath",
	}, -- [212]
	{
		["players"] = "Coldjuice,",
		["index"] = "Neekio-1578710953",
		["dkp"] = -11,
		["date"] = 1578710953,
		["reason"] = "Other - Grimior",
	}, -- [213]
	{
		["players"] = "Schnazzy,",
		["index"] = "Neekio-1578710880",
		["dkp"] = -212,
		["date"] = 1578710880,
		["reason"] = "Other - Deathbringer",
	}, -- [214]
	{
		["players"] = "Emmyy,Bádtothebow,Ugro,Primera,Bigbootyhoho,Spellbender,Stitchess,Veriandra,Coldjuice,Odin,Maryjohanna,Philonious,Trickster,Killionaire,Aku,Grymmlock,Varix,Calixta,Girlslayer,Partywolf,Schnazzy,Finryr,Retkin,",
		["index"] = "Neekio-1578710827",
		["dkp"] = 10,
		["date"] = 1578710827,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [215]
	{
		["players"] = "Emmyy,Bádtothebow,Ugro,Primera,Bigbootyhoho,Spellbender,Stitchess,Veriandra,Coldjuice,Odin,Maryjohanna,Philonious,Trickster,Killionaire,Aku,Grymmlock,Varix,Calixta,Girlslayer,Partywolf,Schnazzy,Finryr,Retkin,",
		["index"] = "Neekio-1578710822",
		["dkp"] = -10,
		["date"] = 1578710822,
		["deletes"] = "Neekio-1578708731",
		["reason"] = "Delete Entry",
	}, -- [216]
	{
		["players"] = "Emmyy,Bádtothebow,Ugro,Primera,Bigbootyhoho,Spellbender,Stitchess,Veriandra,Coldjuice,Odin,Maryjohanna,Philonious,Trickster,Killionaire,Aku,Grymmlock,Varix,Calixta,Girlslayer,Partywolf,Schnazzy,Finryr,Retkin,",
		["index"] = "Neekio-1578708731",
		["dkp"] = 10,
		["date"] = 1578708731,
		["deletedby"] = "Neekio-1578710822",
		["reason"] = "Other - Signup bonus",
	}, -- [217]
	{
		["players"] = "Emmyy,Bádtothebow,Ugro,Primera,Bigbootyhoho,Spellbender,Stitchess,Veriandra,Coldjuice,Odin,Maryjohanna,Philonious,Trickster,Killionaire,Aku,Grymmlock,Varix,Calixta,Girlslayer,Partywolf,Schnazzy,Finryr,Retkin,",
		["index"] = "Neekio-1578708717",
		["dkp"] = 10,
		["date"] = 1578708717,
		["reason"] = "On Time Bonus",
	}, -- [218]
	{
		["players"] = "Moldyrag,",
		["index"] = "Neekio-1578707443",
		["dkp"] = 120,
		["date"] = 1578707443,
		["reason"] = "Other - MC Adjustment",
	}, -- [219]
	{
		["players"] = "Odin,Bruhtato,Madmartagen,Apolyne,Corseau,Mallix,Deeprider,Wahcha,",
		["index"] = "Neekio-1578707420",
		["dkp"] = 60,
		["date"] = 1578707420,
		["reason"] = "Other - Benched players 50% DKP",
	}, -- [220]
	{
		["players"] = "Nightshelf,",
		["index"] = "Xamina-1578554329",
		["dkp"] = 20,
		["date"] = 1578554329,
		["reason"] = "Other - Lucifron / Signup ",
	}, -- [221]
	{
		["players"] = "Oxford,",
		["index"] = "Xamina-1578554221",
		["dkp"] = 20,
		["date"] = 1578554221,
		["reason"] = "Other - Lucifron / Signup ",
	}, -- [222]
	{
		["players"] = "Dolamroth,",
		["index"] = "Xamina-1578554059",
		["dkp"] = 80,
		["date"] = 1578554059,
		["reason"] = "Other - Roll Correction",
	}, -- [223]
	{
		["players"] = "Finryr,",
		["index"] = "Xamina-1578553599",
		["dkp"] = -93,
		["date"] = 1578553599,
		["reason"] = "Other - Crown Destro",
	}, -- [224]
	{
		["players"] = "Raspütin,",
		["index"] = "Xamina-1578553508",
		["dkp"] = -138,
		["date"] = 1578553508,
		["reason"] = "Other - Nemesis pants",
	}, -- [225]
	{
		["players"] = "Bugaboom,",
		["index"] = "Xamina-1578553458",
		["dkp"] = -220,
		["date"] = 1578553458,
		["reason"] = "Other - Netherwind",
	}, -- [226]
	{
		["players"] = "Finryr,",
		["index"] = "Xamina-1578553397",
		["dkp"] = -187,
		["date"] = 1578553397,
		["reason"] = "Other - Onslaught",
	}, -- [227]
	{
		["players"] = "Aku,Bugaboom,Chipgizmo,Dasmook,Deeprider,Dolamroth,Drrl,Dwindle,Eolith,Finryr,Fradge,Galagus,Hititnquitit,Holycritpal,Ihurricanel,Inigma,Ithgar,Kalijah,Mcstaberson,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Raspütin,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Squidprophet,Suprarz,Thepurple,Tokentoken,Ugro,Xamina,Ziggi,Zukohere,Apolyne,",
		["index"] = "Xamina-1578553306",
		["dkp"] = 10,
		["date"] = 1578553306,
		["reason"] = "Other - Signup",
	}, -- [228]
	{
		["players"] = "Aku,Bugaboom,Chipgizmo,Dasmook,Deeprider,Dolamroth,Drrl,Dwindle,Eolith,Finryr,Fradge,Galagus,Hititnquitit,Holycritpal,Ihurricanel,Inigma,Ithgar,Kalijah,Mcstaberson,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Raspütin,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Squidprophet,Suprarz,Thepurple,Tokentoken,Ugro,Xamina,Ziggi,Zukohere,Apolyne,",
		["index"] = "Xamina-1578553295",
		["dkp"] = 10,
		["date"] = 1578553295,
		["reason"] = "Molten Core: Ragnaros",
	}, -- [229]
	{
		["players"] = "Bugaboom,Ihurricanel,Suprarz,Inigma,Dwindle,Oxford,Mystile,Primera,Drrl,Finryr,Eolith,Galagus,Fradge,Solidsix,Xamina,Zukohere,Raspütin,Sparklenips,Holycritpal,Mongous,Thepurple,Ziggi,Snaildaddy,Retkin,Nightshelf,Mcstaberson,Kalijah,Aku,Ugro,Ones,Dasmook,Dolamroth,Chipgizmo,Squidprophet,Hititnquitit,Ithgar,Apolyne,Rez,Deeprider,Tokentoken,",
		["index"] = "Xamina-1578553004",
		["dkp"] = 10,
		["date"] = 1578553004,
		["reason"] = "Molten Core: Majordomo Executus",
	}, -- [230]
	{
		["players"] = "Solidsix,",
		["index"] = "Xamina-1578552417",
		["dkp"] = -33,
		["date"] = 1578552417,
		["reason"] = "Other - Wildgrowth",
	}, -- [231]
	{
		["players"] = "Aku,",
		["index"] = "Xamina-1578552367",
		["dkp"] = -17,
		["date"] = 1578552367,
		["reason"] = "Other - Fireguard ",
	}, -- [232]
	{
		["players"] = "Ihurricanel,Bugaboom,Primera,Inigma,Dwindle,Suprarz,Oxford,Mystile,Drrl,Finryr,Solidsix,Eolith,Fradge,Galagus,Xamina,Zukohere,Raspütin,Sparklenips,Holycritpal,Mongous,Thepurple,Ziggi,Snaildaddy,Retkin,Nightshelf,Mcstaberson,Aku,Kalijah,Ugro,Ones,Dasmook,Dolamroth,Chipgizmo,Squidprophet,Hititnquitit,Ithgar,Apolyne,Rez,Deeprider,Tokentoken,",
		["index"] = "Xamina-1578551585",
		["dkp"] = 10,
		["date"] = 1578551585,
		["reason"] = "Molten Core: Garr",
	}, -- [233]
	{
		["players"] = "Ihurricanel,Bugaboom,Primera,Inigma,Dwindle,Suprarz,Oxford,Mystile,Drrl,Finryr,Solidsix,Eolith,Fradge,Galagus,Xamina,Zukohere,Raspütin,Sparklenips,Holycritpal,Mongous,Thepurple,Ziggi,Snaildaddy,Retkin,Nightshelf,Mcstaberson,Aku,Kalijah,Ugro,Ones,Dasmook,Dolamroth,Chipgizmo,Squidprophet,Hititnquitit,Ithgar,Apolyne,Rez,Deeprider,Tokentoken,",
		["index"] = "Xamina-1578551569",
		["dkp"] = 10,
		["date"] = 1578551569,
		["reason"] = "Molten Core: Golemagg the Incinerator",
	}, -- [234]
	{
		["players"] = "Zukohere,",
		["index"] = "Xamina-1578551436",
		["dkp"] = -28,
		["date"] = 1578551436,
		["reason"] = "Other - Arcanist Robe",
	}, -- [235]
	{
		["players"] = "Snaildaddy,",
		["index"] = "Xamina-1578551366",
		["dkp"] = -21,
		["date"] = 1578551366,
		["reason"] = "Other - Blaster Launcher",
	}, -- [236]
	{
		["players"] = "Nightshelf,Galagus,Snaildaddy,Retkin,Finryr,Fradge,Ziggi,Tokentoken,Sparklenips,Raspütin,Thepurple,Dasmook,Ihurricanel,Inigma,Aku,Hititnquitit,Dwindle,Mystile,Mcstaberson,Xamina,Rez,Squidprophet,Mongous,Apolyne,Holycritpal,Solidsix,Dolamroth,Ones,Chipgizmo,Bugaboom,Suprarz,Oxford,Eolith,Zukohere,Primera,Ithgar,Ugro,Deeprider,Kalijah,Drrl,",
		["index"] = "Xamina-1578551100",
		["dkp"] = 10,
		["date"] = 1578551100,
		["reason"] = "Molten Core: Shazzrah",
	}, -- [237]
	{
		["players"] = "Nightshelf,Galagus,Snaildaddy,Retkin,Finryr,Fradge,Ziggi,Tokentoken,Sparklenips,Raspütin,Thepurple,Dasmook,Ihurricanel,Inigma,Aku,Hititnquitit,Dwindle,Mystile,Mcstaberson,Xamina,Rez,Squidprophet,Mongous,Apolyne,Holycritpal,Solidsix,Dolamroth,Ones,Chipgizmo,Bugaboom,Suprarz,Oxford,Eolith,Zukohere,Primera,Ithgar,Ugro,Deeprider,Kalijah,Drrl,",
		["index"] = "Xamina-1578551095",
		["dkp"] = 10,
		["date"] = 1578551095,
		["reason"] = "Molten Core: Sulfuron Harbinger",
	}, -- [238]
	{
		["players"] = "Ziggi,",
		["index"] = "Xamina-1578551079",
		["dkp"] = -19,
		["date"] = 1578551079,
		["reason"] = "Other - Vendor Strike",
	}, -- [239]
	{
		["players"] = "Tokentoken,",
		["index"] = "Xamina-1578550829",
		["dkp"] = -5,
		["date"] = 1578550829,
		["reason"] = "Other - Heavy Dark Iron Ring",
	}, -- [240]
	{
		["players"] = "Ithgar,",
		["index"] = "Xamina-1578549885",
		["dkp"] = -65,
		["date"] = 1578549885,
		["reason"] = "Other - Giantsalker Wrists",
	}, -- [241]
	{
		["players"] = "Ithgar,",
		["index"] = "Xamina-1578549254",
		["dkp"] = -130,
		["date"] = 1578549254,
		["reason"] = "Other - Giantsalker GLoves",
	}, -- [242]
	{
		["players"] = "Dasmook,",
		["index"] = "Xamina-1578549202",
		["dkp"] = -101,
		["date"] = 1578549202,
		["reason"] = "Other - Slippers",
	}, -- [243]
	{
		["players"] = "Aku,",
		["index"] = "Xamina-1578548832",
		["dkp"] = -140,
		["date"] = 1578548832,
		["reason"] = "Other - Rogue Bracers",
	}, -- [244]
	{
		["players"] = "Aku,Bugaboom,Chipgizmo,Dasmook,Deeprider,Dolamroth,Drrl,Dwindle,Eolith,Finryr,Fradge,Galagus,Hititnquitit,Holycritpal,Ihurricanel,Inigma,Ithgar,Kalijah,Mcstaberson,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Raspütin,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Squidprophet,Suprarz,Thepurple,Tokentoken,Ugro,Xamina,Ziggi,Zukohere,Apolyne,",
		["index"] = "Xamina-1578548564",
		["dkp"] = 10,
		["date"] = 1578548564,
		["reason"] = "Molten Core: Baron Geddon",
	}, -- [245]
	{
		["players"] = "Thepurple,",
		["index"] = "Xamina-1578548549",
		["dkp"] = -20,
		["date"] = 1578548549,
		["reason"] = "Other - Felheart",
	}, -- [246]
	{
		["players"] = "Dolamroth,",
		["index"] = "Xamina-1578548489",
		["dkp"] = -90,
		["date"] = 1578548489,
		["reason"] = "Other - LAwbringer Shoulders",
	}, -- [247]
	{
		["players"] = "Ones,",
		["index"] = "Xamina-1578548180",
		["dkp"] = -97,
		["date"] = 1578548180,
		["reason"] = "Other - Aurastone Hammer",
	}, -- [248]
	{
		["players"] = "Tokentoken,",
		["index"] = "Xamina-1578548052",
		["dkp"] = -32,
		["date"] = 1578548052,
		["reason"] = "Other - Drillborer",
	}, -- [249]
	{
		["players"] = "Chipgizmo,",
		["index"] = "Xamina-1578547928",
		["dkp"] = -9,
		["date"] = 1578547928,
		["reason"] = "Other - Arcanist Crown",
	}, -- [250]
	{
		["players"] = "Aku,Bugaboom,Chipgizmo,Dasmook,Deeprider,Dolamroth,Drrl,Dwindle,Eolith,Finryr,Fradge,Galagus,Hititnquitit,Holycritpal,Ihurricanel,Inigma,Ithgar,Kalijah,Mcstaberson,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Raspütin,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Squidprophet,Suprarz,Thepurple,Tokentoken,Ugro,Xamina,Ziggi,Zukohere,Apolyne,",
		["index"] = "Xamina-1578547447",
		["dkp"] = 10,
		["date"] = 1578547447,
		["reason"] = "Molten Core: Gehennas",
	}, -- [251]
	{
		["players"] = "Rez,",
		["index"] = "Xamina-1578547200",
		["dkp"] = -38,
		["date"] = 1578547200,
		["reason"] = "Other - Gloves of Prophecy",
	}, -- [252]
	{
		["players"] = "Kalijah,",
		["index"] = "Xamina-1578547131",
		["dkp"] = -11,
		["date"] = 1578547131,
		["reason"] = "Other - Dark Iron Ring",
	}, -- [253]
	{
		["players"] = "Apolyne,",
		["index"] = "Xamina-1578546845",
		["dkp"] = 40,
		["date"] = 1578546845,
		["reason"] = "Other - Sign up / On time / Luc / Mag",
	}, -- [254]
	{
		["players"] = "Aku,Bugaboom,Chipgizmo,Dasmook,Deeprider,Dolamroth,Drrl,Dwindle,Eolith,Finryr,Fradge,Galagus,Hititnquitit,Holycritpal,Ihurricanel,Inigma,Ithgar,Kalijah,Mcstaberson,Mongous,Mystile,Nightshelf,Ones,Oxford,Primera,Raspütin,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Squidprophet,Suprarz,Thepurple,Tokentoken,Ugro,Xamina,Ziggi,Zukohere,",
		["index"] = "Xamina-1578546767",
		["dkp"] = 10,
		["date"] = 1578546767,
		["reason"] = "Molten Core: Magmadar",
	}, -- [255]
	{
		["players"] = "Rez,",
		["index"] = "Xamina-1578546675",
		["dkp"] = -65,
		["date"] = 1578546675,
		["reason"] = "Other - Bracers of Prophecy",
	}, -- [256]
	{
		["players"] = "Eolith,",
		["index"] = "Xamina-1578546612",
		["dkp"] = -29,
		["date"] = 1578546612,
		["reason"] = "Other - Arcanist Legs",
	}, -- [257]
	{
		["players"] = "Retkin,",
		["index"] = "Xamina-1578546526",
		["dkp"] = -135,
		["date"] = 1578546526,
		["reason"] = "Other - Flameguard",
	}, -- [258]
	{
		["players"] = "Ugro,",
		["index"] = "Xamina-1578546411",
		["dkp"] = -80,
		["date"] = 1578546411,
		["reason"] = "Other - Hunter Legs",
	}, -- [259]
	{
		["players"] = "Ihurricanel,Bugaboom,Primera,Inigma,Oxford,Suprarz,Mystile,Dwindle,Eolith,Drrl,Finryr,Retkin,Solidsix,Aku,Fradge,Galagus,Ithgar,Zukohere,Xamina,Thepurple,Raspütin,Ones,Dasmook,Holycritpal,Sparklenips,Mongous,Ugro,Snaildaddy,Dolamroth,Ziggi,Rez,Nightshelf,Mcstaberson,Kalijah,Chipgizmo,Tokentoken,Hititnquitit,Squidprophet,Deeprider,",
		["index"] = "Xamina-1578546219",
		["dkp"] = 10,
		["date"] = 1578546219,
		["reason"] = "Molten Core: Lucifron",
	}, -- [260]
	{
		["players"] = "Neekio,",
		["index"] = "Neekio-1578546198",
		["dkp"] = -210,
		["date"] = 1578546198,
		["reason"] = "Other - Band of Acura",
	}, -- [261]
	{
		["players"] = "Tokentoken,",
		["index"] = "Xamina-1578546197",
		["dkp"] = -34,
		["date"] = 1578546197,
		["reason"] = "Other - Gauntlets",
	}, -- [262]
	{
		["players"] = "Chipgizmo,",
		["index"] = "Xamina-1578546113",
		["dkp"] = -54,
		["date"] = 1578546113,
		["reason"] = "Other - Enlightenment",
	}, -- [263]
	{
		["players"] = "Coldjuice,",
		["index"] = "Neekio-1578545061",
		["dkp"] = -11,
		["date"] = 1578545061,
		["reason"] = "Other - Band of Sulf",
	}, -- [264]
	{
		["players"] = "Bigbootyhoho,",
		["index"] = "Neekio-1578544983",
		["dkp"] = -151,
		["date"] = 1578544983,
		["reason"] = "Other - Dragonstalker leggings",
	}, -- [265]
	{
		["players"] = "Vehicle,",
		["index"] = "Neekio-1578544943",
		["dkp"] = -170,
		["date"] = 1578544943,
		["reason"] = "Other - Bloodfang pants",
	}, -- [266]
	{
		["players"] = "Neekio,Inebriated,Junglemain,Morphintyme,Athico,Bádtothebow,Bigbootyhoho,Cyskul,Thelora,Stitchess,Spellbender,Coldjuice,Veriandra,Urkh,Maryjohanna,Artorion,Astlan,Philonious,Ballour,Fawntine,Evangelina,Trickster,Vehicle,Slipperyjohn,Littleshiv,Mozzarella,Mariku,Killionaire,Varix,Lindo,Capybara,Dalia,Kalita,Oragan,Girlslayer,Schnazzy,Weapoñ,",
		["index"] = "Neekio-1578544912",
		["dkp"] = 10,
		["date"] = 1578544912,
		["reason"] = "Molten Core: Ragnaros",
	}, -- [267]
	{
		["players"] = "Bugaboom,",
		["index"] = "Xamina-1578544708",
		["dkp"] = 20,
		["date"] = 1578544708,
		["reason"] = "Other - 12/19 Ontime + 1/2 Lucifron",
	}, -- [268]
	{
		["players"] = "Killionaire,",
		["index"] = "Neekio-1578544165",
		["dkp"] = -13,
		["date"] = 1578544165,
		["reason"] = "Other - Fireguard shoulders",
	}, -- [269]
	{
		["players"] = "Oragan,",
		["index"] = "Neekio-1578544096",
		["dkp"] = -40,
		["date"] = 1578544096,
		["reason"] = "Other - Core Forged Greves",
	}, -- [270]
	{
		["players"] = "Athico,",
		["index"] = "Neekio-1578543930",
		["dkp"] = -39,
		["date"] = 1578543930,
		["reason"] = "Other - Bracers",
	}, -- [271]
	{
		["players"] = "Neekio,Evangelina,Philonious,Schnazzy,Oragan,Athico,Dalia,Lindo,Thelora,Ballour,Spellbender,Vehicle,Girlslayer,Morphintyme,Bigbootyhoho,Mozzarella,Trickster,Urkh,Slipperyjohn,Kalita,Littleshiv,Astlan,Junglemain,Inebriated,Bádtothebow,Weapoñ,Grymmlock,Papasquach,Veriandra,Stitchess,Shinynickels,Cyskul,Maryjohanna,Capybara,Mariku,Killionaire,Varix,Coldjuice,Artorion,Fawntine,",
		["index"] = "Neekio-1578543915",
		["dkp"] = 10,
		["date"] = 1578543915,
		["reason"] = "Molten Core: Majordomo Executus",
	}, -- [272]
	{
		["players"] = "Stitchess,",
		["index"] = "Neekio-1578543002",
		["dkp"] = -200,
		["date"] = 1578543002,
		["reason"] = "Other - THE FUCKING MAGE BLADE",
	}, -- [273]
	{
		["players"] = "Fawntine,",
		["index"] = "Neekio-1578542851",
		["dkp"] = -35,
		["date"] = 1578542851,
		["reason"] = "Other - Robes of Prophecy",
	}, -- [274]
	{
		["players"] = "Artorion,",
		["index"] = "Neekio-1578542824",
		["dkp"] = -50,
		["date"] = 1578542824,
		["reason"] = "Other - Lawbringers chestguard",
	}, -- [275]
	{
		["players"] = "Artorion,Astlan,Athico,Ballour,Bigbootyhoho,Bádtothebow,Capybara,Coldjuice,Cyskul,Dalia,Evangelina,Fawntine,Girlslayer,Grymmlock,Inebriated,Junglemain,Kalita,Killionaire,Lindo,Littleshiv,Mariku,Maryjohanna,Morphintyme,Mozzarella,Neekio,Oragan,Papasquach,Philonious,Schnazzy,Shinynickels,Slipperyjohn,Spellbender,Stitchess,Thelora,Trickster,Urkh,Varix,Vehicle,Veriandra,Weapoñ,",
		["index"] = "Neekio-1578542796",
		["dkp"] = 10,
		["date"] = 1578542796,
		["reason"] = "Molten Core: Golemagg the Incinerator",
	}, -- [276]
	{
		["players"] = "Thepurple,",
		["index"] = "Xamina-1578542553",
		["dkp"] = 10,
		["date"] = 1578542553,
		["reason"] = "On Time Bonus",
	}, -- [277]
	{
		["players"] = "Bunsoffury,",
		["index"] = "Xamina-1578542542",
		["dkp"] = 10,
		["date"] = 1578542542,
		["reason"] = "On Time Bonus",
	}, -- [278]
	{
		["players"] = "Madmartagen,",
		["index"] = "Xamina-1578542533",
		["dkp"] = 10,
		["date"] = 1578542533,
		["reason"] = "On Time Bonus",
	}, -- [279]
	{
		["players"] = "Mystile,",
		["index"] = "Xamina-1578542526",
		["dkp"] = 10,
		["date"] = 1578542526,
		["reason"] = "On Time Bonus",
	}, -- [280]
	{
		["players"] = "Aku,Bugaboom,Chipgizmo,Dasmook,Dolamroth,Drrl,Dwindle,Eolith,Finryr,Fradge,Hititnquitit,Holycritpal,Ihurricanel,Inigma,Ithgar,Kalijah,Mcstaberson,Moldyrag,Mongous,Nightshelf,Ones,Oxford,Primera,Raspütin,Retkin,Rez,Solidsix,Sparklenips,Squidprophet,Suprarz,Tokentoken,Ugro,Xamina,Ziggi,Zukohere,",
		["index"] = "Xamina-1578542498",
		["dkp"] = 10,
		["date"] = 1578542498,
		["reason"] = "On Time Bonus",
	}, -- [281]
	{
		["players"] = "Shinynickels,",
		["index"] = "Neekio-1578542273",
		["dkp"] = -20,
		["date"] = 1578542273,
		["reason"] = "Other - Pauldrons of Might",
	}, -- [282]
	{
		["players"] = "Artorion,Astlan,Athico,Ballour,Bigbootyhoho,Bádtothebow,Capybara,Coldjuice,Cyskul,Dalia,Evangelina,Fawntine,Girlslayer,Grymmlock,Inebriated,Junglemain,Kalita,Killionaire,Lindo,Littleshiv,Mariku,Maryjohanna,Morphintyme,Mozzarella,Neekio,Oragan,Papasquach,Philonious,Schnazzy,Shinynickels,Slipperyjohn,Spellbender,Stitchess,Thelora,Trickster,Urkh,Varix,Vehicle,Veriandra,Weapoñ,",
		["index"] = "Neekio-1578542259",
		["dkp"] = 10,
		["date"] = 1578542259,
		["reason"] = "Molten Core: Sulfuron Harbinger",
	}, -- [283]
	{
		["players"] = "Bigbootyhoho,",
		["index"] = "Neekio-1578541745",
		["dkp"] = -29,
		["date"] = 1578541745,
		["reason"] = "Other - Giantstalker Bracers",
	}, -- [284]
	{
		["players"] = "Capybara,",
		["index"] = "Neekio-1578541077",
		["dkp"] = -155,
		["date"] = 1578541077,
		["reason"] = "Other - Sorc Dagger",
	}, -- [285]
	{
		["players"] = "Cyskul,",
		["index"] = "Neekio-1578541039",
		["dkp"] = -163,
		["date"] = 1578541039,
		["reason"] = "Other - Giantstalker's Gloves",
	}, -- [286]
	{
		["players"] = "Neekio,Stitchess,Evangelina,Philonious,Schnazzy,Oragan,Thelora,Dalia,Lindo,Athico,Ballour,Spellbender,Cyskul,Capybara,Vehicle,Girlslayer,Bigbootyhoho,Morphintyme,Mozzarella,Trickster,Urkh,Slipperyjohn,Kalita,Littleshiv,Junglemain,Inebriated,Astlan,Bádtothebow,Weapoñ,Grymmlock,Papasquach,Veriandra,Shinynickels,Maryjohanna,Mariku,Killionaire,Varix,Artorion,Coldjuice,Fawntine,",
		["index"] = "Neekio-1578541007",
		["dkp"] = 10,
		["date"] = 1578541007,
		["reason"] = "Molten Core: Shazzrah",
	}, -- [287]
	{
		["players"] = "Capybara,",
		["index"] = "Neekio-1578540412",
		["dkp"] = -40,
		["date"] = 1578540412,
		["reason"] = "Other - Lawbringers Spaulders",
	}, -- [288]
	{
		["players"] = "Maryjohanna,",
		["index"] = "Neekio-1578540380",
		["dkp"] = -150,
		["date"] = 1578540380,
		["reason"] = "Other - Lawbringers Spaulders",
	}, -- [289]
	{
		["players"] = "Evangelina,Neekio,Stitchess,Schnazzy,Philonious,Oragan,Thelora,Dalia,Lindo,Athico,Capybara,Ballour,Spellbender,Cyskul,Maryjohanna,Vehicle,Girlslayer,Bigbootyhoho,Morphintyme,Mozzarella,Trickster,Urkh,Slipperyjohn,Kalita,Littleshiv,Inebriated,Junglemain,Astlan,Bádtothebow,Weapoñ,Grymmlock,Papasquach,Veriandra,Shinynickels,Mariku,Killionaire,Varix,Artorion,Coldjuice,Fawntine,",
		["index"] = "Neekio-1578540359",
		["dkp"] = 10,
		["date"] = 1578540359,
		["reason"] = "Molten Core: Baron Geddon",
	}, -- [290]
	{
		["players"] = "Veriandra,",
		["index"] = "Neekio-1578539763",
		["dkp"] = -172,
		["date"] = 1578539763,
		["reason"] = "Other - Mana ignighting cord",
	}, -- [291]
	{
		["players"] = "Morphintyme,",
		["index"] = "Neekio-1578539639",
		["dkp"] = -27,
		["date"] = 1578539639,
		["reason"] = "Other - Druid helm",
	}, -- [292]
	{
		["players"] = "Neekio,Evangelina,Stitchess,Veriandra,Oragan,Schnazzy,Philonious,Lindo,Dalia,Thelora,Athico,Capybara,Ballour,Spellbender,Cyskul,Maryjohanna,Vehicle,Girlslayer,Morphintyme,Bigbootyhoho,Mozzarella,Trickster,Urkh,Slipperyjohn,Kalita,Littleshiv,Inebriated,Junglemain,Astlan,Bádtothebow,Weapoñ,Grymmlock,Papasquach,Shinynickels,Mariku,Killionaire,Varix,Artorion,Coldjuice,Fawntine,",
		["index"] = "Neekio-1578539616",
		["dkp"] = 10,
		["date"] = 1578539616,
		["reason"] = "Molten Core: Garr",
	}, -- [293]
	{
		["players"] = "Bádtothebow,",
		["index"] = "Neekio-1578538883",
		["dkp"] = -21,
		["date"] = 1578538883,
		["reason"] = "Other - Giantstalker's Boots",
	}, -- [294]
	{
		["players"] = "Fawntine,",
		["index"] = "Neekio-1578538857",
		["dkp"] = -10,
		["date"] = 1578538857,
		["reason"] = "Other - Gloves of Prohecy",
	}, -- [295]
	{
		["players"] = "Neekio,Stitchess,Evangelina,Veriandra,Oragan,Schnazzy,Philonious,Lindo,Dalia,Thelora,Athico,Ballour,Capybara,Spellbender,Cyskul,Maryjohanna,Vehicle,Girlslayer,Morphintyme,Bigbootyhoho,Mozzarella,Trickster,Bádtothebow,Urkh,Slipperyjohn,Kalita,Littleshiv,Astlan,Junglemain,Inebriated,Weapoñ,Grymmlock,Papasquach,Shinynickels,Mariku,Killionaire,Varix,Artorion,Coldjuice,Fawntine,",
		["index"] = "Neekio-1578538836",
		["dkp"] = 10,
		["date"] = 1578538836,
		["reason"] = "Molten Core: Gehennas",
	}, -- [296]
	{
		["players"] = "Astlan,",
		["index"] = "Neekio-1578538285",
		["dkp"] = -20,
		["date"] = 1578538285,
		["reason"] = "Other - Flamewalker Legplates",
	}, -- [297]
	{
		["players"] = "Papasquach,",
		["index"] = "Neekio-1578538238",
		["dkp"] = -18,
		["date"] = 1578538238,
		["reason"] = "Other - Lawbringers legplates",
	}, -- [298]
	{
		["players"] = "Fawntine,",
		["index"] = "Neekio-1578538168",
		["dkp"] = -20,
		["date"] = 1578538168,
		["reason"] = "Other - Pants of Prophecy",
	}, -- [299]
	{
		["players"] = "Neekio,Junglemain,Inebriated,Morphintyme,Athico,Bádtothebow,Cyskul,Bigbootyhoho,Stitchess,Spellbender,Coldjuice,Thelora,Urkh,Veriandra,Maryjohanna,Artorion,Papasquach,Astlan,Ballour,Fawntine,Philonious,Evangelina,Vehicle,Slipperyjohn,Trickster,Littleshiv,Mozzarella,Mariku,Killionaire,Dalia,Grymmlock,Lindo,Capybara,Varix,Girlslayer,Kalita,Shinynickels,Oragan,Schnazzy,Weapoñ,",
		["index"] = "Neekio-1578538160",
		["dkp"] = 20,
		["date"] = 1578538160,
		["deletes"] = "Neekio-1578538152",
		["reason"] = "Delete Entry",
	}, -- [300]
	{
		["players"] = "Neekio,Junglemain,Inebriated,Morphintyme,Athico,Bádtothebow,Cyskul,Bigbootyhoho,Stitchess,Spellbender,Coldjuice,Thelora,Urkh,Veriandra,Maryjohanna,Artorion,Papasquach,Astlan,Ballour,Fawntine,Philonious,Evangelina,Vehicle,Slipperyjohn,Trickster,Littleshiv,Mozzarella,Mariku,Killionaire,Dalia,Grymmlock,Lindo,Capybara,Varix,Girlslayer,Kalita,Shinynickels,Oragan,Schnazzy,Weapoñ,",
		["index"] = "Neekio-1578538152",
		["dkp"] = -20,
		["date"] = 1578538152,
		["deletedby"] = "Neekio-1578538160",
		["reason"] = "Other - Pants of Prophecy",
	}, -- [301]
	{
		["players"] = "Neekio,Junglemain,Inebriated,Morphintyme,Athico,Bádtothebow,Cyskul,Bigbootyhoho,Stitchess,Spellbender,Coldjuice,Thelora,Urkh,Veriandra,Maryjohanna,Artorion,Papasquach,Astlan,Ballour,Fawntine,Philonious,Evangelina,Vehicle,Slipperyjohn,Trickster,Littleshiv,Mozzarella,Mariku,Killionaire,Dalia,Grymmlock,Lindo,Capybara,Varix,Girlslayer,Kalita,Shinynickels,Oragan,Schnazzy,Weapoñ,",
		["index"] = "Neekio-1578538135",
		["dkp"] = 10,
		["date"] = 1578538135,
		["reason"] = "Molten Core: Magmadar",
	}, -- [302]
	{
		["players"] = "Coldjuice,",
		["index"] = "Neekio-1578538019",
		["dkp"] = -15,
		["date"] = 1578538019,
		["reason"] = "Other - Choker of Englightenment ",
	}, -- [303]
	{
		["players"] = "Grymmlock,",
		["index"] = "Neekio-1578537928",
		["dkp"] = -17,
		["date"] = 1578537928,
		["reason"] = "Other - Warlock Gloves",
	}, -- [304]
	{
		["players"] = "Neekio,Junglemain,Inebriated,Morphintyme,Athico,Bádtothebow,Cyskul,Bigbootyhoho,Stitchess,Spellbender,Coldjuice,Thelora,Urkh,Veriandra,Maryjohanna,Artorion,Papasquach,Astlan,Ballour,Fawntine,Philonious,Evangelina,Vehicle,Slipperyjohn,Trickster,Littleshiv,Mozzarella,Mariku,Killionaire,Dalia,Grymmlock,Lindo,Capybara,Varix,Girlslayer,Kalita,Shinynickels,Oragan,Schnazzy,Weapoñ,",
		["index"] = "Neekio-1578537812",
		["dkp"] = 10,
		["date"] = 1578537812,
		["reason"] = "Molten Core: Lucifron",
	}, -- [305]
	{
		["players"] = "Stitchess,Neekio,Evangelina,Schnazzy,Veriandra,Oragan,Philonious,Lindo,Dalia,Athico,Thelora,Ballour,Capybara,Spellbender,Cyskul,Vehicle,Girlslayer,Morphintyme,Bigbootyhoho,Mozzarella,Trickster,Urkh,Astlan,Bádtothebow,Slipperyjohn,Kalita,Littleshiv,Grymmlock,Inebriated,Papasquach,Junglemain,Weapoñ,Shinynickels,Mariku,Killionaire,Coldjuice,Fawntine,Artorion,Varix,",
		["index"] = "Neekio-1578535516",
		["dkp"] = 10,
		["date"] = 1578535516,
		["reason"] = "Other - Signup bonus",
	}, -- [306]
	{
		["players"] = "Coldjuice,Fawntine,Artorion,Varix,",
		["index"] = "Neekio-1578535501",
		["dkp"] = 10,
		["date"] = 1578535501,
		["reason"] = "On Time Bonus",
	}, -- [307]
	{
		["players"] = "Evangelina,Stitchess,Neekio,Schnazzy,Veriandra,Oragan,Philonious,Lindo,Dalia,Thelora,Athico,Capybara,Ballour,Spellbender,Cyskul,Vehicle,Girlslayer,Morphintyme,Bigbootyhoho,Mozzarella,Trickster,Astlan,Bádtothebow,Urkh,Slipperyjohn,Kalita,Littleshiv,Grymmlock,Papasquach,Junglemain,Inebriated,Weapoñ,Shinynickels,Mariku,Killionaire,",
		["index"] = "Neekio-1578535353",
		["dkp"] = 10,
		["date"] = 1578535353,
		["reason"] = "On Time Bonus",
	}, -- [308]
	{
		["players"] = "Ihurricanel,",
		["index"] = "Xamina-1578528136",
		["dkp"] = 20,
		["date"] = 1578528136,
		["reason"] = "Other - 12/19 Missing on Time 1/1 Missing Luc",
	}, -- [309]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Galagus,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mallix,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Suprarz,Trickster,Ugro,Wahcha,Weapoñ,Xamina,Inebriated,Bunsoffury,Xyen,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1578368105",
		["dkp"] = -10,
		["date"] = 1578368105,
		["deletes"] = "Neekio-1577941060",
		["reason"] = "Delete Entry",
	}, -- [310]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mallix,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Suprarz,Trickster,Ugro,Wahcha,Weapoñ,Xamina,Inebriated,Bunsoffury,Xyen,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1578368102",
		["dkp"] = -10,
		["date"] = 1578368102,
		["deletes"] = "Neekio-1577938945",
		["reason"] = "Delete Entry",
	}, -- [311]
	{
		["players"] = "Solana,",
		["index"] = "Xamina-1578287938",
		["dkp"] = 5,
		["date"] = 1578287938,
		["reason"] = "Other - Signup",
	}, -- [312]
	{
		["players"] = "Solana,",
		["index"] = "Xamina-1578287921",
		["dkp"] = 5,
		["date"] = 1578287921,
		["reason"] = "On Time Bonus",
	}, -- [313]
	{
		["players"] = "Solana,",
		["index"] = "Xamina-1578287915",
		["dkp"] = 10,
		["date"] = 1578287915,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [314]
	{
		["players"] = "Wahcha,",
		["index"] = "Xamina-1578287833",
		["dkp"] = -9,
		["date"] = 1578287833,
		["reason"] = "Other - No Call / No Show",
	}, -- [315]
	{
		["players"] = "Nubslayer,",
		["index"] = "Xamina-1578287787",
		["dkp"] = 10,
		["date"] = 1578287787,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [316]
	{
		["players"] = "Nubslayer,",
		["index"] = "Xamina-1578287778",
		["dkp"] = 5,
		["date"] = 1578287778,
		["reason"] = "On Time Bonus",
	}, -- [317]
	{
		["players"] = "Nubslayer,",
		["index"] = "Xamina-1578287765",
		["dkp"] = 5,
		["date"] = 1578287765,
		["reason"] = "Other - Signup",
	}, -- [318]
	{
		["players"] = "Kalijah,Primera,Ugro,Cyskul,Bigbootyhoho,Oxford,Suprarz,Zukohere,Chipgizmo,Spellbender,Solidsix,Ones,Odin,Astlan,Rez,Honeypot,Xamina,Squidprophet,Inigma,Dwindle,Holycritpal,Mcstaberson,Mystile,Trickster,Mozzarella,Sparklenips,Ihurricanel,Raspütin,Dasmook,Retkin,Finryr,Snaildaddy,Ziggi,Nightshelf,Tankdaddy,Galagus,Tokentoken,",
		["index"] = "Xamina-1578287686",
		["dkp"] = 5,
		["date"] = 1578287686,
		["reason"] = "Other - Signup",
	}, -- [319]
	{
		["players"] = "Kalijah,Primera,Ugro,Cyskul,Bigbootyhoho,Oxford,Suprarz,Zukohere,Chipgizmo,Spellbender,Solidsix,Ones,Odin,Astlan,Rez,Honeypot,Xamina,Squidprophet,Inigma,Dwindle,Holycritpal,Mcstaberson,Mystile,Trickster,Mozzarella,Sparklenips,Ihurricanel,Raspütin,Dasmook,Retkin,Finryr,Snaildaddy,Ziggi,Nightshelf,Tankdaddy,Galagus,Tokentoken,",
		["index"] = "Xamina-1578287674",
		["dkp"] = 10,
		["date"] = 1578287674,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [320]
	{
		["players"] = "Kalijah,Primera,Ugro,Cyskul,Bigbootyhoho,Oxford,Suprarz,Zukohere,Chipgizmo,Spellbender,Solidsix,Ones,Odin,Astlan,Rez,Honeypot,Xamina,Squidprophet,Inigma,Dwindle,Holycritpal,Mcstaberson,Mystile,Trickster,Mozzarella,Sparklenips,Ihurricanel,Raspütin,Dasmook,Retkin,Finryr,Snaildaddy,Ziggi,Nightshelf,Tankdaddy,Galagus,Tokentoken,",
		["index"] = "Xamina-1578287667",
		["dkp"] = 5,
		["date"] = 1578287667,
		["reason"] = "On Time Bonus",
	}, -- [321]
	{
		["players"] = "Tokentoken,",
		["index"] = "Xamina-1578287094",
		["dkp"] = -59,
		["date"] = 1578287094,
		["reason"] = "Other - T2 Helm ",
	}, -- [322]
	{
		["players"] = "Ones,",
		["index"] = "Xamina-1578287029",
		["dkp"] = -17,
		["date"] = 1578287029,
		["reason"] = "Other - T2 Helm ",
	}, -- [323]
	{
		["players"] = "Raspütin,",
		["index"] = "Xamina-1578286859",
		["dkp"] = -135,
		["date"] = 1578286859,
		["reason"] = "Other - Saphrion Cloak",
	}, -- [324]
	{
		["players"] = "Ugro,",
		["index"] = "Xamina-1578286691",
		["dkp"] = -140,
		["date"] = 1578286691,
		["reason"] = "Other - Head ",
	}, -- [325]
	{
		["players"] = "Lindo,",
		["index"] = "Neekio-1578278335",
		["dkp"] = 5,
		["date"] = 1578278335,
		["reason"] = "Other - Correction",
	}, -- [326]
	{
		["players"] = "Stitchess,Neekio,Athico,Evangelina,Bugaboom,Lindo,Philonious,Veriandra,Oragan,Schnazzy,Thelora,Grymmlock,Capybara,Ballour,Mallix,Bruhtato,Vehicle,Aku,Girlslayer,Morphintyme,Ithgar,Kharlin,Urkh,Thepurple,Inebriated,Bádtothebow,Slipperyjohn,Weapoñ,Kalita,Mongous,Littleshiv,Junglemain,Papasquach,Emmyy,Killionaire,Landlubbers,Hew,",
		["index"] = "Neekio-1578278206",
		["dkp"] = 5,
		["date"] = 1578278206,
		["reason"] = "Other - Ony signup bonus",
	}, -- [327]
	{
		["players"] = "Hew,",
		["index"] = "Neekio-1578278111",
		["dkp"] = -5,
		["date"] = 1578278111,
		["reason"] = "Other - Shroud Esk neck",
	}, -- [328]
	{
		["players"] = "Grymmlock,",
		["index"] = "Neekio-1578278072",
		["dkp"] = -137,
		["date"] = 1578278072,
		["reason"] = "Other - Head of Onyxia",
	}, -- [329]
	{
		["players"] = "Junglemain,Morphintyme,Inebriated,Neekio,Emmyy,Bádtothebow,Ithgar,Athico,Mallix,Thelora,Landlubbers,Stitchess,Urkh,Bugaboom,Veriandra,Papasquach,Mongous,Philonious,Ballour,Evangelina,Kharlin,Slipperyjohn,Killionaire,Vehicle,Littleshiv,Aku,Thepurple,Lindo,Capybara,Grymmlock,Oragan,Bruhtato,Schnazzy,Girlslayer,Weapoñ,Kalita,Hew,",
		["index"] = "Neekio-1578277983",
		["dkp"] = 10,
		["date"] = 1578277983,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [330]
	{
		["players"] = "Slipperyjohn,",
		["index"] = "Neekio-1578277883",
		["dkp"] = -142.5,
		["date"] = 1578277883,
		["reason"] = "Other - Bloodfang Hood",
	}, -- [331]
	{
		["players"] = "Junglemain,Neekio,Inebriated,Morphintyme,Emmyy,Ithgar,Mallix,Athico,Bádtothebow,Veriandra,Stitchess,Urkh,Thelora,Bugaboom,Papasquach,Ballour,Evangelina,Philonious,Mongous,Slipperyjohn,Aku,Vehicle,Kharlin,Littleshiv,Thepurple,Capybara,Grymmlock,Lindo,Bruhtato,Schnazzy,Oragan,Kalita,Girlslayer,",
		["index"] = "Neekio-1578276114",
		["dkp"] = 5,
		["date"] = 1578276114,
		["reason"] = "On Time Bonus",
	}, -- [332]
	{
		["players"] = "Kharlin,",
		["index"] = "Neekio-1578275034",
		["dkp"] = 30,
		["date"] = 1578275034,
		["reason"] = "DKP Adjust",
	}, -- [333]
	{
		["players"] = "Stitchess,",
		["index"] = "Neekio-1578106476",
		["dkp"] = 10,
		["date"] = 1578106476,
		["reason"] = "On Time Bonus",
	}, -- [334]
	{
		["players"] = "Oragan,Kalijah,Ones,Tokentoken,Ihurricanel,Oxford,Zukohere,Dolamroth,Primera,Evangelina,Athico,Solidsix,Ugro,Slipperyjohn,Inigma,Snaildaddy,Mcstaberson,Ballour,Eolith,Raspütin,Bugaboom,Odin,Dasmook,Chipgizmo,Dwindle,Wahcha,Mystile,Retkin,Suprarz,Mongous,Rez,Lemonz,",
		["index"] = "Xamina-1578028370",
		["dkp"] = 5,
		["date"] = 1578028370,
		["reason"] = "On Time Bonus",
	}, -- [335]
	{
		["players"] = "Oragan,Kalijah,Ones,Tokentoken,Ihurricanel,Oxford,Grymmlock,Zukohere,Dolamroth,Primera,Evangelina,Athico,Solidsix,Ugro,Slipperyjohn,Inigma,Snaildaddy,Mcstaberson,Ballour,Eolith,Raspütin,Bugaboom,Odin,Dasmook,Chipgizmo,Dwindle,Wahcha,Mystile,Retkin,Lemonz,Suprarz,Mongous,Rez,",
		["index"] = "Xamina-1578028350",
		["dkp"] = 5,
		["date"] = 1578028350,
		["reason"] = "Other - Signup ",
	}, -- [336]
	{
		["players"] = "Oragan,Kalijah,Ones,Tokentoken,Ihurricanel,Oxford,Grymmlock,Zukohere,Dolamroth,Primera,Evangelina,Athico,Solidsix,Ugro,Slipperyjohn,Inigma,Snaildaddy,Mcstaberson,Ballour,Eolith,Raspütin,Bugaboom,Odin,Dasmook,Chipgizmo,Dwindle,Wahcha,Mystile,Retkin,Lemonz,Suprarz,Mongous,Rez,",
		["index"] = "Xamina-1578028331",
		["dkp"] = 10,
		["date"] = 1578028331,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [337]
	{
		["players"] = "Kalijah,",
		["index"] = "Xamina-1578027854",
		["dkp"] = -60,
		["date"] = 1578027854,
		["reason"] = "Other - Stormrage Druid T2",
	}, -- [338]
	{
		["players"] = "Wahcha,",
		["index"] = "Xamina-1578027783",
		["dkp"] = -70,
		["date"] = 1578027783,
		["reason"] = "Other - T2 Hunter Helm",
	}, -- [339]
	{
		["players"] = "Kalijah,",
		["index"] = "Xamina-1578027735",
		["dkp"] = -121,
		["date"] = 1578027735,
		["reason"] = "Other - Esk Collar",
	}, -- [340]
	{
		["players"] = "Mcstaberson,",
		["index"] = "Xamina-1578027690",
		["dkp"] = -70,
		["date"] = 1578027690,
		["reason"] = "Other - Viskag",
	}, -- [341]
	{
		["players"] = "Suprarz,",
		["index"] = "Xamina-1578025470",
		["dkp"] = 10,
		["date"] = 1578025470,
		["reason"] = "Molten Core: Ragnaros",
	}, -- [342]
	{
		["players"] = "Inebriated,Drrl,Primera,Athico,Bunsoffury,Ugro,Mallix,Wahcha,Oxford,Bugaboom,Chipgizmo,Xyen,Suprarz,Solidsix,Holycritpal,Dolamroth,Ones,Rez,Xamina,Honeypot,Inigma,Mariku,Mcstaberson,Dwindle,Mystile,Trickster,Hititnquitit,Sparklenips,Ihurricanel,Lindo,Dasmook,Curseberry,Kalijah,Nightshelf,Snaildaddy,Weapoñ,Retkin,Fradge,Tokentoken,Galagus,Reina,",
		["index"] = "Xamina-1578025446",
		["dkp"] = 10,
		["date"] = 1578025446,
		["reason"] = "Molten Core: Majordomo Executus",
	}, -- [343]
	{
		["players"] = "Inebriated,Drrl,Primera,Athico,Bunsoffury,Ugro,Mallix,Wahcha,Oxford,Bugaboom,Chipgizmo,Xyen,Suprarz,Solidsix,Holycritpal,Dolamroth,Ones,Rez,Xamina,Honeypot,Inigma,Mariku,Mcstaberson,Dwindle,Mystile,Trickster,Hititnquitit,Sparklenips,Ihurricanel,Lindo,Dasmook,Curseberry,Kalijah,Nightshelf,Snaildaddy,Weapoñ,Retkin,Fradge,Tokentoken,Galagus,Reina,",
		["index"] = "Xamina-1578025434",
		["dkp"] = 10,
		["date"] = 1578025434,
		["reason"] = "Molten Core: Sulfuron Harbinger",
	}, -- [344]
	{
		["players"] = "Finryr,",
		["index"] = "Neekio-1578024630",
		["dkp"] = -26,
		["date"] = 1578024630,
		["reason"] = "Other - Neck",
	}, -- [345]
	{
		["players"] = "Urkh,",
		["index"] = "Neekio-1578024570",
		["dkp"] = -140,
		["date"] = 1578024570,
		["reason"] = "Other - T2 helm shroud",
	}, -- [346]
	{
		["players"] = "Xyen,",
		["index"] = "Neekio-1578024550",
		["dkp"] = -43,
		["date"] = 1578024550,
		["reason"] = "Other - T2 helm shroud",
	}, -- [347]
	{
		["players"] = "Xamina,Philonious,Honeypot,Dalia,Sparklenips,Capybara,Ithgar,Bigbootyhoho,Bádtothebow,Mallix,Girlslayer,Kalita,Schnazzy,Reina,Neekio,Morphintyme,Drrl,Trickster,Mozzarella,Littleshiv,Aku,Vehicle,Kharlin,Arkleis,Astlan,Veriandra,Xyen,Spellbender,Stitchess,Urkh,Weapoñ,Stikyiki,Lindo,Emmyy,Lemonz,Finryr,",
		["index"] = "Neekio-1578024478",
		["dkp"] = 5,
		["date"] = 1578024478,
		["reason"] = "Other - Ony Signup bonus",
	}, -- [348]
	{
		["players"] = "Xamina,Philonious,Honeypot,Dalia,Sparklenips,Capybara,Ithgar,Bigbootyhoho,Bádtothebow,Mallix,Girlslayer,Kalita,Schnazzy,Reina,Neekio,Morphintyme,Drrl,Trickster,Mozzarella,Littleshiv,Aku,Vehicle,Kharlin,Arkleis,Astlan,Veriandra,Xyen,Spellbender,Stitchess,Urkh,Weapoñ,Stikyiki,Lindo,Emmyy,Lemonz,Finryr,",
		["index"] = "Neekio-1578024465",
		["dkp"] = 10,
		["date"] = 1578024465,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [349]
	{
		["players"] = "Xamina,Philonious,Honeypot,Dalia,Sparklenips,Capybara,Ithgar,Bigbootyhoho,Bádtothebow,Mallix,Girlslayer,Kalita,Schnazzy,Reina,Neekio,Morphintyme,Drrl,Trickster,Mozzarella,Littleshiv,Aku,Vehicle,Kharlin,Arkleis,Astlan,Veriandra,Xyen,Spellbender,Stitchess,Urkh,",
		["index"] = "Neekio-1578024354",
		["dkp"] = 5,
		["date"] = 1578024354,
		["reason"] = "Other - Ony Ontime bonus",
	}, -- [350]
	{
		["players"] = "Morphintyme,Lemonz,Junglemain,Neekio,Ziggi,Shinynickels,Schnazzy,Oragan,Girlslayer,Finryr,Bruhtato,Maryjohanna,Odin,Arkleis,Astlan,Ithgar,Bigbootyhoho,Bádtothebow,Cyskul,Veriandra,Zukohere,Urkh,Thelora,Stitchess,Spellbender,Eolith,Philonious,Mongous,Ballour,Evangelina,Dalia,Capybara,Raspütin,Grymmlock,Vehicle,Aku,Kharlin,Slipperyjohn,Mozzarella,Littleshiv,",
		["index"] = "Neekio-1578024100",
		["dkp"] = 100,
		["date"] = 1578024100,
		["reason"] = "Other - MC completion 10/10",
	}, -- [351]
	{
		["players"] = "Morphintyme,",
		["index"] = "Neekio-1578023878",
		["dkp"] = -72,
		["date"] = 1578023878,
		["reason"] = "Other - Shroud",
	}, -- [352]
	{
		["players"] = "Aku,",
		["index"] = "Neekio-1578023843",
		["dkp"] = -80,
		["date"] = 1578023843,
		["reason"] = "Other - Shroud",
	}, -- [353]
	{
		["players"] = "Ithgar,",
		["index"] = "Neekio-1578023803",
		["dkp"] = -70,
		["date"] = 1578023803,
		["reason"] = "Other - Crown - Shroud",
	}, -- [354]
	{
		["players"] = "Vehicle,",
		["index"] = "Neekio-1578023783",
		["dkp"] = -80,
		["date"] = 1578023783,
		["reason"] = "Other - Shroud",
	}, -- [355]
	{
		["players"] = "Girlslayer,",
		["index"] = "Neekio-1578023758",
		["dkp"] = -75,
		["date"] = 1578023758,
		["reason"] = "Other - Bracers",
	}, -- [356]
	{
		["players"] = "Odin,",
		["index"] = "Neekio-1578023741",
		["dkp"] = -15,
		["date"] = 1578023741,
		["reason"] = "Other - Boots",
	}, -- [357]
	{
		["players"] = "Eolith,",
		["index"] = "Neekio-1578023702",
		["dkp"] = -16,
		["date"] = 1578023702,
		["reason"] = "Other - Mage Robes",
	}, -- [358]
	{
		["players"] = "Bigbootyhoho,",
		["index"] = "Neekio-1578023675",
		["dkp"] = -70,
		["date"] = 1578023675,
		["reason"] = "Other - Hunter chest",
	}, -- [359]
	{
		["players"] = "Oragan,",
		["index"] = "Neekio-1578023644",
		["dkp"] = -16,
		["date"] = 1578023644,
		["reason"] = "Other - Pauldrons",
	}, -- [360]
	{
		["players"] = "Ballour,",
		["index"] = "Neekio-1578023629",
		["dkp"] = -15,
		["date"] = 1578023629,
		["reason"] = "Other - Mantle",
	}, -- [361]
	{
		["players"] = "Finryr,",
		["index"] = "Neekio-1578023527",
		["dkp"] = -16,
		["date"] = 1578023527,
		["reason"] = "Other - Warrior Belt",
	}, -- [362]
	{
		["players"] = "Philonious,",
		["index"] = "Neekio-1578023452",
		["dkp"] = -16,
		["date"] = 1578023452,
		["reason"] = "Other - Priest Boots",
	}, -- [363]
	{
		["players"] = "Zukohere,",
		["index"] = "Neekio-1578023421",
		["dkp"] = -63,
		["date"] = 1578023421,
		["reason"] = "Other - Mage Gloves - Shroud",
	}, -- [364]
	{
		["players"] = "Grymmlock,",
		["index"] = "Neekio-1578023383",
		["dkp"] = -16,
		["date"] = 1578023383,
		["reason"] = "Other - Warlock Belt",
	}, -- [365]
	{
		["players"] = "Capybara,",
		["index"] = "Neekio-1578023314",
		["dkp"] = -15,
		["date"] = 1578023314,
		["reason"] = "Other - Warlock Shoulders",
	}, -- [366]
	{
		["players"] = "Veriandra,",
		["index"] = "Neekio-1578023293",
		["dkp"] = -16,
		["date"] = 1578023293,
		["reason"] = "Other - Grimoire",
	}, -- [367]
	{
		["players"] = "Cyskul,",
		["index"] = "Neekio-1578023276",
		["dkp"] = -14,
		["date"] = 1578023276,
		["reason"] = "Other - Hunter Helm",
	}, -- [368]
	{
		["players"] = "Cyskul,",
		["index"] = "Neekio-1578023258",
		["dkp"] = 14,
		["date"] = 1578023258,
		["deletes"] = "Neekio-1578023229",
		["reason"] = "Delete Entry",
	}, -- [369]
	{
		["players"] = "Cyskul,",
		["index"] = "Neekio-1578023229",
		["dkp"] = -14,
		["date"] = 1578023229,
		["deletedby"] = "Neekio-1578023258",
		["reason"] = "Other - Mage Helm",
	}, -- [370]
	{
		["players"] = "Zukohere,",
		["index"] = "Neekio-1578023213",
		["dkp"] = -14,
		["date"] = 1578023213,
		["reason"] = "Other - Mage Helm",
	}, -- [371]
	{
		["players"] = "Mozzarella,",
		["index"] = "Neekio-1578023137",
		["dkp"] = -4,
		["date"] = 1578023137,
		["reason"] = "Other - Rogue Belt",
	}, -- [372]
	{
		["players"] = "Ballour,",
		["index"] = "Neekio-1578022992",
		["dkp"] = -16,
		["date"] = 1578022992,
		["reason"] = "Other - Priest Gloves",
	}, -- [373]
	{
		["players"] = "Littleshiv,",
		["index"] = "Neekio-1578022960",
		["dkp"] = -1,
		["date"] = 1578022960,
		["reason"] = "Other - Rogue Belt",
	}, -- [374]
	{
		["players"] = "Lemonz,",
		["index"] = "Neekio-1578022943",
		["dkp"] = -2,
		["date"] = 1578022943,
		["reason"] = "Other - Druid Bracers",
	}, -- [375]
	{
		["players"] = "Mongous,",
		["index"] = "Neekio-1578022906",
		["dkp"] = -1,
		["date"] = 1578022906,
		["reason"] = "Other - Priest Bracers",
	}, -- [376]
	{
		["players"] = "Mongous,",
		["index"] = "Neekio-1578022886",
		["dkp"] = 5,
		["date"] = 1578022886,
		["deletes"] = "Neekio-1578022576",
		["reason"] = "Delete Entry",
	}, -- [377]
	{
		["players"] = "Lemonz,",
		["index"] = "Neekio-1578022884",
		["dkp"] = 10,
		["date"] = 1578022884,
		["deletes"] = "Neekio-1578022605",
		["reason"] = "Delete Entry",
	}, -- [378]
	{
		["players"] = "Littleshiv,",
		["index"] = "Neekio-1578022880",
		["dkp"] = 5,
		["date"] = 1578022880,
		["deletes"] = "Neekio-1578022625",
		["reason"] = "Delete Entry",
	}, -- [379]
	{
		["players"] = "Shinynickels,",
		["index"] = "Neekio-1578022853",
		["dkp"] = -10,
		["date"] = 1578022853,
		["reason"] = "Other - Earthshaker Mace",
	}, -- [380]
	{
		["players"] = "Morphintyme,",
		["index"] = "Neekio-1578022817",
		["dkp"] = -16,
		["date"] = 1578022817,
		["reason"] = "Other - Druid Legs",
	}, -- [381]
	{
		["players"] = "Spellbender,",
		["index"] = "Neekio-1578022785",
		["dkp"] = -13,
		["date"] = 1578022785,
		["reason"] = "Other - Mage Pants",
	}, -- [382]
	{
		["players"] = "Capybara,",
		["index"] = "Neekio-1578022734",
		["dkp"] = -16,
		["date"] = 1578022734,
		["reason"] = "Other - Choker",
	}, -- [383]
	{
		["players"] = "Schnazzy,",
		["index"] = "Neekio-1578022703",
		["dkp"] = -16,
		["date"] = 1578022703,
		["reason"] = "Other - Warrior Gloves",
	}, -- [384]
	{
		["players"] = "Littleshiv,",
		["index"] = "Neekio-1578022625",
		["dkp"] = -5,
		["date"] = 1578022625,
		["deletedby"] = "Neekio-1578022880",
		["reason"] = "Other - Rogue Belt",
	}, -- [385]
	{
		["players"] = "Lemonz,",
		["index"] = "Neekio-1578022605",
		["dkp"] = -10,
		["date"] = 1578022605,
		["deletedby"] = "Neekio-1578022884",
		["reason"] = "Other - Druid Bracers",
	}, -- [386]
	{
		["players"] = "Mongous,",
		["index"] = "Neekio-1578022576",
		["dkp"] = -5,
		["date"] = 1578022576,
		["deletedby"] = "Neekio-1578022886",
		["reason"] = "Other - Priest Bracers",
	}, -- [387]
	{
		["players"] = "Neekio,Lemonz,Morphintyme,Junglemain,Ziggi,Shinynickels,Schnazzy,Finryr,Girlslayer,Oragan,Astlan,Odin,Cyskul,Bigbootyhoho,Bádtothebow,Ithgar,Ballour,Evangelina,Philonious,Veriandra,Zukohere,Urkh,Thelora,Eolith,Dalia,Capybara,Grymmlock,Vehicle,Slipperyjohn,Aku,Mozzarella,Bruhtato,Maryjohanna,Spellbender,Stitchess,Mongous,Raspütin,Littleshiv,Kharlin,",
		["index"] = "Neekio-1578022387",
		["dkp"] = 10,
		["date"] = 1578022387,
		["reason"] = "Other - MC - Signup bonus",
	}, -- [388]
	{
		["players"] = "Neekio,Lemonz,Morphintyme,Junglemain,Ziggi,Shinynickels,Schnazzy,Finryr,Girlslayer,Oragan,Astlan,Odin,Cyskul,Bigbootyhoho,Bádtothebow,Ithgar,Ballour,Evangelina,Philonious,Veriandra,Zukohere,Urkh,Thelora,Eolith,Dalia,Capybara,Grymmlock,Vehicle,Slipperyjohn,Aku,Mozzarella,Arkleis,",
		["index"] = "Neekio-1578022311",
		["dkp"] = 10,
		["date"] = 1578022311,
		["reason"] = "Other - MC - On time bonus",
	}, -- [389]
	{
		["players"] = "Neekio,Morphintyme,Maryjohanna,Oragan,Vehicle,Arkleis,Ithgar,Cyskul,Bigbootyhoho,Junglemain,Girlslayer,Schnazzy,Finryr,Bruhtato,Ziggi,Lemonz,Bádtothebow,Veriandra,Eolith,Urkh,Stitchess,Zukohere,Spellbender,Dalia,Capybara,Raspütin,Grymmlock,Kharlin,Aku,Littleshiv,Mozzarella,Slipperyjohn,Odin,Astlan,Thelora,Evangelina,Ballour,Mongous,Drrl,Emmyy,Honeypot,Kalita,Lindo,Mallix,Philonious,Reina,Sparklenips,Stikyiki,Weapoñ,Xamina,Xyen,",
		["index"] = "Neekio-1578020869",
		["dkp"] = -10,
		["date"] = 1578020869,
		["deletes"] = "Neekio-1578020523",
		["reason"] = "Delete Entry",
	}, -- [390]
	{
		["players"] = "Neekio,Morphintyme,Maryjohanna,Oragan,Vehicle,Arkleis,Ithgar,Cyskul,Bigbootyhoho,Junglemain,Girlslayer,Schnazzy,Finryr,Bruhtato,Ziggi,Lemonz,Bádtothebow,Veriandra,Eolith,Urkh,Stitchess,Zukohere,Spellbender,Dalia,Capybara,Raspütin,Grymmlock,Kharlin,Aku,Littleshiv,Mozzarella,Slipperyjohn,Odin,Astlan,Thelora,Evangelina,Ballour,Mongous,",
		["index"] = "Neekio-1578020798",
		["dkp"] = -100,
		["date"] = 1578020798,
		["deletes"] = "Neekio-1578019571",
		["reason"] = "Delete Entry",
	}, -- [391]
	{
		["players"] = "Neekio,Morphintyme,Maryjohanna,Oragan,Vehicle,Arkleis,Ithgar,Cyskul,Bigbootyhoho,Junglemain,Girlslayer,Schnazzy,Finryr,Bruhtato,Ziggi,Lemonz,Bádtothebow,Veriandra,Eolith,Urkh,Stitchess,Zukohere,Spellbender,Dalia,Capybara,Raspütin,Grymmlock,Kharlin,Aku,Littleshiv,Mozzarella,Slipperyjohn,Odin,Astlan,Thelora,Evangelina,Ballour,Mongous,Drrl,Emmyy,Honeypot,Kalita,Lindo,Mallix,Philonious,Reina,Sparklenips,Stikyiki,Weapoñ,Xamina,Xyen,",
		["index"] = "Neekio-1578020523",
		["dkp"] = 10,
		["date"] = 1578020523,
		["deletedby"] = "Neekio-1578020869",
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [392]
	{
		["players"] = "Neekio,Morphintyme,Maryjohanna,Oragan,Vehicle,Arkleis,Ithgar,Cyskul,Bigbootyhoho,Junglemain,Girlslayer,Schnazzy,Finryr,Bruhtato,Ziggi,Lemonz,Bádtothebow,Veriandra,Eolith,Urkh,Stitchess,Zukohere,Spellbender,Dalia,Capybara,Raspütin,Grymmlock,Kharlin,Aku,Littleshiv,Mozzarella,Slipperyjohn,Odin,Astlan,Thelora,Evangelina,Ballour,Mongous,",
		["index"] = "Neekio-1578019571",
		["dkp"] = 100,
		["date"] = 1578019571,
		["deletedby"] = "Neekio-1578020798",
		["reason"] = "Other - MC Completion",
	}, -- [393]
	{
		["players"] = "Reina,Drrl,Kalijah,Ugro,Primera,Suprarz,Bugaboom,Oxford,Chipgizmo,Eolith,Holycritpal,Maryjohanna,Honeypot,Pamplemousse,Evangelina,Mystile,Inigma,Trickster,Puffypoose,Dwindle,Vehicle,Raspütin,Dasmook,Capybara,Ihurricanel,Lindo,Thepurple,Tokentoken,Galagus,Retkin,Finryr,Schnazzy,Girlslayer,",
		["index"] = "Neekio-1577951254",
		["dkp"] = 20,
		["date"] = 1577951254,
		["reason"] = "Other - Onyxia Correction",
	}, -- [394]
	{
		["players"] = "Sparklenips,",
		["index"] = "Neekio-1577950335",
		["dkp"] = -110,
		["date"] = 1577950335,
		["reason"] = "Other - T2 Legs",
	}, -- [395]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Ugro,Wahcha,Xamina,Inebriated,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1577950293",
		["dkp"] = 10,
		["date"] = 1577950293,
		["reason"] = "Molten Core: Ragnaros",
	}, -- [396]
	{
		["players"] = "Rez,",
		["index"] = "Neekio-1577950245",
		["dkp"] = -60,
		["date"] = 1577950245,
		["reason"] = "Other - T2 Legs",
	}, -- [397]
	{
		["players"] = "Snaildaddy,",
		["index"] = "Neekio-1577950186",
		["dkp"] = -110,
		["date"] = 1577950186,
		["reason"] = "Other - Onslaught",
	}, -- [398]
	{
		["players"] = "Weapoñ,",
		["index"] = "Neekio-1577950040",
		["dkp"] = -105,
		["date"] = 1577950040,
		["reason"] = "Other - Bonereavers",
	}, -- [399]
	{
		["players"] = "Wahcha,",
		["index"] = "Neekio-1577950024",
		["dkp"] = -110,
		["date"] = 1577950024,
		["reason"] = "Other - Crown of Destro",
	}, -- [400]
	{
		["players"] = "Holycritpal,",
		["index"] = "Neekio-1577948407",
		["dkp"] = -100,
		["date"] = 1577948407,
		["reason"] = "Other - Wild Growth Shoulders",
	}, -- [401]
	{
		["players"] = "Chipgizmo,",
		["index"] = "Neekio-1577948353",
		["dkp"] = -28,
		["date"] = 1577948353,
		["reason"] = "Other - Fireproof Cloak",
	}, -- [402]
	{
		["players"] = "Mallix,",
		["index"] = "Neekio-1577948290",
		["dkp"] = -22,
		["date"] = 1577948290,
		["reason"] = "Other - Leaf",
	}, -- [403]
	{
		["players"] = "Chipgizmo,",
		["index"] = "Neekio-1577948249",
		["dkp"] = -55,
		["date"] = 1577948249,
		["reason"] = "Other - Arcanist Belt ",
	}, -- [404]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Galagus,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mallix,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Suprarz,Trickster,Ugro,Wahcha,Weapoñ,Xamina,Inebriated,Bunsoffury,Xyen,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1577947732",
		["dkp"] = 10,
		["date"] = 1577947732,
		["reason"] = "Molten Core: Golemagg the Incinerator",
	}, -- [405]
	{
		["players"] = "Trickster,",
		["index"] = "Neekio-1577947694",
		["dkp"] = -100,
		["date"] = 1577947694,
		["reason"] = "Other - Nightslayer Chest",
	}, -- [406]
	{
		["players"] = "Chipgizmo,",
		["index"] = "Neekio-1577947622",
		["dkp"] = -100,
		["date"] = 1577947622,
		["reason"] = "Other - Staff of Dominance",
	}, -- [407]
	{
		["players"] = "Solidsix,",
		["index"] = "Neekio-1577947526",
		["dkp"] = -20,
		["date"] = 1577947526,
		["reason"] = "Other - Lawbringer Chest",
	}, -- [408]
	{
		["players"] = "Honeypot,",
		["index"] = "Neekio-1577947110",
		["dkp"] = -80,
		["date"] = 1577947110,
		["reason"] = "Other - Shoulders of Prophecy",
	}, -- [409]
	{
		["players"] = "Tokentoken,",
		["index"] = "Neekio-1577947040",
		["dkp"] = -38,
		["date"] = 1577947040,
		["reason"] = "Other - Shoulders of Might",
	}, -- [410]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Galagus,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mallix,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Suprarz,Trickster,Ugro,Wahcha,Weapoñ,Xamina,Inebriated,Bunsoffury,Xyen,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1577945372",
		["dkp"] = 10,
		["date"] = 1577945372,
		["reason"] = "Molten Core: Shazzrah",
	}, -- [411]
	{
		["players"] = "Mariku,",
		["index"] = "Neekio-1577945341",
		["dkp"] = -23,
		["date"] = 1577945341,
		["reason"] = "Other - Felheart Shoulder",
	}, -- [412]
	{
		["players"] = "Kalijah,",
		["index"] = "Neekio-1577945230",
		["dkp"] = -19,
		["date"] = 1577945230,
		["reason"] = "Molten Core: Shazzrah",
	}, -- [413]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Galagus,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mallix,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Suprarz,Trickster,Ugro,Wahcha,Weapoñ,Xamina,Inebriated,Bunsoffury,Xyen,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1577944902",
		["dkp"] = 10,
		["date"] = 1577944902,
		["reason"] = "Molten Core: Baron Geddon",
	}, -- [414]
	{
		["players"] = "Dasmook,",
		["index"] = "Neekio-1577944892",
		["dkp"] = -53,
		["date"] = 1577944892,
		["reason"] = "Other - Felheart Shoulder",
	}, -- [415]
	{
		["players"] = "Snaildaddy,",
		["index"] = "Neekio-1577944873",
		["dkp"] = -20,
		["date"] = 1577944873,
		["reason"] = "Other - Flamewalker Legs",
	}, -- [416]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Galagus,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mallix,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Suprarz,Trickster,Ugro,Wahcha,Weapoñ,Xamina,Inebriated,Bunsoffury,Xyen,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1577944097",
		["dkp"] = 10,
		["date"] = 1577944097,
		["reason"] = "Molten Core: Garr",
	}, -- [417]
	{
		["players"] = "Mariku,",
		["index"] = "Neekio-1577944087",
		["dkp"] = -35,
		["date"] = 1577944087,
		["reason"] = "Other - Nightslayer Helm",
	}, -- [418]
	{
		["players"] = "Xyen,",
		["index"] = "Neekio-1577944018",
		["dkp"] = -25,
		["date"] = 1577944018,
		["reason"] = "Other - Mana Igniting Cord",
	}, -- [419]
	{
		["players"] = "Ones,",
		["index"] = "Neekio-1577943953",
		["dkp"] = -9,
		["date"] = 1577943953,
		["reason"] = "Other - Lawbringer Helm",
	}, -- [420]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Galagus,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mallix,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Suprarz,Trickster,Ugro,Wahcha,Weapoñ,Xamina,Inebriated,Bunsoffury,Xyen,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1577942277",
		["dkp"] = 10,
		["date"] = 1577942277,
		["reason"] = "Molten Core: Gehennas",
	}, -- [421]
	{
		["players"] = "Xamina,",
		["index"] = "Neekio-1577942223",
		["dkp"] = -160,
		["date"] = 1577942223,
		["reason"] = "Other - Girdle of Prophecy",
	}, -- [422]
	{
		["players"] = "Xamina,",
		["index"] = "Neekio-1577942215",
		["dkp"] = 80,
		["date"] = 1577942215,
		["reason"] = "Other - Girdle of Prophecy",
	}, -- [423]
	{
		["players"] = "Curseberry,",
		["index"] = "Neekio-1577942129",
		["dkp"] = -13,
		["date"] = 1577942129,
		["reason"] = "Other - Robe of Volatile",
	}, -- [424]
	{
		["players"] = "Ones,",
		["index"] = "Neekio-1577942004",
		["dkp"] = -80,
		["date"] = 1577942004,
		["reason"] = "Other - Gauntlets ",
	}, -- [425]
	{
		["players"] = "Nightshelf,",
		["index"] = "Neekio-1577941739",
		["dkp"] = -20,
		["date"] = 1577941739,
		["reason"] = "Molten Core: Magmadar",
	}, -- [426]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Galagus,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mallix,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Suprarz,Trickster,Ugro,Wahcha,Weapoñ,Xamina,Inebriated,Bunsoffury,Xyen,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1577941546",
		["dkp"] = 10,
		["date"] = 1577941546,
		["reason"] = "Molten Core: Magmadar",
	}, -- [427]
	{
		["players"] = "Curseberry,",
		["index"] = "Neekio-1577941444",
		["dkp"] = -15,
		["date"] = 1577941444,
		["reason"] = "Other - Mana Igniting",
	}, -- [428]
	{
		["players"] = "Dasmook,",
		["index"] = "Neekio-1577941373",
		["dkp"] = -75,
		["date"] = 1577941373,
		["reason"] = "Other - Felheart Pants",
	}, -- [429]
	{
		["players"] = "Tokentoken,",
		["index"] = "Neekio-1577941279",
		["dkp"] = -25,
		["date"] = 1577941279,
		["reason"] = "Other - Legplates of Might",
	}, -- [430]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Galagus,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mallix,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Suprarz,Trickster,Ugro,Wahcha,Weapoñ,Xamina,Inebriated,Bunsoffury,Xyen,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1577941060",
		["dkp"] = 10,
		["date"] = 1577941060,
		["deletedby"] = "Neekio-1578368105",
		["reason"] = "Molten Core: Lucifron",
	}, -- [431]
	{
		["players"] = "Nightshelf,",
		["index"] = "Neekio-1577940951",
		["dkp"] = -20,
		["date"] = 1577940951,
		["reason"] = "Other - Gloves of Might",
	}, -- [432]
	{
		["players"] = "Xyen,",
		["index"] = "Neekio-1577940937",
		["dkp"] = -20,
		["date"] = 1577940937,
		["reason"] = "Other - Arcanist Boots",
	}, -- [433]
	{
		["players"] = "Curseberry,",
		["index"] = "Neekio-1577938972",
		["dkp"] = 10,
		["date"] = 1577938972,
		["reason"] = "On Time Bonus",
	}, -- [434]
	{
		["players"] = "Athico,Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Fradge,Holycritpal,Honeypot,Ihurricanel,Inigma,Kalijah,Lindo,Mallix,Mariku,Mystile,Ones,Oxford,Primera,Reina,Retkin,Rez,Snaildaddy,Solidsix,Sparklenips,Suprarz,Trickster,Ugro,Wahcha,Weapoñ,Xamina,Inebriated,Bunsoffury,Xyen,Dolamroth,Mcstaberson,Nightshelf,Tokentoken,Curseberry,",
		["index"] = "Neekio-1577938945",
		["dkp"] = 10,
		["date"] = 1577938945,
		["deletedby"] = "Neekio-1578368102",
		["reason"] = "Other - Sign-Up",
	}, -- [435]
	{
		["players"] = "Tokentoken,Inebriated,Mariku,Xyen,Nightshelf,Dolamroth,Mcstaberson,Rez,",
		["index"] = "Neekio-1577938652",
		["dkp"] = 30,
		["date"] = 1577938652,
		["reason"] = "Other - Ony",
	}, -- [436]
	{
		["players"] = "Bunsoffury,",
		["index"] = "Neekio-1577938458",
		["dkp"] = 120,
		["date"] = 1577938458,
		["reason"] = "Raid Completion Bonus",
	}, -- [437]
	{
		["players"] = "Fradge,Weapoñ,Retkin,Snaildaddy,Ihurricanel,Lindo,Dasmook,Sparklenips,Inigma,Dwindle,Trickster,Mystile,Rez,Xamina,Honeypot,Holycritpal,Solidsix,Ones,Oxford,Suprarz,Chipgizmo,Bugaboom,Ugro,Wahcha,Athico,Primera,Mallix,Drrl,Kalijah,",
		["index"] = "Neekio-1577937727",
		["dkp"] = 10,
		["date"] = 1577937727,
		["reason"] = "On Time Bonus",
	}, -- [438]
	{
		["players"] = "Moldyrag,",
		["index"] = "Neekio-1576988382",
		["dkp"] = 10,
		["date"] = 1576988382,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [439]
	{
		["players"] = "Neekio,Morphintyme,Corseau,Emmyy,Wahcha,Mallix,Athico,Stitchess,Urkh,Veriandra,Thelora,Odin,Kuckuck,Ballour,Philonious,Slipperyjohn,Mozzarella,Aku,Grymmlock,Dalia,Snaildaddy,Oragan,",
		["index"] = "Neekio-1576988222",
		["dkp"] = 10,
		["date"] = 1576988222,
		["reason"] = "Onyxia's Lair: Onyxia",
	}, -- [440]
	{
		["players"] = "Neekio,Morphintyme,Corseau,Emmyy,Wahcha,Mallix,Athico,Stitchess,Urkh,Veriandra,Thelora,Odin,Kuckuck,Ballour,Philonious,Slipperyjohn,Mozzarella,Aku,Grymmlock,Dalia,Snaildaddy,Oragan,",
		["index"] = "Neekio-1576980647",
		["dkp"] = 5,
		["date"] = 1576980647,
		["reason"] = "Other - Signup bonus",
	}, -- [441]
	{
		["players"] = "Neekio,Morphintyme,Corseau,Emmyy,Wahcha,Mallix,Athico,Stitchess,Urkh,Veriandra,Thelora,Odin,Kuckuck,Ballour,Philonious,Slipperyjohn,Mozzarella,Aku,Grymmlock,Dalia,Snaildaddy,Oragan,",
		["index"] = "Neekio-1576980636",
		["dkp"] = 5,
		["date"] = 1576980636,
		["reason"] = "On Time Bonus",
	}, -- [442]
	{
		["players"] = "Honeypot,",
		["index"] = "Neekio-1576742156",
		["dkp"] = 10,
		["date"] = 1576742156,
		["reason"] = "Other - was there for 7 bosses",
	}, -- [443]
	{
		["players"] = "Finryr,",
		["index"] = "Neekio-1576741274",
		["dkp"] = 10,
		["date"] = 1576741274,
		["reason"] = "Other - sign up",
	}, -- [444]
	{
		["players"] = "Galagus,",
		["index"] = "Neekio-1576741256",
		["dkp"] = 110,
		["date"] = 1576741256,
		["reason"] = "Other - sign up",
	}, -- [445]
	{
		["players"] = "Fradge,",
		["index"] = "Neekio-1576741241",
		["dkp"] = 10,
		["date"] = 1576741241,
		["reason"] = "Other - sign up",
	}, -- [446]
	{
		["players"] = "Dwindle,",
		["index"] = "Neekio-1576741085",
		["dkp"] = 10,
		["date"] = 1576741085,
		["reason"] = "Other - sign up",
	}, -- [447]
	{
		["players"] = "Mystile,",
		["index"] = "Neekio-1576741081",
		["dkp"] = 10,
		["date"] = 1576741081,
		["reason"] = "Other - sign up",
	}, -- [448]
	{
		["players"] = "Puffypoose,",
		["index"] = "Neekio-1576741072",
		["dkp"] = 10,
		["date"] = 1576741072,
		["reason"] = "Other - sign up",
	}, -- [449]
	{
		["players"] = "Pamplemousse,",
		["index"] = "Neekio-1576741040",
		["dkp"] = 10,
		["date"] = 1576741040,
		["reason"] = "Other - sign up",
	}, -- [450]
	{
		["players"] = "Solidsix,",
		["index"] = "Neekio-1576741025",
		["dkp"] = 10,
		["date"] = 1576741025,
		["reason"] = "Other - sign up",
	}, -- [451]
	{
		["players"] = "Holycritpal,",
		["index"] = "Neekio-1576741018",
		["dkp"] = 10,
		["date"] = 1576741018,
		["reason"] = "Other - sign up",
	}, -- [452]
	{
		["players"] = "Odin,",
		["index"] = "Neekio-1576741004",
		["dkp"] = 10,
		["date"] = 1576741004,
		["reason"] = "Other - sign up",
	}, -- [453]
	{
		["players"] = "Ones,",
		["index"] = "Neekio-1576740983",
		["dkp"] = 10,
		["date"] = 1576740983,
		["reason"] = "Other - sign up",
	}, -- [454]
	{
		["players"] = "Suprarz,",
		["index"] = "Neekio-1576740969",
		["dkp"] = 10,
		["date"] = 1576740969,
		["reason"] = "Other - sign up",
	}, -- [455]
	{
		["players"] = "Bugaboom,",
		["index"] = "Neekio-1576740941",
		["dkp"] = 10,
		["date"] = 1576740941,
		["reason"] = "Other - sign up",
	}, -- [456]
	{
		["players"] = "Limeybeard,",
		["index"] = "Neekio-1576740910",
		["dkp"] = 20,
		["date"] = 1576740910,
		["reason"] = "Other - sign up",
	}, -- [457]
	{
		["players"] = "Moldyrag,",
		["index"] = "Neekio-1576740875",
		["dkp"] = 10,
		["date"] = 1576740875,
		["reason"] = "Other - sign up",
	}, -- [458]
	{
		["players"] = "Oxford,",
		["index"] = "Neekio-1576740862",
		["dkp"] = 10,
		["date"] = 1576740862,
		["reason"] = "Other - sign up",
	}, -- [459]
	{
		["players"] = "Ugro,",
		["index"] = "Neekio-1576740857",
		["dkp"] = 10,
		["date"] = 1576740857,
		["reason"] = "Other - sign up",
	}, -- [460]
	{
		["players"] = "Primera,",
		["index"] = "Neekio-1576740838",
		["dkp"] = 10,
		["date"] = 1576740838,
		["reason"] = "Other - sign up",
	}, -- [461]
	{
		["players"] = "Chipgizmo,",
		["index"] = "Neekio-1576740773",
		["dkp"] = 10,
		["date"] = 1576740773,
		["reason"] = "Other - sign up",
	}, -- [462]
	{
		["players"] = "Corseau,",
		["index"] = "Neekio-1576740764",
		["dkp"] = 10,
		["date"] = 1576740764,
		["reason"] = "Other - sign up",
	}, -- [463]
	{
		["players"] = "Dasmook,",
		["index"] = "Neekio-1576740753",
		["dkp"] = 10,
		["date"] = 1576740753,
		["reason"] = "Other - sign up",
	}, -- [464]
	{
		["players"] = "Drrl,",
		["index"] = "Neekio-1576740746",
		["dkp"] = 10,
		["date"] = 1576740746,
		["reason"] = "Other - sign up",
	}, -- [465]
	{
		["players"] = "Ihurricanel,",
		["index"] = "Neekio-1576740740",
		["dkp"] = 10,
		["date"] = 1576740740,
		["reason"] = "Other - sign up",
	}, -- [466]
	{
		["players"] = "Gnomenuts,",
		["index"] = "Neekio-1576740736",
		["dkp"] = 10,
		["date"] = 1576740736,
		["reason"] = "Other - sign up",
	}, -- [467]
	{
		["players"] = "Lindo,",
		["index"] = "Neekio-1576740731",
		["dkp"] = 10,
		["date"] = 1576740731,
		["reason"] = "Other - sign up",
	}, -- [468]
	{
		["players"] = "Sparklenips,",
		["index"] = "Neekio-1576740726",
		["dkp"] = 10,
		["date"] = 1576740726,
		["reason"] = "Other - sign up",
	}, -- [469]
	{
		["players"] = "Stikyiki,",
		["index"] = "Neekio-1576740723",
		["dkp"] = 10,
		["date"] = 1576740723,
		["reason"] = "Other - sign up",
	}, -- [470]
	{
		["players"] = "Tankdaddy,",
		["index"] = "Neekio-1576740718",
		["dkp"] = 10,
		["date"] = 1576740718,
		["reason"] = "Other - sign up",
	}, -- [471]
	{
		["players"] = "Thepurple,",
		["index"] = "Neekio-1576740700",
		["dkp"] = 10,
		["date"] = 1576740700,
		["reason"] = "Other - sign up",
	}, -- [472]
	{
		["players"] = "Weapoñ,",
		["index"] = "Neekio-1576740692",
		["dkp"] = 10,
		["date"] = 1576740692,
		["reason"] = "Other - sign up",
	}, -- [473]
	{
		["players"] = "Xamina,",
		["index"] = "Neekio-1576740679",
		["dkp"] = 10,
		["date"] = 1576740679,
		["reason"] = "Other - sign up",
	}, -- [474]
	{
		["players"] = "Kalijah,",
		["index"] = "Neekio-1576740668",
		["dkp"] = 10,
		["date"] = 1576740668,
		["reason"] = "Other - sign up",
	}, -- [475]
	{
		["players"] = "Honeypot,",
		["index"] = "Neekio-1576740510",
		["dkp"] = -30,
		["date"] = 1576740510,
		["reason"] = "Raid Completion Bonus",
	}, -- [476]
	{
		["players"] = "Retkin,",
		["index"] = "Neekio-1576740449",
		["dkp"] = 10,
		["date"] = 1576740449,
		["reason"] = "Raid Completion Bonus",
	}, -- [477]
	{
		["players"] = "Retkin,",
		["index"] = "Neekio-1576740422",
		["dkp"] = -20,
		["date"] = 1576740422,
		["reason"] = "Raid Completion Bonus",
	}, -- [478]
	{
		["players"] = "Inigma,",
		["index"] = "Neekio-1576740317",
		["dkp"] = 110,
		["date"] = 1576740317,
		["reason"] = "Raid Completion Bonus",
	}, -- [479]
	{
		["players"] = "Mallix,",
		["index"] = "Neekio-1576740300",
		["dkp"] = 110,
		["date"] = 1576740300,
		["reason"] = "Raid Completion Bonus",
	}, -- [480]
	{
		["players"] = "Wahcha,",
		["index"] = "Neekio-1576740263",
		["dkp"] = 100,
		["date"] = 1576740263,
		["reason"] = "Raid Completion Bonus",
	}, -- [481]
	{
		["players"] = "Bugaboom,Chipgizmo,Corseau,Dasmook,Drrl,Dwindle,Finryr,Fradge,Gnomenuts,Holycritpal,Honeypot,Ihurricanel,Kalijah,Limeybeard,Lindo,Moldyrag,Mystile,Odin,Ones,Oxford,Pamplemousse,Primera,Puffypoose,Reina,Retkin,Solidsix,Sparklenips,Stikyiki,Suprarz,Tankdaddy,Thepurple,Ugro,Weapoñ,Xamina,",
		["index"] = "Neekio-1576740196",
		["dkp"] = 100,
		["date"] = 1576740196,
		["reason"] = "Raid Completion Bonus",
	}, -- [482]
	{
		["players"] = "Oldmanmike,Neekio,Morphintyme,Cyskul,Bigbootyhoho,Ithgar,Athico,Veriandra,Eolith,Zukohere,Spellbender,Urkh,Thelora,Stitchess,Kuckuck,Papasquach,Maryjohanna,Chaintoker,Arkleis,Ballour,Evangelina,Philonious,Aku,Trickster,Vehicle,Slipperyjohn,Capybara,Grymmlock,Dalia,Raspütin,Snaildaddy,Girlslayer,Kalita,Cheeza,Bruhtato,Oragan,Schnazzy,",
		["index"] = "Neekio-1576733134",
		["dkp"] = 10,
		["date"] = 1576733134,
		["reason"] = "Molten Core: Majordomo Executus",
	}, -- [483]
	{
		["players"] = "Oldmanmike,Neekio,Morphintyme,Cyskul,Bigbootyhoho,Ithgar,Athico,Veriandra,Eolith,Zukohere,Spellbender,Urkh,Thelora,Stitchess,Kuckuck,Papasquach,Maryjohanna,Chaintoker,Arkleis,Ballour,Evangelina,Philonious,Aku,Trickster,Vehicle,Slipperyjohn,Capybara,Grymmlock,Dalia,Raspütin,Snaildaddy,Girlslayer,Kalita,Cheeza,Bruhtato,Oragan,Schnazzy,",
		["index"] = "Neekio-1576733127",
		["dkp"] = 10,
		["date"] = 1576733127,
		["reason"] = "Molten Core: Ragnaros",
	}, -- [484]
	{
		["players"] = "Capybara,Vehicle,",
		["index"] = "Neekio-1576730898",
		["dkp"] = 100,
		["date"] = 1576730898,
		["reason"] = "Other - Signup, OT, 8 kills",
	}, -- [485]
	{
		["players"] = "Morphintyme,Neekio,Oldmanmike,Cyskul,Ithgar,Bigbootyhoho,Athico,Eolith,Zukohere,Spellbender,Thelora,Stitchess,Urkh,Veriandra,Papasquach,Kuckuck,Maryjohanna,Arkleis,Philonious,Evangelina,Ballour,Aku,Trickster,Slipperyjohn,Grymmlock,Raspütin,Dalia,Oragan,Cheeza,Bruhtato,Snaildaddy,Schnazzy,",
		["index"] = "Neekio-1576730780",
		["dkp"] = 10,
		["date"] = 1576730780,
		["reason"] = "On Time Bonus",
	}, -- [486]
	{
		["players"] = "Morphintyme,Neekio,Oldmanmike,Cyskul,Ithgar,Bigbootyhoho,Athico,Eolith,Zukohere,Spellbender,Thelora,Stitchess,Urkh,Veriandra,Papasquach,Kuckuck,Maryjohanna,Chaintoker,Arkleis,Philonious,Evangelina,Ballour,Aku,Trickster,Slipperyjohn,Grymmlock,Raspütin,Dalia,Girlslayer,Kalita,Oragan,Cheeza,Bruhtato,Snaildaddy,Schnazzy,",
		["index"] = "Neekio-1576730700",
		["dkp"] = 10,
		["date"] = 1576730700,
		["reason"] = "Other - Signup bonus",
	}, -- [487]
	{
		["players"] = "Morphintyme,Neekio,Oldmanmike,Cyskul,Ithgar,Bigbootyhoho,Athico,Eolith,Zukohere,Spellbender,Thelora,Stitchess,Urkh,Veriandra,Papasquach,Kuckuck,Maryjohanna,Chaintoker,Arkleis,Philonious,Evangelina,Ballour,Aku,Trickster,Slipperyjohn,Grymmlock,Raspütin,Dalia,Girlslayer,Kalita,Oragan,Cheeza,Bruhtato,Snaildaddy,Schnazzy,",
		["index"] = "Neekio-1576730673",
		["dkp"] = 10,
		["date"] = 1576730673,
		["reason"] = "Molten Core: Golemagg the Incinerator",
	}, -- [488]
	{
		["players"] = "Morphintyme,Neekio,Oldmanmike,Cyskul,Ithgar,Bigbootyhoho,Athico,Eolith,Zukohere,Spellbender,Thelora,Stitchess,Urkh,Veriandra,Papasquach,Kuckuck,Maryjohanna,Chaintoker,Arkleis,Philonious,Evangelina,Ballour,Aku,Trickster,Slipperyjohn,Grymmlock,Raspütin,Dalia,Girlslayer,Kalita,Oragan,Cheeza,Bruhtato,Snaildaddy,Schnazzy,",
		["index"] = "Neekio-1576730668",
		["dkp"] = 10,
		["date"] = 1576730668,
		["reason"] = "Molten Core: Sulfuron Harbinger",
	}, -- [489]
	{
		["players"] = "Morphintyme,Neekio,Oldmanmike,Cyskul,Ithgar,Bigbootyhoho,Athico,Eolith,Zukohere,Spellbender,Thelora,Stitchess,Urkh,Veriandra,Papasquach,Kuckuck,Maryjohanna,Chaintoker,Arkleis,Philonious,Evangelina,Ballour,Aku,Trickster,Slipperyjohn,Grymmlock,Raspütin,Dalia,Girlslayer,Kalita,Oragan,Cheeza,Bruhtato,Snaildaddy,Schnazzy,",
		["index"] = "Neekio-1576730662",
		["dkp"] = 10,
		["date"] = 1576730662,
		["reason"] = "Molten Core: Shazzrah",
	}, -- [490]
	{
		["players"] = "Morphintyme,Neekio,Oldmanmike,Cyskul,Ithgar,Bigbootyhoho,Athico,Eolith,Zukohere,Spellbender,Thelora,Stitchess,Urkh,Veriandra,Papasquach,Kuckuck,Maryjohanna,Chaintoker,Arkleis,Philonious,Evangelina,Ballour,Aku,Trickster,Slipperyjohn,Grymmlock,Raspütin,Dalia,Girlslayer,Kalita,Oragan,Cheeza,Bruhtato,Snaildaddy,Schnazzy,",
		["index"] = "Neekio-1576730659",
		["dkp"] = 10,
		["date"] = 1576730659,
		["reason"] = "Molten Core: Baron Geddon",
	}, -- [491]
	{
		["players"] = "Morphintyme,Neekio,Oldmanmike,Cyskul,Ithgar,Bigbootyhoho,Athico,Eolith,Zukohere,Spellbender,Thelora,Stitchess,Urkh,Veriandra,Papasquach,Kuckuck,Maryjohanna,Chaintoker,Arkleis,Philonious,Evangelina,Ballour,Aku,Trickster,Slipperyjohn,Grymmlock,Raspütin,Dalia,Girlslayer,Kalita,Oragan,Cheeza,Bruhtato,Snaildaddy,Schnazzy,",
		["index"] = "Neekio-1576730654",
		["dkp"] = 10,
		["date"] = 1576730654,
		["reason"] = "Molten Core: Garr",
	}, -- [492]
	{
		["players"] = "Morphintyme,Neekio,Oldmanmike,Cyskul,Ithgar,Bigbootyhoho,Athico,Eolith,Zukohere,Spellbender,Thelora,Stitchess,Urkh,Veriandra,Papasquach,Kuckuck,Maryjohanna,Chaintoker,Arkleis,Philonious,Evangelina,Ballour,Aku,Trickster,Slipperyjohn,Grymmlock,Raspütin,Dalia,Girlslayer,Kalita,Oragan,Cheeza,Bruhtato,Snaildaddy,Schnazzy,",
		["index"] = "Neekio-1576730650",
		["dkp"] = 10,
		["date"] = 1576730650,
		["reason"] = "Molten Core: Gehennas",
	}, -- [493]
	{
		["players"] = "Morphintyme,Neekio,Oldmanmike,Cyskul,Ithgar,Bigbootyhoho,Athico,Eolith,Zukohere,Spellbender,Thelora,Stitchess,Urkh,Veriandra,Papasquach,Kuckuck,Maryjohanna,Chaintoker,Arkleis,Philonious,Evangelina,Ballour,Aku,Trickster,Slipperyjohn,Grymmlock,Raspütin,Dalia,Girlslayer,Kalita,Oragan,Cheeza,Bruhtato,Snaildaddy,Schnazzy,",
		["index"] = "Neekio-1576730646",
		["dkp"] = 10,
		["date"] = 1576730646,
		["reason"] = "Molten Core: Magmadar",
	}, -- [494]
	{
		["players"] = "Morphintyme,Neekio,Oldmanmike,Cyskul,Ithgar,Bigbootyhoho,Athico,Eolith,Zukohere,Spellbender,Thelora,Stitchess,Urkh,Veriandra,Papasquach,Kuckuck,Maryjohanna,Chaintoker,Arkleis,Philonious,Evangelina,Ballour,Aku,Trickster,Slipperyjohn,Grymmlock,Raspütin,Dalia,Girlslayer,Kalita,Oragan,Cheeza,Bruhtato,Snaildaddy,Schnazzy,",
		["index"] = "Neekio-1576730641",
		["dkp"] = 10,
		["date"] = 1576730641,
		["reason"] = "Molten Core: Lucifron",
	}, -- [495]
	{
		["players"] = "Wahcha,",
		["index"] = "Neekio-1576728403",
		["dkp"] = 10,
		["date"] = 1576728403,
		["reason"] = "On Time Bonus",
	}, -- [496]
	{
		["players"] = "Bugaboom,Chipgizmo,Dasmook,Drrl,Dwindle,Finryr,Fradge,Ihurricanel,Inigma,Kalijah,Lindo,Mystile,Ones,Oxford,Pamplemousse,Primera,Puffypoose,Reina,Solidsix,Sparklenips,Stikyiki,Suprarz,Tankdaddy,Thepurple,Ugro,Weapoñ,Xamina,",
		["index"] = "Neekio-1576728356",
		["dkp"] = 10,
		["date"] = 1576728356,
		["reason"] = "On Time Bonus",
	}, -- [497]
	{
		["players"] = "Aku,Arkleis,Astlan,Athico,Awwswitch,Ballour,Bigbootyhoho,Bruhtato,Bugaboom,Captnutsack,Chaintoker,Cheeza,Chipgizmo,Claireamy,Corseau,Craiger,Cyskul,Dalia,Dasmook,Drrl,Dwindle,Emmyy,Eolith,Erectdwarf,Evangelina,Finryr,Fiz,Fradge,Galagus,Girlslayer,Gnomenuts,Gregord,Grymmlock,Hazie,Holycritpal,Honeypot,Huenolairc,Ihurricanel,Inigma,Ithgar,Junglemain,Kalijah,Kalita,Killionaire,Kuckuck,Laird,Landlubbers,Lindo,Littleshiv,Lixx,Mallix,Mariku,Maryjohanna,Moldyrag,Morphintyme,Mozzarella,Mystile,Neekio,Oldmanmike,Ones,Oragan,Oxford,Pamplemousse,Papashep,Papasquach,Philonious,Primera,Puffypoose,Raspütin,Reina,Retkin,Saoirlinnis,Schnazzy,Shinynickels,Slipperyjohn,Snaildaddy,Solidsix,Solten,Sparklenips,Spellbender,Stikyiki,Stitchess,Stoleurbike,Suprarz,Tankdaddy,Thelora,Thepurple,Trickster,Ugro,Urkh,Veriandra,Weapoñ,Webroinacint,Xamina,Zukohere,",
		["index"] = "Neekio-1576652690",
		["dkp"] = "-100%",
		["date"] = 1576652690,
		["reason"] = "Weekly Decay",
	}, -- [498]
	{
		["players"] = "Xamina,",
		["index"] = "Neekio-1576652460",
		["dkp"] = 15,
		["date"] = 1576652460,
		["reason"] = "On Time Bonus",
	}, -- [499]
	{
		["players"] = "Xamina,",
		["index"] = "Neekio-1576652347",
		["dkp"] = 500,
		["date"] = 1576652347,
		["reason"] = "On Time Bonus",
	}, -- [500]
	{
		["players"] = "Xamina,",
		["index"] = "Neekio-1576652318",
		["dkp"] = 500,
		["date"] = 1576652318,
		["reason"] = "On Time Bonus",
	}, -- [501]
	{
		["players"] = "Dwindle,",
		["index"] = "Neekio-1576652313",
		["dkp"] = 500,
		["date"] = 1576652313,
		["reason"] = "On Time Bonus",
	}, -- [502]
	{
		["players"] = "Xamina,",
		["index"] = "Neekio-1576652306",
		["dkp"] = 15,
		["date"] = 1576652306,
		["reason"] = "On Time Bonus",
	}, -- [503]
	{
		["players"] = "Xamina,",
		["index"] = "Neekio-1576652230",
		["dkp"] = 15,
		["date"] = 1576652230,
		["reason"] = "On Time Bonus",
	}, -- [504]
	{
		["players"] = "Dwindle,",
		["index"] = "Neekio-1576652074",
		["dkp"] = 500,
		["date"] = 1576652074,
		["reason"] = "On Time Bonus",
	}, -- [505]
	{
		["players"] = "Dwindle,",
		["index"] = "Neekio-1576651962",
		["dkp"] = 100,
		["date"] = 1576651962,
		["reason"] = "On Time Bonus",
	}, -- [506]
	{
		["players"] = "Dwindle,",
		["index"] = "Neekio-1576651941",
		["dkp"] = 10,
		["date"] = 1576651941,
		["reason"] = "On Time Bonus",
	}, -- [507]
	{
		["players"] = "Dwindle,",
		["index"] = "Neekio-1576651846",
		["dkp"] = 10,
		["date"] = 1576651846,
		["reason"] = "On Time Bonus",
	}, -- [508]
	{
		["players"] = "Aku,Arkleis,Astlan,Athico,Awwswitch,Ballour,Bigbootyhoho,Bruhtato,Bugaboom,Captnutsack,Chaintoker,Cheeza,Chipgizmo,Claireamy,Corseau,Craiger,Cyskul,Dalia,Dasmook,Drrl,Dwindle,Emmyy,Eolith,Erectdwarf,Evangelina,Finryr,Fiz,Fradge,Galagus,Girlslayer,Gnomenuts,Grymmlock,Hazie,Holycritpal,Honeypot,Huenolairc,Ihurricanel,Inigma,Ithgar,Junglemain,Kalijah,Kalita,Killionaire,Kuckuck,Laird,Landlubbers,Lindo,Littleshiv,Lixx,Mallix,Mariku,Maryjohanna,Moldyrag,Morphintyme,Mozzarella,Mystile,Neekio,Oldmanmike,Ones,Oragan,Oxford,Pamplemousse,Papashep,Papasquach,Philonious,Primera,Puffypoose,Raspütin,Reina,Retkin,Saoirlinnis,Schnazzy,Shinynickels,Slipperyjohn,Snaildaddy,Solidsix,Solten,Sparklenips,Spellbender,Stikyiki,Stitchess,Stoleurbike,Suprarz,Tankdaddy,Thelora,Thepurple,Trickster,Ugro,Urkh,Veriandra,Weapoñ,Webroinacint,Xamina,Zukohere,",
		["index"] = "Neekio-1576649461",
		["dkp"] = "-20%",
		["date"] = 1576649461,
		["reason"] = "Weekly Decay",
	}, -- [509]
	{
		["players"] = "Xamina,Eolith,Neekio,Sparklenips,",
		["index"] = "Neekio-1576649422",
		["dkp"] = 10,
		["date"] = 1576649422,
		["reason"] = "On Time Bonus",
	}, -- [510]
	{
		["players"] = "Eolith,Neekio,",
		["index"] = "Neekio-1576648724",
		["dkp"] = 5,
		["date"] = 1576648724,
		["reason"] = "Molten Core: Lucifron",
	}, -- [511]
	{
		["players"] = "Xamina,Sparklenips,Neekio,Eolith,",
		["index"] = "Neekio-1576648414",
		["dkp"] = 10,
		["date"] = 1576648414,
		["reason"] = "Molten Core: Lucifron",
	}, -- [512]
	{
		["players"] = "Xamina,",
		["index"] = "Neekio-1576645593",
		["dkp"] = -1,
		["date"] = 1576645593,
		["reason"] = "Other - tier 2 helm",
	}, -- [513]
	{
		["players"] = "Neekio,",
		["index"] = "Neekio-1576642927",
		["dkp"] = "-50%",
		["date"] = 1576642927,
		["reason"] = "Weekly Decay",
	}, -- [514]
	{
		["players"] = "Junglemain,Morphintyme,Corseau,Drrl,Claireamy,Neekio,Emmyy,Oldmanmike,Kalijah,Cyskul,Mallix,Huenolairc,Ithgar,Saoirlinnis,Craiger,Ugro,Bigbootyhoho,Athico,Primera,Veriandra,Gnomenuts,Landlubbers,Laird,Oxford,Stitchess,Spellbender,Chipgizmo,Suprarz,Fiz,Moldyrag,Urkh,Thelora,Zukohere,Bugaboom,Eolith,Kuckuck,Ones,Maryjohanna,Solidsix,Gregord,Papasquach,Captnutsack,Chaintoker,Astlan,Arkleis,Webroinacint,Erectdwarf,Papashep,Holycritpal,Awwswitch,Philonious,Pamplemousse,Honeypot,Solten,Ballour,Xamina,Evangelina,Stoleurbike,Slipperyjohn,Puffypoose,Stikyiki,Trickster,Aku,Mozzarella,Littleshiv,Killionaire,Dwindle,Lixx,Inigma,Mariku,Lindo,Sparklenips,Ihurricanel,Grymmlock,Thepurple,Dasmook,Dalia,Sinitar,Raspütin,Finryr,Cheeza,Weapoñ,Fradge,Girlslayer,Retkin,Reina,Shinynickels,Galagus,Snaildaddy,Oragan,Kalita,Schnazzy,",
		["index"] = "Neekio-1576642671",
		["dkp"] = 10,
		["date"] = 1576642671,
		["reason"] = "Other - Test",
	}, -- [515]
	{
		["players"] = "Junglemain,Morphintyme,Corseau,Drrl,Claireamy,Neekio,Emmyy,Oldmanmike,Kalijah,Cyskul,Mallix,Huenolairc,Ithgar,Saoirlinnis,Craiger,Ugro,Bigbootyhoho,Athico,Primera,Veriandra,Gnomenuts,Landlubbers,Laird,Oxford,Stitchess,Spellbender,Chipgizmo,Suprarz,Fiz,Moldyrag,Urkh,Thelora,Zukohere,Bugaboom,Eolith,Kuckuck,Ones,Maryjohanna,Solidsix,Gregord,Papasquach,Captnutsack,Chaintoker,Astlan,Arkleis,Webroinacint,Erectdwarf,Papashep,Holycritpal,Awwswitch,Philonious,Pamplemousse,Honeypot,Solten,Ballour,Xamina,Evangelina,Stoleurbike,Slipperyjohn,Puffypoose,Stikyiki,Trickster,Aku,Mozzarella,Littleshiv,Killionaire,Dwindle,Lixx,Inigma,Mariku,Lindo,Sparklenips,Ihurricanel,Grymmlock,Thepurple,Dasmook,Dalia,Sinitar,Raspütin,Finryr,Cheeza,Weapoñ,Fradge,Girlslayer,Retkin,Reina,Shinynickels,Galagus,Snaildaddy,Oragan,Kalita,Schnazzy,",
		["index"] = "Neekio-1576641028",
		["dkp"] = -10,
		["date"] = 1576641028,
		["reason"] = "Other - Test",
	}, -- [516]
	{
		["players"] = "Junglemain,Morphintyme,Corseau,Drrl,Claireamy,Neekio,Emmyy,Oldmanmike,Kalijah,Cyskul,Mallix,Huenolairc,Ithgar,Saoirlinnis,Craiger,Ugro,Bigbootyhoho,Athico,Primera,Veriandra,Gnomenuts,Landlubbers,Laird,Oxford,Stitchess,Spellbender,Chipgizmo,Suprarz,Fiz,Moldyrag,Urkh,Thelora,Zukohere,Bugaboom,Eolith,Kuckuck,Ones,Maryjohanna,Solidsix,Gregord,Papasquach,Captnutsack,Chaintoker,Astlan,Arkleis,Webroinacint,Erectdwarf,Papashep,Holycritpal,Awwswitch,Philonious,Pamplemousse,Honeypot,Solten,Ballour,Xamina,Evangelina,Stoleurbike,Slipperyjohn,Puffypoose,Stikyiki,Trickster,Aku,Mozzarella,Littleshiv,Killionaire,Dwindle,Lixx,Inigma,Mariku,Lindo,Sparklenips,Ihurricanel,Grymmlock,Thepurple,Dasmook,Dalia,Sinitar,Raspütin,Finryr,Cheeza,Weapoñ,Fradge,Girlslayer,Retkin,Reina,Shinynickels,Galagus,Snaildaddy,Oragan,Kalita,Schnazzy,",
		["index"] = "Neekio-1576641005",
		["dkp"] = 10,
		["date"] = 1576641005,
		["deletedby"] = "Neekio-1579832384",
		["reason"] = "Other - Test",
	}, -- [517]
	{
		["players"] = "Evangelina,Solten,Honeypot,Philonious,Pamplemousse,Awwswitch,Ballour,Xamina,",
		["index"] = "Neekio-1576630708",
		["dkp"] = -32,
		["date"] = 1576630708,
		["deletedby"] = "Neekio-1579832354",
		["reason"] = "DKP Adjust",
	}, -- [518]
	{
		["players"] = "Aku,Arkleis,Astlan,Athico,Awwswitch,Ballour,Bigbootyhoho,Bugaboom,Captnutsack,Chaintoker,Cheeza,Chipgizmo,Claireamy,Corseau,Craiger,Cyskul,Dalia,Dasmook,Drrl,Dwindle,Emmyy,Eolith,Erectdwarf,Evangelina,Finryr,Fiz,Fradge,Galagus,Girlslayer,Gnomenuts,Gregord,Grymmlock,Holycritpal,Honeypot,Huenolairc,Ihurricanel,Inigma,Ithgar,Junglemain,Kalijah,Kalita,Kuckuck,Laird,Landlubbers,Lindo,Littleshiv,Lixx,Mallix,Mariku,Maryjohanna,Moldyrag,Morphintyme,Mozzarella,Neekio,Oldmanmike,Ones,Oragan,Oxford,Pamplemousse,Papashep,Papasquach,Philonious,Primera,Puffypoose,Raspütin,Reina,Retkin,Saoirlinnis,Schnazzy,Shinynickels,Sinitar,Slipperyjohn,Snaildaddy,Solidsix,Solten,Sparklenips,Spellbender,Stikyiki,Stitchess,Stoleurbike,Suprarz,Thelora,Thepurple,Trickster,Ugro,Urkh,Veriandra,Weapoñ,Webroinacint,Xamina,Zukohere,Killionaire,",
		["index"] = "Neekio-1576630697",
		["dkp"] = "-20%",
		["date"] = 1576630697,
		["reason"] = "Weekly Decay",
	}, -- [519]
	{
		["players"] = "Aku,Arkleis,Astlan,Athico,Awwswitch,Ballour,Bigbootyhoho,Bugaboom,Captnutsack,Chaintoker,Cheeza,Chipgizmo,Claireamy,Corseau,Craiger,Cyskul,Dalia,Dasmook,Drrl,Dwindle,Emmyy,Eolith,Erectdwarf,Evangelina,Finryr,Fiz,Fradge,Galagus,Girlslayer,Gnomenuts,Gregord,Grymmlock,Holycritpal,Honeypot,Huenolairc,Ihurricanel,Inigma,Ithgar,Junglemain,Kalijah,Kalita,Kuckuck,Laird,Landlubbers,Lindo,Littleshiv,Lixx,Mallix,Mariku,Maryjohanna,Moldyrag,Morphintyme,Mozzarella,Neekio,Oldmanmike,Ones,Oragan,Oxford,Pamplemousse,Papashep,Papasquach,Philonious,Primera,Puffypoose,Raspütin,Reina,Retkin,Saoirlinnis,Schnazzy,Shinynickels,Sinitar,Slipperyjohn,Snaildaddy,Solidsix,Solten,Sparklenips,Spellbender,Stikyiki,Stitchess,Stoleurbike,Suprarz,Thelora,Thepurple,Trickster,Ugro,Urkh,Veriandra,Weapoñ,Webroinacint,Xamina,Zukohere,Killionaire,",
		["index"] = "Neekio-1576630693",
		["dkp"] = "-20%",
		["date"] = 1576630693,
		["reason"] = "Weekly Decay",
	}, -- [520]
	{
		["players"] = "Evangelina,Solten,Honeypot,Philonious,Pamplemousse,Awwswitch,Ballour,Xamina,",
		["index"] = "Neekio-1576630680",
		["dkp"] = 50,
		["date"] = 1576630680,
		["deletedby"] = "Neekio-1579832335",
		["reason"] = "DKP Adjust",
	}, -- [521]
	["seed"] = 0,
}
MonDKP_MinBids = {
	{
		["item"] = "Elixir of Giants",
		["minbid"] = 2,
	}, -- [1]
	{
		["item"] = "Elixir of Fortitude",
		["minbid"] = 10,
	}, -- [2]
}
MonDKP_Whitelist = {
}
MonDKP_Standby = {
}
MonDKP_Archive = {
	["Saoirlinnis"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290160,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = true,
	},
	["Erectdwarf"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Awwswitch"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Hazie"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Craiger"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290458,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = true,
	},
	["Stoleurbike"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Solten"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Huenolairc"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Captnutsack"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Sinitar"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290160,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = true,
	},
	["Fiz"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Gregord"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Webroinacint"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Claireamy"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Laird"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Lixx"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290461,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = "Recovered",
	},
	["Papashep"] = {
		["lifetime_gained"] = 0,
		["edited"] = 1578290458,
		["dkp"] = 0,
		["lifetime_spent"] = 0,
		["deleted"] = true,
	},
}
