--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local PanelFilter = require(RepS.Modules.UI.Components.PanelFilter)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local udNew =  UDim.new
local fromScale = UDim2.fromScale

local function CharacterFrame(self: table): Frame
	local scope = self.scope :: Fusion.Scope

	return Components.Frame(scope, {
		Name = "Character",
		Position = fromScale(0.496, 0.567),
		Size = fromScale(0.944, 0.627),

		Visible = Computed(scope, function(use: Fusion.Use)
			return use(self.frames.Character)
		end),

		[Children] = {
			New(scope, "UIAspectRatioConstraint")({ AspectRatio = 3.389 }),

			Fusion.New(scope, "Frame")({
				Name = "LeftPanel",
				BackgroundTransparency = 1,
				Size = fromScale(0.3, 1),

				[Children] = {
					Fusion.New(scope, "UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = udNew(0.04, 0)
					}),

					PanelFilter("Attributes", "Character", self),
					PanelFilter("Points", "Character", self),
					PanelFilter("Class", "Character", self),
					PanelFilter("Talents", "Character", self)
				}

			}),
			Fusion.New(scope, "Frame")({
				Name = "RightPanel",
				BackgroundTransparency = 1,
				Position = fromScale(0.7, 0),
				Size = fromScale(0.3, 1),

			})
		},
	})
end

return CharacterFrame
