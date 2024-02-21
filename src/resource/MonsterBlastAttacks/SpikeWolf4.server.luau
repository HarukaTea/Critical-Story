--!nocheck

local model = script.Parent

local wait = task.wait

wait(0.5)
model.Fang1:SetAttribute("IsDamage", true)
model.Fang2:SetAttribute("IsDamage", true)
model:SetAttribute("IsDamage", true)

wait(2)
model:Destroy()