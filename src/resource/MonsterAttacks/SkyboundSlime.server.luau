local char = script.Parent

function lookat(target)
	char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
	char.HumanoidRootPart.Orientation = char.HumanoidRootPart.Orientation * Vector3.new(0, 1, 1)
end
function attacking()
	if script.Parent.CanAttack.Value == true then
		wait(1)
		if char.TargetPlayers:FindFirstChildOfClass("ObjectValue") then
			local list = char.TargetPlayers:GetChildren()
			local target = list[math.random(1, #list)]

			local attackrandom = math.random(1, 3)

			if attackrandom == 1 or attackrandom == 2 then
				local comborandom = math.random(1, 2)
				if comborandom == 1 then
					slimecirculate(target.Value)
					wait(0.5)
				end
				for q = 1, math.random(2, 3) do
					lookat(target.Value)
					slimerepulseblast(target.Value)
					wait(0.5)
				end
			end
			if attackrandom == 3 then
				for i = 1, math.random(1, 3) do
					slimecirculatedash(target.Value)
				end
			end
			attacking()
		end
	else
		repeat
			wait(0.5)
		until script.Parent.CanAttack.Value == true
		if script.Parent.CanAttack.Value == true then
			attacking()
		end
	end
end

function slimerepulseblast(target)
	if game.Workspace:FindFirstChild(target.Name) then
		local blast = game.ReplicatedStorage.Package.MonsterAttacks.ArkusMonsters.SkyboundSlime1:Clone()
		blast.Target.Value = target
		blast.Owner.Value = char
		blast.Part.CFrame = char.HumanoidRootPart.CFrame
		blast.Parent = char.Holder.Value
	end
end

function slimecirculate(target)
	if game.Workspace:FindFirstChild(target.Name) then
		lookat(target)
		local Angle = 45 + 90
		for i = 1, 3 do
			local blast = game.ReplicatedStorage.Package.MonsterAttacks.ArkusMonsters.SkyboundSlimeCirculate:Clone()
			blast.Owner.Value = char
			blast.Target.Value = target
			blast:SetPrimaryPartCFrame(char.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, Angle, 0))
			blast.Parent = char.Holder.Value
			Angle = Angle - 45
		end
		Angle = 265 - 90
		lookat(target)
		for i = 1, 3 do
			local blast = game.ReplicatedStorage.Package.MonsterAttacks.ArkusMonsters.SkyboundSlimeCirculate:Clone()
			blast.Owner.Value = char
			blast.Target.Value = target
			blast:SetPrimaryPartCFrame(char.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, Angle, 0))
			blast.Parent = char.Holder.Value
			Angle = Angle - 45
		end
	end
end

function slimecirculatedash(target)
	if game.Workspace:FindFirstChild(target.Name) then
		for i = 1, 3 do
			local post = char.Parent.Position + Vector3.new(math.random(-32, 32), 0, math.random(-32, 32))
			--char:SetPrimaryPartCFrame(CFrame.new(post,post+target.HumanoidRootPart.CFrame.lookVector)*CFrame.new(0,1.5,0)*CFrame.Angles(0,math.random(1,360)*math.pi/180,0)*CFrame.new(0,0,math.random(20,24)))
			char:SetPrimaryPartCFrame(CFrame.new(post))
			char:SetPrimaryPartCFrame(CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position))

			local Angle = 60 + 90
			for i = 1, 2 do
				local blast = game.ReplicatedStorage.Package.MonsterAttacks.ArkusMonsters.SkyboundSlimeCirculate:Clone()
				blast.Owner.Value = char
				blast.Target.Value = target
				blast:SetPrimaryPartCFrame(char.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, Angle, 0))
				blast.Parent = char.Holder.Value
				Angle = Angle - 120
			end
			Angle = 280 - 90
			lookat(target)
			for i = 1, 2 do
				local blast = game.ReplicatedStorage.Package.MonsterAttacks.ArkusMonsters.SkyboundSlimeCirculate:Clone()
				blast.Owner.Value = char
				blast.Target.Value = target
				blast:SetPrimaryPartCFrame(char.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, Angle, 0))
				blast.Parent = char.Holder.Value
				Angle = Angle - 120
			end
			wait(0.5)
		end
	end
end

wait(0.5)
attacking()
