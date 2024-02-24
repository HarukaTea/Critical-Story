--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local LootPlan = require(RepS.Modules.Packages.LootPlan)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local AttackUtil = {}

local wait = task.wait
local insert = table.insert
local instanceNew = Instance.new
local fromRGB = Color3.fromRGB
local cfNew, v3New = CFrame.new, Vector3.new
local cfAngles = CFrame.Angles
local rad = math.rad

--[[
    RNG this attack to be a critical attack, and return the result
]]
function AttackUtil:CriticalHit(plr: Player, monster: Model, maxDmg: number, forceRarity: number?) : string
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

        Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Critical)
		ServerUtil:ShowText(char, "CRITICAL!", fromRGB(230, 241, 3))

		wait(0.3)
		criEff.Enabled = false
		Debris:AddItem(criEff, 1)
	end

	criChance:Destroy()

    return result
end

--[[
    Deal damage to monsters
]]
function AttackUtil:DealDMG(plr: Player, monster: Model, dmg: number)
    ServerUtil:ShowNumber(monster, dmg, AssetBook.ClassInfo[plr:GetAttribute("Class")].Color)
    HarukaLib:Add(monster, "Health", -dmg)

    AttackUtil:CriticalHit(plr, monster, dmg)
end


function AttackUtil.Warrior(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

	HarukaLib:Add(char, "Combo", 1)

	if char:GetAttribute("Combo") > 1 then
		local finalDamage = baseDamage * char:GetAttribute("Combo")

		local comboEff = RepS.Package.Effects.ComboEffect:Clone() :: ParticleEmitter
		comboEff.Parent = monster.PrimaryPart
		Debris:AddItem(comboEff, 1)

        Spawn(function()
            wait(0.4)
			comboEff.Enabled = false
		end)

        AttackUtil:DealDMG(plr, monster, finalDamage)
	else
		AttackUtil:DealDMG(plr, monster, baseDamage)
	end

    SkillUtil:RestoreManaByOrb(plr)
end

function AttackUtil.Archer(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    local arrow = RepS.Package.PlayerAttacks.ArrowOrb:Clone() :: Model
    arrow.Owner.Value = char
    arrow:PivotTo(ServerUtil:GenerateOrbPos(monster, plr.Character))
    arrow:SetAttribute("OrbLifeTime", 8)
    arrow.Parent = workspace.MapComponents.OrbFolders[plr.Name]
    Debris:AddItem(arrow, 8)

    if char:GetAttribute("Arrows") > 0 then
        --- bow dmg
        AttackUtil:DealDMG(plr, monster, baseDamage)

        --- arrow dmg
        for i = char:GetAttribute("Arrows"), 1, -1 do
            if monster:GetAttribute("Health") <= 0 then break end

            HarukaLib:Add(char, "Arrows", -1)

            AttackUtil:DealDMG(plr, monster, baseDamage)
        end
        if char:GetAttribute("Arrows") <= 0 then char:SetAttribute("Arrows", 0) end
    else
        AttackUtil:DealDMG(plr, monster, baseDamage)
    end

    SkillUtil:RestoreManaByOrb(plr)
end
function AttackUtil.PoisonArcher(plr: Player, monster: Model, baseDamage: number)
    AttackUtil:DealDMG(plr, monster, baseDamage)

    SkillUtil:Poison(plr, monster, 4)
end
function AttackUtil.ArcherArrow(plr: Player)
    local char = plr.Character

    HarukaLib:Add(char, "Arrows", 1)

    if char:GetAttribute("Arrows") > 10 then
        char:SetAttribute("Arrows", 10)
    end
end

function AttackUtil.Wizard(plr: Player, monster: Model)
    local char = plr.Character
    local magicDmg = char:GetAttribute("Magic")

    HarukaLib:Add(char, "WizardCasted", 35)
    AttackUtil:DealDMG(plr, monster, magicDmg)

    if char:GetAttribute("WizardCasted") >= 100 then
        char:SetAttribute("WizardCasted", 0)

        Events.MagicCasted:Fire(plr)
        RepS.Resources.Items.WizardMagicBall:Clone().Parent = char.CharStats.Items
    end

    SkillUtil:RestoreManaByOrb(plr)
end

function AttackUtil.Knight(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    HarukaLib:Add(char, "Guard", 15)
    AttackUtil:DealDMG(plr, monster, baseDamage)

    if char:GetAttribute("Guard") > 100 then
        char:SetAttribute("Guard", 100)
    end

    SkillUtil:RestoreManaByOrb(plr)
end

function AttackUtil.Rogue(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    HarukaLib:Add(char, "RogueCritical", 10)
    AttackUtil:DealDMG(plr, monster, baseDamage)

    if char:GetAttribute("RogueCritical") > 100 then
        char:SetAttribute("RogueCritical", 100)
    end

    --- extra critical hit roll cuz it's rogue class
    local result = AttackUtil:CriticalHit(plr, monster, baseDamage, char:GetAttribute("RogueCritical"))

    if result == "CriticalHit" then char:SetAttribute("RogueCritical", 0) end

    SkillUtil:RestoreManaByOrb(plr)
end

function AttackUtil.Repeater(plr: Player, monster: Model, baseDamage: number, orb: Model)
    if not orb:GetAttribute("RepeaterSpawned") then
        local pos = ServerUtil:GenerateOrbPos(monster, plr.Character)
        local repeaterOrb = RepS.Package.PlayerAttacks.RepeaterOrb:Clone() :: Model

        repeaterOrb.Owner.Value = plr.Character
        repeaterOrb:PivotTo(pos)
        repeaterOrb:SetAttribute("RepeaterSpawned", true)
        repeaterOrb:SetAttribute("OrbLifeTime", 5)
        repeaterOrb.Parent = workspace.MapComponents.OrbFolders[plr.Name]

        Debris:AddItem(repeaterOrb, 5)

        Spawn(function()
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
        end)
    end

    AttackUtil:DealDMG(plr, monster, baseDamage)
    SkillUtil:RestoreManaByOrb(plr)
end

function AttackUtil.Striker(plr: Player, monster: Model, baseDamage: number)
    SkillUtil:RestoreManaByOrb(plr)

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
                AttackUtil:DealDMG(plr, monster, baseDamage)
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

function AttackUtil.AlchemistRed(plr: Player, monster: Model)
    local magicDmg = plr.Character:GetAttribute("Magic")
    AttackUtil:DealDMG(plr, monster, magicDmg)

    SkillUtil:RestoreManaByOrb(plr)
end
function AttackUtil.AlchemistBlue(plr: Player, monster: Model)
    local magicDmg = plr.Character:GetAttribute("Magic")
    AttackUtil:DealDMG(plr, monster, magicDmg)

    SkillUtil:RestoreManaByOrb(plr)
end
function AttackUtil.AlchemistGreen(plr: Player, monster: Model)
    local magicDmg = plr.Character:GetAttribute("Magic")
    AttackUtil:DealDMG(plr, monster, magicDmg)

    SkillUtil:RestoreManaByOrb(plr)
end

function AttackUtil.Illusionist(plr: Player, monster: Model)
    local magicDmg = plr.Character:GetAttribute("Magic")
    AttackUtil:DealDMG(plr, monster, magicDmg)

    SkillUtil:RestoreManaByOrb(plr)
end

return AttackUtil
