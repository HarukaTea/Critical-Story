--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)

local Hydrate = Fusion.Hydrate

local monster = script.Parent :: Model

local isDead = false

local wait = task.wait

Hydrate(monster)({
	[Fusion.AttributeChange("Health")] = function(newHP: number)
		monster.Head.Display.Number.Text = newHP

		if newHP <= 0 and not isDead then
			isDead = true

			monster:SetAttribute("Health", 0)

			pcall(function()
				for _, char: Player in monster.TargetPlayers:GetChildren() do
					for _, targetMonster in char.Value.CharStats.TargetMonsters:GetChildren() do
						if targetMonster.Value == monster then targetMonster:Destroy() end
					end
				end
			end)

			monster.Parent.CombatEnd:Fire()
		end
	end
})
Hydrate(monster.TargetPlayers)({
	[Fusion.OnEvent("ChildRemoved")] = function()
		wait()
		if not monster.TargetPlayers:FindFirstChildOfClass("ObjectValue") and not isDead then
			isDead = true

			monster.Parent.CombatEnd:Fire()
		end
	end
})
