--!strict
--!optimize 2
--!native

local AssetBook = require(game:GetService("ReplicatedStorage").Modules.Data.AssetBook)

local model = script.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(model.Parent.Parent)

local color = AssetBook.ClassInfo[plr:GetAttribute("Class")].Color

local wait = task.wait
local csNew, nsNew = ColorSequence.new, NumberSequence.new
local color3New = Color3.new

--- Update color
for _, child in model:GetChildren() do
	if child:IsA("BasePart") then
		child.Beam.Color = csNew(color, color3New())
	end
end

--- Update transparency
for i = 1, 0.1, -0.1 do
	for _, child in model:GetChildren() do
		if child:IsA("BasePart") then
			child.Beam.Transparency = nsNew(i, 1)
		end
	end

	wait(0.01)
end
