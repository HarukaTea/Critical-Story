--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local ceil, floor = math.ceil, math.floor
local fromRGB = Color3.fromRGB
local v3New = Vector3.new

local BuffEffectsUtil = {}

local function _playUpSound(char: Model)
	local plr = Players:GetPlayerFromCharacter(char)

	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Up)
end

--[[
	Arrow players to restore mana by orbs, magic-class only
]]
function BuffEffectsUtil:RestoreTPByOrb(char: Model)
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
function BuffEffectsUtil:RestoreTP(char: Model, restoreVal: number)
	HarukaLib:Add(char, "TP", restoreVal)

	local restoreEff = RepS.Package.Effects.RestoreEffect:Clone() :: ParticleEmitter
	restoreEff.Parent = char.PrimaryPart
	Debris:AddItem(restoreEff, 1)
end

--[[
	Mahoushoujiu bruh, I guess so, the power of magic is great
]]
function BuffEffectsUtil:MagicVFX(monster: Model)
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
function BuffEffectsUtil:Heal(char: Model, healPower: number)
	local plr = Players:GetPlayerFromCharacter(char)
	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Heal)

	char.Humanoid.Health += floor(char.Humanoid.MaxHealth * healPower)

	local healEff = RepS.Package.Effects.HealEffect:Clone() :: ParticleEmitter
	healEff.Parent = char.PrimaryPart
	Debris:AddItem(healEff, 1)
end

--[[
	Burn dmg, also can be used for players, related to Magic
]]
function BuffEffectsUtil:Burn(char: Model, monster: Model, turn: number, isPlayer: boolean?)
	if char.Humanoid.Health <= 0 then return end
	if not monster:FindFirstChild("EffectsList") then return end

	local debuff: Script
	if isPlayer then
		debuff = RepS.Resources.Unloads.DOTDMGPlayer:Clone()
		debuff:SetAttribute("Power", 0.5)
		debuff:SetAttribute("Damage", floor(monster:GetAttribute("Damage") / 2))
	else
		debuff = RepS.Resources.Unloads.DOTDMG:Clone()
		debuff:SetAttribute("Damage", floor(char:GetAttribute("Magic") / 2))
	end
	debuff:SetAttribute("Turn", turn)
	debuff:SetAttribute("Color", fromRGB(255, 85, 0))
	debuff:SetAttribute("Text", "BURN!")
	debuff.Name = "Burn"
	debuff.Parent = if isPlayer then char.CharStats.EffectsList else monster.EffectsList
end

--[[
	Poison dmg, which is related to DMG
]]
function BuffEffectsUtil:Poison(char: Model, monster: Model, turn: number, isPlayer: boolean?)
	if char.Humanoid.Health <= 0 then return end
	if not monster:FindFirstChild("EffectsList") then return end

	local debuff: Script
	if isPlayer then
		debuff = RepS.Resources.Unloads.DOTDMGPlayer:Clone()
		debuff:SetAttribute("Power", 0.5)
		debuff:SetAttribute("Damage", floor(monster:GetAttribute("Damage") / 2))
	else
		debuff = RepS.Resources.Unloads.DOTDMG:Clone()
		debuff:SetAttribute("Damage", floor(char:GetAttribute("MaxDMG") / 2))
	end
	debuff:SetAttribute("Turn", turn)
	debuff:SetAttribute("Color", fromRGB(55, 66, 250))
	debuff:SetAttribute("Text", "POISON!")
	debuff.Name = "Poison"
	debuff.Parent = if isPlayer then char.CharStats.EffectsList else monster.EffectsList
end

--[[
	Give player attack buff, also can be used for monsters
]]
function BuffEffectsUtil:AttackBuff(char: Model, attackPower: number, turn: number, isMob: boolean?)
	if isMob then
		if not char:FindFirstChild("EffectsList") then return end
	else
		if char.Humanoid.Health <= 0 then return end
	end

	local buff: Script
	if isMob then
		buff = RepS.Resources.Unloads.AttackBuffMob:Clone()
	else
		buff = RepS.Resources.Unloads.AttackBuff:Clone()
	end
	buff:SetAttribute("Turn", turn)
	buff:SetAttribute("Power", attackPower)
	buff:SetAttribute("Color", fromRGB(255, 255, 0))
	buff:SetAttribute("Text", "ATTACK UP!")
	buff.Name = "AttackBuff"
	buff.Parent = if isMob then char.EffectsList else char.CharStats.EffectsList

	if not isMob then _playUpSound(char) end
end

--[[
	Give player magic buff, can't be used for monsters
]]
function BuffEffectsUtil:MagicBuff(char: Model, power: number, turn: number)
	if char.Humanoid.Health <= 0 then return end

	local buff = RepS.Resources.Unloads.MagicBuff:Clone() :: Script
	buff:SetAttribute("Turn", turn)
	buff:SetAttribute("Power", power)
	buff:SetAttribute("Color", fromRGB(162, 0, 255))
	buff:SetAttribute("Text", "MAGIC UP!")
	buff.Parent = char.CharStats.EffectsList

	_playUpSound(char)
end

--[[
	Give player speed buff, can't be used for monsters
]]
function BuffEffectsUtil:SpeedBuff(char: Model, exSpeed: number, duration: number)
	local buff = RepS.Resources.Unloads.SpeedBuff:Clone() :: Script

	buff:SetAttribute("Turn", duration)
	buff:SetAttribute("Power", exSpeed)
	buff:SetAttribute("Color", fromRGB(255, 255, 0))
	buff:SetAttribute("Text", "SPEED UP!")
	buff.Parent = char.CharStats.EffectsList

	local speedEffect = RepS.Package.Effects.SpeedEffect:Clone() :: ParticleEmitter
	speedEffect.Parent = char.PrimaryPart
	Debris:AddItem(speedEffect, duration)

	_playUpSound(char)
end

--[[
	Give player defense buff, it's real defense
]]
function BuffEffectsUtil:DefenseBuff(char: Model, def: number, turn: number)
	local buff = RepS.Resources.Unloads.DefenseBuff:Clone() :: Script

	buff:SetAttribute("Turn", turn)
	buff:SetAttribute("Power", def)
	buff:SetAttribute("Color", fromRGB(128, 128, 128))
	buff:SetAttribute("Text", "DEFENSE UP!")
	buff.Parent = char.CharStats.EffectsList

	_playUpSound(char)
end

--[[
	Give player purify status
]]
function BuffEffectsUtil:PurifyBuff(char: Model)
	for _, buff: Script in char.CharStats.EffectsList:GetChildren() do
		if AssetBook.BuffInfo[buff.Name].Type == "Debuff" then buff:SetAttribute("Turn", -1) end
	end
end

return BuffEffectsUtil