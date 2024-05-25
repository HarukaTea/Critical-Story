--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local cfNew = CFrame.new
local wait = task.wait

return function (context: table, monster: string, level: number, amount: number)
    local check = HarukaLib:TypeCheck("MinMax", level, 0, 9999)
    local check2 = HarukaLib:TypeCheck("Integer", level)
    local check3 = HarukaLib:TypeCheck("MinMax", amount, 0, 9999)
    local check4 = HarukaLib:TypeCheck("Integer", amount)

    if not check or not check2 or not check3 or not check4 then
        return "I guess you typed incorrectly..."
    end
    if not AssetBook.MonsterInfo[monster] then
        return "Are you sure there is a monster called "..monster.."?"
    end
    if level > 1100 then
        return "Nah are you sure you can beat monsters that above level 950?"
    end
    if amount > 5 then
        return "Nah "..amount.." monsters will explode the server!"
    end

    local locator = RepS.Package.Unloads.MonsterLocator:Clone() :: BasePart
    locator.Name = monster
    locator:ClearAllChildren()
    locator:SetAttribute("Levels", level)
    locator:SetAttribute("CantRespawn", true)
    locator:SetAttribute("SubMonster", nil)
    locator.CFrame = context.Executor.Character.PrimaryPart.CFrame * cfNew(0, -2, 0)
    locator.Parent = workspace.Monsters

    local spawnedMonster = ServerUtil:SetupMonster(locator, level)

    spawnedMonster:SetAttribute("InCombat", true)
    Spawn(function()
        wait(2)
        spawnedMonster:SetAttribute("InCombat", false)
    end)

    for _ = 1, amount - 1 do
        local subLocator = RepS.Package.Unloads.MonsterLocator:Clone() :: BasePart
        subLocator.Name = monster
        subLocator:ClearAllChildren()
        subLocator:SetAttribute("SubMonster", true)
        subLocator:SetAttribute("CantRespawn", true)
        subLocator:SetAttribute("Levels", level)
        subLocator.CFrame = context.Executor.Character.PrimaryPart.CFrame * cfNew(0, -2, 0)
        subLocator.Parent = locator

        ServerUtil:SetupMonster(subLocator, level)
    end

    return "Level "..level.." "..AssetBook.MonsterInfo[monster].Name.." x"..amount.." spawned"
end