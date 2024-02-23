--!nocheck

local Players = game:GetService("Players")
local TestS = game:GetService("TestService")

local plr = Players.LocalPlayer
local prompt = workspace:WaitForChild("MapComponents").NPCs.FChenP.PrimaryPart.Chat :: ProximityPrompt

local wait = task.wait

local oriParent = prompt.Parent
prompt.Parent = TestS

local inventory = plr:WaitForChild("Inventory", 999) :: Folder
repeat wait(5) until inventory:FindFirstChild("SpikyFur") and inventory.SpikyFur.Value >= 6

prompt.Parent = oriParent
