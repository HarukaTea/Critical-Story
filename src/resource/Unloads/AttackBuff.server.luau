--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local color = script:GetAttribute("Color") :: Color3
local text = script:GetAttribute("Text") :: string
local power = script:GetAttribute("Power") :: number

local floor = math.floor

ServerUtil:ShowText(char, text, color)

local nowMinDMG, nowMaxDMG = char:GetAttribute("MinDMG"):: number, char:GetAttribute("MaxDMG") :: number
local theoryMinDMG, theoryMaxDMG = floor(nowMinDMG * power - nowMinDMG), floor(nowMaxDMG * power - nowMaxDMG)
HarukaLib:Add(char, "MinDMGBuff", theoryMinDMG)
HarukaLib:Add(char, "MaxDMGBuff", theoryMaxDMG)

Fusion.Hydrate(script)({
    [Fusion.AttributeChange("Turn")] = function(newTurn: number)
        if newTurn <= 0 then
            HarukaLib:Add(char, "MinDMGBuff", -theoryMinDMG)
            HarukaLib:Add(char, "MaxDMGBuff", -theoryMaxDMG)
            script:Destroy()
        end
    end
})
