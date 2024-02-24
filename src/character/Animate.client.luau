--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Spawn = require(RepS.Modules.Packages.Spawn)

local plr = Players.LocalPlayer
local char = script.Parent :: Model

local wait = task.wait
local instanceNew = Instance.new
local random, sin = math.random, math.sin
local sub = string.sub

local UIModules = RepS.Modules.UI
local requireList = {
	UIModules.AdventurerStats,
	UIModules.AdventurerMenu,
	UIModules.Backpack,
	UIModules.ShiftLock,
	UIModules.PlayerList,
	UIModules.Hints,
	UIModules.PostStroke,
	UIModules.SwitchScene
}
for _, module in requireList do
	Spawn(function()
		require(module)(plr)
	end)
end

--- I optimized the animate script so it should be pretty good right now
local torso = char:WaitForChild("Torso")
local rightShoulder = torso:WaitForChild("Right Shoulder")
local leftShoulder = torso:WaitForChild("Left Shoulder")
local rightHip = torso:WaitForChild("Right Hip")
local leftHip = torso:WaitForChild("Left Hip")
local humanoid = char:WaitForChild("Humanoid")
local pose = "Standing"

local currentAnim = ""
local currentAnimInstance = nil
local currentAnimTrack = nil
local currentAnimKeyframeHandler = nil
local currentAnimSpeed = 1.0
local animTable = {}
local animNames = {
	idle = {
		{ id = "rbxassetid://12405336225", weight = 10 }
	},
	walk = {
		{ id = "rbxassetid://12405387090", weight = 10 },
	},
	run = {
		{ id = "rbxassetid://12405387090", weight = 10 },
	},
	jump = {
		{ id = "rbxassetid://7119107413", weight = 10 },
	},
	fall = {
		{ id = "rbxassetid://7119109919", weight = 10 },
	},
	climb = {
		{ id = "http://www.roblox.com/asset/?id=180436334", weight = 10 },
	},
	sit = {
		{ id = "rbxassetid://12256035150", weight = 10 },
	},
	wave = {
		{ id = "http://www.roblox.com/asset/?id=128777973", weight = 10 },
	},
	point = {
		{ id = "http://www.roblox.com/asset/?id=128853357", weight = 10 },
	},
	dance1 = {
		{ id = "http://www.roblox.com/asset/?id=182435998", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491037", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491065", weight = 10 },
	},
	dance2 = {
		{ id = "http://www.roblox.com/asset/?id=182436842", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491248", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491277", weight = 10 },
	},
	dance3 = {
		{ id = "http://www.roblox.com/asset/?id=182436935", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491368", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491423", weight = 10 },
	},
	laugh = {
		{ id = "http://www.roblox.com/asset/?id=129423131", weight = 10 },
	},
	cheer = {
		{ id = "http://www.roblox.com/asset/?id=129423030", weight = 10 },
	},
}
local dances = { "dance1", "dance2", "dance3" }

-- Existance in this list signifies that it is an emote, the value indicates if it is a looping emote
local emoteNames =
	{ wave = false, point = false, dance1 = true, dance2 = true, dance3 = true, laugh = false, cheer = false }

local function configureAnimationSet(name: string, fileList: table)
	if animTable[name] then
		for _, connection in animTable[name].connections do
			connection:Disconnect()
		end
	end
	animTable[name] = {}
	animTable[name].count = 0
	animTable[name].totalWeight = 0
	animTable[name].connections = {}

	-- fallback to defaults
	if animTable[name].count <= 0 then
		for idx, anim in fileList do
			animTable[name][idx] = {}
			animTable[name][idx].anim = instanceNew("Animation")
			animTable[name][idx].anim.Name = name
			animTable[name][idx].anim.AnimationId = anim.id
			animTable[name][idx].weight = anim.weight
			animTable[name].count = animTable[name].count + 1
			animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
		end
	end
end

-- Clear any existing animation tracks
-- Fixes issue with characters that are moved in and out of the Workspace accumulating tracks
local animator = if humanoid then humanoid.Animator else nil
if animator then
	local animTracks = animator:GetPlayingAnimationTracks()
	for _, track in ipairs(animTracks) do
		track:Stop(0)
		track:Destroy()
	end
end
for name, fileList in animNames do
	configureAnimationSet(name, fileList)
end

-- ANIMATION
-- declarations
local jumpAnimTime = 0
local jumpAnimDuration = 0.3
local fallTransitionTime = 0.3

-- functions
local function stopAllAnimations()
	local oldAnim = currentAnim

	-- return to idle if finishing an emote
	if emoteNames[oldAnim] and emoteNames[oldAnim] == false then
		oldAnim = "idle"
	end

	currentAnim = ""
	currentAnimInstance = nil
	if currentAnimKeyframeHandler then currentAnimKeyframeHandler:Disconnect() end

	if currentAnimTrack then
		currentAnimTrack:Stop()
		currentAnimTrack:Destroy()
		currentAnimTrack = nil
	end
	return oldAnim
end

