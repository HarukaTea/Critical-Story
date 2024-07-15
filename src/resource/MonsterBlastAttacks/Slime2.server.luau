--!nocheck

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(ReplicatedStorage.Modules.Data.AssetBook)
local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local model = script.Parent :: Model
local char = model.Owner.Value :: Model

local wait = task.wait
local v3New = Vector3.new
local cfNew = CFrame.new

pcall(function()
	Debris:AddItem(model, 1.2)

	--- clear far projectiles
	local max = 5
	for i = 1, 5 do
		for _, child: BasePart in model:GetDescendants() do
			if child.Name ~= "Position"..i then continue end

			if (child.Position - char.Parent.Position).Magnitude >= 46 then
				child:Destroy()
				max -= 1
			end
		end
	end

	--- spawn projectiles
	wait(0.5)
	for i = 1, max do
		for _, child: BasePart in model:GetDescendants() do
			if child.Name == "Position"..i then
				local post = ServerUtil:FindPartOnRay(child.Position + v3New(0, 10, 0), { model })

				Spawn(function()
					local blast = model.Projectile.Value:Clone()
					blast.Owner.Value = model.Owner.Value
					blast:PivotTo(cfNew(post, post + child.CFrame.LookVector) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0))
					blast:SetAttribute("SlimeWaveProjectile", true)

					if i == max then
						HarukaLib:Tween(char, AssetBook.TweenInfos.twiceHalfOne, { Pivot = blast.Base.CFrame * cfNew(0, char.PrimaryPart.Size.Y / 2, 0) })
					end

					wait(0.1 * i)
					blast.Parent = char.AttackHolder.Value

					for _, descendant: BasePart in blast:GetDescendants() do
						if descendant:IsA("BasePart") then descendant.Color = model:GetAttribute("SlimeColor") end
					end

					Debris:AddItem(blast, 10)
					child:Destroy()
				end)
			end
		end
	end
end)

