--!nocheck
--!optimize 2
--!native

local model = script.Parent :: Model

local wait = task.wait

wait(0.5)
model:AddTag("MonsterDMG")

wait(2)
model:Destroy()