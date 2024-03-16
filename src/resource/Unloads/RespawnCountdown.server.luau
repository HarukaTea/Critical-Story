--!strict

local respawnTimer = script.Parent

local wait = task.wait

for i = 12, 0, -1 do
    respawnTimer.Timer.Text.Text = i
    wait(1)
end
