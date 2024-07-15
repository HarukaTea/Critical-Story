--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local model = script.Parent :: Model
local owner = model.Owner.Value :: Model
local orbLifeTime = model:GetAttribute("OrbLifeTime")
local plr = Players:GetPlayerFromCharacter(owner)

local wait = task.wait
local nsNew = NumberSequence.new

--// Main
ServerUtil:WeldModel(model.Middle, model)

if not plr then return end

local middle = model.Middle :: BasePart

middle.Beam1.Transparency = nsNew(1, 1)
middle.Beam2.Transparency = nsNew(1, 1)
model.Part.Transparency = 1
model.Sphere.Transparency = 1

Events.ClientTween:Fire(plr, { middle.Beam1, middle.Beam2 }, { Transparency = nsNew(-1, 1) }, "half", true)
Events.ClientTween:Fire(plr, { model.Part, model.Sphere }, { Transparency = 0 }, "half")

wait(orbLifeTime - 0.6)

Debris:AddItem(model, 0.5)

Events.ClientTween:Fire(plr, { middle.Beam1, middle.Beam2 }, { Transparency = nsNew(1, 1) }, "half", true)
Events.ClientTween:Fire(plr, { model.Part, model.Sphere }, { Transparency = 1 }, "half")

