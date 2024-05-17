--!nocheck
--!optimize 2
--!native

local SS = game:GetService("ServerStorage")

return function (context)
    SS.Resources.Unloads.Freecam:Clone().Parent = context.Executor.Character

    return "Freecam enabled!"
end
