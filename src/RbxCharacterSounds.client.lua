--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Events = HarukaFrameworkClient.Events

local plr = Players.LocalPlayer

local wait = task.wait
local cfAngles = CFrame.Angles
local rad = math.rad

--[[
	Receive sfxs requests from server, and play it locally
]]
local function playSFX(sound: Sound)
	--- if sound is playing, we wanna play two sounds at the same time instead
	if sound.Playing then
		local sfx = sound:Clone()
		sfx.PlayOnRemove = true
		sfx.Parent = workspace

		wait()
		sfx:Destroy()
		return
	end

	sound:Play()
end
Events.PlaySound:Connect(playSFX)

--[[
    Enable client tween, to reduce the pressure of server
]]
local function clientTweenPlayer(objs: table, goal: table, style: string?)
	style = AssetBook.TweenInfos[style]

    for _, obj in objs do
        TS:Create(obj, style, goal):Play()
    end
end
Events.ClientTween:Connect(clientTweenPlayer)

--[[
	The vfx of chests after unlock
]]
local function vfxChestUnlock(chest: Model)
	workspace.Sounds.SFXs.ChestOpened:Play()

	for i = 1,5 do
		wait(0.01)
		chest.Top:PivotTo(chest.Top.Base.CFrame * cfAngles(rad(10), 0, 0))
	end
end
Events.ChestUnlocked:Connect(vfxChestUnlock)

--- once everything is setup, we start the client
require(RepS.Modules.Mechanics.ClientSetups)(plr)
