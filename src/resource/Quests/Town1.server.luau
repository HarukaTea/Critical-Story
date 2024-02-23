--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local Signals = require(SSS.Modules.Data.ServerSignals)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait

RepS.Resources.Quests.Town1Client:Clone().Parent = script.Parent

wait()
local inventory = plr:WaitForChild("Inventory", 999) :: Folder
repeat wait(5) until inventory:FindFirstChild("SpikyFur") and inventory.SpikyFur.Value >= 6

inventory.SpikyFur.Value -= 6

Events.RefreshBackpack:Fire(plr)
Signals.QuestComplete:Fire("Town", 1, plr, true)
