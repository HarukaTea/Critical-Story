--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Guard = require(RepS.Modules.Packages.Guard)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local cfNew = CFrame.new
local wait = task.wait

local levelCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))
local amountCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))

return function (context: table, monster: string, level: number, amount: number)
    local levelPass, levelWant = levelCheck(level)
    local amountPass, amountWant = amountCheck(amount)

    if not levelPass or not amountPass then
        return "I guess you typed incorrectly..."
    end
    if not AssetBook.MonsterInfo[monster] then
        return "Are you sure there is a monster called "..monster.."?"
    end
    if levelWant > 950 then
        return "Nah are you sure you can beat monsters that above level 950?"
    end
    if amountWant > 5 then
        return "Nah "..amountWant.." monsters will explode the server!"
    end

    local tempLocator = workspace.Monsters:FindFirstChild("GreenSlime", true)
    local locator = tempLocator:Clone() :: BasePart
    locator.Name = monster
    locator:ClearAllChildren()
    locator:SetAttribute("Levels", levelWant)
    locator:SetAttribute("CantRespawn", true)
    locator:SetAttribute("SubMonster", nil)
    locator.CFrame = context.Executor.Character.PrimaryPart.CFrame * cfNew(0, -2, 0)
    locator.Parent = workspace.Monsters

    local spawnedMonster = ServerUtil:SetupMonster(locator, levelWant)

    spawnedMonster:SetAttribute("InCombat", true)
    Spawn(function()
        wait(2)
        spawnedMonster:SetAttribute("InCombat", false)
    end)

    for _ = 1, amount - 1 do
        local subLocator = tempLocator:Clone() :: BasePart
        subLocator.Name = monster
        subLocator:ClearAllChildren()
        subLocator:SetAttribute("SubMonster", true)
        subLocator:SetAttribute("CantRespawn", true)
        subLocator:SetAttribute("Levels", levelWant)
        subLocator.CFrame = context.Executor.Character.PrimaryPart.CFrame * cfNew(0, -2, 0)
        subLocator.Parent = locator

        ServerUtil:SetupMonster(subLocator, levelWant)
    end

    return "Level "..levelWant.." "..AssetBook.MonsterInfo[monster].Name.." x"..amountWant.." spawned"
end