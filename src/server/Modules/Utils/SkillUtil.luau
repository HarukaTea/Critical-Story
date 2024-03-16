--!strict

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)

local wait = task.wait
local ceil, floor = math.ceil, math.floor
local fromRGB = Color3.fromRGB

local SkillUtil = {}

--[[
	Arrow players to restore mana by orbs, magic-class only
]]
function SkillUtil:RestoreManaByOrb(plr: Player)
	local char = plr.Character

	local currentMana = char:GetAttribute("Mana")
	local maxMana = char:GetAttribute("MaxMana")

	if currentMana >= maxMana then return end

	HarukaLib:Add(char, "Mana", ceil(maxMana * (char:GetAttribute("RestoreBuff") / 100)))

	local restoreEff = RepS.Package.Effects.RestoreEffect:Clone() :: ParticleEmitter
	restoreEff.Parent = char.PrimaryPart
	Debris:AddItem(restoreEff, 1)

	Spawn(function()
		wait(0.4)
		restoreEff.Enabled = false
	end)
end

--[[
	Restore mana, by script lol
]]
function SkillUtil:RestoreMana(plr: Player, healPower: number)
	local char = plr.Character

	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Heal)

	HarukaLib:Add(char, "Mana", healPower)

	local restoreEff = RepS.Package.Effects.RestoreEffect:Clone() :: ParticleEmitter
	restoreEff.Parent = char.PrimaryPart
	Debris:AddItem(restoreEff, 1)

	Spawn(function()
		wait(0.4)
		restoreEff.Enabled = false
	end)
end

--[[
	Mahoushoujiu bruh, I guess so, the power of magic is great
]]
function SkillUtil:MagicVFX(plr: Player, monster: Model)
	local eff = RepS.Package.MagicAssets.Ignited:Clone() :: Part
	eff.CFrame = monster.PrimaryPart.CFrame
	eff.Transparency = 0
	eff.Parent = workspace
	Debris:AddItem(eff, 0.25)

	Events.ClientTween:Fires({ eff }, { Size = Vector3.one * 24, Transparency = 1 }, "twiceHalf")
end

--[[
	Check if the mana is enough for the active item requirement
]]
function SkillUtil:ManaCheck(plr: Player, req: number) : boolean
	if plr.Character:GetAttribute("Mana") < req then
		return false
	end

	HarukaLib:Add(plr.Character, "Mana", -req)
	return true
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

	Spawn(function()
		wait(0.4)
		healEff.Enabled = false
	end)
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
	buff.Name = "MagicBuff"
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
	buff.Name = "SpeedBuff"
	buff.Parent = plr.Character.CharStats.EffectsList

	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Up)
end

return SkillUtil
