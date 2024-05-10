--!nocheck
--!optimize 2
--!native


local RepS = game:GetService("ReplicatedStorage")

local ServerUtil = require(game:GetService("ServerScriptService").Utils.ServerUtil)

local char = script.Parent
local animController = char.AnimationController
local animTrack2 = animController:LoadAnimation(script.Spin)

local wait = task.wait

char.HumanoidRootPart.CFrame *= CFrame.new(0,7,0)

function lookAt(target)
	char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
	char.HumanoidRootPart.Orientation = char.HumanoidRootPart.Orientation*Vector3.new(0,1,1)
end

function attacking()
	wait(1)
	if char.TargetingList:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetingList:GetChildren()
		local target = list[math.random(1, #list)]

		local style = ServerUtil.enemyAttacksChanceList.Overseer:GetRandomLoot()
		if style == "OverseerBarrage" then
			overseerBarrage(target.Value)

			lookAt(target.Value)
			char:SetAttribute("CantAttack", true)

			wait(1)
			overseerBarrage(target.Value)

			lookAt(target.Value)
			char:SetAttribute("CantAttack", nil)

		elseif style == "OverseerBlast" then
			lookAt(target.Value)
			for i = 1,6 do
				overseerBlast(target.Value)
				wait(0.02)
			end
			wait(0.5)

		elseif style == "OverseerClap" then
			overseerClap(target.Value)

			lookAt(target.Value)
			char:SetAttribute("CantAttack", true)

			wait(1)
			overseerClap(target.Value)

			lookAt(target.Value)
			char:SetAttribute("CantAttack", nil)
		end

		attacking()
	end
end

function overseerBarrage(target)
	char:PivotTo(CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position))

	local blast = RepS.Package.EnemyAttacks.IceMonster.Overseer2:Clone()
	blast.Owner.Value = char
	blast:PivotTo(char.HumanoidRootPart.CFrame)
	blast.Parent = char.Holder.Value
end


function overseerBlast(target)
	local post = ServerUtil:findPartOnRay(target.HumanoidRootPart.Position, target)

	local blast = RepS.Package.EnemyAttacks.IceMonster.Overseer1:Clone()
	blast.Owner.Value = char
	blast:PivotTo(CFrame.new(post,post+target.HumanoidRootPart.CFrame.LookVector)*CFrame.new(math.random(-10,10),0,math.random(-10,10)))
	blast.Parent = char.Holder.Value
end

function overseerClap(target)

	local post = ServerUtil:findPartOnRay(target.HumanoidRootPart.Position, target)

	local rotatingpart = Instance.new("Part")
	rotatingpart.Transparency = 1
	rotatingpart.Anchored = true
	rotatingpart.CanCollide = false
	char:PivotTo(CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position))
	rotatingpart.CFrame = char.HumanoidRootPart.CFrame
	rotatingpart.Orientation = char.HumanoidRootPart.Orientation*Vector3.new(0,1,1)
	rotatingpart.Parent = workspace
	char:PivotTo(rotatingpart.CFrame)

	local blast = RepS.Package.EnemyAttacks.IceMonster.OverseerClap:Clone()
	blast.Owner.Value = char
	blast:PivotTo(CFrame.new(post,post+target.HumanoidRootPart.CFrame.lookVector)*CFrame.new(0,3,0))
	blast:PivotTo(CFrame.new(blast.Base.Position, char.HumanoidRootPart.Position))
	rotatingpart.CFrame = blast.Base.CFrame
	rotatingpart.Orientation = blast.Base.Orientation*Vector3.new(0,1,1)
	rotatingpart:Destroy()

	blast:PivotTo(rotatingpart.CFrame*CFrame.Angles(0,math.pi*math.random(-180,180)/180,0))
	blast.Parent = char.Holder.Value
end

wait(0.5)
attacking()