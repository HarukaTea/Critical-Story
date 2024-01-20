--!nocheck

local data = script.Parent.Data
local packages = script.Parent.Packages

return {
	Fusion = require(packages.dhpfox_fusion.fusion),

	AssetBook = require(data.AssetBook),
	Events = require(data.Events),
	Signals = require(data.Signals),

	Bin = require(packages["red-blox_bin"].bin),
	Clock = require(packages["red-blox_clock"].clock),
	Collection = require(packages["red-blox_collection"].collection),
	FastSpawn = require(packages["red-blox_spawn"].spawn),
	HarukaLib = require(packages["haruka-tea_harukalib"].harukalib)
}
