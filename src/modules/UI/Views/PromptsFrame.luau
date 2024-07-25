--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Prompt = require(RepS.Modules.UI.Components.Prompt)

local v2New, udNew = Vector2.new, UDim.new
local fromScale = UDim2.fromScale


local function PromptsFrame(self: table) : Frame
	local scope = self.scope :: Fusion.Scope

    return Components.Frame(scope, {
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.65, 0),
        Size = fromScale(1, 0.7),
        Name = "PromptsFrame",

        [Fusion.Children] = {
            Fusion.New(scope, "UIListLayout")({
                Padding = udNew(0.3, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            Fusion.ForPairs(scope, self.promptsList, function(_, localScope: Fusion.Scope, index: number, prompt: ProximityPrompt)
                return index, Prompt(prompt, index, localScope, self)
            end)
        },
    })
end

return PromptsFrame