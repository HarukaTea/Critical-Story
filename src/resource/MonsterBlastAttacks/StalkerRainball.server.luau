--!nocheck
--!optimize 2
--!native

local model = script.Parent
local char = model.Owner.Value :: Model

local wait = task.wait

pcall(function()
    wait(0.5)
    local blast = model.Projectile.Value:Clone() :: Model
    blast.Owner.Value = model.Owner.Value
    blast:PivotTo(model.Base.CFrame)
    blast.Parent = char.AttackHolder.Value

    model:Destroy()
end)
