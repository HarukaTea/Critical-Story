--!nocheck

local CS = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)

local wait = task.wait
local sinh, random = math.sinh, math.random
local v3New = Vector3.new
local cfNew, cfAngles = CFrame.new, CFrame.Angles

--// Mob attacks
local function spikeShot(blast: Model)
	wait(0.5)
	blast.Spike:Play()
end

local function spike1(blast: Model)
	blast.Base.CFrame *= cfNew(0, 0, -80)

	TS:Create(blast.Part, AssetBook.TweenInfos.one, { Position = blast.Base.Position }):Play()
end

local function spike2Range(blast: BasePart)
	TS:Create(blast, AssetBook.TweenInfos.one, { Transparency = 1 }):Play()
end

local function spikeRain(blast: Model)
	blast.Spike:Play()
	blast:PivotTo(blast.PrimaryPart.CFrame * cfNew(0, 30, 0))

	for _ = 1, 30 do
		blast:PivotTo(blast.PrimaryPart.CFrame * cfNew(0, -1, 0))
		wait(0.01)
	end
end

local function wolfBite(blast: Model)
	blast.WolfSound:Play()

	TS:Create(blast.Fang1.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()
	TS:Create(blast.Fang2.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()

	wait(0.5)
	for _ = 1, 2 do
		blast.Fang1:PivotTo(blast.Fang1.Base.CFrame * cfNew(0, 0, -3))
		blast.Fang2:PivotTo(blast.Fang2.Base.CFrame * cfNew(0, 0, -3))

		wait(0.01)
	end
end


--// Slimes
local function slimeShot(blast: Model, char: Model)
	blast.Shot.Part.Color = blast:GetAttribute("SlimeColor")

	TS:Create(blast.Base, AssetBook.TweenInfos.twiceHalf, { Size = v3New(4, 1, 4) }):Play()

	local length = (char.PrimaryPart.Position - blast.Base.Position).Magnitude
	local radius = (char.PrimaryPart.Position - blast.Shot.Base.Position).Magnitude
	local angle = sinh((length / 2) / radius)

	blast.Shot:PivotTo(cfNew(char.PrimaryPart.Position, blast.Base.Position) * cfNew(0,0,-length/2))
	blast.Shot.Part.CFrame *= cfNew(0, radius / 2.5, 0)
	blast.Shot:PivotTo(blast.Shot.Base.CFrame * cfAngles(angle,0,0))

	local rotatingangle = angle * 2 /10
	for _ = 1, 10 do
		wait(0.01)
		blast.Shot:PivotTo(blast.Shot.Base.CFrame * cfAngles(-rotatingangle,0,0))
	end

	blast.Shot:Destroy()
end

local function slimeWave(blast: Model)
	blast.SlimeAttack:Play()

	for i = 1, 5 do
		TS:Create(blast["Position"..i], AssetBook.TweenInfos.twiceHalf, { Size = v3New(4, 1, 4) }):Play()
	end
end

local function slimeBlast(blast: Model, noSound: boolean?)
	local centerCFrame = blast.BlastCenter.CFrame :: CFrame
	local cframe1, cframe2, cframe3, cframe4 =
		blast.Blast1.CFrame :: CFrame,
		blast.Blast2.CFrame :: CFrame,
		blast.Blast3.CFrame :: CFrame,
		blast.Blast4.CFrame :: CFrame
	local cframeArray = { [1] = cframe1, [2] = cframe2, [3] = cframe3, [4] = cframe4 }

	if not noSound then blast.SlimeAttack:Play() end
	for _ = 1, 4 do
		wait(0.01)
		blast.BlastCenter.Size += v3New(0, 10, 0)
		blast.BlastCenter.CFrame = centerCFrame
		blast.BlastCenter.Transparency += 0.05

		for j = 1, 4 do
			blast["Blast" .. j].Size += v3New(0, random(5, 7), 0)
			blast["Blast" .. j].CFrame = cframeArray[j]
			blast["Blast" .. j].Transparency += 0.05
		end
	end
	for _ = 1, 4 do
		wait(0.01)
		blast.BlastCenter.Size -= v3New(0, 10, 0)
		blast.BlastCenter.CFrame = centerCFrame
		blast.BlastCenter.Transparency += 0.25

		for j = 1, 4 do
			blast["Blast" .. j].Size -= v3New(0, random(5, 7), 0)
			blast["Blast" .. j].CFrame = cframeArray[j]
			blast["Blast" .. j].Transparency += 0.25
		end
	end
end

local function slimeBlastFade(blast: Model)
	for _, child in blast:GetChildren() do
		if child:IsA("BasePart") then
			TS:Create(child, AssetBook.TweenInfos.one, { Size = v3New() }):Play()
		end
	end
end

local function slimeDive(blast: Model)
	blast.SlimeAttack:Play()

	for i = 1, 2 do
		local size = if i == 1 then v3New(20, 1, 20) else v3New(4, 1, 4)

		TS:Create(blast["Position" .. i], AssetBook.TweenInfos.twiceHalf, { Size = size }):Play()
	end
end

local function slimeBomb(blast: Model)
	blast.Explosion:Play()

	TS:Create(blast.Bomb1, AssetBook.TweenInfos.twiceHalf, { Size = v3New(16, 16, 16) }):Play()
	TS:Create(blast.Bomb2, AssetBook.TweenInfos.twiceHalf, { Size = v3New(22, 26, 26) }):Play()
	TS:Create(blast.Bomb1, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
	TS:Create(blast.Bomb2, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
end

local function slimeSpin(blast: Model)
	TS:Create(blast.Blast1, AssetBook.TweenInfos.twiceHalf, { Size = v3New(16, 16, 16) }):Play()
	TS:Create(blast.Blast2, AssetBook.TweenInfos.twiceHalf, { Size = v3New(22, 26, 26) }):Play()
	TS:Create(blast.Blast1, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
	TS:Create(blast.Blast2, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
end

--// Connections
local function vfxHandler(blast: Model | BasePart)
	local style = blast.Name

	if not blast:IsDescendantOf(workspace) then return end
	blast:WaitForChild("Owner")

	---// most errors here are unnecessary to fix, so just ignore them
	pcall(function()
		if style == "SpikeWolf1" or style == "LavaWolf1" then
			spikeShot(blast)

		elseif style == "SpikeWolfSpike1" or style == "LavaWolfSpike1" then
			spike1(blast)

		elseif style == "SpikeWolfSpike2" or style == "LavaWolfSpike2" then
			spikeRain(blast)

		elseif style == "SpikeWolf2Range" then
			spike2Range(blast)

		elseif style == "SpikeWolf4" or style == "LavaWolf4" then
			wolfBite(blast)



		elseif style == "Slime1" then
			wait(0.3)
			slimeShot(blast, blast.Owner.Value)

		elseif style == "Slime2" then
			wait(0.5)
			slimeWave(blast)

		elseif style == "Slime3" then
			wait(0.5)
			slimeDive(blast)

		elseif style == "Slime4" then
			wait(0.3)
			slimeShot(blast, blast.Owner.Value)

		elseif style == "SlimeBomb" then
			wait(1)
			slimeBomb(blast)

		elseif style == "SlimeSpin" then
			slimeSpin(blast)

		elseif style == "SlimeBlast" then
			slimeBlast(blast, blast:GetAttribute("SlimeWaveProjectile"))

			wait(8)
			slimeBlastFade(blast)
		end
	end)
end
CS:GetInstanceAddedSignal("MonsterAttack"):Connect(vfxHandler)
