--!nocheck

local Debris = game:GetService("Debris")

local model = script.Parent :: Model
local monster = model.Owner.Value :: Model
local target = model.Target.Value :: Model

pcall(function()
    Debris:AddItem(model, 10)

    for i = 1, 6 do
        task.spawn(function()
            local laser = model.Projectile.Value:Clone() :: Model
            laser.Owner.Value = monster
            laser:PivotTo(model.PrimaryPart.CFrame)
            laser.Parent = monster.AttackHolder.Value
            Debris:AddItem(laser, 10)

            model.PrimaryPart.CFrame = CFrame.new(model.PrimaryPart.Position, target.PrimaryPart.Position)
            model.PrimaryPart.Anchored = true

            local oriCFrame = model.PrimaryPart.CFrame * CFrame.new(0, 0, -1)
            laser.PrimaryPart.Size = Vector3.new(0.5, 0.5, (oriCFrame.Position - target.PrimaryPart.Position).Magnitude)
            laser.PrimaryPart.CFrame = CFrame.new((oriCFrame.Position + target.PrimaryPart.Position) / 2, oriCFrame.Position)

            task.wait(1)
            model.PrimaryPart.Anchored = false

            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.one * math.huge
            bv.Velocity = model.PrimaryPart.CFrame.LookVector * (66 + i * 3)
            bv.Parent = model.PrimaryPart
            Debris:AddItem(bv, 1.5)
        end)
        task.wait()
    end

    task.wait(2)
    model:Destroy()
end)