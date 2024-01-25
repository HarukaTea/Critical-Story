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

local instanceNew, v3New = Instance.new, Vector3.new
local one, yAxis = Vector3.one, Vector3.yAxis

local function combatCheck(char: Model, plr: Player) : boolean
    if not char:GetAttribute("InCombat") then
        Events.CreateHint:Fire(plr, "You can only do this when in combat!")
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

    Events.CastClassSkill:Fire(plr, 20, "Class")
    Events.PlayAnimation:Fire(plr, "RogueSlash")

    char:SetAttribute("RogueCritical", 100)

    SkillUtil:AttackBuff(plr, 2, 3)
end

--[[
    Armor Shredder - Step backwards and shoot out 6 bullets rapidly that deal neutral damage
]]
function CSCombat.Repeater()

end

--[[
    Harpoon Strike - Throw a spear forward, disable you for a while, fling you to the spear's position once hits
]]
function CSCombat.Striker()

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
