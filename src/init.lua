local _G = _G
local AddonName, core = ...

local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')

local PDKP = AceAddon:NewAddon(AddonName, "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")

core.PDKP = PDKP
_G.PDKP = PDKP

PDKP.Media = {}
PDKP.GUI = {}
PDKP.DKP = {}
PDKP.Settings = {}
PDKP.Guild = {}
PDKP.Util = {}
PDKP.Character = {}
PDKP.Raid = {}
PDKP.Defaults = {}
PDKP.Member = {}
PDKP.Setup = {}
PDKP.Loot = {}
PDKP.Shroud = {}
PDKP.Comms = {}
PDKP.ScrollTable = {}
PDKP.DKP_Entry = {}
PDKP.HistoryTable = {}
PDKP.SimpleScrollFrame = {}
PDKP.Minimap = {}
PDKP.Export = {}
PDKP.Import = {}
PDKP.Events = {}

PDKP.ldb = _G.LibStub:GetLibrary("LibDataBroker-1.1")
PDKP.cbh = _G.LibStub("CallbackHandler-1.0"):New(PDKP)
PDKP.LibDeflate = _G.LibStub:GetLibrary("LibDeflate")

local PDKP_Instances = {
    ['PDKP']=PDKP,
    ['Media']=PDKP.Media,
    ['GUI']=PDKP.GUI,
    ['DKP']=PDKP.DKP,
    ['Settings']=PDKP.Settings,
    ['Guild']=PDKP.Guild,
    ['Util']=PDKP.Util,
    ['Character']=PDKP.Character,
    ['Raid']=PDKP.Raid,
    ['Member']=PDKP.Member,
    ['Setup']=PDKP.Setup,
    ['Loot']=PDKP.Loot,
    ['Shroud']=PDKP.Shroud,
    ['Comms']=PDKP.Comms,
    ['ScrollTable']=PDKP.ScrollTable,
    ['DKP_Entry']=PDKP.DKP_Entry,
    ['HistoryTable']=PDKP.HistoryTable,
    ['SimpleScrollFrame']=PDKP.SimpleScrollFrame,
    ['Minimap']=PDKP.Minimap,
    ['Import']=PDKP.Import,
    ['Events']=PDKP.Events,
}

function PDKP:GetInst(...)
    local reqInstances = {}
    for _, val in pairs({...}) do
        local inst = PDKP_Instances[val]
        if inst == nil then inst = nil end
        table.insert(reqInstances, inst)
    end
    return unpack(reqInstances)
end