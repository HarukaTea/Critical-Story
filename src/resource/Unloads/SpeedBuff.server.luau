--!nocheck

local Debris = game:GetService("Debris")
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

local speedEffect = RepS.Package.Effects.SpeedEffect:Clone() :: ParticleEmitter
speedEffect.Parent = char.PrimaryPart
Debris:AddItem(speedEffect, duration)

local afterSpeed = 30 * power - 30
HarukaLib:AddAttr(char, "SpeedBuff", afterSpeed)

wait(duration)

HarukaLib:AddAttr(char, "SpeedBuff", -afterSpeed)
script:Destroy()
