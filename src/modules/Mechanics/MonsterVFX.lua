--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)

local MonsterVFX = {}
MonsterVFX.__index = MonsterVFX

local wait = task.wait
local sinh, random = math.sinh, math.random
local v3New = Vector3.new
local cfNew, cfAngles = CFrame.new, CFrame.Angles

function MonsterVFX:FullWait(blast: Model)
	blast:WaitForChild("Owner")
end

---// Foxes
function MonsterVFX:Spike1(blast: Model)
	self:FullWait(blast)

	blast.Base.CFrame *= cfNew(0, 0, -80)
	TS:Create(blast.Part, AssetBook.TweenInfos.one, { Position = blast.Base.Position }):Play()
end

function MonsterVFX:Spike2Range(blast: BasePart)
	self:FullWait(blast)

	TS:Create(blast, AssetBook.TweenInfos.one, { Transparency = 1 }):Play()
end

function MonsterVFX:SpikeRain(blast: Model)
	self:FullWait(blast)

	blast:PivotTo(blast.PrimaryPart.CFrame * cfNew(0, 30, 0))

	for i = 1, 30 do
		if not blast then break end

		blast:PivotTo(blast.PrimaryPart.CFrame * cfNew(0, -1, 0))
		wait(0.01)
	end
end

function MonsterVFX:WolfBite(blast: Model)
	self:FullWait(blast)

	TS:Create(blast.Fang1.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()
	TS:Create(blast.Fang2.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()

	wait(0.5)
	for i = 1, 2 do
		blast.Fang1:PivotTo(blast.Fang1.Base.CFrame * cfNew(0, 0, -3))
		blast.Fang2:PivotTo(blast.Fang2.Base.CFrame * cfNew(0, 0, -3))

		wait(0.01)
	end
end



--// Slimes
function MonsterVFX:SlimeShot(blast: Model, char: Model)
	self:FullWait(blast)

	if not blast:FindFirstChild("Shot") then return end

	blast.Shot.Part.Color = blast:GetAttribute("SlimeColor")
	TS:Create(blast.Base, AssetBook.TweenInfos.twiceHalf, { Size = v3New(4, 1, 4) }):Play()

	local length = (char.PrimaryPart.Position - blast.Base.Position).Magnitude
	local radius = (char.PrimaryPart.Position - blast.Shot.Base.Position).Magnitude
	local angle = sinh((length / 2) / radius)

	blast.Shot:PivotTo(cfNew(char.PrimaryPart.Position, blast.Base.Position) * cfNew(0,0,-length/2))
	blast.Shot.Part.CFrame *= cfNew(0, radius / 2.5, 0)
	blast.Shot:PivotTo(blast.Shot.Base.CFrame * cfAngles(angle,0,0))

	local rotatingangle = angle * 2 /10
	for i = 1,10 do
		wait(0.01)
		if not blast:FindFirstChild("Shot") then return end

		blast.Shot:PivotTo(blast.Shot.Base.CFrame * cfAngles(-rotatingangle,0,0))
	end
	blast.Shot:Destroy()
end

function MonsterVFX:SlimeWave(blast: Model)
	self:FullWait(blast)

	for i = 1, 5 do
		if not blast:FindFirstChild("Position"..i) then continue end

		TS:Create(blast["Position"..i], AssetBook.TweenInfos.twiceHalf, { Size = v3New(4, 1, 4) }):Play()
	end
end

function MonsterVFX:SlimeBlast(blast: Model)
	self:FullWait(blast)

	local centerCFrame = blast.BlastCenter.CFrame :: CFrame
	local cframe1, cframe2, cframe3, cframe4 =
		blast.Blast1.CFrame :: CFrame,
		blast.Blast2.CFrame :: CFrame,
		blast.Blast3.CFrame :: CFrame,
		blast.Blast4.CFrame :: CFrame
	local cframeArray = { [1] = cframe1, [2] = cframe2, [3] = cframe3, [4] = cframe4 }

	for i = 1, 4 do
		wait(0.01)
		if not blast:FindFirstChild("BlastCenter") then return end

		blast.BlastCenter.Size += v3New(0, 10, 0)
		blast.BlastCenter.CFrame = centerCFrame
		blast.BlastCenter.Transparency += 0.05

		for j = 1, 4 do
			blast["Blast" .. j].Size += v3New(0, random(5, 7), 0)
			blast["Blast" .. j].CFrame = cframeArray[j]
			blast["Blast" .. j].Transparency += 0.05
		end
	end
	for i = 1, 4 do
		wait(0.01)
		if not blast:FindFirstChild("BlastCenter") then return end

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

function MonsterVFX:SlimeBlastFade(blast: Model)
	for _, child in blast:GetChildren() do
		if child:IsA("BasePart") then
			TS:Create(child, AssetBook.TweenInfos.one, { Size = v3New() }):Play()
		end
	end
end

function MonsterVFX:SlimeDive(blast: Model)
	self:FullWait(blast)

	for i = 1, 2 do
		local size = if i == 1 then v3New(20, 1, 20) else v3New(4, 1, 4)

		TS:Create(blast["Position" .. i], AssetBook.TweenInfos.twiceHalf, { Size = size }):Play()
	end
end

function MonsterVFX:SlimeBomb(blast: Model)
	self:FullWait(blast)

	TS:Create(blast.Bomb1, AssetBook.TweenInfos.twiceHalf, { Size = v3New(16, 16, 16) }):Play()
	TS:Create(blast.Bomb2, AssetBook.TweenInfos.twiceHalf, { Size = v3New(22, 26, 26) }):Play()
	TS:Create(blast.Bomb1, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
	TS:Create(blast.Bomb2, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
end

function MonsterVFX:SlimeSpin(blast: Model)
	self:FullWait(blast)

	TS:Create(blast.Blast1, AssetBook.TweenInfos.twiceHalf, { Size = v3New(16, 16, 16) }):Play()
	TS:Create(blast.Blast2, AssetBook.TweenInfos.twiceHalf, { Size = v3New(22, 26, 26) }):Play()
	TS:Create(blast.Blast1, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
	TS:Create(blast.Blast2, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()
end

return function()
	local self = setmetatable({}, MonsterVFX)

	local function _vfxHandler(blast)
		wait()
		local style = blast.Name

		if style == "SpikeWolfSpike1" then
			self:Spike1(blast)

		elseif style == "SpikeWolfSpike2" then
			self:SpikeRain(blast)

		elseif style == "SpikeWolf2Range" then
			self:Spike2Range(blast)

		elseif style == "SpikeWolf4" then
			self:WolfBite(blast)

		elseif style == "Slime1" then
			wait(0.3)
			self:SlimeShot(blast, blast.Owner.Value)

		elseif style == "Slime2" then
			wait(0.5)
			self:SlimeWave(blast)

		elseif style == "SlimeBlast" then
			self:SlimeBlast(blast)

			wait(8)
			self:SlimeBlastFade(blast)
		end
	end
	local function _firstWait(folder: Folder)
		wait()
		if not folder:IsA("Folder") then return end

		folder.ChildAdded:Connect(_vfxHandler)
	end
	workspace:WaitForChild("MapComponents").CombatFolders.ChildAdded:Connect(_firstWait)
end
