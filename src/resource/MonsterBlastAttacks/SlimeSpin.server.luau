--!strict

local model = script.Parent :: Model

local wait = task.wait

for _, descendant in model:GetDescendants() do
    if descendant:IsA("BasePart") then
        descendant.Color = model:GetAttribute("SlimeColor")
    end
end

wait(0.2)
model:Destroy()
