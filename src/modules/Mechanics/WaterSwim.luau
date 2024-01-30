--!nocheck

local CAS = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TS = game:GetService("TweenService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local waters = workspace:WaitForChild("MapComponents").Waters

local currentAnim = nil
local isSwimming = false
local swimUp, swimDown = false, false

local instanceNew = Instance.new
local v3New = Vector3.new
local tweenInfoNew = TweenInfo.new
local color3New = Color3.new

local function returnFunc(plr: Player)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = char.Humanoid
    local animator = humanoid.Animator :: Animator
    local animations = RepS.Package.Animations

    local ANIMS = {
        SwimUp = animator:LoadAnimation(animations.SwimUp),
        SwimDown = animator:LoadAnimation(animations.SwimDown),
        SwimIdle = animator:LoadAnimation(animations.SwimIdle),
        Swimming = animator:LoadAnimation(animations.Swimming),
        SwimUpDiagonal = animator:LoadAnimation(animations.DiagonalSwimUp),
        SwimDownDiagonal = animator:LoadAnimation(animations.DiagonalSwimDown)
    }

    --// Actions
    local function _changeAction(actionName: string, inputState: Enum.UserInputState)
        if actionName == "SwimDown" then
            if inputState == Enum.UserInputState.Begin then
                swimDown = true

            elseif inputState == Enum.UserInputState.End then
                swimDown = false
            end
        end
    end
    CAS:BindActionAtPriority("SwimDown", _changeAction, false, 1000, Enum.KeyCode.LeftShift)

    --// Functions
    local function __changeAnim(anim: string)
        local old = currentAnim :: AnimationTrack?
        local new = ANIMS[anim] :: AnimationTrack?

        if new ~= old then
            if old then old:Stop() end
            if new then new:Play() end

            currentAnim = new
        end
    end
    local function _swimIn()
        if isSwimming then return end

        isSwimming = true

        local HRP = humanoid.RootPart
        local vel = HRP.AssemblyLinearVelocity

        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        humanoid.HipHeight = -3

        local diveVel = instanceNew("BodyVelocity")
        diveVel.Name = "DiveVel"
        diveVel.MaxForce = v3New(0, 8000, 0)
        diveVel.Velocity = v3New(vel.X, vel.Y, vel.Z)
        diveVel.Parent = char.Head
        Debris:AddItem(diveVel, 0.2)

        local swimVel = instanceNew("BodyVelocity")
        swimVel.Name = "SwimVel"
        swimVel.P = 8000
        swimVel.Velocity = v3New()
        swimVel.MaxForce = v3New(vel.X, 8000, vel.Z)
        swimVel.Parent = HRP

        TS:Create(diveVel, tweenInfoNew(0.2), { Velocity = v3New(vel.X, 0, vel.Z) }):Play()

        __changeAnim("SwimIdle")

        CAS:BindActionAtPriority("SwimDown", _changeAction, false, 3000, Enum.KeyCode.LeftShift)
    end
    local function _swimOut()
        if not isSwimming then return end

        isSwimming = false
        swimUp = false
        swimDown = false

        local HRP = humanoid.RootPart
        local vel = HRP.AssemblyLinearVelocity

        for _, child in HRP:GetChildren() do
            if child.Name == "SwimVel" then child:Destroy() end
        end

        humanoid.HipHeight = 0
        HRP.AssemblyLinearVelocity = v3New(vel.X, 70, vel.Z)

        __changeAnim(nil)

        CAS:BindActionAtPriority("SwimDown", _changeAction, false, 1000, Enum.KeyCode.LeftShift)
    end

    --// Connections
    local head = char:WaitForChild("Head")

    local function _onHit(hit: BasePart)
        if hit and hit:GetAttribute("Water") then
            workspace.Sounds.SFXs.Splash:Play()

            _swimIn()
        end
    end
    local function _endHit(hit: BasePart)
        if hit and hit:GetAttribute("Water") then _swimOut() end
    end
    head.Touched:Connect(_onHit)
    head.TouchEnded:Connect(_endHit)

    local function _stateChanged()
        local jumping = humanoid.Jump

        if jumping and isSwimming then
            swimUp = true
            swimDown = false

        elseif not jumping and isSwimming then
            swimUp = false

        elseif jumping and not isSwimming then
            swimUp = false

        elseif not jumping and not isSwimming then
            swimUp = false
        end
    end
    local function _onDead()
        if not isSwimming then return end

        isSwimming = false
        swimUp = false
        swimDown = false
    end
    humanoid.Changed:Connect(_stateChanged)
    humanoid.Died:Connect(_onDead)

    local function _swimmingHeartbeat()
        if not isSwimming then return end

        local HRP = humanoid.RootPart
        local swimVel = HRP:WaitForChild("SwimVel") :: BodyVelocity

        local moveDirection = humanoid.MoveDirection
        local moving = moveDirection.Magnitude > 0.1
        local direction = swimVel.Velocity

        local vel = 0
        if swimUp then
            vel = humanoid.WalkSpeed
        elseif swimDown then
            vel = -humanoid.WalkSpeed
        elseif not swimDown or not swimUp then
            vel = 0
        end

        if direction.Magnitude > 0.2 then
            if moving then
                if vel > 0.1 then
                    __changeAnim("SwimUpDiagonal")

                elseif vel < -0.1 then
                    __changeAnim("SwimDownDiagonal")

                else
                    __changeAnim("Swimming")
                end

            else
                __changeAnim(if vel < 0 then "SwimDown" else "SwimUp")
            end

        else
            __changeAnim("SwimIdle")
        end

        swimVel.Velocity = v3New(moveDirection.X * humanoid.WalkSpeed, vel, moveDirection.Z * humanoid.WalkSpeed)
    end
    local function _cameraInWaterRender()
        local camera = workspace.CurrentCamera
        local water = HarukaLib:IsInRegion(camera.CFrame.Position, waters:GetChildren())

        local inWater = water ~= nil

        camera.WaterBlur.Enabled = inWater
        camera.WaterColor.Enabled = inWater
        SoundService.Musics.Equalizer.Enabled = inWater

        camera.WaterColor.TintColor = if inWater then color3New(1, 1, 1):Lerp(water.Color, 0.65) else color3New(1, 1, 1)
    end
    RS.Heartbeat:Connect(_swimmingHeartbeat)
    RS.RenderStepped:Connect(_cameraInWaterRender)
end

return returnFunc
