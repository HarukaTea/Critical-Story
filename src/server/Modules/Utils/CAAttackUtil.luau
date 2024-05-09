--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local LootPlan = require(RepS.Modules.Packages.LootPlan)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local CAAttackUtil = {}

local wait = task.wait
local insert = table.insert
local instanceNew = Instance.new
local fromRGB = Color3.fromRGB
local cfNew, v3New = CFrame.new, Vector3.new
local cfAngles = CFrame.Angles
local rad, floor = math.rad, math.floor

--[[
    RNG this attack to be a critical attack, and return the result
]]
function CAAttackUtil:CriticalHit(plr: Player, monster: Model, maxDmg: number, forceRarity: number?) : string
    local char = plr.Character
    local criChanceRarity = forceRarity or char:GetAttribute("CriChance")

    local criChance = LootPlan.new()
	criChance:Add("CriticalHit", criChanceRarity)
	criChance:Add("None", 100 - criChanceRarity)

    local result = criChance:Roll()

	if result == "CriticalHit" then
		local dmg = maxDmg * 2
        HarukaLib:Add(monster, "Health", -dmg)

        ServerUtil:ShowNumber(monster, dmg, fromRGB(230, 241, 3))

		local criEff = RepS.Package.Effects.CriticalHitEffect:Clone() :: ParticleEmitter
		criEff.Parent = monster.PrimaryPart
        Debris:AddItem(criEff, 1)

        Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Critical)
		ServerUtil:ShowText(char, "CRITICAL!", fromRGB(230, 241, 3))
	end

	criChance:Destroy()

    return result
end

--[[
    Deal damage to monsters
]]
function CAAttackUtil:DealDMG(plr: Player, monster: Model, dmg: number)
    ServerUtil:ShowNumber(monster, dmg, AssetBook.ClassInfo[plr:GetAttribute("Class")].Color)

    HarukaLib:Add(monster, "Health", -dmg)

    CAAttackUtil:CriticalHit(plr, monster, dmg)
end


