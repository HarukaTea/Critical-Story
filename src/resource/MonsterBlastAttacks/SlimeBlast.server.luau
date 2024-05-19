--!nocheck

local model = script.Parent

local wait = task.wait

pcall(function()
    wait(8)
    model:RemoveTag("MonsterDMG")

    wait(2)
    model:Destroy()
end)
