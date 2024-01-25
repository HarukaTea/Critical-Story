--!nocheck

local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")

local camera = workspace.CurrentCamera
local musics = workspace:WaitForChild("Sounds")
local effects = RepS.Package.Effects
local mapComponents = workspace:WaitForChild("MapComponents")

local CharacterSetups = {}
CharacterSetups.__index = CharacterSetups

local fromRGB = Color3.fromRGB

--[[
    Actions when character spawns, note that it's client-side
]]
function CharacterSetups:Spawn()
	musics.Overworld:Play()

	for _, effect in camera:GetChildren() do
		if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") then effect:Destroy() end
	end
	for _, prompt in mapComponents:GetDescendants() do
		if prompt:IsA("ProximityPrompt") and prompt.Name ~= "Chest" then prompt.Enabled = true end
	end

	effects.UIBlur:Clone().Parent = camera
	effects.WaterColor:Clone().Parent = camera
	effects.WaterBlur:Clone().Parent = camera

	Lighting.ColorShift_Top = fromRGB(220, 255, 255)
	Lighting.ColorShift_Bottom = fromRGB(220, 255, 255)
end

--[[
    Actions when character was dead, note that it's client-side
]]
function CharacterSetups:Clear()
	musics.SFXs.Dead:Play()

    for _, prompt in mapComponents:GetDescendants() do
		if prompt:IsA("ProximityPrompt") and prompt.Name ~= "Chest" then prompt.Enabled = false end
	end
	for _, sound in musics:GetChildren() do
		if sound:IsA("Sound") then sound:Stop() end
	end

	effects.DeathBlur:Clone().Parent = camera

	Lighting.ColorShift_Bottom = fromRGB(255, 0, 0)
	Lighting.ColorShift_Top = fromRGB(255, 0, 0)
end

return function (plr: Player)
    local self = setmetatable({}, CharacterSetups)

	local char = plr.Character or plr.CharacterAdded:Wait()

    --// Setup
    self:Spawn()

	--// Connections
	local function _onDied()
		self:Clear()
	end
    char.Humanoid.Died:Once(_onDied)
end
