--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Events = require(RepS.Modules.Data.Events)
local Signals = require(RepS.Modules.Data.Signals)
local SuperTween = require(RepS.Modules.Packages.SuperTween)

local plr = Players.LocalPlayer

local wait = task.wait
local cfAngles, cfNew = CFrame.Angles, CFrame.new
local rad = math.rad
local v3New = Vector3.new

--[[
	Play the sound when server requests, usually used for
	client-only SFXs
]]
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


--[[,
	Used to perform client-only tweens
]]
local function clientTweenPlayer(objs: table, goal: table, style: string)
	style = AssetBook.TweenInfos[style]

	for _, obj: Instance in objs do
		if not obj then continue end
		if not obj.Parent then continue end

		SuperTween.new(obj, style, goal):Play()
	end
end
Events.ClientTween:Connect(clientTweenPlayer)


--[[
	Play VFX when a chest is unlocked
]]
local function vfxChestUnlock(chest: Model)
	workspace.Sounds.SFXs.ChestOpened:Play()

	SuperTween.new(chest.Top, AssetBook.TweenInfos.twiceHalf, { Pivot = chest.Top.PrimaryPart.CFrame * cfAngles(rad(50), 0, 0) }):Play()
end
Events.ChestUnlocked:Connect(vfxChestUnlock)

--[[
	Create a border when mob phase starts
]]
local function createBorder(method: string, locator: BasePart)
	local char = Players.LocalPlayer.Character

	if method == "Create" then
		if (char.PrimaryPart.Position - locator.Position).Magnitude >= 32 then
			char:PivotTo(cfNew(locator.Position + v3New(0, 5.99, 0)))
		end
		local border = RepS.Package.Unloads.CombatBorder:Clone() :: Model
		border:PivotTo(cfNew(locator.Position))
		border.Parent = char

	else
		if char:FindFirstChild("CombatBorder") then char.CombatBorder:Destroy() end
	end
end
Events.CreateCombatBorder:Connect(createBorder)

--[[
	Tween to that camera position
]]
local function cameraTween(cam: BasePart | string)
	local camera = workspace.CurrentCamera

	if cam == "Reset" then
		camera.CameraType = Enum.CameraType.Custom
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable
	TS:Create(camera, AssetBook.TweenInfos.one, { CFrame = cam.CFrame }):Play()
end
Events.CameraPointTo:Connect(cameraTween)
Signals.CameraPointTo:Connect(cameraTween)


--[[
	Freeze player's controls when combating
]]
local function freezePlayerControls(method: string)
	ClientUtil:FreezePlayerControls(method)
end
Events.FreezePlayerControls:Connect(freezePlayerControls)

--[[
	Class attack vfx!
]]
local function classVFX(monster: Model)
	ClientUtil:ClassHitVFX(monster, plr.Character)
end
Events.ClassClientVFX:Connect(classVFX)
