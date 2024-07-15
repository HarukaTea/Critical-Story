--!nocheck

local Debris = game:GetService("Debris")

local model = script.Parent
local char = model.Owner.Value :: Model

local wait = task.wait

pcall(function()
    Debris:AddItem(model, 10)
    model.Shot.Part.Color = model:GetAttribute("SlimeColor")

    wait(0.9)
    local blast = model.Projectile.Value:Clone() :: Model
    blast.Owner.Value = model.Owner.Value
    blast:PivotTo(model.Base.CFrame * CFrame.Angles(0, math.rad(math.random(1, 360)), 0))
    blast.Parent = char.AttackHolder.Value

    Debris:AddItem(blast, 10)

    for _, child: BasePart in blast:GetDescendants() do
        if child:IsA("BasePart") then child.Color = model:GetAttribute("SlimeColor") end
    end

    model.Base:Destroy()
end)
