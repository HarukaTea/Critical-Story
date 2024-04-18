--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local wait = task.wait
local fromRGB = Color3.fromRGB

local ITEM_ATTRIBUTES = { CD = 10, MANA_REQ = 600, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic2)
Events.MagicCasted:Fire(plr)

local mark = RepS.Package.MagicAssets.ArcaneMark:Clone() :: BasePart
mark.CFrame = monster.PrimaryPart.CFrame
mark.Parent = char
Debris:AddItem(mark, 0.4)

local radius = (mark.Size.X + mark.Size.Z)/4
for i = 1,5 do
	if not monster or not monster.PrimaryPart then break end

	if (mark.Position - monster.PrimaryPart.Position).Magnitude <= radius then
		local dmg = char:GetAttribute("Magic") :: number

		ServerUtil:ShowNumber(monster, dmg, fromRGB(85, 255, 255))

		HarukaLib:Add(monster, "Health", -dmg)
	end

	mark.Transparency = 0.4
	Events.ClientTween:Fires({ mark }, { Transparency = 0.9 }, "threeHalf")

	wait(0.35)
end
Events.ClientTween:Fires({ mark }, { Transparency = 1 }, "half")
