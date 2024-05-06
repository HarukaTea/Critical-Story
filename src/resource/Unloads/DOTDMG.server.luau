--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

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

local firstDMG = true
HarukaLib:Hydrate(script, {
    ["Attr-Turn"] = function(newTurn: number)
        if newTurn >= 0 then
            if firstDMG then firstDMG = false return end

            HarukaLib:Add(char, "Health", -dmg)
            ServerUtil:ShowNumber(char, dmg, color)

            if newTurn == 0 then HarukaLib:Add(script, "Turn", -1) end
        else
            light:Destroy()
            particle:Destroy()

            script:Destroy()
        end
    end
})
