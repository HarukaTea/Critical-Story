
local model = script.Parent

local wait = task.wait

wait(8)
model:SetAttribute("IsDamage", nil)

wait(2)
model:Destroy()