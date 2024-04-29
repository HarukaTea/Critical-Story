--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local ceil, floor = math.ceil, math.floor
local fromRGB = Color3.fromRGB
local v3New = Vector3.new

local SkillUtil = {}

--[[
	Arrow players to restore mana by orbs, magic-class only
]]
function SkillUtil:RestoreTPByOrb(plr: Player)
	local char = plr.Character

	local currentTP = char:GetAttribute("TP") :: number
	if currentTP >= 100 then return end

	HarukaLib:Add(char, "TP", ceil(100 * (char:GetAttribute("RestoreBuff") / 100)))

	local restoreEff = RepS.Package.Effects.RestoreEffect:Clone() :: ParticleEmitter
	restoreEff.Parent = char.PrimaryPart
	Debris:AddItem(restoreEff, 1)
end

--[[
	Restore mana, by script lol
]]
function SkillUtil:RestoreTP(plr: Player, restoreVal: number)
	local char = plr.Character

	HarukaLib:Add(char, "TP", restoreVal)

	local restoreEff = RepS.Package.Effects.RestoreEffect:Clone() :: ParticleEmitter
	restoreEff.Parent = char.PrimaryPart
	Debris:AddItem(restoreEff, 1)
end

--[[
	Mahoushoujiu bruh, I guess so, the power of magic is great
]]
function SkillUtil:MagicVFX(monster: Model)
	local eff = RepS.Package.MagicAssets.Ignited:Clone() :: Part
	eff.CFrame = monster.PrimaryPart.CFrame
	eff.Transparency = 0
	eff.Parent = workspace
	Debris:AddItem(eff, 0.25)

	Events.ClientTween:Fires({ eff }, { Size = v3New(1, 1, 1) * 24, Transparency = 1 }, "twiceHalf")
end

--[[
	Heal health, by active items
]]
function SkillUtil:Heal(plr: Player, healPower: number)
	local char = plr.Character

	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Heal)

	char.Humanoid.Health += floor(char.Humanoid.MaxHealth * healPower)

	local healEff = RepS.Package.Effects.HealEffect:Clone() :: ParticleEmitter
	healEff.Parent = char.PrimaryPart
	Debris:AddItem(healEff, 1)
end

--[[
	Burn dmg, also can be used for players, related to Magic
]]
function SkillUtil:Burn(plr: Player, monster: Model, duration: number, isPlayer: boolean?)
	if plr.Character.Humanoid.Health <= 0 then return end
	if not monster:FindFirstChild("EffectsList") then return end

	local debuff: Script
	if isPlayer then
		debuff = RepS.Resources.Unloads.BurnDMGPlayer:Clone()
		debuff:SetAttribute("Power", 0.5)
		debuff:SetAttribute("Damage", floor(monster:GetAttribute("Damage") / 2))
	else
		debuff = RepS.Resources.Unloads.BurnDMG:Clone()
		debuff:SetAttribute("Damage", floor(plr.Character:GetAttribute("Magic") / 2))
	end
	debuff:SetAttribute("Duration", duration)
	debuff:SetAttribute("Color", fromRGB(255, 85, 0))
	debuff:SetAttribute("Text", "BURN!")
	debuff.Name = "Burn"
	debuff.Parent = if isPlayer then plr.Character.CharStats.EffectsList else monster.EffectsList
end

--[[
	Poison dmg, which is related to DMG
]]
function SkillUtil:Poison(plr: Player, monster: Model, duration: number, isPlayer: boolean?)
	if plr.Character.Humanoid.Health <= 0 then return end
	if not monster:FindFirstChild("EffectsList") then return end

	local debuff: Script
	if isPlayer then
		debuff = RepS.Resources.Unloads.BurnDMGPlayer:Clone()
		debuff:SetAttribute("Power", 0.5)
		debuff:SetAttribute("Damage", floor(monster:GetAttribute("Damage") / 2))
	else
		debuff = RepS.Resources.Unloads.BurnDMG:Clone()
		debuff:SetAttribute("Damage", floor(plr.Character:GetAttribute("MaxDMG") / 2))
	end
	debuff:SetAttribute("Duration", duration)
	debuff:SetAttribute("Color", fromRGB(55, 66, 250))
	debuff:SetAttribute("Text", "POISON!")
	debuff.Name = "Poison"
	debuff.Parent = if isPlayer then plr.Character.CharStats.EffectsList else monster.EffectsList
end

--[[
	Give player attack buff, also can be used for monsters
]]
function SkillUtil:AttackBuff(target: Model | Player, attackPower: number, duration: number, isMob: boolean?)
	if isMob then
		if not target:FindFirstChild("EffectsList") then return end
	else
		if target.Character.Humanoid.Health <= 0 then return end
	end

	local buff: Script
	if isMob then
		buff = RepS.Resources.Unloads.AttackBuffMob:Clone()
	else
		buff = RepS.Resources.Unloads.AttackBuff:Clone()
	end
	buff:SetAttribute("Duration", duration)
	buff:SetAttribute("Power", attackPower)
	buff:SetAttribute("Color", fromRGB(255, 255, 0))
	buff:SetAttribute("Text", "ATTACK UP!")
	buff.Name = "AttackBuff"
	buff.Parent = if isMob then target.EffectsList else target.Character.CharStats.EffectsList

	if not isMob then Events.PlaySound:Fire(target, workspace.Sounds.SFXs.Up) end
end

--[[
	Give player magic buff, can't be used for monsters
]]
function SkillUtil:MagicBuff(plr: Player, power: number, duration: number)
	if plr.Character.Humanoid.Health <= 0 then return end

	local buff = RepS.Resources.Unloads.MagicBuff:Clone() :: Script
	buff:SetAttribute("Duration", duration)
	buff:SetAttribute("Power", power)
	buff:SetAttribute("Color", fromRGB(162, 0, 255))
	buff:SetAttribute("Text", "MAGIC UP!")
	buff.Parent = plr.Character.CharStats.EffectsList

	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Up)
end

--[[
	Give player speed buff, can't be used for monsters
]]
function SkillUtil:SpeedBuff(plr: Player, exSpeed: number, duration: number)
	local buff = RepS.Resources.Unloads.SpeedBuff:Clone() :: Script

	buff:SetAttribute("Duration", duration)
	buff:SetAttribute("Power", exSpeed)
	buff:SetAttribute("Color", fromRGB(255, 255, 0))
	buff:SetAttribute("Text", "SPEED UP!")
	buff.Parent = plr.Character.CharStats.EffectsList

	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Up)
end

--[[
	Give player defense buff, it's real defense
]]
function SkillUtil:DefenseBuff(plr: Player, def: number, duration: number)
	local buff = RepS.Resources.Unloads.DefenseBuff:Clone() :: Script

	buff:SetAttribute("Duration", duration)
	buff:SetAttribute("Power", def)
	buff:SetAttribute("Color", fromRGB(128, 128, 128))
	buff:SetAttribute("Text", "DEFENSE UP!")
	buff.Parent = plr.Character.CharStats.EffectsList

	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Up)
end

return SkillUtil
