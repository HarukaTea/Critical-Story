--!strict

local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")

local Signals = require(SSS.Modules.Data.ServerSignals)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait

wait()
local inventory = plr:WaitForChild("Inventory", 999) :: Folder

local function completed()
    Signals.QuestComplete:Fire("Town", 1, plr, true)
end

if inventory:FindFirstChild("SpikyFur") then
    if inventory.SpikyFur.Value >= 6 then
        completed()

    else
        repeat wait() until inventory.SpikyFur.Value >= 6

        completed()
    end

else
    repeat wait(2) until inventory:FindFirstChild("SpikyFur")
    repeat wait() until inventory.SpikyFur.Value >= 6

    completed()
end
