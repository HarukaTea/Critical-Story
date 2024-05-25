--!nocheck

local CS = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Octree = require(RepS.Modules.Packages.DataLibs.Octree)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Add, Empty = HarukaLib.Bin()
local monsterTree = Octree.new()

local char = script.Parent :: Model
local monsterNodes = {}

local wait = task.wait
local random, rad = math.random, math.rad
local cfAngles = CFrame.Angles


---// Setup
local function setup()
	for _, monster: Model in workspace:WaitForChild("MapComponents", 999):GetDescendants() do
		if monster:HasTag("Monster") and monster.PrimaryPart and not monster:GetAttribute("SubMonster") then
			monsterNodes[#monsterNodes + 1] = monsterTree:CreateNode(monster.PrimaryPart.Position, monster)
		end
	end
	local function _addMonster(monster: Model)
		wait()
		if monster:GetAttribute("SubMonster") then return end

		repeat wait() until monster.PrimaryPart --// Low-end devices, uhhhh!

		monsterNodes[#monsterNodes + 1] = monsterTree:CreateNode(monster.PrimaryPart.Position, monster)
	end
	local function _removeMonster(monster: Model)
		for index: number, node: any in monsterNodes do
			if node:GetObject() == monster then
				node:Destroy()

				table.remove(monsterNodes, index)
			end
		end
	end
	Add(CS:GetInstanceAddedSignal("Monster"):Connect(_addMonster))
	Add(CS:GetInstanceRemovedSignal("Monster"):Connect(_removeMonster))

    Add(HarukaLib.Clock(1.5, function()
        if not char.PrimaryPart then return end

        local nearbyMonsters = monsterTree:RadiusSearch(char.PrimaryPart.Position, 159.9)
        for _, monster: Model in nearbyMonsters do
            if not monster then continue end
            if not monster.PrimaryPart then continue end
            if monster:GetAttribute("InCombat") then continue end
            if monster:GetAttribute("CantRotate") then continue end

            Spawn(function()
                local rotating = random(5, 20)
                local direction = random(-2, 2)

                pcall(function()
                    for _ = 1, rotating do
                        monster.PrimaryPart.CFrame *= cfAngles(0, rad(direction * 5), 0)
                        wait(0.01)
                    end
                end)
            end)
        end
    end))
end
setup()

--// Clear
char.Humanoid.Died:Once(function()
	Empty()

	for _, node: any in monsterNodes do
		node:Destroy()
	end
	monsterTree = nil
	monsterNodes = nil
end)
