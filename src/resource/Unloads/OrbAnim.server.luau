--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local model = script.Parent :: Model
local orbLifeTime = model:GetAttribute("OrbLifeTime")

local wait = task.wait
local nsNew = NumberSequence.new

--// Main
ServerUtil:WeldPart(model.Middle, model)

local middle = model.Middle :: BasePart

middle.Beam1.Transparency = nsNew(1, 1)
middle.Beam2.Transparency = nsNew(1, 1)
middle.Beam1.LightInfluence = 0
middle.Beam2.LightInfluence = 0
middle.Beam1.LightEmission = 1
middle.Beam2.LightEmission = 1
model.Part.Transparency = 1

HarukaLib:Tween(middle.Beam1, AssetBook.TweenInfos.half, { Transparency = nsNew(-1, 1) })
HarukaLib:Tween(middle.Beam2, AssetBook.TweenInfos.half, { Transparency = nsNew(-1, 1) })
HarukaLib:Tween(model.Part, AssetBook.TweenInfos.half, { Transparency = 0 })

wait(orbLifeTime - 0.6)

Debris:AddItem(model, 0.5)

HarukaLib:Tween(middle.Beam1, AssetBook.TweenInfos.half, { Transparency = nsNew(1, 1) })
HarukaLib:Tween(middle.Beam2, AssetBook.TweenInfos.half, { Transparency = nsNew(1, 1) })
HarukaLib:Tween(model.Part, AssetBook.TweenInfos.half, { Transparency = 1 })
