--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ClassBook = require(RepS.Modules.Data.ClassBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local CAAttackUtil = {}

local wait = task.wait
local instanceNew = Instance.new
local fromRGB = Color3.fromRGB
local cfNew, v3New = CFrame.new, Vector3.new
local cfAngles = CFrame.Angles
local rad, floor = math.rad, math.floor


function CAAttackUtil:CriticalHit(plr: Player, monster: Model, maxDmg: number, forceRarity: number?) : string
    local char = plr.Character
    local criChanceRarity = forceRarity or char:GetAttribute("CriChance")

    local result = HarukaLib:RollLoot({
        ["CriticalHit"] = criChanceRarity,
        ["None"] = 100 - criChanceRarity
    })

	if result == "CriticalHit" then
		local dmg = maxDmg * 2
        HarukaLib:AddAttr(monster, "Health", -dmg)

        ServerUtil:ShowNumber(monster, dmg, fromRGB(230, 241, 3))

		local criEff = RepS.Package.Effects.CriticalHitEffect:Clone() :: ParticleEmitter
		criEff.Parent = monster.PrimaryPart
        Debris:AddItem(criEff, 1)

        Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.Critical })
		ServerUtil:ShowText(char, "CRITICAL!", fromRGB(230, 241, 3))
	end

    return result
end


function CAAttackUtil:DealDMG(plr: Player, monster: Model, dmg: number, noCri: boolean?) : string
    ServerUtil:ShowNumber(monster, dmg, ClassBook.ClassInfo[plr:GetAttribute("Class")].Color)

    HarukaLib:AddAttr(monster, "Health", -dmg)

    if noCri then return "None" end

    local criResult = CAAttackUtil:CriticalHit(plr, monster, dmg)

    return criResult
end


