--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local PanelFilter = require(RepS.Modules.UI.Components.PanelFilter)
local SettingToggleBtn = require(RepS.Modules.UI.Components.SettingToggleBtn)

local Children, Computed = Fusion.Children, Fusion.Computed

local udNew =  UDim.new
local fromScale = UDim2.fromScale

local function ListPadding(self: table) : UIListLayout
	return Fusion.New(self.scope, "UIListLayout")({
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = udNew(0.04, 0)
	})
end

local function SettingsFrame(self: table): Frame
	local scope = self.scope :: Fusion.Scope

	return Components.Frame(scope, {
		Name = "Settings",
		Position = fromScale(0.496, 0.531),
		Size = fromScale(0.944, 0.7),

		Visible = Fusion.Computed(scope, function(use: Fusion.Use)
			return use(self.frames.Settings)
		end),

		[Fusion.Children] = {
			Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 3.389 }),

			Fusion.New(scope, "Frame")({
				Name = "LeftPanel",
				BackgroundTransparency = 1,
				Size = fromScale(0.3, 1),

				[Children] = {
					ListPadding(self),

					PanelFilter("Graphics", "Settings", self),
					PanelFilter("Combat", "Settings", self),
					PanelFilter("Sounds", "Settings", self),
					PanelFilter("Misc", "Settings", self)
				}
			}),
			Fusion.New(scope, "Frame")({
				Name = "RightPanel",
				BackgroundTransparency = 1,
				Position = fromScale(0.3, 0),
				Size = fromScale(0.7, 1),

				[Children] = {
					Components.Frame(scope, {
						Name = "Graphics",

						Visible = Computed(scope, function(use: Fusion.Use)
							return use(self.panelFilterFrames.Settings.Graphics)
						end),

						[Children] = {
							ListPadding(self),

							SettingToggleBtn("MapDetails", self),
							SettingToggleBtn("PotatoMode", self),
							SettingToggleBtn("MapShadows", self),
							SettingToggleBtn("TreeOptimizations", self)
						}
					}),
					Components.Frame(scope, {
						Name = "Combat",

						Visible = Computed(scope, function(use: Fusion.Use)
							return use(self.panelFilterFrames.Settings.Combat)
						end),

						[Children] = {
							ListPadding(self),

							SettingToggleBtn("PublicCombat", self),
						}
					}),
					Components.Frame(scope, {
						Name = "Sounds",

						Visible = Computed(scope, function(use: Fusion.Use)
							return use(self.panelFilterFrames.Settings.Sounds)
						end),

						[Children] = {
							ListPadding(self),

							SettingToggleBtn("Musics", self),
							SettingToggleBtn("SFXs", self)
						}
					}),
					Components.Frame(scope, {
						Name = "Misc",

						Visible = Computed(scope, function(use: Fusion.Use)
							return use(self.panelFilterFrames.Settings.Misc)
						end),

						[Children] = {
							ListPadding(self),

							SettingToggleBtn("PlayerList", self),
						}
					}),
				}
			})
		},
	})
end

return SettingsFrame
