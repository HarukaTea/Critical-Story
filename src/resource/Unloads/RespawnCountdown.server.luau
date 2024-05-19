--!nocheck

local respawnTimer = script.Parent :: BasePart

local wait = task.wait

for i = 12, 0, -1 do
    respawnTimer.Timer.Text.Text = i
    wait(1)
end
