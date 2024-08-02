--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent :: Model
local color = script:GetAttribute("Color") :: Color3
local text = script:GetAttribute("Text") :: string
local duration = script:GetAttribute("Duration") :: number
local power = script:GetAttribute("Power") :: number

local floor = math.floor
local wait = task.wait

ServerUtil:ShowText(char, text, color)

local nowDMG = char:GetAttribute("Damage") :: number
local theoryDMG = floor(nowDMG * power - nowDMG)

HarukaLib:AddAttr(char, "Damage", theoryDMG)

wait(duration)

HarukaLib:AddAttr(char, "Damage", -theoryDMG)

script:Destroy()
