--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local Pinia = require(RepS.Modules.UI.Pinia.PlayerListPinia)

local PlayerDescFrame = require(RepS.Modules.UI.Views.PlayerDescFrame)

local PlayerSlot = require(RepS.Modules.UI.Components.PlayerSlot)

local Children, Computed, peek = Fusion.Children, Fusion.Computed, Fusion.peek

local PlayerList = {}
PlayerList.__index = PlayerList
PlayerList.__type = "PlayerList"

local wait = task.wait
local color3New, v2New, udNew, ud2New = Color3.new, Vector2.new, UDim.new, UDim2.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local fromRGB = Color3.fromRGB
local min = math.min

return function(plr: Player)
	local self = setmetatable({}, PlayerList)
	local char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until char:GetAttribute("CharDataLoaded")

	Pinia(self)

	local scope = self.scope
	Components.ScreenGui(scope, {
		Name = "PlayerList",
		DisplayOrder = 10,
		Parent = plr.PlayerGui,

		[Children] = {
			Components.Frame(scope, {
				Name = "Top",
				AnchorPoint = v2New(),
				Position = fromOffset(0, 36),
				Size = fromScale(1, 0.1),

				[Children] = {
					Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.386 }),

					Components.ScrollingFrame(scope, {
						Name = "List",
						AnchorPoint = v2New(),
						Size = fromScale(0.118, 3),
						ZIndex = 2,
						ScrollingDirection = Enum.ScrollingDirection.Y,

						Position = Fusion.Tween(scope, Computed(scope, function(use)
							return if use(self.isOpen) then fromScale(0.875, 0) else fromScale(1.2, 0)
						end), AssetBook.TweenInfos.half),
						CanvasSize = Computed(scope, function(use)
							return if use(self.absContentSize) > use(self.absSize) then fromOffset(0, use(self.absContentSize)) else fromOffset(0, 0)
						end),
						ScrollingEnabled = Computed(scope, function(use)
							return if use(self.absContentSize) > use(self.absSize) then true else false
						end),

						[Fusion.Ref] = self.list,
						[Fusion.OnChange("AbsoluteSize")] = function(newSize: Vector2)
							self.absSize:set(newSize.Y)
						end,

						[Children] = {
							Fusion.New(scope, "UIListLayout")({
								Padding = udNew(0, 2),
								HorizontalAlignment = Enum.HorizontalAlignment.Center,

								[Fusion.OnChange("AbsoluteContentSize")] = function(newSize)
									self.absContentSize:set(newSize.Y)
								end,
							}),
							Fusion.ForValues(scope, self.players, function(_, localScope: table, player: Player)
								return PlayerSlot(self, player, localScope)
							end),
						},
					}),
					Components.HoverImageButton(scope, {
						AnchorPoint = v2New(),
						Position = fromScale(0.875, 0),

						Size = Computed(scope, function(use)
							return ud2New(0.118, 0, 0, min(use(self.absSize), use(self.absContentSize)))
						end),
						Visible = Computed(scope, function(use)
							return use(self.isOpen)
						end),

						[Fusion.OnEvent("MouseLeave")] = function()
							for _, element: Frame in peek(self.list):GetChildren() do
								if element:IsA("Frame") then
									element.BackgroundColor3 = fromRGB(30, 30, 30)
									element.PlayerName.TextColor3 = if Players[element.Name]:GetAttribute("Role") then fromRGB(170, 255, 255) else color3New(1, 1, 1)
								end
							end

							self.playerDescVisible:set(false)
						end,
					}),

					PlayerDescFrame(self),
				}
			}),
		},
	})

	--// Actions
	local function _togglePlayerList(_, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		Events.ChangePlayerSetting:Fire("PlayerList")
	end
	CAS:BindAction("TogglePlayerList", _togglePlayerList, false, Enum.KeyCode.Tab)

	---// Setup
	for _, player in Players:GetPlayers() do
		repeat wait() until player:GetAttribute("PlayerDataLoaded")
	end
	self.players:set(Players:GetPlayers())

	---// Listening events
	self.Add(Players.PlayerAdded:Connect(function(player)
		repeat wait() until player:GetAttribute("PlayerDataLoaded")

		self.players:set(Players:GetPlayers())
	end))
	self.Add(Players.PlayerRemoving:Connect(function()
		self.players:set(Players:GetPlayers())
	end))
	self.Add(HarukaLib:Hydrate(plr, {
		["Attr-PlayerList"] = function(state: boolean)
			self.isOpen:set(state)
		end
	}))
	Signals.ExCategoryOpened:Connect(function()
		for _, element: Frame in peek(self.list):GetChildren() do
			if element:IsA("Frame") then
				element.BackgroundColor3 = fromRGB(30, 30, 30)
				element.PlayerName.TextColor3 = if Players[element.Name]:GetAttribute("Role") then fromRGB(170, 255, 255) else color3New(1, 1, 1)
			end
		end

		self.playerDescVisible:set(false)
	end)

	local function _onDead()
		CAS:UnbindAction("TogglePlayerList")

		Signals.ExCategoryOpened:DisconnectAll()

		self.Empty()

		Fusion.doCleanup(scope)

		self = nil
	end
	char.Humanoid.Died:Once(_onDead)
end
