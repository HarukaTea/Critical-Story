--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local wait = task.wait
local fromRGB = Color3.fromRGB

local ITEM_ATTRIBUTES = { CD = 12, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.Magic2 })
Events.PlayAnimation.Fire(plr, { AnimId = "MagicCastedAnim1" })

local mark = RepS.Package.MagicAssets.ArcaneMark:Clone() :: BasePart
mark.CFrame = monster.PrimaryPart.CFrame
mark.Parent = workspace
Debris:AddItem(mark, 3)

local radius = (mark.Size.X + mark.Size.Z)/4
for _ = 1, 5 do
	local success, errorMsg = pcall(function()
		if (mark.Position - monster.PrimaryPart.Position).Magnitude <= radius then
			local dmg = char:GetAttribute("Magic") :: number

			ServerUtil:ShowNumber(monster, dmg, fromRGB(85, 255, 255))
			HarukaLib:AddAttr(monster, "Health", -dmg)
		end

		mark.Transparency = 0.4
		Events.ClientTween.FireAll({ Objs = { mark }, Goal = { Transparency = 0.9 }, TweenInfo = "threeHalf" })

		wait(0.35)
	end)

	if not success and RS:IsStudio() then warn(errorMsg) end
end
Events.ClientTween.FireAll({ Objs = { mark }, Goal = { Transparency = 1 }, TweenInfo = "half" })
