--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(RepS.Modules.Data.Events)
local SuperTween = require(RepS.Modules.Packages.SuperTween)
local Signals = require(RepS.Modules.Data.Signals)

local plr = Players.LocalPlayer

local wait = task.wait
local cfAngles = CFrame.Angles
local rad = math.rad

local function playSound(sound: Sound | string, pos: number?)
	if sound == "StopAll" then
		for _, music: Sound in workspace.Sounds:GetChildren() do
			if music:IsA("Sound") then music:Stop() end
		end
		return
	end
	if sound.Playing then
		local newSound = sound:Clone() :: Sound
		newSound.PlayOnRemove = true
		newSound.TimePosition = if pos then pos else 0
		newSound.Parent = workspace

		wait()
		newSound:Destroy()
		return
	end

	sound:Play()
	if pos then sound.TimePosition = pos end
end
Events.PlaySound:Connect(playSound)


local function clientTweenPlayer(objs: table, goal: table, style: string)
	style = AssetBook.TweenInfos[style]

	for _, obj: Instance in objs do
		pcall(function()
			TS:Create(obj, style, goal):Play()
		end)
	end
end
Events.ClientTween:Connect(clientTweenPlayer)


local function vfxChestUnlock(chest: Model)
	workspace.Sounds.SFXs.ChestOpened:Play()

	SuperTween.new(chest.Top, AssetBook.TweenInfos.twiceHalf, { Pivot = chest.Top.PrimaryPart.CFrame * cfAngles(rad(50), 0, 0) }):Play()
end
Events.ChestUnlocked:Connect(vfxChestUnlock)


local function lockCam(cam: BasePart | string)
	local camera = workspace.CurrentCamera

	if cam == "Reset" then
		camera.CameraType = Enum.CameraType.Custom
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cam.CFrame
end
Events.LockCam:Connect(lockCam)


local function storySignals(symbol: string)
	if not Signals[symbol] then warn("No signal found: "..symbol) return end

	Signals[symbol]:Fire(plr)
end
Events.StoryEvents:Connect(storySignals)