local function setAnimationSpeed(speed: number)
	if speed ~= currentAnimSpeed then
		currentAnimSpeed = speed
		currentAnimTrack:AdjustSpeed(currentAnimSpeed)
	end
end

-- Preload animations
local function playAnimation(animName: string, transitionTime: number)
	local roll = random(1, animTable[animName].totalWeight)
	local idx = 1
	while roll > animTable[animName][idx].weight do
		roll = roll - animTable[animName][idx].weight
		idx += 1
	end

	local anim = animTable[animName][idx].anim
	-- switch animation
	if anim ~= currentAnimInstance then
		if currentAnimTrack then
			currentAnimTrack:Stop(transitionTime)
			currentAnimTrack:Destroy()
		end

		currentAnimSpeed = 1.0

		-- load it to the humanoid; get AnimationTrack
		currentAnimTrack = humanoid:LoadAnimation(anim)
		currentAnimTrack.Priority = Enum.AnimationPriority.Core

		-- play the animation
		currentAnimTrack:Play(transitionTime)
		currentAnim = animName
		currentAnimInstance = anim

		-- set up keyframe name triggers
		if currentAnimKeyframeHandler then currentAnimKeyframeHandler:Disconnect() end

        local function keyFrameReachedFunc(frameName: string)
            if frameName == "End" then
                local repeatAnim = currentAnim
                -- return to idle if finishing an emote
                if emoteNames[repeatAnim] and not emoteNames[repeatAnim] then repeatAnim = "idle" end

                local animSpeed = currentAnimSpeed
                playAnimation(repeatAnim, 0)

                setAnimationSpeed(animSpeed)
            end
        end
		currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:Connect(keyFrameReachedFunc)
	end
end


local function onRunning()
	if humanoid.MoveDirection.Magnitude > 0 then
		playAnimation("walk", 0.1)

		pose = "Running"
	else
		if emoteNames[currentAnim] == nil then
			playAnimation("idle", 0.1)
			pose = "Standing"
		end
	end
end
local function onDied()
	pose = "Dead"
end
local function onJumping()
	playAnimation("jump", 0.1)

	jumpAnimTime = jumpAnimDuration
	pose = "Jumping"
end
local function onClimbing(speed: number)
	playAnimation("climb", 0.1)

	setAnimationSpeed(speed / 12)
	pose = "Climbing"
end
local function onGettingUp()
	pose = "GettingUp"
end
local function onFreeFall()
	if jumpAnimTime <= 0 then
		playAnimation("fall", fallTransitionTime)
	end
	pose = "FreeFall"
end
local function onFallingDown()
	pose = "FallingDown"
end
local function onSeated()
	pose = "Seated"
end
local function onPlatformStanding()
	pose = "PlatformStanding"
end

local lastTick = tick()
local function move()
	local amplitude = 1
	local frequency = 1
	local deltaTime = tick() - lastTick
	lastTick = tick()

	local climbFudge = 0
	local setAngles = false

	if jumpAnimTime > 0 then jumpAnimTime = jumpAnimTime - deltaTime end

	if pose == "FreeFall" and jumpAnimTime <= 0 then
		playAnimation("fall", fallTransitionTime)

	elseif pose == "Seated" then
		playAnimation("sit", 0.5)

		return
	elseif pose == "Running" then
		playAnimation("walk", 0.1)

	elseif
		pose == "Dead"
		or pose == "GettingUp"
		or pose == "FallingDown"
		or pose == "Seated"
		or pose == "PlatformStanding"
	then
		stopAllAnimations()
		amplitude = 0.1
		frequency = 1
		setAngles = true
	end

	if setAngles then
		local desiredAngle = amplitude * sin(tick() * frequency)

		rightShoulder:SetDesiredAngle(desiredAngle + climbFudge)
		leftShoulder:SetDesiredAngle(desiredAngle - climbFudge)

		rightHip:SetDesiredAngle(-desiredAngle)
		leftHip:SetDesiredAngle(-desiredAngle)
	end
end

-- Connect events
humanoid.Died:Connect(onDied)
humanoid.Running:Connect(onRunning)
humanoid.Jumping:Connect(onJumping)
humanoid.Climbing:Connect(onClimbing)
humanoid.GettingUp:Connect(onGettingUp)
humanoid.FreeFalling:Connect(onFreeFall)
humanoid.FallingDown:Connect(onFallingDown)
humanoid.Seated:Connect(onSeated)
humanoid.PlatformStanding:Connect(onPlatformStanding)

---- setup emote chat hook
Players.LocalPlayer.Chatted:Connect(function(msg)
	local emote = ""
	if msg == "/e dance" then
		emote = dances[random(1, #dances)]
	elseif sub(msg, 1, 3) == "/e " then
		emote = sub(msg, 4)
	elseif sub(msg, 1, 7) == "/emote " then
		emote = sub(msg, 8)
	end

	if pose == "Standing" and emoteNames[emote] then
		playAnimation(emote, 0.1)
	end
end)

-- initialize to idle
playAnimation("idle", 0.1)
pose = "Standing"

while char.Parent do
	wait(0.1)
	move()
end
