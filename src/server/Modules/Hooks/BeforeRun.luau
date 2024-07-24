--!nocheck

local isTestGame = if game.PlaceId == 17553875545 then true else false
local testerPerm = if isTestGame then 2 else 125

return function (registry: table)
    registry:RegisterHook("BeforeRun", function(context)
        if context.Group == "Developer" and context.Executor:GetAttribute("Rank") < testerPerm then
            return "No permission for that!"

        elseif context.Group == "Moderator" and context.Executor:GetAttribute("Rank") < 126 then
            return "No permission for that!"

        elseif context.Group == "Owner" and context.Executor:GetAttribute("Rank") < 255 then
            return "No permission for that!"
        end
    end)
end
