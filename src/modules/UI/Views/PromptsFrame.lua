--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local Fusion = HarukaFrameworkClient.Fusion

local Prompt = require(RepS.Modules.UI.Components.Prompt)

local v2New, udNew = Vector2.new, UDim.new
local fromScale = UDim2.fromScale

--[[
    TODO: multi-prompt actions
]]

local function PromptsFrame(self: table) : Frame
    return Components.Frame({
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.65, 0),
        Size = fromScale(1, 0.7),
        Name = "PromptsFrame",

        [Fusion.Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0.2, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            Fusion.ForValues(self.promptsList, function(use, prompt)
                return Prompt(prompt, 1)
            end, Fusion.cleanup)
        },
    })
end

return PromptsFrame