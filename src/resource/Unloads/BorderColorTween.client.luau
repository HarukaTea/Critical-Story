--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local SuperTween = require(RepS.Modules.Packages.SuperTween)

local model = script.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(model.Parent.Parent)

local color = AssetBook.ClassInfo[plr:GetAttribute("Class")].Color

local csNew, nsNew = ColorSequence.new, NumberSequence.new
local color3New = Color3.new

--- Update color
for _, child in model:GetChildren() do
	if child:IsA("BasePart") then
		child.Beam.Color = csNew(color, color3New())
		child.Beam.Transparency = nsNew(1, 1)
	end
end

--- Update transparency
for _, child in model:GetChildren() do
	if child:IsA("BasePart") then
		SuperTween.new(child.Beam, AssetBook.TweenInfos.twiceHalfOne, { Transparency = nsNew(0.1, 1) }):Play()
	end
end