function CAAttackUtil.Warrior(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

	HarukaLib:AddAttr(char, "Combo", 1)

	if char:GetAttribute("Combo") > 1 then
		local finalDamage = floor(baseDamage * char:GetAttribute("Combo"))

		local comboEff = RepS.Package.Effects.ComboEffect:Clone() :: ParticleEmitter
		comboEff.Parent = monster.PrimaryPart
		Debris:AddItem(comboEff, 1)

        ServerUtil:ShowText(char, "COMBO!", ClassBook.ClassInfo.Warrior.Color)

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
    arrow.Parent = workspace.MapComponents.OrbHolders[plr.Name]
    Debris:AddItem(arrow, char:GetAttribute("OrbLifeTime"))

    if char:GetAttribute("Stack") > 0 then
        --- bow dmg
        CAAttackUtil:DealDMG(plr, monster, baseDamage)

        -- arrow dmg
        for _ = char:GetAttribute("Stack"), 1, -1 do
            CAAttackUtil:DealDMG(plr, monster, baseDamage)
        end

        char:SetAttribute("Stack", 0)
    else
        CAAttackUtil:DealDMG(plr, monster, baseDamage)
    end

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end
function CAAttackUtil.ArcherArrow(plr: Player)
    local char = plr.Character

    HarukaLib:AddAttr(char, "Stack", 1)

    if char:GetAttribute("Stack") > 10 then char:SetAttribute("Stack", 10) end
end

function CAAttackUtil.Wizard(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character
    local magicDmg = char:GetAttribute("Magic")

    HarukaLib:AddAttr(char, "Focus", 35)
    CAAttackUtil:DealDMG(plr, monster, magicDmg)

    if char:GetAttribute("Focus") >= 100 then
        char:SetAttribute("Focus", 0)

        BuffEffectsUtil:MagicVFX(monster)

        ServerUtil:ShowText(char, "BURST!", ClassBook.ClassInfo.Wizard.Color)

        CAAttackUtil:DealDMG(plr, monster, floor(baseDamage * 3), true)
    end

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.Knight(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    HarukaLib:AddAttr(char, "Guard", 15)
    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    if char:GetAttribute("Guard") > 100 then char:SetAttribute("Guard", 100) end

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.Rogue(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    HarukaLib:AddAttr(char, "RogueCri", 10)

    if char:GetAttribute("RogueCri") > 100 then char:SetAttribute("RogueCri", 100) end
    BuffEffectsUtil:RestoreManaByOrb(plr.Character)

    local result = CAAttackUtil:DealDMG(plr, monster, baseDamage)
    if result == "CriticalHit" then return end --- double crit disabled

    local exResult = CAAttackUtil:CriticalHit(plr, monster, baseDamage, char:GetAttribute("RogueCri"))
    if exResult == "CriticalHit" then char:SetAttribute("RogueCri", 0) end
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
        repeaterOrb.Parent = workspace.MapComponents.OrbHolders[plr.Name]
        Debris:AddItem(repeaterOrb, char:GetAttribute("OrbLifeTime"))

        local laser = instanceNew("Part")
        laser.Material = Enum.Material.Neon
        laser.CanCollide = false
        laser.CanTouch = false
        laser.CanQuery = false
        laser.Anchored = true
        laser.Color = fromRGB(9, 137, 207)
        laser.Size = v3New(0.5, 0.5, (orb.PrimaryPart.CFrame.Position - repeaterOrb.PrimaryPart.CFrame.Position).Magnitude)
        laser.CFrame = cfNew((orb.PrimaryPart.CFrame.Position + repeaterOrb.PrimaryPart.CFrame.Position) / 2, orb.PrimaryPart.CFrame.Position)
        laser.Parent = workspace.MapComponents.OrbHolders[plr.Name]
        Debris:AddItem(laser, 1)

        Events.ClientTween.Fire(plr, { Objs = { laser }, Goal = { Transparency = 1 }, TweenInfo = "half" })
    end

    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.Striker(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character
    local count = 0
    local orbs = workspace.MapComponents.OrbHolders[plr.Name]:GetChildren()

    for _, orb: Model in orbs do
        if orb.Name == "StrikerOrb" then count += 1 end
    end
    if count > 0 then
        Spawn(function()
            for _, orb: Model in orbs do
                if orb.Name ~= "StrikerOrb" then continue end

                local shockwave = RepS.Package.MagicAssets.Shockwave:Clone()
                shockwave.Transparency = 0.6
                shockwave.CFrame = char.PrimaryPart.CFrame * cfNew(0,0,-2) * cfAngles(0, rad(90), rad(90))
                shockwave.Parent = workspace
                Debris:AddItem(shockwave, 1)

                Events.ClientTween.FireAll({ Objs = { shockwave }, Goal = { Size = shockwave.Size + v3New(20, 0, 20), Transparency = 1 }, TweenInfo = "one" })

                wait(0.25)
                if orb and orb.PrimaryPart then plr.Character:PivotTo(orb.PrimaryPart.CFrame) end
            end
        end)
    end

    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

local function _createAlchemy(char: Model, color: string)
    local creation = instanceNew("BoolValue")
    creation.Name = color
    creation.Parent = char.AlchemistCreations

    local creations = char.AlchemistCreations:GetChildren()
    if #creations >= 3 then
        local r, g, b = 0, 0, 0
        for _, created: BoolValue in creations do
            if created.Name == "Red" then r += 1 end
            if created.Name == "Blue" then b += 1 end
            if created.Name == "Green" then g += 1 end
        end

        ServerUtil:ShowText(char, "ALCHEMY!", ClassBook.ClassInfo.Alchemist.Color)

        char.AlchemistCreations:ClearAllChildren()

        if r >= 3 then
            if not char.CharStats.TargetMonster.Value then return end

            BuffEffectsUtil:Burn(char, char.CharStats.TargetMonster.Value, 1, 12)

        elseif b >= 3 then
            BuffEffectsUtil:RestoreMana(char, char:GetAttribute("MaxMana"))

        elseif g >= 3 then
            BuffEffectsUtil:Heal(char, char.Humanoid.MaxHealth)

        elseif r == 1 and g == 1 and b == 1 then
            BuffEffectsUtil:MagicBuff(char, 3, 6)

        else
            BuffEffectsUtil:DefenseBuff(char, 30, 12)
        end
    end
end
function CAAttackUtil.AlchemistRed(plr: Player, monster: Model, baseDamage: number)
    _createAlchemy(plr.Character, "Red")

    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end
function CAAttackUtil.AlchemistBlue(plr: Player, monster: Model, baseDamage: number)
    _createAlchemy(plr.Character, "Blue")

    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end
function CAAttackUtil.AlchemistGreen(plr: Player, monster: Model, baseDamage: number)
    _createAlchemy(plr.Character, "Green")

    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.Illusionist(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    --// leave a clone
    local clone = RepS.Package.MagicAssets.IllusionClone:Clone() :: Model
    clone.PrimaryPart.CFrame = char.PrimaryPart.CFrame
	clone.Parent = workspace.MapComponents.OrbHolders[plr.Name]

	for _, child: BasePart in clone:GetChildren() do
        child.CFrame = char[child.Name].CFrame

        if child.Name == "Head" then
            child.CFrame = char.Head.CFrame * cfNew(0, 0.75, 0)
            child.CFrame = char.Head.CFrame * CFrame.fromEulerAnglesXYZ(0, 90, 0)
        end
	end

    --// explode
    local count = 0
    for _, child: Model in workspace.MapComponents.OrbHolders[plr.Name]:GetChildren() do
        if child.Name == "IllusionClone" then count += 1 end
    end

    if count >= 3 then
        for _, child: Model in workspace.MapComponents.OrbHolders[plr.Name]:GetChildren() do
            if child.Name == "IllusionClone" then
                local ignited = RepS.Package.MagicAssets.Ignited:Clone() :: BasePart
                ignited.Color = fromRGB(255, 255, 255)
                ignited.Transparency = 0.5
                ignited.CFrame = child.PrimaryPart.CFrame
                ignited.Parent = workspace
                Debris:AddItem(ignited, 1)

                Events.ClientTween.Fire(plr, { Objs = { ignited }, Goal = { Size = Vector3.one * 77, Transparency = 1 }, TweenInfo = "one" })

                child:Destroy()

                pcall(function()
                    local monsters = char.CharStats.TargetMonsters:GetChildren() :: table
                    for _, targetMonster: ObjectValue in monsters do
                        if not targetMonster.Value then continue end
                        if not targetMonster.Value.PrimaryPart then continue end

                        local explosionDMG = floor(baseDamage / 2)

                        ServerUtil:ShowNumber(targetMonster.Value, explosionDMG, ClassBook.ClassInfo[plr:GetAttribute("Class")].Color)

                        HarukaLib:AddAttr(targetMonster.Value, "Health", -explosionDMG)
                    end
                end)
            end
        end
    end

    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(char)
end

function CAAttackUtil.Juggernaut(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    HarukaLib:AddAttr(char, "Rage", 15)

    if char:GetAttribute("Rage") >= 100 then
        char:SetAttribute("Rage", 100)

        ServerUtil:ShowText(char, "RAGING!", ClassBook.ClassInfo.Juggernaut.Color)

        Spawn(function()
            while wait(0.015) do
                if char:GetAttribute("Rage") < 0 then return end

                HarukaLib:AddAttr(char, "Rage", -1)
            end
        end)

        local pos, pos2 = ServerUtil:GenerateOrbPos(monster), ServerUtil:GenerateOrbPos(monster)

        local juggHealOrb = RepS.Package.PlayerAttacks.JuggernautHealOrb:Clone() :: Model
        juggHealOrb.Owner.Value = plr.Character
        juggHealOrb:PivotTo(pos)
        juggHealOrb:SetAttribute("OrbLifeTime", char:GetAttribute("OrbLifeTime"))
        juggHealOrb.Parent = workspace.MapComponents.OrbHolders[plr.Name]
        Debris:AddItem(juggHealOrb, char:GetAttribute("OrbLifeTime"))

        local juggPierceOrb = RepS.Package.PlayerAttacks.JuggernautPierceOrb:Clone() :: Model
        juggPierceOrb.Owner.Value = plr.Character
        juggPierceOrb:PivotTo(pos2)
        juggPierceOrb:SetAttribute("OrbLifeTime", char:GetAttribute("OrbLifeTime"))
        juggPierceOrb.Parent = workspace.MapComponents.OrbHolders[plr.Name]
        Debris:AddItem(juggPierceOrb, char:GetAttribute("OrbLifeTime"))
    end

    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.JuggernautHeal(plr: Player)
    BuffEffectsUtil:Heal(plr.Character, plr.Character:GetAttribute("MaxHealth"))
end
function CAAttackUtil.JuggernautPierce(plr: Player, monster: Model)
    BuffEffectsUtil:Burn(plr.Character, monster, 1, 6)
end

function CAAttackUtil.Reaper(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    HarukaLib:AddAttr(char, "LifeStolen", 15)
    if char:GetAttribute("LifeStolen") >= 100 then
        char:SetAttribute("LifeStolen", 0)

        ServerUtil:ShowText(char, "LIFE STOLE!", ClassBook.ClassInfo.Reaper.Color)

        BuffEffectsUtil:Heal(char, char.Humanoid.MaxHealth)
        CAAttackUtil:DealDMG(plr, monster, char.Humanoid.Health)
    end

    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(plr.Character)
end

function CAAttackUtil.FireStaff(plr: Player, monster: Model)
    BuffEffectsUtil:Burn(plr.Character, monster, 1, 6)
end

return CAAttackUtil
