--!nocheck

local model = script.Parent

local wait = task.wait

model.WolfSound:Play()

wait(0.5)
model.Fang1:SetAttribute("IsDamage")
model.Fang2:SetAttribute("IsDamage")

wait(2)
model:Destroy()