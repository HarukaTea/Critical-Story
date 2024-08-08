--!nocheck

local model = script.Parent :: Model

local wait = task.wait

pcall(function()
    wait(0.5)
    model.Fang1:AddTag("MonsterDMG")
    model.Fang2:AddTag("MonsterDMG")

    wait(2)
    model:Destroy()
end)
