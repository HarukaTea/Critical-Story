--!nocheck
--!optimize 2
--!native

local model = script.Parent :: Model

local wait = task.wait

pcall(function()
    for _, descendant: BasePart in model:GetDescendants() do
        if descendant:IsA("UnionOperation") then descendant.Color = model:GetAttribute("SlimeColor") end
    end

    wait(0.2)
    model:Destroy()
end)
