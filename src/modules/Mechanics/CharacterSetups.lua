--!nocheck

local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")

local CharacterSetups = {}
CharacterSetups.__index = CharacterSetups

local fromRGB = Color3.fromRGB

--[[
    Actions when character spawns, note that it's client-side
]]
function CharacterSetups:Spawn()
    local camera = self.camera

	self.musics.Overworld:Play()

	for _, effect in camera:GetChildren() do
		if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") then effect:Destroy() end
	end
	for _, prompt in self.mapComponents:GetDescendants() do
		if prompt:IsA("ProximityPrompt") and prompt.Name ~= "Chest" then prompt.Enabled = true end
	end

	self.effects.UIBlur:Clone().Parent = camera
	Lighting.ColorShift_Top = fromRGB(220, 255, 255)
	Lighting.ColorShift_Bottom = fromRGB(220, 255, 255)
end

--[[
    Actions when character was dead, note that it's client-side
]]
function CharacterSetups:Clear()
	self.musics.SFXs.Dead:Play()

    for _, prompt in self.mapComponents:GetDescendants() do
		if prompt:IsA("ProximityPrompt") and prompt.Name ~= "Chest" then prompt.Enabled = false end
	end
	for _, sound in self.musics:GetChildren() do
		if sound:IsA("Sound") then sound:Stop() end
	end

	self.effects.DeathBlur:Clone().Parent = self.camera
	Lighting.ColorShift_Bottom = fromRGB(255, 0, 0)
	Lighting.ColorShift_Top = fromRGB(255, 0, 0)
end

return function (plr: Player)
    local self = setmetatable({}, CharacterSetups)

    self.char = plr.Character or plr.CharacterAdded:Wait()

    self.camera = workspace.CurrentCamera
	self.musics = workspace:WaitForChild("Sounds")
	self.effects = RepS.Package.Effects
	self.mapComponents = workspace:WaitForChild("MapComponents")

    --// Setup
    self:Spawn()

	--// Connections
	local function _onDied()
		self:Clear()
	end
    self.char:WaitForChild("Humanoid").Died:Once(_onDied)
end
