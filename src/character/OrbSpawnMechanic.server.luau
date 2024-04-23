--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Fusion = require(RepS.Modules.Packages.Fusion)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local random = math.random

--// Connections
local function orbSpawnHandler(state: boolean)
    local orbFolders = workspace.MapComponents.OrbFolders :: Folder

    local function _placeOrb(orb: Model, pos: CFrame)
        orb.Owner.Value = char
        orb:PivotTo(pos)
        orb:SetAttribute("OrbLifeTime", 6)
        orb.Parent = orbFolders[char.Name]

        Debris:AddItem(orb, 6)
    end
    local function _spawnOrb(isSpawned: boolean?)
        local monster, orbAttack = char.CharStats.TargetMonster :: ObjectValue, RepS.Package.PlayerAttacks :: Folder
        local isInCombat, class = char:GetAttribute("InCombat") :: boolean, plr:GetAttribute("Class") :: string

        if monster.Value and isInCombat and orbFolders:FindFirstChild(char.Name) and char.Humanoid.Health > 0 then
            local orb
            if class == "Alchemist" then
                orb = orbAttack["AlchemistOrb" .. random(1, 3)]:Clone() :: Model
            elseif class == "Archer" then
                orb = if random(1, 2) == 1 then orbAttack.ArcherOrb:Clone() else orbAttack.ArrowOrb:Clone()
            else
                orb = orbAttack[class .. "Orb"]:Clone() :: Model
            end
            _placeOrb(orb, ServerUtil:GenerateOrbPos(monster.Value))

            --- extra orbs from items
            if not isSpawned then
                for attr, val in char.CharStats.ExtraOrbs:GetAttributes() do
                    if not val then continue end

                    _placeOrb(orbAttack[attr]:Clone(), ServerUtil:GenerateOrbPos(monster.Value))
                end
            end
        end
    end

    if state and char:GetAttribute("InCombat") then
        for _ = 1, char:GetAttribute("OrbSpawnAmount") do
            _spawnOrb()
        end
	end
end

Fusion.Hydrate(char)({
    [Fusion.AttributeChange("AttackingTime")] = function(newState: boolean)
        orbSpawnHandler(newState)
    end
})
