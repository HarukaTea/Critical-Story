--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model
local humanoid = char:FindFirstChildOfClass("Humanoid") :: Humanoid

local rayNew = Ray.new
local cfNew = CFrame.new
local v3New = Vector3.new

local walljumpAnim = humanoid.Animator:LoadAnimation(RepS.Package.Animations.Walljump)
local lastJumped = tick()

local function stick()
    local HRP = humanoid.RootPart

    local isJumping = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
    local state = humanoid:GetState()

    local stateType = Enum.HumanoidStateType
    if isJumping and (state == stateType.Jumping or state == stateType.Freefall) then
        local ray = rayNew(HRP.Position, HRP.CFrame.LookVector * 2)
        local hit, pos, normal = workspace:FindPartOnRay(ray, char)

        if hit and hit:HasTag("Walljump") and tick() - lastJumped > 0.02 then
            humanoid.AutoRotate = false

            HRP.Anchored = true
            HRP.CFrame = cfNew(HRP.Position, HRP.Position + normal)

            walljumpAnim:Play()
            workspace.Sounds.SFXs.Walljump:Play()

            local start = tick()
            local jumped = false

            Spawn(function()
                UIS.JumpRequest:Wait()

                jumped = true
            end)
            repeat RS.RenderStepped:Wait() until jumped or tick() - start > 1

            lastJumped = tick()
            humanoid.AutoRotate = true
            HRP.Anchored = false

            walljumpAnim:Stop()

            if jumped then
                HRP.AssemblyLinearVelocity = v3New(normal.X * 50, 50 + normal.Y * 50, normal.Z * 50)
            else
                HRP.AssemblyLinearVelocity = v3New()
            end
        end
    end
end
humanoid.Touched:Connect(stick)
