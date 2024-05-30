--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Pinia = require(RepS.Modules.UI.Pinia.ShopPinia)

local ShopItemList = require(RepS.Modules.UI.Views.ShopItemList)
local ItemDescFrame = require(RepS.Modules.UI.Views.ItemDescFrame)

local ExCategoryBottomBtns = require(RepS.Modules.UI.Components.ExCategoryBottomBtns)
local ExCategoryTitle = require(RepS.Modules.UI.Components.ExCategoryTitle)

local Children = Fusion.Children

local Shop = {}
Shop.__index = Shop
Shop.__type = "Shop"

local wait = task.wait
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

return function(plr: Player)
	local self = setmetatable({}, Shop)

	self.plr = plr
	self.plrGui = plr.PlayerGui
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	Pinia(self)

	local scope = self.scope
	Components.ScreenGui(scope, {
		Name = "Shop",
		Parent = self.plrGui,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		DisplayOrder = 10,

		Enabled = Fusion.Computed(scope, function(use)
			return use(self.visible)
		end),

		[Children] = {
			Components.Frame(scope, {
				Name = "BG",
				ZIndex = 2,

				[Children] = {
					ExCategoryTitle("Shop", self),

					ExCategoryBottomBtns("Right", self, {
						Components.TextButton(scope, {
                            Name = "Buy",
                            BackgroundColor3 = fromRGB(162, 54, 81),
                            Text = "BUY",
                            Size = fromScale(0.24, 1),

                            [Fusion.OnEvent("MouseButton1Click")] = function()

                            end,

                            [Children] = {
                                Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.2, 0) }),
                            },
                        })
					}),

					Components.Frame(scope, {
						Name = "ItemBG",
						Position = fromScale(0.375, 0.567),
						Size = fromScale(0.71, 0.662),

						[Children] = { ShopItemList("Shop", self) },
					}),

					ItemDescFrame(self),

					Components.Frame(scope, {
						Name = "Stats",
						Position = fromScale(0.853, 0.572),
						Size = fromScale(0.25, 0.651),

						[Children] = {
							Fusion.New(scope, "UIListLayout")({
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0.05, 0),
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Bottom
							}),

							Components.TextLabel(scope, {
								Name = "ItemCost",
								Position = fromScale(0.5, 0.052),
								Size = fromScale(0.9, 0.075),
								AnchorPoint = Vector2.new(0.5, 0.5),

								Text = Fusion.Computed(scope, function(use)
									return "COST "..use(self.itemCost).." GOLD"
								end),
								TextColor3 = Fusion.Computed(scope, function(use)
									return use(self.itemCostColor)
								end)
							})
						}
					})
				},
			}),

			Components.Frame(scope, {
				Name = "Shadow",
				BackgroundTransparency = 0.15,
				ZIndex = 0
			})
		},
	})


	--// Clear
	local function _clearGarbage()
		Events.EnterShopping:DisconnectAll()

		self.itemSlotClicked:Destroy()

		self.Empty()

		Fusion.doCleanup(scope)

		self = nil
	end
	self.char.Humanoid.Died:Once(_clearGarbage)
end
