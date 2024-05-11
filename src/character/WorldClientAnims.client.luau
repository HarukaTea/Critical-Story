--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent :: Model
local map = workspace:WaitForChild("Maps") :: Folder

local yAxis = Vector3.yAxis
local cfAngles = CFrame.Angles
local rad = math.rad
local wait, spawn = task.wait, task.spawn

local function worldAnims()
    for _, child: Instance in map:GetDescendants() do
        if child.Name == "Wings" and child.Parent.Name == "Windmill" then
			Add(HarukaLib.Clock(0.01, function()
				if not char then return end
				if not char.PrimaryPart then return end
				if (child.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude > 555 then return end

				child:PivotTo(child.PrimaryPart.CFrame * cfAngles(rad(-1.5), 0, 0))
			end))

        elseif child.Name == "Sky Galleon" then
            Add(spawn(function()
                while wait() do
					if not char then continue end
					if not char.PrimaryPart then continue end
					if (child.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude > 159.9 then continue end

                    for _ = 1, 100 do
                        child:PivotTo(child.PrimaryPart.CFrame + yAxis * 0.03)
                        wait(0.01)
                    end
                    for _ = 1, 100 do
                        child:PivotTo(child.PrimaryPart.CFrame - yAxis * 0.03)
                        wait(0.01)
                    end
                end
            end))
        end
    end
end
worldAnims()

local function onDead()
    Empty()

    script:Destroy()
end
char.Humanoid.Died:Once(onDead)
