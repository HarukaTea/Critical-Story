
--- tree solid
for _, child in workspace:GetDescendants() do
    if child:IsA("Model") and child.Name == "Tree" then
        for _, descendant in child:GetDescendants() do
            if descendant:IsA("BasePart") then descendant.Transparency = 0 end
        end
    end
end

for _, child in workspace.MonsterModels:GetDescendants() do
    if child:IsA("BasePart") then
        if child.Name ~= "HumanoidRootPart" then child.CanCollide = false end
    end
end
for _, child in workspace.MonsterModels:GetDescendants() do
    if child:IsA("BillboardGui") then
        child:Destroy()
    end
end

for _, child in workspace:GetDescendants() do
    if child:IsA("ProximityPrompt") then child.HoldDuration = 0 end
end

for _, child in workspace.MapComponents.Statues:GetChildren() do
    child.Prompt.Class.ActionText = child.Name

    for attr, _ in child.Prompt.Class:GetAttributes() do
        child.Prompt.Class:SetAttribute(attr, nil)
    end
end
for _, child in workspace.MapComponents.Chests:GetChildren() do
    child.Giver.ItemName:Destroy()
    child.Giver.Opened:Destroy()
end

for _, child in workspace.Maps:GetChildren() do
    if child:IsA("Model") then
        local folder = Instance.new("Folder")
        folder.Name = child.Name
        folder.Parent = workspace.Maps

        for _, mapPart in child:GetChildren() do
            if mapPart.Name == "Models" then
                local modelsContainer = Instance.new("Folder")
                modelsContainer.Name = "Models"
                modelsContainer.Parent = folder

                for _, mapDescendants in mapPart:GetChildren() do
                    mapDescendants.Parent = modelsContainer
                end

                mapPart:Destroy()
                continue
            end
            if mapPart.Name == "Terrain" then
                local terrainContainer = Instance.new("Folder")
                terrainContainer.Name = "Terrain"
                terrainContainer:AddTag("Terrain")
                terrainContainer.Parent = folder

                for _, mapDescendants in mapPart:GetChildren() do
                    if mapDescendants:IsA("IntValue") and mapDescendants.Name == "Terrain" then
                        mapDescendants:Destroy()
                        continue
                    end

                    mapDescendants.Parent = terrainContainer
                end

                mapPart:Destroy()
                continue
            end
            mapPart.Parent = folder
        end

        child:Destroy()
    end
end