--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(ServerScriptService.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local healDMG = script:GetAttribute("HealDMG") :: number
local power = script:GetAttribute("Power") :: number

local wait = task.wait

local times = 6 / 0.75
local trueHealDMG = math.ceil(healDMG * power) :: number

for _ = times, 0, -1 do
    HarukaLib:AddAttr(char, "Mana", trueHealDMG)

    local restoreEff = RepS.Package.Effects.RestoreEffect:Clone() :: BasePart
    restoreEff.Parent = workspace
    Debris:AddItem(restoreEff, 1)

    ServerUtil:ShowNumber(char, trueHealDMG, Color3.fromRGB(65, 179, 255))
    wait(0.75)
end

script:Destroy()
