--!nocheck


local SSS = game:GetService("ServerScriptService")
local RepS = game:GetService("ReplicatedStorage")

local ServerUtil = require(SSS.Utils.ServerUtil)

local styles = {"LurkerDive1", "LurkerDive2"}

local char = script.Parent

local wait = task.wait

function lookAt(target)
	char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
	char.HumanoidRootPart.Orientation = char.HumanoidRootPart.Orientation*Vector3.new(0,1,1)
end

function attacking()
	wait(0.1)
	if char.TargetingList:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetingList:GetChildren()
		local target = list[math.random(1, #list)]

		local style = styles[math.random(1,2)]
		if style == "LurkerDive1" then
			slimedive1(target.Value)

			char:SetAttribute("CantAttack", true)

			wait(0.1)
			slimedive2(target.Value)
			char:SetAttribute("CantAttack", nil)

			for i = 1,6 do
				slimedive2(target.Value)
				wait(0.01)
			end

		elseif style == "LurkerDive2" then
			for i = 1,3 do
				lookAt(target.Value)
				slimedive2(target.Value)
				wait(0.1)
			end

			slimedive1(target.Value)

			char:SetAttribute("CantAttack", true)

			wait(0.1)
			slimedive2(target.Value)

			char:SetAttribute("CantAttack", nil)

			wait(0.1)
		end
		attacking()
	end
end

function slimedive1(target)
	local post = ServerUtil:findPartOnRay(char.HumanoidRootPart.Position, char)

	local blast = RepS.Package.EnemyAttacks.IceMonster.LurkerDive:Clone()
	blast.Owner.Value = char
	blast:PivotTo(CFrame.new(post,post+char.HumanoidRootPart.CFrame.LookVector))
	blast.Parent = char.Holder.Value

	char.HumanoidRootPart.CFrame = blast.Base.CFrame*CFrame.new(0,-8,0)

	local divedown = blast.Base.CFrame*CFrame.new(0,-4,0)
	wait(0.5)
	char.HumanoidRootPart.CFrame = divedown
end

function slimedive2(target)
	local post = ServerUtil:findPartOnRay(target.HumanoidRootPart.Position, target)

	local blast = RepS.Package.EnemyAttacks.IceMonster.LurkerDive:Clone()
	blast.Owner.Value = char
	blast:SetPrimaryPartCFrame(CFrame.new(post,post+target.HumanoidRootPart.CFrame.LookVector))
	blast.Parent = char.Holder.Value

	char.HumanoidRootPart.CFrame = blast.Base.CFrame*CFrame.new(0,-8,0)

	local diveup = blast.Base.CFrame*CFrame.new(0,char.HumanoidRootPart.Size.Y/2,0)
	wait(0.5)
	char.HumanoidRootPart.CFrame = diveup
end

wait(0.5)
attacking()