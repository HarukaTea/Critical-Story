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

local wait = task.wait
local instanceNew = Instance.new
local csNew = ColorSequence.new

local function dealDMG()
    local last = 0

    for i = duration, 0, -0.1 do
        HarukaLib:Add(script, "Duration", -0.1)
        last += 0.1

        if last >= 1 then
            last = 0

            HarukaLib:Add(char, "Health", -dmg)
            ServerUtil:ShowNumber(char, dmg, color)
        end

        wait(0.1)
    end
end

ServerUtil:ShowText(char, text, color)

if char:HasTag("Monster") then
    local light = instanceNew("PointLight")
    light.Color = color
    light.Range = 10
    light.Parent = char.PrimaryPart
    local particle = RepS.Package.Effects.BurnEffect:Clone() :: ParticleEmitter
    particle.Color = csNew(color)
    particle.Parent = char.PrimaryPart

    dealDMG()

    light:Destroy()
    particle:Destroy()
    script:Destroy()
end
