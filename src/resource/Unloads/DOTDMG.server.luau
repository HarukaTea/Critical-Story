--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent :: Model
local color = script:GetAttribute("Color") :: Color3
local dmg = script:GetAttribute("Damage") :: number
local duration = script:GetAttribute("Duration") :: number
local text = script:GetAttribute("Text") :: string
local level = script:GetAttribute("Power") :: number

local instanceNew = Instance.new
local csNew = ColorSequence.new
local wait = task.wait

ServerUtil:ShowText(char, text, color)

local function setup()
    local light = instanceNew("PointLight")
    light.Color = color
    light.Range = 10
    light:AddTag("ProjectileEmitter")
    light.Parent = char.PrimaryPart

    local particle = RepS.Package.Effects.BurnEffect:Clone() :: ParticleEmitter
    particle.Color = csNew(color)
    particle:AddTag("ProjectileEmitter")
    particle.Parent = char.PrimaryPart

    for _ = duration, 0, -0.05 * HarukaLib:CalculateTick(level) do
        HarukaLib:AddAttr(char, "Health", -dmg)

        ServerUtil:ShowNumber(char, dmg, color)
        wait(0.05 * HarukaLib:CalculateTick(level))
    end

    light:Destroy()
    particle:Destroy()

    script:Destroy()
end
setup()
