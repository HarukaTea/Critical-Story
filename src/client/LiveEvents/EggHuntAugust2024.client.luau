--!nocheck

if workspace:GetAttribute("WorldType") ~= "Mainworld" then return end

local RepS = game:GetService("ReplicatedStorage")

local eggs = workspace:WaitForChild("MapComponents", 999).SecretEggs :: Folder

for _, egg: BasePart in eggs:GetChildren() do
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.Parent = egg

    clickDetector.MouseClick:Connect(function()
        RepS.Debris.FindEgg:FireServer()

        workspace.Sounds.SFXs.ArrowPick:Play()

        egg:Destroy()
    end)
end
