--!nocheck

local Signals = require(game:GetService("ServerScriptService").Modules.Data.ServerSignals)

local char = script.Parent :: Model
local isDead = false

local wait = task.wait

char:GetAttributeChangedSignal("Health"):Connect(function()
	char.Head.Display.Number.Text = char:GetAttribute("Health")

	if char:GetAttribute("Health") <= 0 and not isDead then
		isDead = true

		char:SetAttribute("Health", 0)
		for _, character in char.TargetingList:GetChildren() do
			for _, monster in character.Value.CharStats.TargetMonsters:GetChildren() do
				if monster.Value == char then monster:Destroy() end
			end
		end

		Signals.CombatEnd:Fire(char)
	end
end)

char.TargetingList.ChildRemoved:Connect(function()
	wait()
	if not char.TargetingList:FindFirstChildOfClass("ObjectValue") and not isDead then
		isDead = true

		Signals.CombatEnd:Fire(char)
	end
end)