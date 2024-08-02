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
    HarukaLib:AddAttr(char, "Mana", healDMG)

    local restoreEff = RepS.Package.Effects.RestoreEffect:Clone() :: ParticleEmitter
	restoreEff.Parent = workspace
	Debris:AddItem(restoreEff, 1)

    wait(TICK * HarukaLib:CalculateTick(level))
end

script:Destroy()
