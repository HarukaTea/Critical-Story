--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local PlayerItemSlot = require(RepS.Modules.UI.Components.PlayerItemSlot)
local PlayerSlot = require(RepS.Modules.UI.Components.PlayerSlot)

local Children, New, Value, Ref, Computed, peek =
	Fusion.Children, Fusion.New, Fusion.Value, Fusion.Ref, Fusion.Computed, Fusion.peek

local PlayerList = {}
PlayerList.__index = PlayerList

local wait = task.wait
local color3New, v2New, udNew, ud2New = Color3.new, Vector2.new, UDim.new, UDim2.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local fromRGB = Color3.fromRGB
local min = math.min

function PlayerList:ChangePlayerSlotClass(player: Player)
	if not player:IsDescendantOf(Players) then return end --- cuz plr left also triggers this

	peek(self.list)[player.Name].Class.Image = AssetBook.ClassInfo[player:GetAttribute("Class")].Image
end

return function(plr: Player)
	repeat wait() until plr:GetAttribute("PlayerDataLoaded")

	local self = setmetatable({}, PlayerList)
	self.plrGui = plr.PlayerGui

	self.UI, self.list, self.desc = Value(), Value(), Value()
	self.absSize, self.absContentSize = Value(90), Value(30)
	self.players = Value(Players:GetPlayers())

	self.isOpen = Value(true)

	Components.ScreenGui({
		Name = "PlayerList",
		Parent = self.plrGui,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		[Ref] = self.UI,

		[Children] = {
			Components.ScrollingFrame({
				Name = "List",
				ClipsDescendants = true,
				AnchorPoint = v2New(),
				Position = Fusion.Tween(Computed(function(use)
					local state = use(self.isOpen)

					return if state then ud2New(0.868, 0, 0.013, 20) else ud2New(1.2, 0, 0.013, 20)
				end), AssetBook.TweenInfos.half),
				Size = fromScale(0.127, 0.32),
				ZIndex = 2,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				CanvasSize = Computed(function(use)
					if use(self.absContentSize) > use(self.absSize) then
						return fromOffset(0, use(self.absContentSize))
					else
						return fromOffset(0, 0)
					end
				end),
				[Ref] = self.list,
				[Fusion.OnChange("AbsoluteSize")] = function(newSize)
					self.absSize:set(newSize.Y)
				end,

				[Children] = {
					New("UIListLayout")({
						Padding = udNew(0, 2),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,

						[Fusion.OnChange("AbsoluteContentSize")] = function(newSize)
							self.absContentSize:set(newSize.Y)
						end,
					}),
					Fusion.ForValues(self.players, function(use, player)
						return PlayerSlot(self, player)
					end, Fusion.cleanup),
				},
			}),
			Components.Frame({
				Name = "Desc",
				BackgroundTransparency = 0.1,
				AnchorPoint = v2New(),
				Position = ud2New(0.7, 0, 0.013, 20),
				Size = fromScale(0.16, 0.475),
				Visible = false,
				[Ref] = self.desc,

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 0.859 }),
					New("UICorner")({ CornerRadius = udNew(0.03, 0) }),
					New("ImageLabel")({
						Name = "Class",
						BackgroundColor3 = color3New(),
						Position = fromScale(0.05, 0.055),
						Size = fromScale(0.205, 0.175),

						[Children] = { Components.RoundUICorner() },
					}),
					Components.TextLabel({
						Name = "DisplayName",
						Position = fromScale(0.3, 0.05),
						Size = fromScale(0.63, 0.095),
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
					Components.TextLabel({
						Name = "UserName",
						Position = fromScale(0.3, 0.15),
						Size = fromScale(0.63, 0.06),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = fromRGB(193, 193, 193),
					}),
					Components.TextLabel({
						Name = "Level",
						Position = fromScale(0.06, 0.245),
						Size = fromScale(0.866, 0.077),
						TextColor3 = fromRGB(255, 255, 0),
					}),
					New("Frame")({
						Name = "HorizonLine",
						AnchorPoint = v2New(0.5, 0),
						Position = fromScale(0.5, 0.35),
						Size = fromScale(0.9, 0.005),
						BackgroundTransparency = 0.7
					}),

					PlayerItemSlot(1),
					PlayerItemSlot(2),
					PlayerItemSlot(3),
					PlayerItemSlot(4),
					PlayerItemSlot(5),
					PlayerItemSlot(6),
					PlayerItemSlot(7),
					PlayerItemSlot(8),
					PlayerItemSlot(9),
					PlayerItemSlot(10),

					Components.TextLabel({
						Name = "Role",
						Position = fromScale(0.06, 0.91),
						Size = fromScale(0.865, 0.06),
						TextTransparency = 0.2,
					}),
				},
			}),
			Components.HoverImageButton({
				Name = "Hover",
				AnchorPoint = v2New(),
				Position = ud2New(0.868, 0, 0.013, 20),
				Size = Computed(function(use)
					return ud2New(0.127, 0, 0, min(use(self.absContentSize), use(self.absSize)))
				end),
				Visible = Computed(function(use)
					return use(self.isOpen)
				end),

				[Fusion.OnEvent("MouseLeave")] = function()
					for _, element in peek(self.list):GetChildren() do
						if element:IsA("Frame") and element.BackgroundColor3 == color3New(1, 1, 1) then
							element.BackgroundColor3 = fromRGB(30, 30, 30)
							element.PlayerName.TextColor3 = if Players[element.Name]:GetAttribute("Role") then fromRGB(170, 255, 255) else color3New(1, 1, 1)
						end
					end

					peek(self.desc).Visible = false
				end,
			}),
		},
	})

	---// Listening events
	Players.PlayerAdded:Connect(function(player)
		repeat wait() until player:GetAttribute("PlayerDataLoaded")

		self.players:set(Players:GetPlayers())

		player:GetAttributeChangedSignal("Class"):Connect(function()
			self:ChangePlayerSlotClass(player)
		end)
	end)
	Players.PlayerRemoving:Connect(function()
		self.players:set(Players:GetPlayers())
	end)
	Fusion.Hydrate(plr)({
		[Fusion.AttributeChange("PlayerList")] = function(state)
			self.isOpen:set(state)
		end
	})

	---// Setup
	self.absSize:set(peek(self.list).AbsoluteSize.Y)
	self.absContentSize:set(peek(self.list).UIListLayout.AbsoluteContentSize.Y)
	for _, player in Players:GetPlayers() do
		repeat wait() until player:GetAttribute("PlayerDataLoaded")

		player:GetAttributeChangedSignal("Class"):Connect(function()
			self:ChangePlayerSlotClass(player)
		end)
	end
end
