--!nocheck

local CS = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Octree = require(RepS.Modules.Packages.Octree)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent :: Model

local wait = task.wait
local random, rad = math.random, math.rad
local cfAngles = CFrame.Angles

---// Setup
local function setup()
    local monsterTree = Octree.new()

	for _, monster: Model in workspace:WaitForChild("Monsters"):GetDescendants() do
		if monster:HasTag("Monster") and monster.PrimaryPart then monsterTree:CreateNode(monster.PrimaryPart.Position, monster) end
	end
	local function _handleMonster(monster: Model)
		wait()
        repeat wait() until monster.PrimaryPart --// Low-end device players, I highly respect them

		monsterTree:CreateNode(monster.PrimaryPart.Position, monster)
	end
	Add(CS:GetInstanceAddedSignal("Monster"):Connect(_handleMonster))

    Add(HarukaLib.Clock(1.5, function()
        if not char.PrimaryPart then return end

        local nearbyMonsters = monsterTree:RadiusSearch(char.PrimaryPart.Position, 159.9)
        for _, monster: Model in nearbyMonsters do
            if not monster then continue end
            if not monster.PrimaryPart then continue end
            if monster:GetAttribute("InCombat") then continue end
            if monster:GetAttribute("CantRotate") then continue end

            Spawn(function()
                wait(random(0, 5) / 10)
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
local function onDead()
    Empty()

    script:Destroy()
end
char.Humanoid.Died:Once(onDead)
