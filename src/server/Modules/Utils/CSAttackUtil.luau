--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)

local CSCombat = {}

local wait = task.wait
local instanceNew, v3New = Instance.new, Vector3.new
local one, yAxis = Vector3.one, Vector3.yAxis
local cfNew, cfAngles = CFrame.new, CFrame.Angles
local rad = math.rad

local function combatCheck(char: Model, plr: Player) : boolean
    if not char:GetAttribute("InCombat") then
        Events.CreateHint:Fire(plr, "You can only do this when in combat!", "Error")
        return false
    end

    return true
end

function CSCombat.Warrior(char: Model)
    local plr = Players:GetPlayerFromCharacter(char)
    local HRP = char.PrimaryPart

    Events.CastClassSkill:Fire(plr, 8, "Class")

    local bv = instanceNew("BodyVelocity")
    bv.MaxForce = one * 99999999
    bv.Velocity = HRP.CFrame.LookVector + yAxis * 70
    bv.Parent = HRP
    Debris:AddItem(bv, 0.05)

    local jumpEff = RepS.Package.MagicAssets.JumpEffect:Clone()
    jumpEff.CFrame = HRP.CFrame
    jumpEff.Parent = workspace
    Debris:AddItem(jumpEff, 1)

    Events.ClientTween:Fires({ jumpEff }, { Transparency = 1, Size = v3New(15, 1, 15) }, "half")
end

function CSCombat.Archer(char: Model)
    local plr = Players:GetPlayerFromCharacter(char)

    if combatCheck(char, plr) == false then return end

    Events.PlayAnimation:Fire(plr, "ArcherCharge")
    Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.ArrowPick)
    Events.CastClassSkill:Fire(plr, 12, "Class")

    HarukaLib:Add(char, "Arrows", 1)

    if char.CharStats.TargetMonster.Value then
        local orb = RepS.Package.PlayerAttacks.PoisonArcherOrb:Clone() :: Model
        orb.Owner.Value = char
        orb:PivotTo(ServerUtil:GenerateOrbPos(char.CharStats.TargetMonster.Value))
        orb:SetAttribute("OrbLifeTime", 8)
        orb.Parent = workspace.MapComponents.OrbFolders[char.Name]

        Debris:AddItem(orb, 8)
    end
end

function CSCombat.Wizard(char: Model)
    local plr = Players:GetPlayerFromCharacter(char)

    if combatCheck(char, plr) == false then return end

    Events.CastClassSkill:Fire(plr, 16, "Class")
    Events.MagicCasted:Fire(plr)
    RepS.Resources.Items.WizardFireBall:Clone().Parent = char.CharStats.Items
end


function CSCombat.Knight(char: Model)
    local plr = Players:GetPlayerFromCharacter(char)

    Events.CastClassSkill:Fire(plr, 25, "Class")
    Events.PlayAnimation:Fire(plr, "KnightParry")

    RepS.Resources.Items.RecoveryWind:Clone().Parent = char.CharStats.Items
end


function CSCombat.Rogue(char: Model)
    local plr = Players:GetPlayerFromCharacter(char)

    if combatCheck(char, plr) == false then return end

    Events.CastClassSkill:Fire(plr, 20, "Class")
    Events.PlayAnimation:Fire(plr, "RogueSlash")

    char:SetAttribute("RogueCritical", 100)

    SkillUtil:AttackBuff(plr, 2, 3)
end


function CSCombat.Repeater(char: Model)
    local plr = Players:GetPlayerFromCharacter(char)

    if combatCheck(char, plr) == false then return end

    local monster = char.CharStats.TargetMonster.Value
    if not monster then return end

    for _ = 1, 3 do
        local pos = ServerUtil:GenerateOrbPos(monster)
        local repeaterOrb = RepS.Package.PlayerAttacks.RepeaterOrb:Clone() :: Model

        repeaterOrb.Owner.Value = char
        repeaterOrb:PivotTo(pos)
        repeaterOrb:SetAttribute("RepeaterSpawned", true)
        repeaterOrb:SetAttribute("OrbLifeTime", 5)
        repeaterOrb.Parent = workspace.MapComponents.OrbFolders[plr.Name]

        Debris:AddItem(repeaterOrb, 5)
    end

    Events.CastClassSkill:Fire(plr, 15, "Class")
    Events.PlayAnimation:Fire(plr, "RepeaterFire")

    SkillUtil:AttackBuff(plr, 2, 3)
end

function CSCombat.Striker(char: Model)
    local plr = Players:GetPlayerFromCharacter(char)

    --- checks
    if combatCheck(char, plr) == false then return end
    local orbFolder = workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name)
    if not orbFolder then return end

    local monster = char.CharStats.TargetMonster.Value
    if not monster then return end

    Events.CastClassSkill:Fire(plr, 15, "Class")

    local orb = orbFolder:FindFirstChild("StrikerOrb")
    local bp = instanceNew("BodyPosition")
    bp.Name = "DashVel"
    bp.D = 500
    bp.MaxForce = v3New(1, 1, 1) * 100000

    if orb and orb:GetAttribute("IsOrb") then
        bp.Position = orb.Base.Position
        bp.Parent = char.PrimaryPart

        Debris:AddItem(bp, 0.3)

    else
        local pos = ServerUtil:GenerateOrbPos(monster)
        local strikerOrb = RepS.Package.PlayerAttacks.StrikerOrb:Clone() :: Model

        strikerOrb.Owner.Value = char
        strikerOrb:PivotTo(pos)
        strikerOrb:SetAttribute("OrbLifeTime", 8)
        strikerOrb:SetAttribute("IsOrb", true)
        strikerOrb.Parent = workspace.MapComponents.OrbFolders[plr.Name]

        Debris:AddItem(strikerOrb, 8)

        wait()
        bp.Position = strikerOrb.Base.Position
        bp.Parent = char.PrimaryPart

        Debris:AddItem(bp, 0.3)
    end

    local shockwave = RepS.Package.MagicAssets.Shockwave:Clone() :: MeshPart
    shockwave.Transparency = 0.6
    shockwave.CFrame = char.PrimaryPart.CFrame * cfNew(0,0,-2) * cfAngles(0, rad(90), rad(90))
    shockwave.Parent = char
    Debris:AddItem(shockwave, 1)

    Events.ClientTween:Fires({ shockwave }, { Size = shockwave.Size + v3New(20, 0, 20), Transparency = 1 }, "one")
end

--[[
    Potions Clash - Create an AoE that deals damage, deals more damage and apply effect depend on your research stage
]]
function CSCombat.Alchemist()

end

--[[
    Replica - give yourself Alternate for a while and recast the lastest active used.
]]
function CSCombat.Illusionist()

end

return CSCombat
