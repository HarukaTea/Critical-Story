--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local delay = task.delay
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

	delay(0.4, function()
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

	delay(0.4, function()
		restoreEff.Enabled = false
	end)
end

--[[
	Heal health, by active items
]]
function SkillUtil:Heal(plr: Player, healPower: number)
	local char = plr.Character

	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Heal)

	char.Humanoid.Health += healPower

	local healEff = RepS.Package.Effects.HealEffect:Clone() :: ParticleEmitter
	healEff.Parent = char.PrimaryPart
	Debris:AddItem(healEff, 1)

	delay(0.4, function()
		healEff.Enabled = false
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

function SkillUtil:Burn(plr: Player, monster: Model, duration: number)
	if not monster:FindFirstChild("EffectsList") then return end

	local burn = RepS.Resources.Unloads.BurnDMG:Clone() :: Script
	burn:SetAttribute("Duration", duration)
	burn:SetAttribute("Damage", floor(plr.Character:GetAttribute("Magic") / 2))
	burn:SetAttribute("Color", fromRGB(255, 176, 0))
	burn:SetAttribute("Text", "BURN!")
	burn.Name = "Burn"
	burn.Parent = monster.EffectsList
end

function SkillUtil:Poison(plr: Player, monster: Model, duration: number)
	if not monster:FindFirstChild("EffectsList") then return end

	local poison = RepS.Resources.Unloads.BurnDMG:Clone() :: Script
	poison:SetAttribute("Duration", duration)
	poison:SetAttribute("Damage", floor(plr.Character:GetAttribute("Damage") / 2))
	poison:SetAttribute("Color", fromRGB(255, 0, 191))
	poison:SetAttribute("Text", "POISON!")
	poison.Name = "Poison"
	poison.Parent = monster.EffectsList
end

function SkillUtil:AttackBuff(plr: Player, attackPower: number, duration: number)
	local attackBuff = RepS.Resources.Unloads.AttackBuff:Clone() :: Script
	attackBuff:SetAttribute("Duration", duration)
	attackBuff:SetAttribute("Power", attackPower)
	attackBuff:SetAttribute("Color", fromRGB(255, 255, 0))
	attackBuff:SetAttribute("Text", "ATTACK UP!")
	attackBuff.Name = "AttackBuff"
	attackBuff.Parent = plr.Character.CharStats.EffectsList

	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Up)
end

return SkillUtil
