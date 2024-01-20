--!nocheck

local SSS = game:GetService("ServerScriptService")

local HarukaFrameworkServer = require(SSS.Modules.HarukaFrameworkServer)

local AssetBook = require(game:GetService("ReplicatedStorage").Modules.Data.AssetBook)
local Guard = HarukaFrameworkServer.Guard
local ServerUtil = HarukaFrameworkServer.ServerUtil

local stringCheck = Guard.Check(Guard.String)
local numberCheck = Guard.Check(Guard.NumberMinMax(1, 9999))

return function (_, plr, item, amount)
    local itemPass, itemName = stringCheck(item)
    local amountPass, amountWanted = numberCheck(amount)

    if not itemPass then
        return "I guess you typed incorrectly..."
    end
    if not amountPass then
        return "Wrong amount!"
    end

    if not AssetBook.Items.ItemName[itemName] then
        return "There is no item named "..itemName..", are you sure you typed correctly?"

    else
        ServerUtil:GiveItem(plr, itemName, amountWanted)

        return "Gived "..amountWanted.." "..itemName.." to "..plr.DisplayName
    end
end
