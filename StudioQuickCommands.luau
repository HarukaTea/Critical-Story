
for _, child in workspace:GetDescendants() do

end

for _, child in workspace.Maps:GetChildren() do
    if child:IsA("Model") then
        local folder = Instance.new("Folder")
        folder.Name = child.Name
        folder.Parent = workspace.Maps

        for _, mapPart in child:GetChildren() do
            mapPart.Parent = folder
        end

        child:Destroy()
    end
end