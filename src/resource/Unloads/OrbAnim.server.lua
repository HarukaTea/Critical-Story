--!nocheck

local ServerUtil = require(game:GetService("ServerScriptService").Modules.Utils.ServerUtil)

local model = script.Parent
local plr = game:GetService("Players"):GetPlayerFromCharacter(model.Owner.Value)
local orbLifeTime = plr.Character:GetAttribute("OrbLifeTime") - 0.8

local wait = task.wait
local nsNew = NumberSequence.new

ServerUtil:WeldPart(model.Base, model, "Orb")

model.Base.Beam1.Transparency = nsNew(1, 1)
model.Base.Beam2.Transparency = nsNew(1, 1)
model.Part.Transparency = 1

for i = 1, 10 do
	model.Base.Beam1.Transparency = nsNew((1 - (0.2 * i)), 1)
	model.Base.Beam2.Transparency = nsNew((1 - (0.2 * i)), 1)
	model.Part.Transparency -= 0.1

	wait(0.02)
end

wait(orbLifeTime)
for i = 10, 1, -1 do
	model.Base.Beam1.Transparency = nsNew((1 - (0.2 * i)), 1)
	model.Base.Beam2.Transparency = nsNew((1 - (0.2 * i)), 1)
	model.Part.Transparency += 0.1

	wait(0.02)
end
