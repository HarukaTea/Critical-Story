--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New, peek = Fusion.Children, Fusion.New, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local clear = table.clear

local TEXTS = {
	Musics = "Musics",
	SFXs = "Sound Effects",
	PublicCombat = "Public Combat Mode",
	PartyCombat = "Party Combat Mode",
	PotatoMode = "Low Detail Mode",
	PlayerList = "Player List",
	InviteAccess = "Can Be Invited"
}

local function OptionFrame(id: string, self: table) : Frame
	return Components.Frame {
		Name = id,

		[Children] = {
			Components.TextLabel({
				Name = "Title",
				Size = fromScale(0.65, 1),
				Text = TEXTS[id],
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			Components.HoverImageButton({
				Name = "SwitchBG",
				BackgroundTransparency = 0,
				AnchorPoint = v2New(),
				Position = fromScale(0.7, 0),
				Size = fromScale(0.2, 1),

				[Fusion.OnEvent("MouseButton1Click")] = function()
					local plr, playerSettings = self.plr :: Player, self.playerSettings :: table

					if peek(self.playerSettings[id]) then
						workspace.Sounds.SFXs.SwitchOff:Play()
					else
						workspace.Sounds.SFXs.SwitchOn:Play()
					end

					if id == "PublicCombat" then
						if plr:GetAttribute("CombatMode") == "Public" then
							plr:SetAttribute("CombatMode", "Solo")
						else
							plr:SetAttribute("CombatMode", "Public")
						end

						return

					elseif id == "PartyCombat" then
						if plr:GetAttribute("CombatMode") == "Party" then
							plr:SetAttribute("CombatMode", "Solo")
						else
							plr:SetAttribute("CombatMode", "Party")
						end

						return

					elseif id == "PotatoMode" then
						if plr:GetAttribute("PotatoMode") then
							for part, material in self.potatoStoreParts do
								if part.Parent then part.Material = material end
							end

							clear(self.potatoStoreParts)

							plr:SetAttribute("PotatoMode", false)
							return
						end

						for _, child in workspace.Maps:GetDescendants() do
							if child:IsA("BasePart") then
								self.potatoStoreParts[child] = child.Material
								child.Material = Enum.Material.Plastic
							end
						end

					elseif id == "InviteAccess" then
						Events.ChangeInviteAccess:Fire()
					end

					self.plr:SetAttribute(id, not self.plr:GetAttribute(id))
				end,

				[Children] = { Components.RoundUICorner() }
			}),
			Components.Frame({
				Name = "Switch",
				BackgroundTransparency = 0,
				AnchorPoint = v2New(),
				Size = fromScale(0.1, 1),
				BackgroundColor3 = Fusion.Tween(Fusion.Computed(function(use)
					return if use(self.playerSettings[id]) then fromRGB(80, 161, 118) else fromRGB(214, 71, 107)
				end), AssetBook.TweenInfos.threeHalf),
				Position = Fusion.Tween(Fusion.Computed(function(use)
					return if use(self.playerSettings[id]) then fromScale(0.8, 0) else fromScale(0.7, 0)
				end), AssetBook.TweenInfos.twiceHalf),

				[Children] = { Components.RoundUICorner() }
			})
		}
	}
end

local function SettingsFrame(self: table): Frame
	return Components.Frame({
		Name = "Settings",
		Position = fromScale(0.496, 0.567),
		Size = fromScale(0.944, 0.627),
		Visible = false,

		[Children] = {
			New("UIAspectRatioConstraint")({ AspectRatio = 3.856 }),
			New("UIGridLayout")({
				CellPadding = fromScale(0.1, 0.1),
				CellSize = fromScale(0.4, 0.09),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),

			OptionFrame("Musics", self),
			OptionFrame("SFXs", self),
			OptionFrame("PublicCombat", self),
			OptionFrame("PartyCombat", self),
			OptionFrame("PotatoMode", self),
			OptionFrame("PlayerList", self),
			OptionFrame("InviteAccess", self)
		},
	})
end

return SettingsFrame
