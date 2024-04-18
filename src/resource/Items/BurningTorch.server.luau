--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local char = script.Parent.Parent.Parent :: Model

local light = RepS.Package.Effects.Light:Clone() :: PointLight
light.Enabled = if char:GetAttribute("CanLight") then true else false
light.Parent = char.PrimaryPart

local function onDestroyed()
    light:Destroy()
end
script.Destroying:Connect(onDestroyed)
