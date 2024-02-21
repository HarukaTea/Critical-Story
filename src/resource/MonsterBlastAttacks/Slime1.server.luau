--!nocheck

local model = script.Parent
local char = model.Owner.Value :: Model

local wait = task.wait

wait(0.5)
local blast = model.Projectile.Value:Clone() :: Model
blast.Owner.Value = model.Owner.Value
blast:PivotTo(model.Base.CFrame)
blast.Parent = char.Holder.Value

for _, child in blast:GetDescendants() do
    if child:IsA("BasePart") then
        child.Color = model:GetAttribute("SlimeColor")
    end
end

model:Destroy()
