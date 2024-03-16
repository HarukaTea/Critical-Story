--!strict

local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")

local Signals = require(SSS.Modules.Data.ServerSignals)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait

wait()
local function completed()
    Signals.QuestComplete:Fire("Main", 7, plr, true)
end

if plr:GetAttribute("Levels") >= 10 then
    completed()
else
    repeat wait() until plr:GetAttribute("Levels") >= 10

    completed()
end
