--!nocheck
--!optimize 2
--!native


local RepS = game:GetService("ReplicatedStorage")

local ServerUtil = require(game:GetService("ServerScriptService").Utils.ServerUtil)

local char = script.Parent

local wait = task.wait

function lookAt(target)
	char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
	char.HumanoidRootPart.Orientation = char.HumanoidRootPart.Orientation*Vector3.new(0,1,1)
end

function attacking()
	if char.TargetingList:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetingList:GetChildren()
		local target = list[math.random(1, #list)]

		local style = ServerUtil.enemyAttacksChanceList.SkyboundSlime:GetRandomLoot()
		if style == "SlimeCirculate" then
			slimeCirculate(target.Value)
			wait(0.5)

		elseif style == "SlimeRepulseBlast" then
			lookAt(target.Value)

			slimeRepulseBlast(target.Value)
			wait(0.5)

		elseif style == "SlimeCirculateDash" then
			for i = 1,math.random(1,3) do
				slimeCirculateDash(target.Value)
			end
		end

		attacking()
	end
end

function slimeRepulseBlast(target)
	local blast = RepS.Package.EnemyAttacks.Slime.SkyboundSlime1:Clone()
	blast.Target.Value = target
	blast.Owner.Value = char
	blast.Part.CFrame = char.HumanoidRootPart.CFrame
	blast.Parent = char.Holder.Value
end

function slimeCirculate(target)
	lookAt(target)
	local angle = 135

	for i = 1,3 do
		local blast = RepS.Package.EnemyAttacks.Slime.SkyboundSlimeCirculate:Clone()
		blast.Owner.Value = char
		blast.Target.Value = target
		blast:PivotTo(char.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0,angle,0))
		blast.Parent = char.Holder.Value

		angle -= 45
	end
	angle = 175

	lookAt(target)
	for i = 1,3 do
		local blast = RepS.Package.EnemyAttacks.Slime.SkyboundSlimeCirculate:Clone()
		blast.Owner.Value = char
		blast.Target.Value = target
		blast:PivotTo(char.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0,angle,0))
		blast.Parent = char.Holder.Value

		angle -= 45
	end
end

function slimeCirculateDash(target)
	for i = 1,3 do
		local post = ServerUtil:findPartOnRay(char.InitialPos.Value + Vector3.new(math.random(-32,32), 0, math.random(-32,32)), char)

		char:PivotTo(CFrame.new(post))
		char:PivotTo(CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position))

		local angle = 150
		for i = 1,2 do
			local blast = RepS.Package.EnemyAttacks.Slime.SkyboundSlimeCirculate:Clone()
			blast.Owner.Value = char
			blast.Target.Value = target
			blast:PivotTo(char.HumanoidRootPart.CFrame*CFrame.fromEulerAnglesXYZ(0,angle,0))
			blast.Parent = char.Holder.Value

			angle -= 120
		end

		angle = 190
		lookAt(target)

		for i = 1,2 do
			local blast = RepS.Package.EnemyAttacks.Slime.SkyboundSlimeCirculate:Clone()
			blast.Owner.Value = char
			blast.Target.Value = target
			blast:PivotTo(char.HumanoidRootPart.CFrame*CFrame.fromEulerAnglesXYZ(0,angle,0))
			blast.Parent = char.Holder.Value

			angle -= 120
		end
		wait(0.5)
	end
end

wait(0.5)
attacking()