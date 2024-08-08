--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)

local testRank = if game.PlaceId == AssetBook.WorldInfo.Mainworld then 124 else 2

return function (registry: table)
    registry:RegisterHook("BeforeRun", function(context)
        if context.Group == "Developer" and context.Executor:GetAttribute("Rank") < testRank then
            return "No permission for that!"

        elseif context.Group == "Moderator" and context.Executor:GetAttribute("Rank") < 126 then
            return "No permission for that!"

        elseif context.Group == "Owner" and context.Executor:GetAttribute("Rank") < 255 then
            return "No permission for that!"
        end
    end)
end
