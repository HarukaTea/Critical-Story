--!strict
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local ServerUtil = require(game:GetService("ServerScriptService").Modules.Utils.ServerUtil)

local char = script.Parent :: Model

local wait = task.wait
local cfNew = CFrame.new
local random = math.random
local v3New = Vector3.new
local fromRGB = Color3.fromRGB

local SLIME_COLOR = fromRGB(0, 76, 176)

local function lookAt(target: Model)
	char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position)
	char.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function slimeShot(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	local blast = RepS.Package.MonsterAttacks.Slime.Slime1:Clone() :: Model
	blast.Owner.Value = char
	blast:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector))
	blast:SetAttribute("SlimeColor", SLIME_COLOR)
	blast.Parent = char.Holder.Value
end

local function slimeWave(target: Model)
	lookAt(target)
	local post = ServerUtil:FindPartOnRay(char.PrimaryPart.Position, { target })

	local blast = RepS.Package.MonsterAttacks.Slime.Slime2:Clone() :: Model
	blast.Owner.Value = char
	blast:PivotTo(cfNew(post, post + char.PrimaryPart.CFrame.LookVector))
	blast:SetAttribute("SlimeColor", SLIME_COLOR)
	blast.Parent = char.Holder.Value
end

local function slimeDiveDown(target: Model)
	local post = ServerUtil:FindPartOnRay(char.PrimaryPart.Position, { target })

	local blast = RepS.Package.MonsterAttacks.Slime.Slime3:Clone() :: Model
	blast.Owner.Value = char
	blast:PivotTo(cfNew(post, post + char.PrimaryPart.CFrame.LookVector))
	blast:SetAttribute("SlimeColor", SLIME_COLOR)
	blast.Parent = char.Holder.Value

	local divedown = blast.Base.CFrame * cfNew(0,-8,0)
	wait(0.5)
	char.PrimaryPart.CFrame = divedown
end

local function slimeDiveUp(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	local blast = RepS.Package.MonsterAttacks.Slime.Slime3:Clone() :: Model
	blast.Owner.Value = char
	blast:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector))
	blast:SetAttribute("SlimeColor", SLIME_COLOR)
	blast.Parent = char.Holder.Value
	char.PrimaryPart.CFrame = blast.Base.CFrame * cfNew(0,-8,0)

	local diveup = blast.Base.CFrame * cfNew(0, char.PrimaryPart.Size.Y/2, 0)

	wait(0.5)
	char.PrimaryPart.CFrame = diveup
end

local function slimeBarrage(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	local blast = RepS.Package.MonsterAttacks.Slime.Slime1:Clone() :: Model
	blast.Owner.Value = char
	blast:PivotTo(cfNew(post,post+target.PrimaryPart.CFrame.LookVector))
	blast:SetAttribute("SlimeColor", SLIME_COLOR)
	blast.Parent = char.Holder.Value

	for i = 1, random(3, 5) do
		local postR = ServerUtil:FindPartOnRay(char.Parent.Position + v3New(random(-32,32), 20, random(-32,32)), { target })

		local blastR = RepS.Package.MonsterAttacks.Slime.Slime1:Clone() :: Model
		blastR.Owner.Value = char
		blastR:PivotTo(cfNew(postR, postR + target.PrimaryPart.CFrame.LookVector))
		blastR:SetAttribute("SlimeColor", SLIME_COLOR)
		blastR.Parent = char.Holder.Value
	end

	wait(0.5)
	lookAt(target)

	local blastS = RepS.Package.MonsterAttacks.Slime.SlimeSpin:Clone() :: Model
	blastS.Owner.Value = char
	blastS:PivotTo(char.PrimaryPart.CFrame)
	blastS:SetAttribute("SlimeColor", SLIME_COLOR)
	blastS.Parent = char.Holder.Value

	char.PrimaryPart.CFrame *= cfNew(0,0,-2.5)
end

local function attacking()
	wait(1)
	if char.TargetingList:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetingList:GetChildren()
		local target = list[random(1, #list)] :: ObjectValue

		local style = random(1, 4)

		if style == 1 then
			if random(1, 2) == 1 then
				slimeWave(target.Value)
				wait(0.5)
			end

			for q = 1, random(2, 3) do
				lookAt(target.Value)

				for i = 1, 3 do
					slimeShot(target.Value)
					wait(0.2)
				end
				wait(0.5)
			end

		elseif style == 2 then
			for i = 1, random(1, 3) do
				slimeWave(target.Value)
				wait(0.8)
			end

        elseif style == 3 then
            slimeDiveDown(target.Value)

            char:SetAttribute("CantAttack", true)

            wait(1)
            slimeDiveUp(target.Value)
            char:SetAttribute("CantAttack", nil)

        elseif style == 4 then
            for i = 1, random(2,4) do
                slimeBarrage(target.Value)
                wait(0.4)
            end
		end

		attacking()
	end
end

wait(0.5)
attacking()
