local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local DKP = {}

local DKP_DB, GUILD_DB;

function DKP:Initialize()
    DKP_DB = MODULES.Database:DKP()
end

function DKP:AddNewEntryToDB(entry)
    DKP_DB[entry.id] = entry.sd
    for _, member in pairs(entry.members) do
        member:_UpdateDKP(entry.sd.dkp_change)
        member:Save()
    end

    PDKP.memberTable:DataChanged()
    PDKP.memberTable:ClearAll()
end

MODULES.DKPManager = DKP