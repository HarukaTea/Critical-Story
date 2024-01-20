--!nocheck

local HarukaFrameworkServer = require(game:GetService("ServerScriptService").Modules.HarukaFrameworkServer)

local HarukaLib = HarukaFrameworkServer.HarukaLib
local ServerUtil = HarukaFrameworkServer.ServerUtil

local char = script.Parent.Parent.Parent
local color = script:GetAttribute("Color")
local duration = script:GetAttribute("Duration")
local text = script:GetAttribute("Text")
local power = script:GetAttribute("Power")

local wait = task.wait
local floor = math.floor

ServerUtil:ShowText(char, text, color)

local nowDMG = char:GetAttribute("Damage")
local theoryDMG = floor(nowDMG * power - nowDMG)
HarukaLib:Add(char, "DamageBuff", theoryDMG)

for i = duration, 0, -0.1 do
    HarukaLib:Add(script, "Duration", -0.1)
    wait(0.1)
end

HarukaLib:Add(char, "DamageBuff", -theoryDMG)
script:Destroy()
