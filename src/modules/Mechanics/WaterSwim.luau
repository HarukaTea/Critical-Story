--!nocheck

local CAS = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TS = game:GetService("TweenService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local waters = workspace:WaitForChild("MapComponents").Waters

local Swimming = {}
Swimming.__index = Swimming

local instanceNew = Instance.new
local v3New = Vector3.new
local tweenInfoNew = TweenInfo.new
local color3New = Color3.new

--[[
    Change an anim to a different one
]]
function Swimming:ChangeAnim(anim: string)
    local old = self.currentAnim :: AnimationTrack?
    local new = self.ANIMS[anim] :: AnimationTrack?

    if new ~= old then
        if old then old:Stop() end
        if new then new:Play() end

        self.currentAnim = new
    end
end

--[[
    Jump in the water!
]]
function Swimming:SwimIn()
    if self.isSwimming then return end

    self.isSwimming = true

    local humanoid = self.humanoid :: Humanoid
    local HRP = humanoid.RootPart

    local vel = HRP.AssemblyLinearVelocity

    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    humanoid.HipHeight = -3

    local diveVel = instanceNew("BodyVelocity")
    diveVel.Name = "DiveVel"
    diveVel.MaxForce = v3New(0, 8000, 0)
    diveVel.Velocity = v3New(vel.X, vel.Y, vel.Z)
    diveVel.Parent = self.char.Head
    Debris:AddItem(diveVel, 0.2)

    local swimVel = instanceNew("BodyVelocity")
    swimVel.Name = "SwimVel"
    swimVel.P = 8000
    swimVel.Velocity = v3New()
    swimVel.MaxForce = v3New(vel.X, 8000, vel.Z)
    swimVel.Parent = HRP

    TS:Create(diveVel, tweenInfoNew(0.2), { Velocity = v3New(vel.X, 0, vel.Z) }):Play()

    self:ChangeAnim("SwimIdle")
end

--[[
    Jump out of the water
]]
function Swimming:SwimOut()
    if not self.isSwimming then return end

    self.isSwimming = false
    self.swimUp = false
    self.swimDown = false

    workspace.Sounds.SFXs.Splash:Play()

    local humanoid = self.humanoid :: Humanoid
    local HRP = humanoid.RootPart

    local vel = HRP.AssemblyLinearVelocity
    for _, child in HRP:GetChildren() do
        if child.Name == "SwimVel" then child:Destroy() end
    end

    humanoid.HipHeight = 0
    HRP.AssemblyLinearVelocity = v3New(vel.X, 60, vel.Z)

    self:ChangeAnim(nil)
end

--[[
    The handler of swim touch
]]
function Swimming:Touch(hit: BasePart)
    if hit and hit:GetAttribute("Water") then
        workspace.Sounds.SFXs.Splash:Play()

        self:SwimIn()
    end
end

--[[
    The handler when attribute changed
]]
function Swimming:ChangeState()
    local humanoid = self.humanoid :: Humanoid

    local isSwimming = self.isSwimming
    local jumping = humanoid.Jump

    if jumping and isSwimming then
        self.swimUp = true
        self.swimDown = false

    elseif not jumping and isSwimming then
        self.swimUp = false

    elseif jumping and not isSwimming then
        self.swimUp = false

    elseif not jumping and not isSwimming then
        self.swimUp = false
    end
end

--[[
    The handler when character dead
]]
function Swimming:Clear()
    if not self.isSwimming then return end

    self.isSwimming = false
    self.swimUp = false
    self.swimDown = false
end

--[[
    The handler while swimming
]]
function Swimming:InSwimming()
    if not self.isSwimming then return end

    local vel = 0

    if self.swimUp then
        vel = 18
    elseif self.swimDown then
        vel = -18
    elseif not self.swimDown or not self.swimUp then
        vel = 0
    end

    local humanoid = self.humanoid :: Humanoid
    local HRP = humanoid.RootPart
    local swimVel = HRP:WaitForChild("SwimVel") :: BodyVelocity

    local moveDirection = humanoid.MoveDirection
    local moving = moveDirection.Magnitude > 0.1
    local direction = swimVel.Velocity

    if direction.Magnitude > 0.2 then
        if moving then
            if vel > 0.1 then
                self:ChangeAnim("SwimUpDiagonal")

            elseif vel < -0.1 then
                self:ChangeAnim("SwimDownDiagonal")

            else
                self:ChangeAnim("Swimming")
            end

        else
            self:ChangeAnim(if vel < 0 then "SwimDown" else "SwimUp")
        end

    else
        self:ChangeAnim("SwimIdle")
    end

    swimVel.Velocity = v3New(moveDirection.X * 18, vel, moveDirection.Z * 18)
end

--[[
    The handler of camera that in water
]]
function Swimming:CameraInWater()
    local camera = workspace.CurrentCamera
    local water = HarukaLib:IsInRegion(camera.CFrame.Position, waters:GetChildren())

    local inWater = water ~= nil

    camera.WaterBlur.Enabled = inWater
    camera.WaterColor.Enabled = inWater
    SoundService.Musics.Equalizer.Enabled = inWater

    camera.WaterColor.TintColor = if inWater then color3New(1, 1, 1):Lerp(water.Color, 0.65) else color3New(1, 1, 1)
end

return function (plr: Player)
    local self = setmetatable({}, Swimming)

    local char = plr.Character or plr.CharacterAdded:Wait()
    local animator = char.Humanoid.Animator :: Animator

    self.char = char
    self.humanoid = char.Humanoid
    self.currentAnim = nil

    self.isSwimming = false
    self.swimUp = false
    self.swimDown = false

    local animations = RepS.Package.Animations
    self.ANIMS = {
        SwimUp = animator:LoadAnimation(animations.SwimUp),
        SwimDown = animator:LoadAnimation(animations.SwimDown),
        SwimIdle = animator:LoadAnimation(animations.SwimIdle),
        Swimming = animator:LoadAnimation(animations.Swimming),
        SwimUpDiagonal = animator:LoadAnimation(animations.DiagonalSwimUp),
        SwimDownDiagonal = animator:LoadAnimation(animations.DiagonalSwimDown)
    }

    --// Actions
    local function _changeAction(actionName: string, inputState: Enum.UserInputState)
        if actionName == "SwimUp" then
            if inputState == Enum.UserInputState.Begin then
                self.swimUp = true

            elseif inputState == Enum.UserInputState.End then
                self.swimUp = false
            end

        elseif actionName == "SwimDown" then
            if inputState == Enum.UserInputState.Begin then
                self.swimDown = true

            elseif inputState == Enum.UserInputState.End then
                self.swimDown = false
            end
        end

        return (self.isSwimming and inputState == Enum.UserInputState.Begin) and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
    end
    CAS:BindActionAtPriority("SwimDown", _changeAction, false, 3000, Enum.KeyCode.LeftShift)

    --// Connections
    local head = char:WaitForChild("Head")

    local function _onHit(hit: BasePart)
        self:Touch(hit)
    end
    local function _endHit(hit: BasePart)
        if hit and hit:GetAttribute("Water") then
            self:SwimOut()
        end
    end
    head.Touched:Connect(_onHit)
    head.TouchEnded:Connect(_endHit)

    local function _stateChanged()
        self:ChangeState()
    end
    local function _onDead()
        self:Clear()
    end
    self.humanoid.Changed:Connect(_stateChanged)
    self.humanoid.Died:Connect(_onDead)

    local function _heartbeat()
        self:InSwimming()
    end
    local function _render()
        self:CameraInWater()
    end
    RS.Heartbeat:Connect(_heartbeat)
    RS.RenderStepped:Connect(_render)
end
