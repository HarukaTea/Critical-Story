--- store some quick cmds for studio

for _, child in workspace.Monsters:GetDescendants() do
    if child:GetAttribute("EnemyLocation") then
        child:SetAttribute("EnemyLocation", nil)
        child:SetAttribute("MonsterLocation", true)
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