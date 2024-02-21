--!nocheck

local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")

local Clock = require(RepS.Modules.Packages.Clock)
local Spawn = require(RepS.Modules.Packages.Spawn)

local wait = task.wait
local cfAngles = CFrame.Angles
local rad = math.rad
local yAxis = Vector3.yAxis

local function enableWorldAnims()
	local world = workspace:WaitForChild("Maps")

    for _, child in world:GetDescendants() do
        if child.Name == "Wings" and child.Parent.Name == "Windmill" then
			Clock(0.01, function()
				child:PivotTo(child.PrimaryPart.CFrame * cfAngles(rad(-1.5), 0, 0))
			end)

        elseif child.Name == "Sky Galleon" then
            Spawn(function()
                while true do
                    for _ = 1, 100 do
                        child:PivotTo(child.PrimaryPart.CFrame + yAxis * 0.03)
                        wait(0.01)
                    end
                    for _ = 1, 100 do
                        child:PivotTo(child.PrimaryPart.CFrame - yAxis * 0.03)
                        wait(0.01)
                    end
                end
            end)
        end
    end
end
enableWorldAnims()


local function dayNightCycle()
    local cycleTime, minutesInADay = 12 * 60, 24 * 60
    local startTime = tick() - (Lighting:GetMinutesAfterMidnight() / minutesInADay) * cycleTime
    local endTime = startTime + cycleTime
    local timeRatio, currentTime = minutesInADay / cycleTime, nil

    Clock(0.05, function()
        currentTime = tick()

        if currentTime > endTime then
            startTime = endTime
            endTime = startTime + cycleTime
        end

        Lighting:SetMinutesAfterMidnight((currentTime - startTime) * timeRatio)
    end)
end
dayNightCycle()
