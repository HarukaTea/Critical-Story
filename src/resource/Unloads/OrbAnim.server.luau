--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SuperTween = require(RepS.Modules.Packages.SuperTween)

local model = script.Parent :: Model
local orbLifeTime = model:GetAttribute("OrbLifeTime")

local wait = task.wait
local nsNew = NumberSequence.new

--// Main
ServerUtil:WeldPart(model.Middle, model)

model.Middle.Beam1.Transparency = nsNew(1, 1)
model.Middle.Beam2.Transparency = nsNew(1, 1)
model.Part.Transparency = 1

SuperTween.new(model.Middle.Beam1, AssetBook.TweenInfos.half, { Transparency = nsNew(-1, 1) }):Play()
SuperTween.new(model.Middle.Beam2, AssetBook.TweenInfos.half, { Transparency = nsNew(-1, 1) }):Play()
SuperTween.new(model.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()

wait(orbLifeTime - 0.6)

Debris:AddItem(model, 0.5)

SuperTween.new(model.Middle.Beam1, AssetBook.TweenInfos.half, { Transparency = nsNew(1, 1) }):Play()
SuperTween.new(model.Middle.Beam2, AssetBook.TweenInfos.half, { Transparency = nsNew(1, 1) }):Play()
SuperTween.new(model.Part, AssetBook.TweenInfos.half, { Transparency = 1 }):Play()
