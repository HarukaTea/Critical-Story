--!nocheck

local model = script.Parent :: Model

local wait = task.wait

pcall(function()
    wait(9)
    model:RemoveTag("MonsterDMG")
end)
