--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent :: Model
local plr = Players.LocalPlayer
local animations = ReplicatedStorage.Package.Animations.CharAnims :: Folder
local animator = char.Humanoid:WaitForChild("Animator") :: Animator

repeat task.wait() until plr:GetAttribute("PlayerDataLoaded")

local class = plr:GetAttribute("Class") :: string

local ANIMS = {
	Idle = animator:LoadAnimation(animations.ClassExclusive:FindFirstChild(class) or animations.Idle),
	Freefall = animator:LoadAnimation(animations.Freefall),
	Jumping = animator:LoadAnimation(animations.Jumping),
	Running = animator:LoadAnimation(animations.Running),
	Seated = animator:LoadAnimation(animations.Seated),
	Climbing = animator:LoadAnimation(animations.Climbing),
}
local oldAnim: AnimationTrack

--// Private

local function startAnim(anim: AnimationTrack, transitionTime: number)
	if char:GetAttribute("IsNocliping") then return end

	if oldAnim ~= anim then
		if oldAnim then oldAnim:Stop(transitionTime) end
		if anim then anim:Play(transitionTime) end

		oldAnim = anim
	end
end

local jumpAnimTime = 0
local isFreefalling = false

--// Setup
local function setup()
	local humanoid = char.Humanoid :: Humanoid

	Add(humanoid.Running:Connect(function()
		if humanoid.MoveDirection.Magnitude > 0 then
			startAnim(ANIMS.Running, 0.1)
		else
			startAnim(ANIMS.Idle, 0.1)
		end

		isFreefalling = false
	end))
	Add(humanoid.Climbing:Connect(function(vel)
		if vel ~= 0 then
			startAnim(ANIMS.Climbing, 0.1)
			ANIMS.Climbing:AdjustSpeed(1)
		else
			ANIMS.Climbing:AdjustSpeed(0)
		end

		isFreefalling = false
	end))
	Add(humanoid.Jumping:Connect(function()
		jumpAnimTime = 0.3

		startAnim(ANIMS.Jumping, 0.1)
		isFreefalling = false
	end))
	Add(humanoid.FreeFalling:Connect(function()
		if jumpAnimTime <= 0 then
			startAnim(ANIMS.Freefall, 0.1)
		end

		isFreefalling = true
	end))
	Add(humanoid.Seated:Connect(function()
		startAnim(ANIMS.Seated, 0.1)

		isFreefalling = false
	end))

	Add(RunService.RenderStepped:Connect(function(dt)
		if jumpAnimTime > 0 then jumpAnimTime -= dt end
		if isFreefalling and jumpAnimTime <= 0 then startAnim(ANIMS.Freefall, 0.1) end
	end))

	startAnim(ANIMS.Idle, 0.1)

	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
end
setup()

--// Clear
local function onDead()
	--// 256 limit still happens, idk
	for _, anim: AnimationTrack in ANIMS do
		anim:Stop(0)
		anim:Destroy()
	end
	local animTracks = animator:GetPlayingAnimationTracks()
	for _, track: AnimationTrack in animTracks do
		track:Stop(0)
		track:Destroy()
	end

	Empty()
end
char.Humanoid.Died:Once(onDead)
