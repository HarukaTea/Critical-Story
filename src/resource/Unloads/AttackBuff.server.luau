--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Formula = require(RepS.Modules.Data.Formulas)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local color = script:GetAttribute("Color") :: Color3
local text = script:GetAttribute("Text") :: string
local duration = script:GetAttribute("Duration") :: number
local power = script:GetAttribute("Power") :: number

local floor = math.floor
local wait = task.wait

ServerUtil:ShowText(char, text, color)

local DMGPoints = plr:GetAttribute("DMGPoints") :: number
local nowMinDMG, nowMaxDMG = Formula.PlayerDMGMin(DMGPoints), Formula.PlayerDMGMax(DMGPoints)
local theoryMinDMG, theoryMaxDMG = floor(nowMinDMG * power - nowMinDMG), floor(nowMaxDMG * power - nowMaxDMG)

HarukaLib:AddAttr(char, "MinDMGBuff", theoryMinDMG)
HarukaLib:AddAttr(char, "MaxDMGBuff", theoryMaxDMG)

wait(duration)

HarukaLib:AddAttr(char, "MinDMGBuff", -theoryMinDMG)
HarukaLib:AddAttr(char, "MaxDMGBuff", -theoryMaxDMG)

script:Destroy()
