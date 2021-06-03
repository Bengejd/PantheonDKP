local _, PDKP = ...;
local _G = _G;
local L = PDKP.L;

local LibStub = LibStub
PDKP = LibStub("AceAddon-3.0"):NewAddon("PDKP", "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")
PDKP.PDKP.ldb = LibStub:GetLibrary("LibDataBroker-1.1")
PDKP.PDKP.cbh = LibStub("CallbackHandler-1.0"):New(PDKP)
PDKP.LibDeflate = LibStub:GetLibrary("LibDeflate")

_G.PDKP = PDKP

PDKP.GUI, PDKP.DKP, PDKP.Settings, PDKP.Guild, PDKP.Util, PDKP.Character, PDKP.Raid, PDKP.Defaults, PDKP.Member,
PDKP.Setup, PDKP.Loot, PDKP.Shroud, PDKP.Comms, PDKP.ScrollTable, PDKP.DKP_Entry, PDKP.HistoryTable,
PDKP.SimpleScrollFrame, PDKP.Minimap, PDKP.Export, PDKP.Import = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {};
