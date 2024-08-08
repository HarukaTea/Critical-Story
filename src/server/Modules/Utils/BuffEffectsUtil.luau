--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local StatusEffectBook = require(RepS.Modules.Data.StatusEffectBook)

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
	healEff.Parent = char.PrimaryPart
	Debris:AddItem(healEff, 1)
end


function BuffEffectsUtil:HealBuff(char: Model, level: number, isMob: boolean?)
	if isMob then if char:GetAttribute("Health") <= 0 then return end end
	if not isMob then if char.Humanoid.Health <= 0 then return end end

	local buff: Script
	if isMob then
		buff = SS.Resources.Unloads.HealBuff:Clone()
		buff:SetAttribute("HealDMG", floor(char:GetAttribute("MaxHealth") * 0.1))
		buff:SetAttribute("IsMob", true)
	else
		buff = SS.Resources.Unloads.HealBuff:Clone()
		buff:SetAttribute("HealDMG", floor(char.Humanoid.MaxHealth * 0.2))
	end
	buff:SetAttribute("Power", level)
	buff:SetAttribute("MaxDuration", 6)
	buff.Name = "HealBuff"
	buff.Parent = if isMob then char.EffectsList else char.CharStats.EffectsList
end


function BuffEffectsUtil:ManaBuff(char: Model, level: number)
	if char.Humanoid.Health <= 0 then return end

	local buff = SS.Resources.Unloads.ManaBuff:Clone()
	buff:SetAttribute("HealDMG", floor(char:GetAttribute("MaxMana") * 0.15))
	buff:SetAttribute("Power", level)
	buff:SetAttribute("MaxDuration", 6)
	buff.Name = "ManaBuff"
	buff.Parent = char.CharStats.EffectsList
end


function BuffEffectsUtil:Burn(char: Model, monster: Model, level: number, isPlayer: boolean?)
	if char.Humanoid.Health <= 0 then return end
	if not monster:FindFirstChild("EffectsList") then return end

	local debuff: Script
	if isPlayer then
		debuff = SS.Resources.Unloads.DOTDMG:Clone()
		debuff:SetAttribute("Damage", floor(monster:GetAttribute("Damage") / 4))
		debuff:SetAttribute("IsPlayer", true)
	else
		debuff = SS.Resources.Unloads.DOTDMG:Clone()
		debuff:SetAttribute("Damage", floor(char:GetAttribute("Magic") / 4.5))
	end
	debuff:SetAttribute("Power", level)
	debuff:SetAttribute("MaxDuration", 6)
	debuff:SetAttribute("Color", fromRGB(255, 85, 0))
	debuff:SetAttribute("Text", "BURN!")
	debuff.Name = "Burn"
	debuff.Parent = if isPlayer then char.CharStats.EffectsList else monster.EffectsList
end


function BuffEffectsUtil:Poison(char: Model, monster: Model, level: number, isPlayer: boolean?)
	if char.Humanoid.Health <= 0 then return end
	if not monster:FindFirstChild("EffectsList") then return end

	local debuff: Script
	if isPlayer then
		debuff = SS.Resources.Unloads.DOTDMG:Clone()
		debuff:SetAttribute("Damage", floor(monster:GetAttribute("Damage") / 4))
		debuff:SetAttribute("IsPlayer", true)
	else
		debuff = SS.Resources.Unloads.DOTDMG:Clone()
		debuff:SetAttribute("Damage", floor(char:GetAttribute("MaxDMG") / 4.5))
	end
	debuff:SetAttribute("Power", level)
	debuff:SetAttribute("MaxDuration", 6)
	debuff:SetAttribute("Color", fromRGB(55, 66, 250))
	debuff:SetAttribute("Text", "POISON!")
	debuff.Name = "Poison"
	debuff.Parent = if isPlayer then char.CharStats.EffectsList else monster.EffectsList
end


function BuffEffectsUtil:AttackBuff(char: Model, attackPower: number, duration: number, isMob: boolean?)
	if isMob then if char:GetAttribute("Health") <= 0 then return end end
	if not isMob then if char.Humanoid.Health <= 0 then return end end

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


function BuffEffectsUtil:SpeedBuff(char: Model, power: number, duration: number, noSound: boolean?)
	local buff = SS.Resources.Unloads.SpeedBuff:Clone() :: Script

	buff:SetAttribute("Duration", duration)
	buff:SetAttribute("MaxDuration", duration)
	buff:SetAttribute("Power", power)
	buff:SetAttribute("Color", fromRGB(255, 255, 0))
	buff:SetAttribute("Text", "SPEED UP!")
	buff.Parent = char.CharStats.EffectsList

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


function BuffEffectsUtil:PurifyBuff(char: Model, isMob: boolean?)
	local folder = if isMob then char.EffectsList else char.CharStats.EffectsList

	for _, buff: Script in folder:GetChildren() do
		if StatusEffectBook.BuffInfo[buff.Name].Type == "Debuff" then buff:Destroy() end
	end
	for _, child: ParticleEmitter in char:GetDescendants() do
		if child:HasTag("ProjectileEmitter") then child:Destroy() end
	end
end

return BuffEffectsUtil
