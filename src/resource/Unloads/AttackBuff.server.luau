--!nocheck

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

local nowMinDMGBuff, nowMaxDMGBuff = char:GetAttribute("MinDMGBuff") :: number, char:GetAttribute("MaxDMGBuff") :: number
local nowMinDMG, nowMaxDMG = char:GetAttribute("MinDMG") - nowMinDMGBuff :: number, char:GetAttribute("MaxDMG") - nowMaxDMGBuff :: number
local theoryMinDMG, theoryMaxDMG = floor(nowMinDMG * power - nowMinDMG), floor(nowMaxDMG * power - nowMaxDMG)

HarukaLib:AddAttr(char, "MinDMGBuff", theoryMinDMG)
HarukaLib:AddAttr(char, "MaxDMGBuff", theoryMaxDMG)

wait(duration)

HarukaLib:AddAttr(char, "MinDMGBuff", -theoryMinDMG)
HarukaLib:AddAttr(char, "MaxDMGBuff", -theoryMaxDMG)

script:Destroy()
