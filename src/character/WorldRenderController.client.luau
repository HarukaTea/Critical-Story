--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Octree = require(RepS.Modules.Packages.DataLibs.Octree)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Add, Empty = HarukaLib.Bin()

local treeTree = Octree.new()
local treeNodes = {}

local MAX_RENDER_DISTANCE = 555

local char = script.Parent :: Model
local plr = Players.LocalPlayer

--// Setups
for _, obj: Instance in workspace:WaitForChild("Maps", 999):GetDescendants() do
    if obj:IsA("Model") and string.find(obj.Name, "Tree") then
        table.insert(treeNodes, treeTree:CreateNode(obj:GetPivot().Position, obj))

        obj.Parent = RepS.Debris.Trees
    end
end
for _, obj: Instance in RepS.Debris.Trees:GetChildren() do
    if obj:IsA("Model") and string.find(obj.Name, "Tree") then
        table.insert(treeNodes, treeTree:CreateNode(obj:GetPivot().Position, obj))
    end
end
Add(treeNodes)

--// Connections

Add(HarukaLib:Hydrate(plr, {
    ["Attr-TreeOptimizations"] = function(state: boolean)
        MAX_RENDER_DISTANCE = if state then 555 else math.huge - 1
    end
}))

Add(HarukaLib.Clock(0.5, function()
    if not char.PrimaryPart then return end

    local nearbyTrees = treeTree:RadiusSearch(char.PrimaryPart.Position, MAX_RENDER_DISTANCE)
    for _, tree: Model in nearbyTrees do
        if not tree then continue end
        if tree:IsDescendantOf(workspace) then continue end

        tree.Parent = workspace.Maps

        --- despawn
        Spawn(function()
            while tree do
                task.wait()
                if not tree then break end

                local treeDistance = plr:DistanceFromCharacter(tree:GetPivot().Position)
                if treeDistance > MAX_RENDER_DISTANCE then tree.Parent = RepS.Debris.Trees end
            end
        end)
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
