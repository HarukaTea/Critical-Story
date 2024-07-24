--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(RepS.Modules.Data.Events)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local plr = Players.LocalPlayer

local wait = task.wait
local cfAngles = CFrame.Angles
local rad = math.rad


Events.PlaySound.SetCallback(function(data)
	local sound, timePos = data.Sound, data.TimePos

	if sound.Name == "ResetSound" then
		for _, music: Sound in workspace.Sounds:GetChildren() do
			if music:IsA("Sound") then music:Stop() end
		end
		return
	end

	if sound.Playing then
		local newSound = sound:Clone() :: Sound
		newSound.PlayOnRemove = true
		newSound.TimePosition = if timePos then timePos else 0
		newSound.Parent = workspace

		wait()
		newSound:Destroy()
		return
	end

	sound:Play()
	if timePos then sound.TimePosition = timePos end
end)


Events.ClientTween.SetCallback(function(data)
	local style, goal, objs, useHarukaTween = data.TweenInfo, data.Goal, data.Objs, data.UseHarukaTween

	style = AssetBook.TweenInfos[style]

	for _, obj: Instance in objs do
		pcall(function()
			if not useHarukaTween then
				TS:Create(obj, style, goal):Play()
			else
				HarukaLib:Tween(obj, style, goal)
			end
		end)
	end
end)


Events.ChestUnlocked.SetCallback(function(data)
	workspace.Sounds.SFXs.ChestOpened:Play()

	HarukaLib:Tween(data.Chest.Top, AssetBook.TweenInfos.twiceHalf, { Pivot = data.Chest.Top.PrimaryPart.CFrame * cfAngles(rad(50), 0, 0) })
end)


Events.CameraScene.SetCallback(function(data)
	local part = data.Part
	local camera = workspace.CurrentCamera

	if camera.Name == "CameraReset" then
		camera.CameraType = Enum.CameraType.Custom
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = part.CFrame
end)


Events.FireStoryEvents.SetCallback(function(data)
	local symbol = data.EventSymbol
	if not Signals[symbol] then warn("No signal found: "..symbol) return end

	Signals[symbol]:Fire(plr)
end)
