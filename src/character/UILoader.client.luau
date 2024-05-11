--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Spawn = require(RepS.Modules.Packages.Spawn)

local plr = Players.LocalPlayer
local char = script.Parent :: Model

local wait = task.wait

--- Reload UI modules when character respawned
local UIModules = RepS.Modules.UI
local requireList = {
	UIModules.AdventurerStats,
	UIModules.AdventurerMenu,
	UIModules.Backpack,
	UIModules.ShiftLock,
	UIModules.PlayerList,
	UIModules.Hints,
	UIModules.PostStroke,
	UIModules.SwitchScene
}
for _, module in requireList do
	Spawn(function()
		require(module)(plr)
	end)
end

local function onDead()
	wait(2)
	script:Destroy()
end
char.Humanoid.Died:Connect(onDead)
