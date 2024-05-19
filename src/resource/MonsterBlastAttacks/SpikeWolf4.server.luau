--!nocheck

local model = script.Parent :: Model

local wait = task.wait

pcall(function()
    wait(0.5)
    model:AddTag("MonsterDMG")

    wait(2)
    model:Destroy()
end)
