--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ItemBook = require(RepS.Modules.Data.ItemBook)
local Guard = require(RepS.Modules.Packages.Guard)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 9999))

return function (_, players: table, item: string, amount: number)
    local amountPass, amountWanted = numberCheck(amount)

    if not amountPass then
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
            ServerUtil:GiveItem(plr, item, amountWanted)
        end

        return "Gived "..amountWanted.."x "..item.."!"
    end
end
