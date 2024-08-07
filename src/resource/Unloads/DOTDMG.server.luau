--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model
if script:GetAttribute("IsPlayer") then char = script.Parent.Parent.Parent :: Model end

local color = script:GetAttribute("Color") :: Color3
local dmg = script:GetAttribute("Damage") :: number
local text = script:GetAttribute("Text") :: string
local power = script:GetAttribute("Power") :: number

local instanceNew = Instance.new
local csNew = ColorSequence.new
local wait = task.wait

Debris:AddItem(script, 15)

ServerUtil:ShowText(char, text, color)

local light = instanceNew("PointLight")
light.Color = color
light.Range = 10
light:AddTag("ProjectileEmitter")
light.Parent = char.PrimaryPart

local particle = RepS.Package.Effects.BurnEffect:Clone() :: ParticleEmitter
particle.Color = csNew(color)
particle:AddTag("ProjectileEmitter")
particle.Parent = char.PrimaryPart

Add(light)
Add(particle)
Debris:AddItem(light)
Debris:AddItem(particle)

local times = 6 / 0.75
local trueDMG = math.ceil(dmg * power) :: number

for _ = times, 0, -1 do
    if script:GetAttribute("IsPlayer") then
        char.Humanoid.Health -= trueDMG
    else
        HarukaLib:AddAttr(char, "Health", -trueDMG)
    end

    ServerUtil:ShowNumber(char, trueDMG, color)
    wait(0.75)
end

Empty()

script:Destroy()
