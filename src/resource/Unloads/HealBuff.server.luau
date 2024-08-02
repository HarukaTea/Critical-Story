--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local char = script.Parent.Parent.Parent :: Model
local healDMG = script:GetAttribute("HealDMG") :: number
local level = script:GetAttribute("Power") :: number
local duration = script:GetAttribute("Duration") :: number

local wait = task.wait

local TICK = 0.05

for _ = duration, 0, -TICK * HarukaLib:CalculateTick(level) do
    char.Humanoid.Health += healDMG

    local healEff = RepS.Package.Effects.HealEffect:Clone() :: BasePart
    healEff.CFrame = char.PrimaryPart.CFrame
    healEff.Parent = workspace
    Debris:AddItem(healEff, 1)

    wait(TICK * HarukaLib:CalculateTick(level))
end

script:Destroy()
