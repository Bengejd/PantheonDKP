local _G = _G
local AddonName, core = ...

local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')

local PDKP = AceAddon:NewAddon(AddonName, "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")

core.PDKP = PDKP

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
PDKP.Dev = {}

PDKP.ldb = _G.LibStub:GetLibrary("LibDataBroker-1.1")
PDKP.cbh = _G.LibStub("CallbackHandler-1.0"):New(PDKP)
PDKP.LibDeflate = _G.LibStub:GetLibrary("LibDeflate")

local PDKP_Instances = {
    ['Media']=PDKP.Media,
    ['GUI']=PDKP.GUI,
    ['DKP']=PDKP.DKP,
    ['Settings']=PDKP.Settings,
    ['Guild']=PDKP.Guild,
    ['Util']=PDKP.Util,
    ['Character']=PDKP.Character,
    ['Raid']=PDKP.Raid,
    ['Defaults']=PDKP.Defaults,
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
    ['Export']=PDKP.Export,
    ['Import']=PDKP.Import,
    ['Events']=PDKP.Events,
    ['Dev']=PDKP.Dev
}

local waitTable = {};
local waitFrame = nil;

local unpack, pairs = unpack, pairs

_G.PDKP = core.PDKP

function PDKP_wait(delay, func, ...)
    if(type(delay)~="number" or type(func)~="function") then
        return false;
    end
    if(waitFrame == nil) then
        waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
        waitFrame:SetScript("onUpdate",function (self,elapse)
            local count = #waitTable;
            local i = 1;
            while(i<=count) do
                local waitRecord = tremove(waitTable,i);
                local d = tremove(waitRecord,1);
                local f = tremove(waitRecord,1);
                local p = tremove(waitRecord,1);
                if(d>elapse) then
                    tinsert(waitTable,i,{d-elapse,f,p});
                    i = i + 1;
                else
                    count = count - 1;
                    f(unpack(p));
                end
            end
        end);
    end
    tinsert(waitTable,{delay,func,{...}});
    return true;
end

function PDKP:GetInst(...)
    local reqInstances = {}
    for key, val in pairs({...}) do reqInstances[key] = PDKP_Instances[val] end
    return unpack(reqInstances)
end