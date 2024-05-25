--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

return function (_, players: table, item: string, amount: number)
    local check = HarukaLib:TypeCheck("MinMax", amount, 0, 999)

    if not check then
        return "Wrong amount!"
    end

    if not ItemBook:IsItemExist(item) and item ~= "all" then
        return "There is no item named "..item..", are you sure you typed correctly?"

    elseif item == "all" then
        for _, plr: Player in players do
            for _, everyItem: table in ItemBook.Items do
                ServerUtil:GiveItem(plr, everyItem.ItemId, if everyItem.IsSkill then 1 else 999)
            end
        end

        return "Gived all items!"
    else
        for _, plr: Player in players do
            ServerUtil:GiveItem(plr, item, amount)
        end

        return "Gived "..amount.."x "..item.."!"
    end
end
