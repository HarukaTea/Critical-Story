--!nocheck

return function (registry: table)
    registry:RegisterHook("BeforeRun", function(context)
        if context.Group == "Testers" and context.Executor:GetAttribute("Rank") < 2 then
            return "No permission for that!"

        elseif context.Group == "Moderators" and context.Executor:GetAttribute("Rank") < 125 then
            return "No permission for that!"

        elseif context.Group == "DefaultAdmin" and context.Executor:GetAttribute("Rank") < 255 then
            return "No permission for that!"
        end
    end)
end
