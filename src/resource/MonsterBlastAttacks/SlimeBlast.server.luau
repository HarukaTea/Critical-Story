
local model = script.Parent

local wait = task.wait

wait(8)
model:RemoveTag("MonsterDMG")

if model:HasTag("TurnBase") then return end

wait(2)
model:Destroy()
