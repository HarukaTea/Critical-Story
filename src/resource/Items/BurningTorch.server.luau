--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local char = script.Parent.Parent.Parent :: Model

if not char.PrimaryPart:FindFirstChildOfClass("PointLight") then
    local light = RepS.Package.Effects.Light:Clone() :: PointLight
    light.Enabled = true
    light.Parent = char.PrimaryPart
end
