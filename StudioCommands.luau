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

local locator = workspace.Monsters["Tundra"]["Lava Wolf"]:Clone()
locator:ClearAllChildren()
locator:SetAttribute("Levels", 100)
locator.CFrame = workspace.IceX_Dust.PrimaryPart.CFrame * CFrame.new(0, -2, 0)
locator.Parent = workspace.Monsters

local monster = game.ReplicatedStorage.Package.MonsterModels[locator.Name]:Clone() :: Model
monster:PivotTo(CFrame.new(locator.Position))
monster:SetAttribute("Levels", 100)
monster.Head.TierDisplay.Text.Text = monster.Name
monster.Head.TierDisplay.Level.Text = "Level " .. 100
monster.Head.TierDisplay.Enabled = true

if locator:GetAttribute("SubMonster") then
    monster.Head.TierDisplay.Enabled = false
    monster:SetAttribute("SubMonster", true)
end

monster:SetAttribute("MaxHealth", math.floor(100 ^ 2.2) + 99)
monster:SetAttribute("Health", monster:GetAttribute("MaxHealth"))
monster:SetAttribute("EXP", (math.floor(100 ^ 1.25) + 25) * if workspace:GetAttribute("2XEXPEvent") then 2 else 1)
monster:SetAttribute("Damage", 5 * 100)
monster:SetAttribute("InCombat", false)
