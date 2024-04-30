--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local OptionToggleBtn = require(RepS.Modules.UI.Components.OptionToggleBtn)

local AttributeChange = Fusion.AttributeChange

local fromScale = UDim2.fromScale
local clear = table.clear

local function SettingsFrame(self: table): Frame
	local potatoStoreParts = {}
	local playerSettings = self.playerSettings :: table

	Fusion.Hydrate(self.plr)({
		[AttributeChange("CombatMode")] = function(style: string)
			playerSettings.PublicCombat:set(style == "Public")
		end,
		[AttributeChange("Musics")] = function(state: boolean)
			playerSettings.Musics:set(state)

			SoundService.Musics.Volume = if state then 1 else 0
		end,
		[AttributeChange("SFXs")] = function(state: boolean)
			playerSettings.SFXs:set(state)

			SoundService.SFXs.Volume = if state then 1 else 0
		end,
		[AttributeChange("PotatoMode")] = function(state: boolean)
			playerSettings.PotatoMode:set(state)

			if state == false then
				for part: BasePart, material: Enum.Material in potatoStoreParts do
					if part.Parent then part.Material = material end
				end

				clear(potatoStoreParts)

			elseif state then
				for _, child: Instance in workspace.Maps:GetDescendants() do
					if child:IsA("BasePart") or child:IsA("UnionOperation") then
						potatoStoreParts[child] = child.Material

						child.Material = Enum.Material.Plastic
					end
				end
			end
		end,
		[AttributeChange("PlayerList")] = function(state: boolean)
			playerSettings.PlayerList:set(state)
		end,
	})

	return Components.Frame({
		Name = "Settings",
		Position = fromScale(0.496, 0.567),
		Size = fromScale(0.944, 0.627),
		Visible = false,

		[Fusion.Children] = {
			Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 3.856 }),
			Fusion.New("UIGridLayout")({
				CellPadding = fromScale(0.1, 0.1),
				CellSize = fromScale(0.4, 0.09),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),

			OptionToggleBtn("Musics", self),
			OptionToggleBtn("SFXs", self),
			OptionToggleBtn("PublicCombat", self),
			OptionToggleBtn("PotatoMode", self),
			OptionToggleBtn("PlayerList", self),
		},
	})
end

return SettingsFrame
