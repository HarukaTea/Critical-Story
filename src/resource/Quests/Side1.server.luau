--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")

local Signals = require(SSS.Modules.Data.ServerSignals)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait

wait()
repeat wait() until plr:GetAttribute("Class") == "Archer"

Signals.QuestComplete:Fire("Side", 1, plr)
