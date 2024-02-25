--!nocheck

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
local floor = math.floor

ServerUtil:ShowText(char, text, color)

local nowMagic = char:GetAttribute("Magic"):: number
local theoryMagic = floor(nowMagic * power - nowMagic)
HarukaLib:Add(char, "MagicBuff", theoryMagic)

for _ = duration, 0, -0.1 do
    HarukaLib:Add(script, "Duration", -0.1)
    wait(0.1)
end

HarukaLib:Add(char, "MagicBuff", -theoryMagic)
script:Destroy()
