--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local char = script.Parent :: Model

local wait = task.wait

while wait(0.15) do
    if char:GetAttribute("Shield") >= char:GetAttribute("MaxShield") then
        char:SetAttribute("Repairing", false)
        break
    end

    if char:GetAttribute("HitCD") <= 0 then
        char:SetAttribute("Repairing", true)

        HarukaLib:Add(char, "Shield", 1)
    end
end

wait()
script:Destroy()
