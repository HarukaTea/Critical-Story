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

local magicPoints = plr:GetAttribute("MagicPoints") :: number
local nowMagic = Formula.PlayerMagic(magicPoints)
local theoryMagic = floor(nowMagic * power - nowMagic)

HarukaLib:AddAttr(char, "MagicBuff", theoryMagic)

wait(duration)

HarukaLib:AddAttr(char, "MagicBuff", -theoryMagic)

script:Destroy()
