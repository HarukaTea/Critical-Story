--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local map = workspace:WaitForChild("Maps", 999) :: Folder

local yAxis = Vector3.yAxis
local cfAngles = CFrame.Angles
local rad = math.rad
local wait, spawn = task.wait, task.spawn

local function worldAnims()
    for _, child: Instance in map:GetDescendants() do
        if child.Name == "Wings" and child.Parent.Name == "Windmill" then
			HarukaLib.Clock(0.01, function()
				child:PivotTo(child.PrimaryPart.CFrame * cfAngles(rad(-1.5), 0, 0))
			end)

        elseif child.Name == "Sky Galleon" then
            spawn(function()
                while wait() do
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
worldAnims()
