--!strict

local model = script.Parent

local wait = task.wait

wait(0.5)
model:AddTag("MonsterDMG")

wait(2)
model:Destroy()