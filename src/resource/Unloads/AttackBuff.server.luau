--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local color = script:GetAttribute("Color") :: Color3
local text = script:GetAttribute("Text") :: string
local duration = script:GetAttribute("Duration") :: number
local power = script:GetAttribute("Power") :: number

local floor = math.floor
local wait = task.wait

ServerUtil:ShowText(char, text, color)

local nowMinDMG, nowMaxDMG = char:GetAttribute("MinDMG"):: number, char:GetAttribute("MaxDMG") :: number
local theoryMinDMG, theoryMaxDMG = floor(nowMinDMG * power - nowMinDMG), floor(nowMaxDMG * power - nowMaxDMG)
HarukaLib:Add(char, "MinDMGBuff", theoryMinDMG)
HarukaLib:Add(char, "MaxDMGBuff", theoryMaxDMG)

wait(duration)

HarukaLib:Add(char, "MinDMGBuff", -theoryMinDMG)
HarukaLib:Add(char, "MaxDMGBuff", -theoryMaxDMG)

script:Destroy()
