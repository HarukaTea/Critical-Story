--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent :: Model
local color = script:GetAttribute("Color") :: Color3
local dmg = script:GetAttribute("Damage") :: number
local text = script:GetAttribute("Text") :: string

local instanceNew = Instance.new
local csNew = ColorSequence.new

ServerUtil:ShowText(char, text, color)

local light = instanceNew("PointLight")
light.Color = color
light.Range = 10
light.Parent = char.PrimaryPart

local particle = RepS.Package.Effects.BurnEffect:Clone() :: ParticleEmitter
particle.Color = csNew(color)
particle.Parent = char.PrimaryPart

Fusion.Hydrate(script)({
    [Fusion.AttributeChange("Turn")] = function(newTurn: number)
        if newTurn <= 0 then
            light:Destroy()
            particle:Destroy()

            script:Destroy()
        else
            HarukaLib:Add(char, "Health", -dmg)
            ServerUtil:ShowNumber(char, dmg, color)
        end
    end
})
