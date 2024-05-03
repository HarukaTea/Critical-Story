--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ItemBook = require(RepS.Modules.Data.ItemBook)
local Guard = require(RepS.Modules.Packages.Guard)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local stringCheck = Guard.Check(Guard.String)
local numberCheck = Guard.Check(Guard.NumberMinMax(0, 9999))

return function (_, plr: Player, item: string, amount: number)
    local itemPass, itemName = stringCheck(item)
    local amountPass, amountWanted = numberCheck(amount)

    if not itemPass then
        return "I guess you typed incorrectly..."
    end
    if not amountPass then
        return "Wrong amount!"
    end

    if not ItemBook:IsItemExist(itemName) and itemName ~= "all" then
        return "There is no item named "..itemName..", are you sure you typed correctly?"

    elseif itemName == "all" then
        for _, everyItem: table in ItemBook.Items do
            ServerUtil:GiveItem(plr, everyItem.ItemId, everyItem.MaxAmount)
        end

        return "Gived all items to "..plr.DisplayName
    else
        ServerUtil:GiveItem(plr, itemName, amountWanted)

        return "Gived "..amountWanted.." "..itemName.." to "..plr.DisplayName
    end
end
