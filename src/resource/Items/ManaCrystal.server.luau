--!strict
--!optimize 2
--!native

local HarukaLib = require(game:GetService("ReplicatedStorage").Modules.Packages.HarukaLib)

local char = script.Parent.Parent.Parent :: Model

local wait = task.wait
local floor = math.floor

while wait(1) do
	local currentMana = char:GetAttribute("Mana") :: number
	local maxMana = char:GetAttribute("MaxMana") :: number

	if currentMana < maxMana then
        HarukaLib:Add(char, "Mana", floor(maxMana * 0.05))
    end
end
