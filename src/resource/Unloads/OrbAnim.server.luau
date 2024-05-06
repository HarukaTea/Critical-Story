--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Clock = require(RepS.Modules.Packages.Clock)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SuperTween = require(RepS.Modules.Packages.SuperTween)

local model = script.Parent :: Model
local orbLifeTime = model:GetAttribute("OrbLifeTime")

local wait = task.wait
local nsNew = NumberSequence.new

--// Despawn
Clock(1, function()
    orbLifeTime -= 1

    if orbLifeTime <= 1 then model:SetAttribute("Despawn", true) end
end)

--// Main
ServerUtil:WeldPart(model.Middle, model)

model.Middle.Beam1.Transparency = nsNew(1, 1)
model.Middle.Beam2.Transparency = nsNew(1, 1)
model.Part.Transparency = 1

SuperTween.new(model.Middle.Beam1, AssetBook.TweenInfos.half, { Transparency = nsNew(-1, 1) }):Play()
SuperTween.new(model.Middle.Beam2, AssetBook.TweenInfos.half, { Transparency = nsNew(-1, 1) }):Play()
SuperTween.new(model.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()

repeat wait() until model:GetAttribute("Despawn")

Debris:AddItem(model, 0.5)

SuperTween.new(model.Middle.Beam1, AssetBook.TweenInfos.half, { Transparency = nsNew(1, 1) }):Play()
SuperTween.new(model.Middle.Beam2, AssetBook.TweenInfos.half, { Transparency = nsNew(1, 1) }):Play()
SuperTween.new(model.Part, AssetBook.TweenInfos.half, { Transparency = 1 }):Play()
