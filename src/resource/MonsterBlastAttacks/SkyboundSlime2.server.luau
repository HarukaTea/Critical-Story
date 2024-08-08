--!nocheck

local Debris = game:GetService("Debris")

local model = script.Parent :: Model

pcall(function()
    Debris:AddItem(model, 2)

    model.PrimaryPart.Anchored = false

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.one * math.huge
    bv.Velocity = model.PrimaryPart.CFrame.LookVector * math.random(25, 55)
    bv.Parent = model.PrimaryPart
end)
