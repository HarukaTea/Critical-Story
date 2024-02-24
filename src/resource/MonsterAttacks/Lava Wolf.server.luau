--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model

local wait = task.wait
local v3New = Vector3.new
local random, rad = math.random, math.rad
local cfNew, cfLookat, cfAngles = CFrame.new, CFrame.lookAt, CFrame.Angles
local insert = table.insert

--// Boss fights then
char:SetAttribute("Stage", 1)
Spawn(function()
	repeat wait() until char:GetAttribute("Stage") > 1

	local combatPlrs = {}
	for _, target in char.TargetingList:GetChildren() do
		local tempPlr = Players:GetPlayerFromCharacter(target.Value)

		if tempPlr then insert(combatPlrs, tempPlr) end
	end

	for _, plr in combatPlrs do
		Events.PlaySound:Fire(plr, "StopAll")
		Events.PlaySound:Fire(plr, workspace.Sounds.Aokana2)
	end

	for _, descendant in char:GetDescendants() do
		if descendant.Name == "LavaThorn" then descendant.Transparency = 0 end
	end

	wait(3)
	char:SetAttribute("CantAttack", nil)
end)

local function lookAt(target: Model)
	local pos, pos2 = target.PrimaryPart.Position, char.PrimaryPart.Position :: Vector3
	local x, y, z = cfLookat(pos2, pos):ToOrientation()

	char.PrimaryPart.CFrame = cfNew(pos2) * cfAngles(0, y, 0)
	return pos, pos2, y
end
local function moving(target: Model)
	local post = ServerUtil:FindPartOnRay(char.Parent.Position + v3New(random(-32,32), 0, random(-32,32)), { target })

	char:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(0, 1.5, 0))
	char:PivotTo(cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position))
	char.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function spikeShot(target: Model)
	lookAt(target)

	local blast: Model
	if char:GetAttribute("Stage") == 1 then
		blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolf1:Clone()
	else
		blast = RepS.Package.MonsterAttacks.Wolf.LavaWolf1:Clone()
	end
	blast.Owner.Value = char
	blast:PivotTo(char.PrimaryPart.CFrame)

	blast.Parent = char.Holder.Value

	if char.Head:FindFirstChild("Encountered") then return end

	local attention = RepS.Package.Effects.Encountered:Clone() :: BillboardGui
	attention.Parent = char.Head

	Debris:AddItem(attention, 1.2)
end

local function spikeRain(target: Model)
	lookAt(target)

	local rangePos = ServerUtil:FindPartOnRay(
		target.PrimaryPart.Position + v3New(random(-15, 15), 10, random(-15, 15)),
		{ target, char }
	)

	local rangeTip = RepS.Package.MonsterAttacks.Wolf.SpikeWolf2Range:Clone() :: Part
	rangeTip.Position = rangePos
	rangeTip.Owner.Value = char
	rangeTip.Parent = char.Holder.Value

	Debris:AddItem(rangeTip, 1)

	for _ = 1, random(5, 6) do
		local post = ServerUtil:FindPartOnRay(
			rangePos + v3New(random(-15, 15), 10, random(-15, 15)),
			{ target, char, rangeTip }
		)

		local blast: Model
		if char:GetAttribute("Stage") == 1 then
			blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolfSpike2:Clone()
		else
			blast = RepS.Package.MonsterAttacks.Wolf.LavaWolfSpike2:Clone()
		end
		blast:PivotTo(cfNew(post, post + blast.Base.CFrame.LookVector))
		blast:PivotTo(cfNew(post) * cfAngles(0, rad(random(1, 360)), 0))
		blast.Owner.Value = char

		blast.Parent = char.Holder.Value

		Debris:AddItem(blast, 10)
	end
end

local function bite(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	char:PivotTo(cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position))
	char.PrimaryPart.Orientation *= v3New(0, 1, 1)

	local blast: Model
	if char:GetAttribute("Stage") == 1 then
		blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolf4:Clone()
	else
		blast = RepS.Package.MonsterAttacks.Wolf.LavaWolf4:Clone()
	end
	blast.Owner.Value = char
	blast:PivotTo(cfNew(post,post+target.PrimaryPart.CFrame.LookVector) * cfNew(0, 3 ,0))
	blast:PivotTo(cfNew(blast.Base.Position, char.PrimaryPart.Position))

	blast.Parent = char.Holder.Value
end

local function attacking()
	wait(0.1)
	if char.TargetingList:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetingList:GetChildren()
		local target = list[math.random(1, #list)]

		local style = random(1, 3)

		if style == 1 then
			for i = 1, random(2, 3) do
				moving(target.Value)
				wait(0.1)
			end
			wait(0.1)
			for i = 1, random(2, 3) do
				spikeShot(target.Value)
				wait(0.1)
			end
			wait(0.1)
			if random(1, 2) == 1 then
				spikeRain(target.Value)
				wait(0.1)
			end

		elseif style == 2 then
			for i = 1, random(2, 3) do
				moving(target.Value)
				wait(0.1)
			end
			wait(0.1)
			for i = 1, random(2, 3) do
				spikeRain(target.Value)
				wait(0.1)
			end

		elseif style == 3 then
			for i = 1, random(2, 3) do
				moving(target.Value)
				wait(0.1)
			end

			wait(0.1)
			for i = 1, random(2, 4) do
				bite(target.Value)
				wait(0.1)
			end
		end

		attacking()
	end
end

wait(0.3)
attacking()
