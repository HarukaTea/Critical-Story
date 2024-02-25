--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(RepS.Modules.Data.Events)

local plr = Players.LocalPlayer

local wait = task.wait
local cfAngles = CFrame.Angles
local rad = math.rad


--[[
	Play the sound when server requests, usually used for
	client-only SFXs
]]
local function playSound(sound: Sound | string, pos: number)
	if sound == "StopAll" then
		for _, music: Sound in workspace.Sounds:GetChildren() do
			if music:IsA("Sound") then music:Stop() end
		end
		return
	end
	if sound.Playing then
		local newSound = sound:Clone()
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

		TS:Create(obj, style, goal):Play()
	end
end
Events.ClientTween:Connect(clientTweenPlayer)


--[[
	Play VFX when a chest is unlocked
]]
local function vfxChestUnlock(chest: Model)
	workspace.Sounds.SFXs.ChestOpened:Play()

	for _ = 1, 5 do
		wait(0.01)
		chest.Top:PivotTo(chest.Top.PrimaryPart.CFrame * cfAngles(rad(10), 0, 0))
	end
end
Events.ChestUnlocked:Connect(vfxChestUnlock)


--[[
	Join the public or party combat by prompt requests
]]
local function joinCombat()
	local char = plr.Character :: Model
	local charStats = char:FindFirstChild("CharStats") :: Folder

	if not charStats then return end
	for _, monsterSymbol: ObjectValue in charStats.TargetMonsters:GetChildren() do
		local monster = monsterSymbol.Value :: Model

		if monster and monster:FindFirstChild("Holder") and monster.Holder.Value then
			local folder = monster.Holder.Value :: Folder
			if not folder then return end
			if not folder.Parent then return end

			folder.Parent = workspace.MapComponents.CombatFolders
		end
	end
end
Events.RejoinCombat:Connect(joinCombat)
