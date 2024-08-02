--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local floor = math.floor
local fromRGB = Color3.fromRGB
local v3New = Vector3.new

local BuffEffectsUtil = {}

local function _playUpSound(char: Model)
	local plr = Players:GetPlayerFromCharacter(char)

	Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.Up })
end


function BuffEffectsUtil:RestoreManaByOrb(char: Model)
	local currentMana = char:GetAttribute("Mana") :: number

	if currentMana >= char:GetAttribute("MaxMana") then return end

	HarukaLib:AddAttr(char, "Mana", floor(char:GetAttribute("MaxMana") * char:GetAttribute("RestoreBuff") / 100))

	local restoreEff = RepS.Package.Effects.RestoreEffect:Clone() :: ParticleEmitter
	restoreEff.Parent = char.PrimaryPart
	Debris:AddItem(restoreEff, 1)
end


function BuffEffectsUtil:RestoreMana(char: Model, restoreVal: number)
	HarukaLib:AddAttr(char, "Mana", restoreVal)

	local restoreEff = RepS.Package.Effects.RestoreEffect:Clone() :: ParticleEmitter
	restoreEff.Parent = char.PrimaryPart
	Debris:AddItem(restoreEff, 1)
end


function BuffEffectsUtil:MagicVFX(monster: Model)
	local eff = RepS.Package.MagicAssets.Ignited:Clone() :: Part
	eff.CFrame = monster.PrimaryPart.CFrame
	eff.Transparency = 0
	eff.Parent = workspace
	Debris:AddItem(eff, 0.25)

	Events.ClientTween.FireAll({ Objs = { eff }, Goal = { Size = v3New(1, 1, 1) * 24, Transparency = 1 }, TweenInfo = "twiceHalf" })
end


function BuffEffectsUtil:Heal(char: Model, healPower: number)
	local plr = Players:GetPlayerFromCharacter(char)
	Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.Heal })

	char.Humanoid.Health += floor(char.Humanoid.MaxHealth * healPower)

	local healEff = RepS.Package.Effects.HealEffect:Clone() :: BasePart
	healEff.CFrame = char.PrimaryPart.CFrame
	healEff.Parent = workspace
	Debris:AddItem(healEff, 1)
end


function BuffEffectsUtil:Burn(char: Model, monster: Model, duration: number, isPlayer: boolean?)
	if char.Humanoid.Health <= 0 then return end
	if not monster:FindFirstChild("EffectsList") then return end

	local debuff: Script
	if isPlayer then
		debuff = SS.Resources.Unloads.DOTDMGPlayer:Clone()
		debuff:SetAttribute("Damage", floor(monster:GetAttribute("Damage") / 2))
		debuff:SetAttribute("Power", 0.5)
	else
		debuff = SS.Resources.Unloads.DOTDMG:Clone()
		debuff:SetAttribute("Damage", floor(char:GetAttribute("Magic") / 4))
		debuff:SetAttribute("Power", 0.25)
	end
	debuff:SetAttribute("Power", 0.25)
	debuff:SetAttribute("Duration", duration)
	debuff:SetAttribute("MaxDuration", duration)
	debuff:SetAttribute("Color", fromRGB(255, 85, 0))
	debuff:SetAttribute("Text", "BURN!")
	debuff.Name = "Burn"
	debuff.Parent = if isPlayer then char.CharStats.EffectsList else monster.EffectsList
end


