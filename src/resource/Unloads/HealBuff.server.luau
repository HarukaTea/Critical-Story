--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(ServerScriptService.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
if script:GetAttribute("IsMob") then char = script.Parent.Parent :: Model end

local healDMG = script:GetAttribute("HealDMG") :: number
local power = script:GetAttribute("Power") :: number

local wait = task.wait

local times = 6 / 0.75
local trueHealDMG = math.ceil(healDMG * power) :: number

for _ = times, 0, -1 do
    if script:GetAttribute("IsMob") then
        HarukaLib:AddAttr(char, "Health", trueHealDMG)
    else
        char.Humanoid.Health += trueHealDMG
    end

    local healEff = RepS.Package.Effects.HealEffect:Clone() :: BasePart
    healEff.Parent = char.PrimaryPart
    Debris:AddItem(healEff, 1)

    ServerUtil:ShowNumber(char, trueHealDMG, Color3.fromRGB(100, 255, 100))
    wait(0.75)
end

script:Destroy()
