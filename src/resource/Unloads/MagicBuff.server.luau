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

local nowMagicBuff = char:GetAttribute("MagicBuff") :: number
local nowMagic = char:GetAttribute("Magic") - nowMagicBuff :: number

local theoryMagic = floor(nowMagic * power - nowMagic)
HarukaLib:AddAttr(char, "MagicBuff", theoryMagic)

wait(duration)

HarukaLib:AddAttr(char, "MagicBuff", -theoryMagic)

script:Destroy()
