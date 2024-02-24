--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New, Value, AttributeChange, Tween, Computed, OnEvent, peek =
	Fusion.Children,
	Fusion.New,
	Fusion.Value,
	Fusion.AttributeChange,
	Fusion.Tween,
	Fusion.Computed,
	Fusion.OnEvent,
	Fusion.peek

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
	local stroke_trans = Fusion.Value(1)

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

				[OnEvent("MouseEnter")] = function()
					stroke_trans:set(0)
				end,
				[OnEvent("MouseLeave")] = function()
					stroke_trans:set(1)
				end,
				[OnEvent("MouseButton1Click")] = function()
					local plr = self.plr :: Player

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

				[Children] = {
					Components.RoundUICorner(),
					Components.UIStroke({
						Thickness = 3,
						Enabled = true,
						Transparency = Tween(Computed(function(use)
							return use(stroke_trans)
						end), AssetBook.TweenInfos.twiceHalf)
					})
				}
			}),
			Components.Frame({
				Name = "Switch",
				BackgroundTransparency = 0,
				AnchorPoint = v2New(),
				Size = fromScale(0.1, 1),

				BackgroundColor3 = Tween(Computed(function(use)
					return if use(self.playerSettings[id]) then fromRGB(80, 161, 118) else fromRGB(214, 71, 107)
				end), AssetBook.TweenInfos.threeHalf),
				Position = Tween(Computed(function(use)
					return if use(self.playerSettings[id]) then fromScale(0.8, 0) else fromScale(0.7, 0)
				end), AssetBook.TweenInfos.twiceHalf),

				[Children] = { Components.RoundUICorner() }
			})
		}
	}
end

local function SettingsFrame(self: table): Frame
	self.playerSettings = {
		Musics = Value(true),
		SFXs = Value(true),
		PublicCombat = Value(false),
		PartyCombat = Value(false),
		PotatoMode = Value(false),
		PlayerList = Value(true),
		InviteAccess = Value(true)
	}
	self.potatoStoreParts = {}

	local playerSettings = self.playerSettings
	Fusion.Hydrate(self.plr)({
		[AttributeChange("CombatMode")] = function(style)
			playerSettings.PartyCombat:set(style == "Party")
			playerSettings.PublicCombat:set(style == "Public")
		end,
		[AttributeChange("Musics")] = function(state)
			playerSettings.Musics:set(state)

			SoundService.Musics.Volume = if state then 1 else 0
		end,
		[AttributeChange("SFXs")] = function(state)
			playerSettings.SFXs:set(state)

			SoundService.SFXs.Volume = if state then 1 else 0
		end,
		[AttributeChange("PotatoMode")] = function(state)
			playerSettings.PotatoMode:set(state)
		end,
		[AttributeChange("PlayerList")] = function(state)
			playerSettings.PlayerList:set(state)
		end,
		[AttributeChange("InviteAccess")] = function(state)
			playerSettings.InviteAccess:set(state)
		end
	})

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
