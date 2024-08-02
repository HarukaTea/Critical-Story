--!nocheck

return function (registry: table)
    registry:RegisterHook("BeforeRun", function(context)
        if context.Group == "Developer" and context.Executor:GetAttribute("Rank") < 2 then
            return "No permission for that!"

        elseif context.Group == "Moderator" and context.Executor:GetAttribute("Rank") < 126 then
            return "No permission for that!"

        elseif context.Group == "Owner" and context.Executor:GetAttribute("Rank") < 255 then
            return "No permission for that!"
        end
    end)
end
