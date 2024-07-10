--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local cfNew = CFrame.new

return function (context: table, monster: string, level: number, amount: number, respawnable: boolean)
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
    if typeof(respawnable) ~= "boolean" then
        return "Respawnable must be a boolean value!"
    end

    local locator = RepS.Package.Unloads.MonsterLocator:Clone() :: BasePart
    locator.Name = monster
    locator:ClearAllChildren()
    locator:SetAttribute("Levels", level)
    locator:SetAttribute("CantRespawn", if respawnable then nil else true)
    locator:SetAttribute("SubMonster", nil)
    locator.CFrame = context.Executor.Character.PrimaryPart.CFrame * cfNew(0, -2, 0)
    locator.Transparency = 1
    locator.Parent = workspace.Monsters

    for _ = 1, amount - 1 do
        local subLocator = RepS.Package.Unloads.MonsterLocator:Clone() :: BasePart
        subLocator.Name = monster
        subLocator:ClearAllChildren()
        subLocator:SetAttribute("SubMonster", true)
        subLocator:SetAttribute("CantRespawn", if respawnable then nil else true)
        subLocator:SetAttribute("Levels", level)
        subLocator.CFrame = context.Executor.Character.PrimaryPart.CFrame * cfNew(0, -2, 0)
        subLocator.Transparency = 1
        subLocator.Parent = locator
    end

    return "Level "..level.." "..AssetBook.MonsterInfo[monster].Name.." x"..amount.." spawned"
end