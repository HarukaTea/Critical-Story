--!strict
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local char = script.Parent :: Model
local isDead = false
local isInStage = false

local wait = task.wait

char:GetAttributeChangedSignal("Health"):Connect(function()
	local hp = char:GetAttribute("Health") :: number
	local maxHP = char:GetAttribute("MaxHealth") :: number

	char.Head.Display.Number.Text = hp

	--// Stage mobs
	if char:GetAttribute("StageMob") and hp <= (maxHP * 0.4) and not isInStage and not isDead then
		isInStage = true

		char:SetAttribute("CantAttack", true)

		HarukaLib:Add(char, "Stage", 1)
		char:SetAttribute("Health", maxHP)
	end

	--// Normal mobs
	if char:GetAttribute("Health") <= 0 and not isDead then
		isDead = true

		char:SetAttribute("Health", 0)
		for _, character in char.TargetingList:GetChildren() do
			for _, monster in character.Value.CharStats.TargetMonsters:GetChildren() do
				if monster.Value == char then monster:Destroy() end
			end
		end

		char.Parent.CombatEnd:Fire()
	end
end)

char.TargetingList.ChildRemoved:Connect(function()
	wait()
	if not char.TargetingList:FindFirstChildOfClass("ObjectValue") and not isDead then
		isDead = true

		char.Parent.CombatEnd:Fire()
	end
end)
