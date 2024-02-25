--- store some quick cmds for studio

for _, child in workspace.Monsters:GetDescendants() do
    if child:GetAttribute("EnemyLocation") then
        child:SetAttribute("EnemyLocation", nil)
        child:SetAttribute("MonsterLocation", true)
    end
end

for _, child in workspace.Monsters:GetDescendants() do
    if child:GetAttribute("MonsterLocation") then
        child:SetAttribute("MonsterLocation", nil)
        child:AddTag("MonsterLocation")
    end
end

for _, child in workspace.Maps:GetDescendants() do
    if child:FindFirstChild("Terrain") then
        child:SetAttribute("Terrain", true)

    elseif child.Name == "Terrain" and (child:IsA("BoolValue") or child:IsA("IntValue")) then
        child:Destroy()
    end
end

for _, child in workspace.MapComponents.Statues:GetChildren() do
    child.Prompt.Class.ActionText = child.Prompt.Class:GetAttribute("Class")
end

for _, child in workspace.MapComponents.Chests:GetChildren() do
    child.Giver:SetAttribute("IsChest", nil)
end

for _, child in workspace:GetDescendants() do
    if child.Name == "Tree" then
        for _, descendant in child:GetDescendants() do
            if descendant:IsA("BasePart") then descendant.Transparency = 0 end
        end
    end
end

for _, child in workspace:GetDescendants() do
    child:SetAttribute("IsDamage", nil)
end

for _, child in workspace.Maps:GetDescendants() do
    if child:IsA("Folder") and child.Name == "Terrain" then
        for _, descendant in child:GetDescendants() do
            if descendant:IsA("Weld") then descendant:Destroy() end
        end
    end
end
