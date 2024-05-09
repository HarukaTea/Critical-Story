
local char = script.Parent :: Model
local humanoid = char.Humanoid :: Humanoid

local wait = task.wait

while wait(0.5) do
    if humanoid.Health <= 0 or humanoid.Health >= humanoid.MaxHealth then
        char:SetAttribute("Healing", false)
        break
    end

    if char:GetAttribute("HitCD") <= 0 then
        char:SetAttribute("Healing", true)

        humanoid.Health += 1
    end
end

wait()
script:Destroy()
