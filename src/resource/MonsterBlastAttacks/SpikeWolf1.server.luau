--!nocheck

local Debris = game:GetService("Debris")

local model = script.Parent :: Model
local target = model.Owner.Value :: Model

local wait = task.wait

Debris:AddItem(model, 3)

pcall(function()
	wait(0.5)
	for _, child: BasePart in model:GetChildren() do
		if child.Name == "Position" then
			local blast = model.Projectile.Value:Clone() :: Model
			blast.Owner.Value = target
			blast:PivotTo(child.CFrame)
			blast.Parent = target.AttackHolder.Value

			Debris:AddItem(blast, 1)
		end
	end
end)

