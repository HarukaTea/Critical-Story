--!nocheck

local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Events = require(RepS.Modules.Data.Events)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model
local camera = workspace.CurrentCamera
local musics = workspace:WaitForChild("Sounds", 999) :: Folder
local effects = RepS.Package.Effects :: Folder

local fromRGB = Color3.fromRGB

--// Setups
local function setup()
	for _, effect: Instance in camera:GetChildren() do
		if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") then effect:Destroy() end
	end

	ClientUtil:SetAllPromptsState(true)

	effects.UIBlur:Clone().Parent = camera

	Lighting.ColorShift_Top = fromRGB(220, 255, 255)
	Lighting.ColorShift_Bottom = fromRGB(220, 255, 255)
end
Spawn(setup)

--// Connections
local function onDied()
	---// sometimes the reset button did not make server thinks player is dead
	Events.ForceReset.Fire({})

	ClientUtil:SetAllPromptsState(false)

	for _, sound: Sound in musics:GetDescendants() do
		if sound:IsA("Sound") then sound:Stop() end
	end

	effects.DeathBlur:Clone().Parent = camera

	Lighting.ColorShift_Bottom = fromRGB(255, 0, 0)
	Lighting.ColorShift_Top = fromRGB(255, 0, 0)
end
char.Humanoid.Died:Once(onDied)
