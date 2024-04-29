--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Clock = require(RepS.Modules.Packages.Clock)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model
local map = workspace:WaitForChild("Maps") :: Folder

local yAxis = Vector3.yAxis
local cfAngles = CFrame.Angles
local rad = math.rad
local wait = task.wait

local function worldAnims()
    for _, child: Instance in map:GetDescendants() do
        if child.Name == "Wings" and child.Parent.Name == "Windmill" then
			Clock(0.01, function()
				if not char then return end
				if not char.PrimaryPart then return end
				if (child.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude > 555 then return end

				child:PivotTo(child.PrimaryPart.CFrame * cfAngles(rad(-1.5), 0, 0))
			end)

        elseif child.Name == "Sky Galleon" then
            Spawn(function()
                while wait() do
					if not char then continue end
					if not char.PrimaryPart then continue end
					if (child.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude > 256 then continue end

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
