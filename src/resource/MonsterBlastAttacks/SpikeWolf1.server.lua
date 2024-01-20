--!nocheck

local model = script.Parent :: Model
local target = model.Owner.Value :: Model

local wait, delay = task.wait, task.delay

wait(0.5)
model.Spike:Play()

for _, child in model:GetChildren() do
	if child.Name == "Position" then
		local blast = model.Projectile.Value:Clone() :: Model
		blast.Owner.Value = target
		blast:PivotTo(child.CFrame)
		blast.Parent = target.Holder.Value

		delay(1, function()
			blast:Destroy()
		end)
	end
end

wait(2)
model:Destroy()