function BuffEffectsUtil:Poison(char: Model, monster: Model, duration: number, isPlayer: boolean?)
	if char.Humanoid.Health <= 0 then return end
	if not monster:FindFirstChild("EffectsList") then return end

	local debuff: Script
	if isPlayer then
		debuff = SS.Resources.Unloads.DOTDMGPlayer:Clone()
		debuff:SetAttribute("Damage", floor(monster:GetAttribute("Damage") / 2))
		debuff:SetAttribute("Power", 0.5)
	else
		debuff = SS.Resources.Unloads.DOTDMG:Clone()
		debuff:SetAttribute("Damage", floor(char:GetAttribute("MaxDMG") / 4))
		debuff:SetAttribute("Power", 0.25)
	end
	debuff:SetAttribute("Duration", duration)
	debuff:SetAttribute("MaxDuration", duration)
	debuff:SetAttribute("Color", fromRGB(55, 66, 250))
	debuff:SetAttribute("Text", "POISON!")
	debuff.Name = "Poison"
	debuff.Parent = if isPlayer then char.CharStats.EffectsList else monster.EffectsList
end


function BuffEffectsUtil:AttackBuff(char: Model, attackPower: number, duration: number, isMob: boolean?)
	if isMob then
		if not char:FindFirstChild("EffectsList") then return end
	else
		if char.Humanoid.Health <= 0 then return end
	end

	local buff: Script
	if isMob then
		buff = SS.Resources.Unloads.AttackBuffMob:Clone()
	else
		buff = SS.Resources.Unloads.AttackBuff:Clone()
	end
	buff:SetAttribute("Duration", duration)
	buff:SetAttribute("MaxDuration", duration)
	buff:SetAttribute("Power", attackPower)
	buff:SetAttribute("Color", fromRGB(255, 255, 0))
	buff:SetAttribute("Text", "ATTACK UP!")
	buff.Name = "AttackBuff"
	buff.Parent = if isMob then char.EffectsList else char.CharStats.EffectsList

	if not isMob then _playUpSound(char) end
end


function BuffEffectsUtil:MagicBuff(char: Model, power: number, duration: number)
	if char.Humanoid.Health <= 0 then return end

	local buff = SS.Resources.Unloads.MagicBuff:Clone() :: Script
	buff:SetAttribute("Duration", duration)
	buff:SetAttribute("MaxDuration", duration)
	buff:SetAttribute("Power", power)
	buff:SetAttribute("Color", fromRGB(162, 0, 255))
	buff:SetAttribute("Text", "MAGIC UP!")
	buff.Parent = char.CharStats.EffectsList

	_playUpSound(char)
end


function BuffEffectsUtil:SpeedBuff(char: Model, exSpeed: number, duration: number, noSound: boolean?)
	local buff = SS.Resources.Unloads.SpeedBuff:Clone() :: Script

	buff:SetAttribute("Duration", duration)
	buff:SetAttribute("MaxDuration", duration)
	buff:SetAttribute("Power", exSpeed)
	buff:SetAttribute("Color", fromRGB(255, 255, 0))
	buff:SetAttribute("Text", "SPEED UP!")
	buff.Parent = char.CharStats.EffectsList

	local speedEffect = RepS.Package.Effects.SpeedEffect:Clone() :: ParticleEmitter
	speedEffect.Parent = char.PrimaryPart
	Debris:AddItem(speedEffect, duration)

	if not noSound then _playUpSound(char) end
end


function BuffEffectsUtil:DefenseBuff(char: Model, def: number, duration: number)
	local buff = SS.Resources.Unloads.DefenseBuff:Clone() :: Script

	buff:SetAttribute("Duration", duration)
	buff:SetAttribute("MaxDuration", duration)
	buff:SetAttribute("Percentage", def)
	buff:SetAttribute("Color", fromRGB(128, 128, 128))
	buff:SetAttribute("Text", "DEFENSE UP!")
	buff.Parent = char.CharStats.EffectsList

	_playUpSound(char)
end


function BuffEffectsUtil:PurifyBuff(char: Model)
	for _, buff: Script in char.CharStats.EffectsList:GetChildren() do
		if AssetBook.BuffInfo[buff.Name].Type == "Debuff" then buff:Destroy() end
	end
	for _, child: ParticleEmitter in char:GetDescendants() do
		if child:HasTag("ProjectileEmitter") then child:Destroy() end
	end
end

return BuffEffectsUtil
