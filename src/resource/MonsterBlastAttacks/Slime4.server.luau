--!nocheck

local model = script.Parent :: Model
local char = model.Owner.Value :: Model

local wait = task.wait

for _, descendant in model:GetDescendants() do
    if descendant:IsA("BasePart") then
        descendant.Color = model:GetAttribute("SlimeColor")
    end
end

wait(0.3)
local blast = model.Projectile.Value:Clone() :: Model
blast.Owner.Value = model.Owner.Value
blast:PivotTo(model.Base.CFrame)
blast.Parent = char.Holder.Value

for _, descendant in blast:GetDescendants() do
    if descendant:IsA("BasePart") and not descendant:GetAttribute("BombCore") then
        descendant.Color = model:GetAttribute("SlimeColor")
    end
end

wait(1)
blast.Bomb1.Transparency = 0
blast.Bomb2.Transparency = 0
blast.Core:Destroy()
blast.Blob:Destroy()

wait(0.23)
blast:Destroy()
model:Destroy()
