--!nocheck
--!optimize 2
--!native

local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")

local Events = require(RepS.Modules.Data.Events)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model
local camera = workspace.CurrentCamera
local musics = workspace:WaitForChild("Sounds") :: Folder
local effects = RepS.Package.Effects :: Folder
local mapComponents = workspace:WaitForChild("MapComponents") :: Folder

local fromRGB = Color3.fromRGB

--// Setups
local function setup()
	musics.Overworld:Play()

	for _, effect: Instance in camera:GetChildren() do
		if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") then effect:Destroy() end
	end
	for _, prompt: Instance in mapComponents:GetDescendants() do
		if prompt:IsA("ProximityPrompt") and prompt.Name ~= "Chest" then prompt.Enabled = true end
	end

	effects.UIBlur:Clone().Parent = camera

	Lighting.ColorShift_Top = fromRGB(220, 255, 255)
	Lighting.ColorShift_Bottom = fromRGB(220, 255, 255)
end
Spawn(setup)

--// Connections
local function onDied()
	--- sometimes the reset button did not make server thinks he is dead
	Events.ForceReset:Fire()

	musics.SFXs.Dead:Play()

	for _, prompt: Instance in mapComponents:GetDescendants() do
		if prompt:IsA("ProximityPrompt") and prompt.Name ~= "Chest" then prompt.Enabled = false end
	end
	for _, sound: Sound in musics:GetChildren() do
		if sound:IsA("Sound") then sound:Stop() end
	end

	effects.DeathBlur:Clone().Parent = camera

	Lighting.ColorShift_Bottom = fromRGB(255, 0, 0)
	Lighting.ColorShift_Top = fromRGB(255, 0, 0)

	script:Destroy()
end
char.Humanoid.Died:Once(onDied)
