--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Events = require(SSS.Modules.Data.ServerEvents)
local FastSpawn = HarukaFrameworkClient.FastSpawn
local HarukaLib = HarukaFrameworkClient.HarukaLib
local LootPlan = require(RepS.Modules.Packages.colbert2677_lootplan.lootplan)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)

local AttackUtil = {}

local wait, delay = task.wait, task.delay
local clear, insert = table.clear, table.insert
local instanceNew = Instance.new
local fromRGB = Color3.fromRGB
local cfNew, v3New = CFrame.new, Vector3.new
local cfLookAt, cfAngles = CFrame.lookAt, CFrame.Angles
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

		local criEff = RepS.Package.Effects.CriticalHitEffect:Clone() :: ParticleEmitter
		criEff.Parent = monster.PrimaryPart

		ServerUtil:ShowText(plr.Character, "CRITICAL!", fromRGB(230, 241, 3))

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
		delay(0.4, function()
			comboEff.Enabled = false
		end)
		Debris:AddItem(comboEff, 1)

        AttackUtil:DealDMG(plr, monster, finalDamage)
	else
		AttackUtil:DealDMG(plr, monster, baseDamage)
	end
end

function AttackUtil.Archer(plr: Player, monster: Model, baseDamage: number)
    local char = plr.Character

    local arrow = RepS.Package.PlayerAttacks.ArrowOrb:Clone() :: Model
    arrow.Owner.Value = char
    arrow:PivotTo(ServerUtil:GenerateOrbPos(monster))
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
end

function AttackUtil.Repeater(plr: Player, monster: Model, baseDamage: number, orb: Model)
    if not orb:GetAttribute("IsSpawnedOneForRepeater") then
        local pos = ServerUtil:GenerateOrbPos(monster)
        local repeaterOrb = RepS.Package.PlayerAttacks.RepeaterOrb:Clone() :: Model

        repeaterOrb.Owner.Value = plr.Character
        repeaterOrb:PivotTo(pos)
        repeaterOrb.Parent = workspace.MapComponents.OrbFolders[plr.Name]
        repeaterOrb:SetAttribute("IsSpawnedOneForRepeater", true)
        Debris:AddItem(repeaterOrb, 5)

        FastSpawn(function()
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
end

function AttackUtil.Striker(plr: Player, monster: Model, baseDamage: number, originOrb: Model)
    local char = plr.Character
    local orbs = workspace.MapComponents.OrbFolders[plr.Name]:GetChildren()
    local strikerOrbs = {}

    for _, strikerOrb in orbs do
        if strikerOrb.Name == "StrikerOrb" then
            insert(strikerOrbs, strikerOrb)
        end
    end

    AttackUtil:DealDMG(plr, monster, baseDamage)

    wait(0.2)
    local function _findNearestOrb()
        local foundOrb = nil
        local distance = 200

        for _, orb in strikerOrbs do
            if orb ~= originOrb and orb:FindFirstChild("Base") then
                local realMagnitude = (orb.Base.Position - char.PrimaryPart.Position).Magnitude

                if realMagnitude < distance then
                    foundOrb = orb.Base
                    distance = realMagnitude
                end
            end
        end

        if foundOrb then return foundOrb.Parent end
    end
    local nearestOrb = _findNearestOrb()

    if nearestOrb then
        local vel = instanceNew("BodyVelocity")
        vel.MaxForce = Vector3.one * math.huge
        vel.Name = "StrikerDashVel"
        vel.Velocity = char.PrimaryPart.CFrame.LookVector * 0
        vel.Parent = char.PrimaryPart
        Debris:AddItem(vel, 0.8)

        char.Humanoid.AutoRotate = false
        char.PrimaryPart.CFrame = cfLookAt(char.PrimaryPart.Position, nearestOrb.Base.Position)

        local originHRPCFrame = char.PrimaryPart.CFrame
        local shockwave = RepS.Package.MagicAssets.Shockwave:Clone()
        shockwave.Transparency = 0.6
        shockwave.CFrame = char.PrimaryPart.CFrame * cfNew(0,0,-2) * cfAngles(0, rad(90), rad(90))
        shockwave.Parent = char
        Debris:AddItem(shockwave, 1)
        Events.ClientTween:Fires({ shockwave }, { Size = shockwave.Size + v3New(20, 0, 20), Transparency = 1 }, "one")

        char.PrimaryPart.CFrame = nearestOrb.Base.CFrame

        for i = 1,3 do
            FastSpawn(function()
                local strikerDash = RepS.Package.MagicAssets.StrikerDash:Clone()
                strikerDash:PivotTo(originHRPCFrame)
                strikerDash.Parent = char
                Debris:AddItem(strikerDash, 1)

                local tweenObjs = {}
                for _, child in strikerDash:GetChildren() do
                    if child:IsA("Part") and child.Name ~= "HumanoidRootPart" then
                        child.Transparency = 0.6
                        insert(tweenObjs, child)
                    end
                end
                Events.ClientTween:Fires(tweenObjs, { Transparency = 1 }, "one")

                local newHRPCFrame = char.PrimaryPart.CFrame
                Events.ClientTween:Fires({ strikerDash.PrimaryPart }, { Position = newHRPCFrame.Position }, "one")
            end)
            wait(0.1)
        end
    end

    wait(0.3)
    for _, child in char.PrimaryPart:GetChildren() do
        if child.Name == "StrikerDashVel" then child:Destroy() end
    end

    local shockwave2 = RepS.Package.MagicAssets.Shockwave:Clone()
    shockwave2.Transparency = 0.7
    shockwave2.CFrame = char.PrimaryPart.CFrame * cfNew(0,0,-2) * cfAngles(0, rad(90), rad(90))
    shockwave2.Parent = char
    Debris:AddItem(shockwave2, 1)
    Events.ClientTween:Fires({ shockwave2 }, { Size = shockwave2.Size + v3New(20, 0, 20), Transparency = 1 }, "one")

    local bv = instanceNew("BodyVelocity")
    bv.MaxForce = Vector3.one * math.huge
    bv.Velocity = char.PrimaryPart.CFrame.UpVector * 50
    bv.Parent = char.PrimaryPart
    Debris:AddItem(bv, 0.05)
end

function AttackUtil.AlchemistRed(plr: Player, monster: Model)
    SkillUtil:RestoreManaByOrb(plr)

    local magicDmg = plr.Character:GetAttribute("Magic")
    AttackUtil:DealDMG(plr, monster, magicDmg)
end
function AttackUtil.AlchemistBlue(plr: Player, monster: Model)
    SkillUtil:RestoreManaByOrb(plr)

    local magicDmg = plr.Character:GetAttribute("Magic")
    AttackUtil:DealDMG(plr, monster, magicDmg)
end
function AttackUtil.AlchemistGreen(plr: Player, monster: Model)
    SkillUtil:RestoreManaByOrb(plr)

    local magicDmg = plr.Character:GetAttribute("Magic")
    AttackUtil:DealDMG(plr, monster, magicDmg)
end

function AttackUtil.Illusionist(plr: Player, monster: Model)
    SkillUtil:RestoreManaByOrb(plr)

    local magicDmg = plr.Character:GetAttribute("Magic")
    AttackUtil:DealDMG(plr, monster, magicDmg)
end

return AttackUtil
