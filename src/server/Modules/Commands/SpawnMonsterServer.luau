--!strict

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Guard = require(RepS.Modules.Packages.Guard)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local cfNew = CFrame.new

local levelCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))
local amountCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))

return function (context, level, amount)
    local levelPass, levelWant = levelCheck(level)
    local amountPass, amountWant = amountCheck(amount)

    if not levelPass or not amountPass then
        return "I guess you typed incorrectly..."
    end

    if levelWant > 950 then
        return "Nah are you sure you can beat monsters that above level 950?"
    end

    local locator = workspace.Monsters["Initus Bay"]["Spike Fox"]:Clone() :: BasePart
    locator:ClearAllChildren()
    locator:SetAttribute("Levels", levelWant)
    locator:SetAttribute("CantRespawn", true)
    locator.CFrame = context.Executor.Character.PrimaryPart.CFrame * cfNew(0, -2, 0)
    locator.Parent = workspace.Monsters

    RepS.Package.Unloads.CombatEnd:Clone().Parent = locator

    ServerUtil:SetupMonster(locator, levelWant)
    ServerUtil:ConnectMob(locator)

    for _ = 1, amount do
        local subLocator = workspace.Monsters["Initus Bay"]["Spike Fox"]:Clone() :: BasePart

        subLocator:ClearAllChildren()
        subLocator:SetAttribute("SubMonster", true)
        subLocator:SetAttribute("CantRespawn", true)
        subLocator:SetAttribute("Levels", levelWant)
        subLocator.CFrame = context.Executor.Character.PrimaryPart.CFrame * cfNew(0, -2, 0)
        subLocator.Parent = locator

        RepS.Package.Unloads.CombatEnd:Clone().Parent = subLocator

        ServerUtil:SetupMonster(subLocator, levelWant)
        ServerUtil:ConnectMob(subLocator)
    end

    return "Level "..levelWant.." Spike Fox x"..amountWant.." Spawned"
end