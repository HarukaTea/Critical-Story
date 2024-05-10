--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")

local model = script.Parent

local wait = task.wait

for i = 1, 15 do
    for _, child: BasePart in model:GetChildren() do
        if child.Name == "Position"..i then
            local blast = model.Projectile.Value:Clone() :: Model
            blast.Owner.Value = model.Owner.Value
            blast:PivotTo(child.CFrame)
            blast.Parent = model.Owner.Value.AttackHolder.Value

            Debris:AddItem(blast, 10)

            child:Destroy()
        end
    end
    wait(0.01)
end