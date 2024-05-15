--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local char = script.Parent.Parent.Parent :: Model

if char.PrimaryPart:FindFirstChildOfClass("PointLight") then char.PrimaryPart:FindFirstChildOfClass("PointLight"):Destroy() end

local light = RepS.Package.Effects.Light:Clone() :: PointLight
light.Enabled = true
light.Parent = char.PrimaryPart
