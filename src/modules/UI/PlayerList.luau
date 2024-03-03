--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local PlayerSlot = require(RepS.Modules.UI.Components.PlayerSlot)

local PlayerDescFrame = require(RepS.Modules.UI.Views.PlayerDescFrame)
local PartyInvFrame = require(RepS.Modules.UI.Views.PartyInvFrame)

local Children, Value, Computed, peek = Fusion.Children, Fusion.Value, Fusion.Computed, Fusion.peek

local PlayerList = {}
PlayerList.__index = PlayerList

local wait = task.wait
local color3New, v2New, udNew, ud2New = Color3.new, Vector2.new, UDim.new, UDim2.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local fromRGB = Color3.fromRGB
local min = math.min

return function(plr: Player)
	repeat wait() until plr:GetAttribute("PlayerDataLoaded")

	local self = setmetatable({}, PlayerList)
	self.plrGui = plr.PlayerGui

	self.UI, self.list, self.desc = Value(), Value(), Value()
	self.absSize, self.absContentSize = Value(90), Value(30)
	self.players = Value({})
	self.isOpen = Value(true)

	local char = plr.Character or plr.CharacterAdded:Wait()

	Components.ScreenGui({
		Name = "PlayerList",
		Parent = self.plrGui,
		[Fusion.Ref] = self.UI,

		[Children] = {
			Components.ScrollingFrame({
				Name = "List",
				ClipsDescendants = true,
				AnchorPoint = v2New(),
				Position = Fusion.Tween(Computed(function(use)
					return if use(self.isOpen) then ud2New(0.868, 0, 0.013, 20) else ud2New(1.2, 0, 0.013, 20)
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
				ScrollingEnabled = Computed(function(use)
					return if use(self.absContentSize) > use(self.absSize) then true else false
				end),

				[Fusion.Ref] = self.list,
				[Fusion.OnChange("AbsoluteSize")] = function(newSize)
					self.absSize:set(newSize.Y)
				end,

				[Children] = {
					Fusion.New("UIListLayout")({
						Padding = udNew(0, 2),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,

						[Fusion.OnChange("AbsoluteContentSize")] = function(newSize)
							self.absContentSize:set(newSize.Y)
						end,
					}),
					Fusion.ForValues(self.players, function(use, player: Player)
						return PlayerSlot(self, player)
					end, Fusion.cleanup),
				},
			}),

			PlayerDescFrame(self),

			Components.HoverImageButton({
				Name = "Hover",
				AnchorPoint = v2New(),
				Position = ud2New(0.868, 0, 0.013, 20),

				Size = Computed(function(use)
					return ud2New(0.127, 0, 0, use(self.absSize))
				end),
				Visible = Computed(function(use)
					return use(self.isOpen)
				end),

				[Fusion.OnEvent("MouseLeave")] = function()
					for _, element in peek(self.list):GetChildren() do
						if element:IsA("Frame") then
							element.BackgroundColor3 = fromRGB(30, 30, 30)
							element.PlayerName.TextColor3 = if Players[element.Name]:GetAttribute("Role") then fromRGB(170, 255, 255) else color3New(1, 1, 1)
						end
					end

					peek(self.desc).Visible = false
				end,
			}),

			Components.Frame({
				Name = "TopBG",
				AnchorPoint = v2New(0.5, 0),
				Position = ud2New(0.5, 0, 0, 25),

				[Children] = {
					Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 25.697 }),

					PartyInvFrame(self)
				}
			})
		},
	})

	--// Actions
	local function _togglePlayerList(_, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		plr:SetAttribute("PlayerList", not plr:GetAttribute("PlayerList"))
	end
	CAS:BindAction("TogglePlayerList", _togglePlayerList, false, Enum.KeyCode.Tab)

	---// Setup
	for _, player in Players:GetPlayers() do
		repeat wait() until player:GetAttribute("PlayerDataLoaded")
	end
	self.players:set(Players:GetPlayers())

	---// Listening events
	Players.PlayerAdded:Connect(function(player)
		repeat wait() until player:GetAttribute("PlayerDataLoaded")

		self.players:set(Players:GetPlayers())
	end)
	Players.PlayerRemoving:Connect(function()
		self.players:set(Players:GetPlayers())
	end)
	Fusion.Hydrate(plr)({
		[Fusion.AttributeChange("PlayerList")] = function(state)
			self.isOpen:set(state)
		end
	})

	local function _onDead()
		peek(self.UI):Destroy()

		CAS:UnbindAction("TogglePlayerList")

		Events.PartyInvite:DisconnectAll()
	end
	char.Humanoid.Died:Once(_onDead)
end