function CAAttackUtil.Warrior(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

	HarukaLib:Add(char, "Combo", 1)

	if char:GetAttribute("Combo") > 1 then
        local combo = char:GetAttribute("Combo") :: number
        local multiplier = if combo % 2 == 1 then (combo + 1) / 2 else combo / 2 + 0.5
		local finalDamage = floor(baseDamage * multiplier)

		local comboEff = RepS.Package.Effects.ComboEffect:Clone() :: ParticleEmitter
		comboEff.Parent = monster.PrimaryPart
		Debris:AddItem(comboEff, 1)

        CAAttackUtil:DealDMG(plr, monster, finalDamage)
	else
		CAAttackUtil:DealDMG(plr, monster, baseDamage)
	end

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.Archer(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    local arrow = RepS.Package.PlayerAttacks.ArrowOrb:Clone() :: Model
    arrow.Owner.Value = char
    arrow:PivotTo(ServerUtil:GenerateOrbPos(monster))
    arrow:SetAttribute("OrbLifeTime", char:GetAttribute("OrbLifeTime"))
    arrow.Parent = workspace.MapComponents.OrbFolders[plr.Name]
    Debris:AddItem(arrow, char:GetAttribute("OrbLifeTime"))

    if char:GetAttribute("Stack") > 0 then
        --- bow dmg
        CAAttackUtil:DealDMG(plr, monster, baseDamage)

        --- arrow dmg
        for _ = char:GetAttribute("Stack"), 1, -1 do
            if monster:GetAttribute("Health") <= 0 then break end

            HarukaLib:Add(char, "Stack", -1)

            CAAttackUtil:DealDMG(plr, monster, baseDamage)
        end
        if char:GetAttribute("Stack") <= 0 then char:SetAttribute("Stack", 0) end
    else
        CAAttackUtil:DealDMG(plr, monster, baseDamage)
    end

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end
function CAAttackUtil.ArcherArrow(plr: Player)
    local char = plr.Character

    HarukaLib:Add(char, "Stack", 1)

    if char:GetAttribute("Stack") > 10 then char:SetAttribute("Stack", 10) end
end

function CAAttackUtil.Wizard(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character
    local magicDmg = char:GetAttribute("Magic")

    HarukaLib:Add(char, "Focus", 35)
    CAAttackUtil:DealDMG(plr, monster, magicDmg)

    if char:GetAttribute("Focus") >= 100 then
        char:SetAttribute("Focus", 0)

        CAAttackUtil:DealDMG(plr, monster, floor(baseDamage * 3))
    end

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.Knight(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    HarukaLib:Add(char, "Guard", 15)
    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    if char:GetAttribute("Guard") > 100 then char:SetAttribute("Guard", 100) end

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.Rogue(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    HarukaLib:Add(char, "RogueCri", 10)
    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    if char:GetAttribute("RogueCri") > 100 then char:SetAttribute("RogueCri", 100) end

    --- extra critical hit roll cuz it's rogue class
    local result = CAAttackUtil:CriticalHit(plr, monster, baseDamage, char:GetAttribute("RogueCri"))

    if result == "CriticalHit" then char:SetAttribute("RogueCri", 0) end

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.Repeater(plr: Player, monster: Model, baseDamage: number, orb: Model)
    local char = plr.Character

    if not orb:GetAttribute("RepeaterSpawned") then
        local pos = ServerUtil:GenerateOrbPos(monster)
        local repeaterOrb = RepS.Package.PlayerAttacks.RepeaterOrb:Clone() :: Model

        repeaterOrb.Owner.Value = plr.Character
        repeaterOrb:PivotTo(pos)
        repeaterOrb:SetAttribute("RepeaterSpawned", true)
        repeaterOrb:SetAttribute("OrbLifeTime", char:GetAttribute("OrbLifeTime"))
        repeaterOrb.Parent = workspace.MapComponents.OrbFolders[plr.Name]
        Debris:AddItem(repeaterOrb, char:GetAttribute("OrbLifeTime"))

        local laser = instanceNew("Part")
        laser.Material = Enum.Material.Neon
        laser.CanCollide = false
        laser.CanTouch = false
        laser.CanQuery = false
        laser.Anchored = true
        laser.Transparency = 0
        laser.Color = fromRGB(9, 137, 207)
        laser.Size = v3New(0.5, 0.5, (orb.Base.CFrame.Position - repeaterOrb.Base.CFrame.Position).Magnitude)
        laser.CFrame = cfNew((orb.Base.CFrame.Position + repeaterOrb.Base.CFrame.Position) / 2, orb.Base.CFrame.Position)
        laser.Parent = workspace.MapComponents.OrbFolders[plr.Name]
        Debris:AddItem(laser, 1)

        Events.ClientTween:Fire(plr, { laser }, { Transparency = 1 }, "half")
    end

    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.Striker(plr: Player, monster: Model, baseDamage: number)
    BuffEffectsUtil:RestoreManaByOrb(plr.Character)

    Spawn(function()
        local char = plr.Character
        local orbs = workspace.MapComponents.OrbFolders[plr.Name]:GetChildren()
        local strikerOrbs = {}

        for _, strikerOrb in orbs do
            if strikerOrb.Name == "StrikerOrb" and not strikerOrb:GetAttribute("Obtained") then
                insert(strikerOrbs, strikerOrb)

                strikerOrb:SetAttribute("Obtained", true)
            end
        end

        wait(0.2)
        HarukaLib:Add(char, "SpeedBuff", -999)
        HarukaLib:Add(char, "JumpBuff", -999)

        Spawn(function()
            for _ = 1, #strikerOrbs do
                CAAttackUtil:DealDMG(plr, monster, baseDamage)
                wait(0.3)
            end
        end)

        for _, orb in strikerOrbs do
            if orb:FindFirstChild("Base") then
                char.Humanoid.AutoRotate = false

                local shockwave = RepS.Package.MagicAssets.Shockwave:Clone()
                shockwave.Transparency = 0.6
                shockwave.CFrame = char.PrimaryPart.CFrame * cfNew(0,0,-2) * cfAngles(0, rad(90), rad(90))
                shockwave.Parent = char
                Debris:AddItem(shockwave, 1)

                Events.ClientTween:Fires({ shockwave }, { Size = shockwave.Size + v3New(20, 0, 20), Transparency = 1 }, "one")

                local bp = instanceNew("BodyPosition")
                bp.Name = "DashVel"
                bp.D = 500
                bp.MaxForce = v3New(1, 1, 1) * 100000
                bp.Position = orb.Base.Position
                bp.Parent = char.PrimaryPart

                wait(0.3)
                char.Humanoid.AutoRotate = true
                bp:Destroy()
            end
        end

        HarukaLib:Add(char, "SpeedBuff", 999)
        HarukaLib:Add(char, "JumpBuff", 999)
    end)
end

function CAAttackUtil.AlchemistRed(plr: Player, monster: Model, baseDamage: number)
    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end
function CAAttackUtil.AlchemistBlue(plr: Player, monster: Model, baseDamage: number)
    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end
function CAAttackUtil.AlchemistGreen(plr: Player, monster: Model, baseDamage: number)
    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.Illusionist(plr: Player, monster: Model, baseDamage: number)
    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.FireStaff(plr: Player, monster: Model)
    BuffEffectsUtil:Burn(plr.Character, monster, 6)
end

return CAAttackUtil
