--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local data = SSS.Modules.Data
local packages = RepS.Modules.Packages
local utils = SSS.Modules.Utils

return {
	Cmdr = require(packages.evaera_cmdr.cmdr),
	Fusion = require(packages.dhpfox_fusion.fusion),
	LootPlan = require(packages.colbert2677_lootplan.lootplan),
	SuphiDataStore = require(packages["5uphi_suphidatastore"].suphidatastore),

	AttackUtil = require(utils.AttackUtil),
	CSAttackUtil = require(utils.CSAttackUtil),
	PassiveUtil = require(utils.PassiveUtil),
	ServerUtil = require(utils.ServerUtil),
	SkillUtil = require(utils.SkillUtil),

	Events = require(data.ServerEvents),
	Signals = require(data.ServerSignals),

	Clock = require(packages["red-blox_clock"].clock),
	FastSpawn = require(packages["red-blox_spawn"].spawn),
	Guard = require(packages["red-blox_guard"].guard),
	HarukaLib = require(packages["haruka-tea_harukalib"].harukalib)
}
