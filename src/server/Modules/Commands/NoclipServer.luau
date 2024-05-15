--!nocheck
--!optimize 2
--!native

local SS = game:GetService("ServerStorage")

local instanceNew = Instance.new

return function (_, plr: Player)
    local tool = instanceNew("HopperBin")
    tool.Name = "Noclip"

    SS.Resources.Unloads.NoclipControls:Clone().Parent = tool

    tool.Parent = plr.Backpack

    return "Noclip has given!"
end
