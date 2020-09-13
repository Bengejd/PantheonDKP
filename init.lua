--[[
-- This is the first file initialized in the addon, it's really just a global setter, if anything.
-- It can be mostly left empty
 ]]

local _, core = ...;
local _G = _G;
local L = core.L;

core.PDKP = {}; -- global addon object
core.characterDB = {}; -- global characterDB
--core.guildDB = {}; -- global guildDB
--core.dkpDB = {};

core.DKP = {}; -- global dkp object.
core.Guild = {}; -- global guild object.

core.Util = {}; -- global utility object.
core.Shroud = {};
core.Item = {};
core.Invites = {};
core.Raid = {};
core.Comms = {};
core.defaults = {};
core.Defaults = {};
core.Import = {};
core.Setup = {}; -- Creates the UI for us.
core.Officer = {};
core.Minimap = {};
core.Member = {}; -- Member class object.
core.JSON = {};

core.PDKP = LibStub("AceAddon-3.0"):NewAddon("PDKP", "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0"); -- set the plugin up.
core.LibDeflate = LibStub:GetLibrary("LibDeflate")

