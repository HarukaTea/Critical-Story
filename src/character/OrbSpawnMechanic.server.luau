--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local Add, Empty = HarukaLib.Bin()
local orbSpawnAdd, orbSpawnEmpty = HarukaLib.Bin()

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local orbFolders = workspace.MapComponents.OrbHolders :: Folder

local random = math.random

--// Connections
local function _placeOrb(orb: Model, pos: CFrame)
    orb.Owner.Value = char
    orb:PivotTo(pos)
    orb:SetAttribute("OrbLifeTime", char:GetAttribute("OrbLifeTime"))
    orb.Parent = orbFolders[char.Name]

    Debris:AddItem(orb, char:GetAttribute("OrbLifeTime"))
end
local function _spawnOrb()
    local monster, orbAttack = char.CharStats.TargetMonster :: ObjectValue, RepS.Package.PlayerAttacks :: Folder
    local class = plr:GetAttribute("Class") :: string

    if monster.Value and orbFolders:FindFirstChild(char.Name) and char.Humanoid.Health > 0 then
        local orb
        if class == "Alchemist" then
            orb = orbAttack["AlchemistOrb" .. random(1, 3)]:Clone() :: Model
        else
            orb = orbAttack[class .. "Orb"]:Clone() :: Model
        end
        _placeOrb(orb, ServerUtil:GenerateOrbPos(monster.Value))
    end
end
local function _spawnExtraOrb()
    local monster = char.CharStats.TargetMonster :: ObjectValue

    if monster.Value and orbFolders:FindFirstChild(char.Name) and char.Humanoid.Health > 0 then
        ---// extra orbs from items
        for attr: string, val: any in char.CharStats.ExtraOrbs:GetAttributes() do
            if not val then continue end

            _placeOrb(RepS.Package.PlayerAttacks[attr]:Clone(), ServerUtil:GenerateOrbPos(monster.Value))
        end
    end
end
local function orbSpawnHandler(state: boolean)
    if state then
        local spawnTime = char:GetAttribute("OrbSpawnTime")

        if char:GetAttribute("CanSpawnMultiOrb") then
            for _ = 1, 2 do _spawnOrb() end
        end

        orbSpawnEmpty()

		orbSpawnAdd(HarukaLib.Clock(spawnTime, function()
			if char:GetAttribute("InCombat") then _spawnOrb() end
		end))
        orbSpawnAdd(HarukaLib.Clock(spawnTime + 4, function()
            if char:GetAttribute("InCombat") then _spawnExtraOrb() end
        end))
	else
		orbSpawnEmpty()
	end
end
Add(HarukaLib:Hydrate(char, {
    ["Attr-InCombat"] = orbSpawnHandler
}))
Add(orbSpawnEmpty)

--// Clear
char.Humanoid.Died:Once(Empty)
