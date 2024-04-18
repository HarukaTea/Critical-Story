--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local wait = task.wait
local fromRGB = Color3.fromRGB
local instanceNew = Instance.new
local cfNew, cfAngles = CFrame.new, CFrame.Angles
local v3New = Vector3.new
local random, rad = math.random, math.rad

local ITEM_ATTRIBUTES = { CD = 7, MANA_REQ = 300, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic2)
Events.MagicCasted:Fire(plr)

local chain = RepS.Package.MagicAssets.DarkChain.ChainPart:Clone() :: BasePart
chain.CFrame = plr.Character["Right Arm"].CFrame
chain.CFrame = cfNew(chain.Position, monster.PrimaryPart.Position)
chain.Parent = plr.Character

local beam = RepS.Package.MagicAssets.DarkChain.Beam:Clone() :: Beam
beam.Parent = plr.Character
local att0, att1 = instanceNew("Attachment"), instanceNew("Attachment")
beam.Attachment0 = att0
beam.Attachment1 = att1
att0.Parent = chain
att1.Parent = monster.PrimaryPart

local bv = instanceNew("BodyVelocity")
bv.MaxForce = v3New(math.huge, math.huge, math.huge)
bv.Velocity = chain.CFrame.LookVector * 100

Spawn(function()
	while wait() do
		if chain then
			if monster and monster.Parent then
				if (chain.Position - monster.Parent.Position).Magnitude >= 46 then
					local temp = instanceNew("Part")
					temp.Anchored = true
					temp.Transparency = 1
					temp.CFrame = chain.CFrame
					temp.Parent = plr.Character

					Debris:AddItem(temp, 0.2)
				end
			end

			if not monster.PrimaryPart or not monster.Parent then
				chain:Destroy()
				beam:Destroy()
				att0:Destroy()
				att1:Destroy()
			end
		end
	end
end)

chain.Touched:Connect(function(hit)
	if hit and not hit:IsDescendantOf(plr.Character) and not hit.Parent:HasTag("MonsterAttack") and not hit.Parent:FindFirstChild("Owner") then
		chain.Anchored = true

		local pullBv = instanceNew("BodyVelocity")
		pullBv.MaxForce = v3New(math.huge, math.huge, math.huge)
		pullBv.Velocity = chain.CFrame.LookVector * 100 + plr.Character.PrimaryPart.CFrame.UpVector * 50
		pullBv.Parent = plr.Character.PrimaryPart
		Debris:AddItem(pullBv, 0.05)

		if hit.Parent == monster or hit.Parent.Parent == monster then
			local enemyCFrame = monster.PrimaryPart.CFrame

			Spawn(function()
				for i = 1,2 do
					if monster.PrimaryPart then
						local slash = RepS.Package.MagicAssets.DarkChain.SlashEff:Clone() :: BasePart
						slash.Parent = plr.Character

						local mesh = instanceNew("FileMesh", slash)
						mesh.Scale = v3New(0.11,0.99,0.11) * (random(100,130)/100)
						mesh.Offset = v3New(-6.5 + mesh.Scale.X * 9, 0, 0)
						mesh.MeshId = "rbxassetid://540445680"

						slash.CFrame = enemyCFrame * cfAngles(random(-360,360)*rad(1), random(-360,360)*rad(1), random(-360,360)*rad(1))

						Spawn(function()
							local randomX = random(0,10)
							for j = 1, 12 do
								wait()
								slash.Transparency = 0.4
								slash.Transparency = 0.1 + i/(20/(1 - 0.1))
								slash.CFrame = slash.CFrame * cfAngles(0, rad(25 + randomX), 0)
							end
							slash:Destroy()
						end)
					end
				end
			end)
		end

		local dmg1 = char:GetAttribute("MaxDMG") :: number
		local dmg2 = char:GetAttribute("Magic") :: number

		ServerUtil:ShowNumber(monster, dmg1, fromRGB(255, 0, 0))
		ServerUtil:ShowNumber(monster, dmg2, fromRGB(170, 170, 255))

		HarukaLib:Add(monster, "Health", -dmg1)
		HarukaLib:Add(monster, "Health", -dmg2)

		chain:Destroy()
		att0:Destroy()
		att1:Destroy()
		beam:Destroy()
	end
end)
