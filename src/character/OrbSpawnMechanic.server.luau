--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local random = math.random

--// Connections
local stopSpawn = nil
local function orbSpawnHandler(state: boolean)
    local orbFolders = workspace.MapComponents.OrbFolders :: Folder

    local function _placeOrb(orb: Model, pos: CFrame)
        orb.Owner.Value = char
        orb:PivotTo(pos)
        orb:SetAttribute("OrbLifeTime", char:GetAttribute("OrbLifeTime"))
        orb.Parent = orbFolders[char.Name]

        Debris:AddItem(orb, orb:GetAttribute("OrbLifeTime"))
    end
    local function _spawnOrb(isSpawned: boolean?)
        local monster, orbAttack = char.CharStats.TargetMonster :: ObjectValue, RepS.Package.PlayerAttacks :: Folder
        local isInCombat, class = char:GetAttribute("InCombat") :: boolean, plr:GetAttribute("Class") :: string

        if monster.Value and isInCombat and orbFolders:FindFirstChild(char.Name) and char.Humanoid.Health > 0 then
            local orb
            if class == "Alchemist" then
                orb = orbAttack["AlchemistOrb" .. random(1, 3)]:Clone() :: Model
            else
                orb = orbAttack[class .. "Orb"]:Clone() :: Model
            end
            _placeOrb(orb, ServerUtil:GenerateOrbPos(monster.Value))

            --- extra orbs from items
            if not isSpawned then
                for attr: string, val: any in char.CharStats.ExtraOrbs:GetAttributes() do
                    if not val then continue end

                    _placeOrb(orbAttack[attr]:Clone(), ServerUtil:GenerateOrbPos(monster.Value))
                end
            end
        end
    end

    if state then
        local spawnTime = char:GetAttribute("OrbSpawnTime") :: number

		stopSpawn = HarukaLib.Clock(spawnTime, function()
			if char:GetAttribute("OrbAttackingTime") and char:GetAttribute("InCombat") then _spawnOrb() end
		end)
	else
		if stopSpawn then stopSpawn() end

        stopSpawn = nil
	end
end
local Empty = HarukaLib:Hydrate(char, {
    ["Attr-OrbAttackingTime"] = orbSpawnHandler
})

local function onDead()
    if stopSpawn then stopSpawn() end
    stopSpawn = nil

    Empty()

    script:Destroy()
end
char.Humanoid.Died:Once(onDead)
