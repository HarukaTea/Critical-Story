--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")

local model = script.Parent :: Model
local target = model.Owner.Value :: Model

local wait = task.wait

wait(0.5)
for _, child in model:GetChildren() do
	if child.Name == "Position" then
		local blast = model.Projectile.Value:Clone() :: Model
		blast.Owner.Value = target
		blast:PivotTo(child.CFrame)

		blast.Parent = target.Holder.Value

		Debris:AddItem(blast, 1)
	end
end

wait(2)
model:Destroy()
