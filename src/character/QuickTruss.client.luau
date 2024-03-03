--!nocheck

local char = script.Parent :: Model

local v3New = Vector3.new

local function climb(isJumping: boolean) : nil
    if isJumping then
        local HRP = char.PrimaryPart :: BasePart
        local vel = HRP.AssemblyLinearVelocity

        HRP.AssemblyLinearVelocity = v3New(vel.X, char.Humanoid.JumpPower * 1.1, vel.Z)
    end
end
char.Humanoid.Jumping:Connect(climb)
