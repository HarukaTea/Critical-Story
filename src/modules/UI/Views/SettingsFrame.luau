--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local SettingToggleBtn = require(RepS.Modules.UI.Components.SettingToggleBtn)

local fromScale = UDim2.fromScale
local clear = table.clear

local function SettingsFrame(self: table): Frame
	local scope = self.scope
	local potatoStoreParts = {}
	local playerSettings = self.playerSettings :: table

	self.emptyList[#self.emptyList + 1] = HarukaLib:Hydrate(self.plr, {
		["Attr-CombatMode"] = function(newMode: string)
			playerSettings.PublicCombat:set(if newMode == "Public" then true else false)
		end,
		["Attr-Musics"] = function(state: boolean)
			playerSettings.Musics:set(state)

			SoundService.Musics.Volume = if state then 1 else 0
		end,
		["Attr-SFXs"] = function(state: boolean)
			playerSettings.SFXs:set(state)

			SoundService.SFXs.Volume = if state then 1 else 0
		end,
		["Attr-PotatoMode"] = function(state: boolean)
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
				for _, child: Instance in workspace.MapComponents:GetDescendants() do
					if child:IsA("BasePart") or child:IsA("UnionOperation") then
						potatoStoreParts[child] = child.Material

						child.Material = Enum.Material.Plastic
					end
				end
			end
		end,
		["Attr-PlayerList"] = function(state: boolean)
			playerSettings.PlayerList:set(state)
		end,
		["Attr-MapDetails"] = function(state: boolean)
			playerSettings.MapDetails:set(state)

			Signals.EnableMapDetails:Fire(if state then "Enable" else "Disable")
		end
	})

	return Components.Frame(scope, {
		Name = "Settings",
		Position = fromScale(0.496, 0.567),
		Size = fromScale(0.944, 0.627),

		Visible = Fusion.Computed(scope, function(use)
			return use(self.frames.Settings)
		end),

		[Fusion.Children] = {
			Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 3.856 }),
			Fusion.New(scope, "UIGridLayout")({
				CellPadding = fromScale(0.1, 0.1),
				CellSize = fromScale(0.4, 0.09),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),

			SettingToggleBtn("Musics", self),
			SettingToggleBtn("SFXs", self),
			SettingToggleBtn("PublicCombat", self),
			SettingToggleBtn("PotatoMode", self),
			SettingToggleBtn("PlayerList", self),
			SettingToggleBtn("MapDetails", self)
		},
	})
end

return SettingsFrame
