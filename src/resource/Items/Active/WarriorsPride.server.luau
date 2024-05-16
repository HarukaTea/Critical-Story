--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local wait = task.wait
local fromRGB = Color3.fromRGB
local instanceNew = Instance.new
local cfNew = CFrame.new
local v3New = Vector3.new
local floor = math.floor

local ITEM_ATTRIBUTES = { CD = 12, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.KnifeKill)
Events.PlayAnimation:Fire(plr, "MagicCastedAnim1")

local pride = RepS.Package.MagicAssets.WarriorBlast:Clone() :: UnionOperation
pride.CFrame = char.PrimaryPart.CFrame
pride.CFrame = cfNew(pride.Position, monster.PrimaryPart.Position)
pride.Parent = workspace
Debris:AddItem(pride, 5)

local bv = instanceNew("BodyVelocity")
bv.MaxForce = v3New(math.huge, math.huge, math.huge)
bv.Velocity = pride.CFrame.LookVector * 150
bv.Parent = pride

--- select target
local hit = false
local success, errorMsg = pcall(function()
	while wait(0.01) do
		if hit then break end

		if (pride.Position - monster.PrimaryPart.Position).Magnitude <= 3 then
			hit = true

			BuffEffectsUtil:MagicVFX(monster)
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic1)

			pride:Destroy()

			local dmg = floor(char:GetAttribute("MaxDMG") * 4) :: number

			ServerUtil:ShowNumber(monster, dmg, fromRGB(255, 0, 127))

			HarukaLib:Add(monster, "Health", -dmg)
		end
	end
end)
if not success and RS:IsStudio() then warn(errorMsg) end
