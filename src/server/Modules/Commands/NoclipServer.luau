--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local instanceNew = Instance.new

return function (_, plr: Player)
    local tool = instanceNew("HopperBin")
    tool.Name = "Noclip"

    RepS.Resources.Unloads.NoclipControls:Clone().Parent = tool

    tool.Parent = plr.Backpack

    return "Noclip has given!"
end
