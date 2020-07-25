--[[
-- This is the first file initialized in the addon, it's really just a global setter, if anything.
-- It can be mostly left empty
 ]]

local _, core = ...;
local _G = _G;
local L = core.L;

core.PDKP = {}; -- global addon object
core.Settings = {};
core.Guild = {};
core.Util = {};
core.Character = {};
core.Raid = {};
core.Defaults = {};
core.Member = {};
core.Setup = {};

core.PDKP = LibStub("AceAddon-3.0"):NewAddon("PDKP", "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0");
core.PDKP.ldb = LibStub:GetLibrary("LibDataBroker-1.1")

