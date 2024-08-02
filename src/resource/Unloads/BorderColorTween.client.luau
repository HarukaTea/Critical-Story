--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ClassBook = require(RepS.Modules.Data.ClassBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local model = script.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(model.Parent.Parent)

local color = ClassBook.ClassInfo[plr:GetAttribute("Class")].Color

local csNew, nsNew = ColorSequence.new, NumberSequence.new
local color3New = Color3.new

--- Update color
for _, child: Instance in model:GetChildren() do
	if child:IsA("BasePart") then
		child.Beam.Color = csNew(color, color3New())
		child.Beam.Transparency = nsNew(1, 1)
		child.Beam.LightInfluence = 0
		child.Beam.LightEmission = 1
	end
end

--- Update transparency
for _, child: Instance in model:GetChildren() do
	if child:IsA("BasePart") then
		HarukaLib:Tween(child.Beam, AssetBook.TweenInfos.twiceHalfOne, { Transparency = nsNew(0.1, 1) })
	end
end
