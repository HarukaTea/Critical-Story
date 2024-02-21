--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent.Parent.Parent :: Model

local floor = math.floor
local wait = task.wait

while task.wait(30) do
    local humanoid = char.Humanoid :: Humanoid

	if humanoid.Health < humanoid.MaxHealth then
		local healPower = floor(humanoid.MaxHealth * 0.3)

		humanoid.Health += healPower

		local healEff = RepS.Package.Effects.HealEffect:Clone() :: ParticleEmitter
        healEff.Parent = char.PrimaryPart
        Debris:AddItem(healEff, 1)

        Spawn(function()
            wait(0.4)
            healEff.Enabled = false
        end)
	end
end