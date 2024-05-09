--!nocheck
--!optimize 2
--!native

local model = script.Parent

local wait = task.wait

wait(8)
model:RemoveTag("MonsterDMG")

wait(2)
model:Destroy()
