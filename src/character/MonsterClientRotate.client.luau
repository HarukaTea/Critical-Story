--!nocheck
--!optimize 2
--!native

local CS = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")

local Clock = require(RepS.Modules.Packages.Clock)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model

local wait = task.wait
local random, rad = math.random, math.rad
local cfAngles = CFrame.Angles
local tFind, remove = table.find, table.remove

--- add all mobs
local monsters = {} :: { Model }
for _, monster: Model in workspace:WaitForChild("Monsters"):GetDescendants() do
    if monster:HasTag("Monster") then monsters[#monsters + 1] = monster end
end
local function _handleMonster(monster: Model)
    wait()
    if tFind(monsters, monster) then
        remove(monsters, tFind(monsters, monster))
    else
        monsters[#monsters + 1] = monster
    end
end
CS:GetInstanceAddedSignal("Monster"):Connect(_handleMonster)
CS:GetInstanceRemovedSignal("Monster"):Connect(_handleMonster)

Clock(1.5, function()
    for _, monster: Model in monsters do
        if monster.PrimaryPart and not monster:GetAttribute("InCombat") then
            if (char.PrimaryPart.Position - monster.PrimaryPart.Position).Magnitude <= 159.9 then
                Spawn(function()
                    local rotating = random(5, 20)
                    local direction = random(-2, 2)

                    wait(random(0, 6) / 10)
                    for _ = 1, rotating do
                        if not monster and monster.PrimaryPart then break end

                        monster.PrimaryPart.CFrame *= cfAngles(0, rad(direction * 5), 0)
                        wait(0.01)
                    end
                end)
            end
        end
    end
end)