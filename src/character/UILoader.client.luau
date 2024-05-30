--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Spawn = require(RepS.Modules.Packages.Spawn)

local plr = Players.LocalPlayer

--- Reload UI modules when character respawned
local UIModules = RepS.Modules.UI
local requireList = {
	UIModules.AdventurerStats,
	UIModules.AdventurerMenu,
	UIModules.Backpack,
	UIModules.ShiftLock,
	UIModules.PlayerList,
	UIModules.Shop,
	UIModules.NPCChat,
	UIModules.Hints
}

local function setup()
	for _, module: ModuleScript in requireList do
		Spawn(function() require(module)(plr) end)
	end
end
setup()
