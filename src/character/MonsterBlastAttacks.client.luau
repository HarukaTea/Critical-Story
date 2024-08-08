--!nocheck

local CS = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent :: Model

local wait = task.wait
local sinh = math.sinh
local v3New = Vector3.new
local cfNew, cfAngles = CFrame.new, CFrame.Angles

--// Foxes
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

	HarukaLib:Tween(blast, AssetBook.TweenInfos.half, { Pivot = blast.PrimaryPart.CFrame * CFrame.new(0, -30, 0) })
end

local function wolfBite(blast: Model)
	blast.WolfSound:Play()

	TS:Create(blast.Fang1.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()
	TS:Create(blast.Fang2.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()

	wait(0.5)
	HarukaLib:Tween(blast.Fang1, AssetBook.TweenInfos.twiceHalf, { Pivot = blast.Fang1.Base.CFrame * CFrame.new(0, 0, -6) })
	HarukaLib:Tween(blast.Fang2, AssetBook.TweenInfos.twiceHalf, { Pivot = blast.Fang2.Base.CFrame * CFrame.new(0, 0, -6) })
end

local function stalkerBite(blast: Model)
	blast.WolfSound:Play()

	TS:Create(blast.Fang1.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()
	TS:Create(blast.Fang2.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()

	wait(0.5)
	local spin = if math.random(1, 2) == 1 then 10 else -10

	HarukaLib:Tween(blast, AssetBook.TweenInfos.fourOneHalf, { Pivot = blast.Base.CFrame * CFrame.Angles(0, spin, 0) })
	HarukaLib:Tween(blast.Fang1, AssetBook.TweenInfos.fourOneHalf, { Pivot = blast.Fang1.Base.CFrame * CFrame.new(0, 0, -24) })
	HarukaLib:Tween(blast.Fang2, AssetBook.TweenInfos.fourOneHalf, { Pivot = blast.Fang2.Base.CFrame * CFrame.new(0, 0, -24) })
end


--// Slimes
local function slimeShot(blast: Model, monster: Model)
	wait(0.4)
	TS:Create(blast.Base, AssetBook.TweenInfos.twiceHalf, { Size = Vector3.new(4, 1, 4) }):Play()

	local length = (monster.PrimaryPart.Position - blast.Base.Position).Magnitude
	local height = 8
	blast.Shot:PivotTo(cfNew(monster.PrimaryPart.Position, blast.Base.Position) * cfNew(0, 0, -length/2) * cfNew(0, -height, 0))

	local radius = (monster.PrimaryPart.Position - blast.Shot.Base.Position).Magnitude
	blast.Shot.Part.CFrame *= cfNew(0, radius, 0)

	local angle = sinh((length / 2) / radius)
	blast.Shot:PivotTo(blast.Shot.Base.CFrame * cfAngles(angle, 0, 0))

	local rotatingangle = angle * 2
	HarukaLib:Tween(blast.Shot, AssetBook.TweenInfos.half, { Pivot = blast.Shot.Base.CFrame * cfAngles(-rotatingangle, 0, 0) }):Wait()

	blast.Shot:Destroy()
end

local function slimeWave(blast: Model)
	blast.SlimeAttack:Play()

	for i = 1, 5 do
		TS:Create(blast["Position"..i], AssetBook.TweenInfos.twiceHalf, { Size = v3New(4, 1, 4) }):Play()
	end
end

local function slimeBlast(blast: Model, noSound: boolean?)
	if not noSound then blast.SlimeAttack:Play() end

	blast.Part.Size = v3New()
	TS:Create(blast.Part, AssetBook.TweenInfos.half, { Size = v3New(1, 8, 8) }):Play()
end

local function slimeBlastFade(blast: Model)
	for _, child: BasePart in blast:GetChildren() do
		if child:IsA("BasePart") then TS:Create(child, AssetBook.TweenInfos.one, { Size = v3New() }):Play() end
	end
end

local function slimeSpin(blast: Model)
	TS:Create(blast.Blast1, AssetBook.TweenInfos.twiceHalf, { Size = v3New(16, 16, 16) }):Play()
	TS:Create(blast.Blast2, AssetBook.TweenInfos.twiceHalf, { Size = v3New(22, 26, 26) }):Play()
	TS:Create(blast.Blast1, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
	TS:Create(blast.Blast2, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
end

local function skyboundSlimeLaser(blast: Model)
	blast.PrimaryPart.Transparency = 0

	wait(0.2)
	TS:Create(blast.PrimaryPart, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
end


--// Connections
local function vfxHandler(blast: Model | BasePart)
	local style = blast:GetAttribute("LinkedProjectile") or blast.Name

	if not blast:IsDescendantOf(workspace) then return end
	blast:WaitForChild("Owner", 999)

	---// most errors here are unnecessary to fix, so just ignore them
	local success, errorMsg = pcall(function()
		if style == "SpikeWolf1" then
			spikeShot(blast)

		elseif style == "SpikeWolfSpike1" then
			spike1(blast)

		elseif style == "SpikeWolfSpike2" then
			spikeRain(blast)

		elseif style == "SpikeWolf2Range" then
			spike2Range(blast)

		elseif style == "SpikeWolf4" then
			wolfBite(blast)

		elseif style == "StalkerBite" then
			stalkerBite(blast)


		elseif style == "Slime1" then
			slimeShot(blast, blast.Owner.Value)

		elseif style == "Slime2" then
			wait(0.5)
			slimeWave(blast)

		elseif style == "SlimeSpin" then
			slimeSpin(blast)

		elseif style == "SlimeBlast" then
			slimeBlast(blast, blast:GetAttribute("SlimeWaveProjectile"))

			wait(8)
			slimeBlastFade(blast)

		elseif style == "SkyboundSlime1Laser" then
			skyboundSlimeLaser(blast)
		end
	end)

	if not success and RS:IsStudio() then warn(errorMsg) end
end
Add(CS:GetInstanceAddedSignal("MonsterAttack"):Connect(vfxHandler))

--// Clear
char.Humanoid.Died:Once(Empty)
