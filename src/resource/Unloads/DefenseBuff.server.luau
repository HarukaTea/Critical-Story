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

local wait = task.wait

ServerUtil:ShowText(char, text, color)

HarukaLib:Add(char, "Defense", power)

wait(duration)

HarukaLib:Add(char, "Defense", -power)

script:Destroy()
