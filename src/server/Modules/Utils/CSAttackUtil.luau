--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local CAAttackUtil = require(SSS.Modules.Utils.CAAttackUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)

local random = math.random

local CSAttackUtil = {}

function CSAttackUtil:DealDMG(plr: Player)
    local char = plr.Character

	local monster = char.CharStats.TargetMonster.Value :: Model
	local class = plr:GetAttribute("Class") :: string
	local dmgType = AssetBook.ClassInfo[class].Type
	local baseDamage = 0
	if dmgType == "DMG" then
		local minDMG: number, maxDMG: number = char:GetAttribute("MinDMG"), char:GetAttribute("MaxDMG")
		baseDamage = if minDMG >= maxDMG then maxDMG else random(minDMG, maxDMG)
	else
		baseDamage = char:GetAttribute("Magic")
	end

    Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.AttackHit)
    Events.ClassClientVFX:Fire(plr, monster)

    CAAttackUtil:DealDMG(plr, monster, baseDamage)
    SkillUtil:RestoreTPByOrb(plr)
end

function CSAttackUtil.Warrior(plr: Player)
    Events.PlayAnimation:Fire(plr, "WarriorAnim1")

    CSAttackUtil:DealDMG(plr)
end

function CSAttackUtil.Archer(plr: Player)
    Events.PlayAnimation:Fire(plr, "ArcherAnim1")

    CSAttackUtil:DealDMG(plr)
end

function CSAttackUtil.Wizard(plr: Player)
    Events.PlayAnimation:Fire(plr, "WizardAnim1")

    CSAttackUtil:DealDMG(plr)
end

function CSAttackUtil.Knight(plr: Player)
    Events.PlayAnimation:Fire(plr, "KnightAnim1")

    CSAttackUtil:DealDMG(plr)
end

function CSAttackUtil.Rogue(plr: Player)
    Events.PlayAnimation:Fire(plr, "RogueAnim1")

    CSAttackUtil:DealDMG(plr)
end

function CSAttackUtil.Repeater(plr: Player)
    Events.PlayAnimation:Fire(plr, "RepeaterAnim1")

    CSAttackUtil:DealDMG(plr)
end

function CSAttackUtil.Striker(plr: Player)
    Events.PlayAnimation:Fire(plr, "StrikerAnim1")

    CSAttackUtil:DealDMG(plr)
end

function CSAttackUtil.Alchemist(plr: Player)
    Events.PlayAnimation:Fire(plr, "AlchemistAnim1")

    CSAttackUtil:DealDMG(plr)
end

function CSAttackUtil.Illusionist(plr: Player)
    Events.PlayAnimation:Fire(plr, "IllusionistAnim1")

    CSAttackUtil:DealDMG(plr)
end


return CSAttackUtil
