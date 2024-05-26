--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
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

--[[
    RNG this attack to be a critical attack, and return the result
]]
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

        Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Critical)
		ServerUtil:ShowText(char, "CRITICAL!", fromRGB(230, 241, 3))
	end

    return result
end

--[[
    Deal damage to monsters
]]
function CAAttackUtil:DealDMG(plr: Player, monster: Model, dmg: number)
    ServerUtil:ShowNumber(monster, dmg, AssetBook.ClassInfo[plr:GetAttribute("Class")].Color)

    HarukaLib:AddAttr(monster, "Health", -dmg)

    CAAttackUtil:CriticalHit(plr, monster, dmg)
end


function CAAttackUtil.Warrior(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

	HarukaLib:AddAttr(char, "Combo", 1)

	if char:GetAttribute("Combo") > 1 then
		local finalDamage = floor(baseDamage * char:GetAttribute("Combo"))

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
    arrow.Parent = workspace.MapComponents.OrbHolders[plr.Name]
    Debris:AddItem(arrow, char:GetAttribute("OrbLifeTime"))

    if char:GetAttribute("Stack") > 0 then
        --- bow dmg
        CAAttackUtil:DealDMG(plr, monster, baseDamage)

        --- arrow dmg
        for _ = char:GetAttribute("Stack"), 1, -1 do
            if monster:GetAttribute("Health") <= 0 then break end

            HarukaLib:AddAttr(char, "Stack", -1)

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
        CAAttackUtil:DealDMG(plr, monster, floor(baseDamage * 3))
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

        Events.ClientTween:Fire(plr, { laser }, { Transparency = 1 }, "half")
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

                Events.ClientTween:FireAll({ shockwave }, { Size = shockwave.Size + v3New(20, 0, 20), Transparency = 1 }, "one")

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

        char.AlchemistCreations:ClearAllChildren()

        if r >= 3 then
            if not char.CharStats.TargetMonster.Value then return end

            BuffEffectsUtil:Burn(char, char.CharStats.TargetMonster.Value, 12)

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

                Events.ClientTween:Fire(plr, { ignited }, { Size = Vector3.one * 77, Transparency = 1 }, "one")

                child:Destroy()

                ServerUtil:ShowNumber(monster, baseDamage, AssetBook.ClassInfo[plr:GetAttribute("Class")].Color)
                HarukaLib:AddAttr(monster, "Health", -baseDamage)
            end
        end

        BuffEffectsUtil:MagicBuff(char, 2, 6)
    end

    CAAttackUtil:DealDMG(plr, monster, baseDamage)

    BuffEffectsUtil:RestoreManaByOrb(char)
end

function CAAttackUtil.FireStaff(plr: Player, monster: Model)
    BuffEffectsUtil:Burn(plr.Character, monster, 6)
end

return CAAttackUtil
