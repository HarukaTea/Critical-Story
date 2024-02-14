--!nocheck

return function (registry)
    registry:RegisterHook("BeforeRun", function(context)
        -- if context.Group == "Testers" and context.Executor:GetAttribute("Rank") <= 1 then
        --     return "No permission for that!"

        if context.Group == "DefaultAdmin" and context.Executor:GetAttribute("Rank") < 255 then
            return "No permission for that!"
        end
    end)
end