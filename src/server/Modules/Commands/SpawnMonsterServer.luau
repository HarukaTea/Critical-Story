--!nocheck

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

    if amountWant > 10 then
        return "Bruh you are trying to explode the server!!!"
    end
    if levelWant > 950 then
        return "Nah are you sure you can beat monsters that above level 950?"
    end

    local locator = workspace.Monsters["Fox Forest"]["Spike Fox"]:Clone()
    locator:ClearAllChildren()
    locator:SetAttribute("Levels", levelWant)
    locator:SetAttribute("CantRespawn", true)
    locator.CFrame = context.Executor.Character.PrimaryPart.CFrame * cfNew(0, -2, 0)
    locator.Parent = workspace.Monsters

    ServerUtil:SetupMonster(locator, levelWant)

    for _ = 1, amount do
        local subLocator = workspace.Monsters["Fox Forest"]["Spike Fox"]:Clone()

        subLocator:ClearAllChildren()
        subLocator:SetAttribute("SubMonster", true)
        subLocator:SetAttribute("CantRespawn", true)
        subLocator:SetAttribute("Levels", levelWant)
        subLocator.CFrame = context.Executor.Character.PrimaryPart.CFrame * cfNew(0, -2, 0)
        subLocator.Parent = locator

        ServerUtil:SetupMonster(subLocator, levelWant)
    end

    return "Level "..levelWant.." Spike Fox x"..amountWant.." Spawned"
end