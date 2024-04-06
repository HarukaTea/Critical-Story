--!strict
--!optimize 2
--!native

local isMainGame = if game.PlaceId == 12343565896 then true else false

return function (registry)
    registry:RegisterHook("BeforeRun", function(context)
        local testerRank = if isMainGame then 124 else 1

        if context.Group == "Testers" and context.Executor:GetAttribute("Rank") <= testerRank then
            return "No permission for that!"

        elseif context.Group == "DefaultAdmin" and context.Executor:GetAttribute("Rank") < 255 then
            return "No permission for that!"
        end
    end)
end
