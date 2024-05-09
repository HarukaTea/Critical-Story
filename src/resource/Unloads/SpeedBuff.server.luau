--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local color = script:GetAttribute("Color") :: Color3
local duration = script:GetAttribute("Duration") :: number
local text = script:GetAttribute("Text") :: string
local power = script:GetAttribute("Power") :: number

local wait = task.wait

ServerUtil:ShowText(char, text, color)

local afterSpeed = char.Humanoid.WalkSpeed * power - char.Humanoid.WalkSpeed
HarukaLib:Add(char, "SpeedBuff", afterSpeed)

wait(duration)

HarukaLib:Add(char, "SpeedBuff", -afterSpeed)
script:Destroy()
