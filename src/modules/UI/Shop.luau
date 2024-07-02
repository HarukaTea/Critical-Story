--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local Pinia = require(RepS.Modules.UI.Pinia.ShopPinia)

local ShopItemList = require(RepS.Modules.UI.Views.ShopItemList)
local ItemDescFrame = require(RepS.Modules.UI.Views.ItemDescFrame)
local ItemCostFrame = require(RepS.Modules.UI.Views.ItemCostFrame)

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

		[Children] = {
			Components.Frame(scope, {
				Name = "BG",
				ZIndex = 2,
				Visible = false,

				[Children] = {
					ExCategoryTitle("Shop", self),
					ExCategoryBottomBtns("Right", self, {
						Components.TextButton(scope, {
                            Name = "Buy",
                            BackgroundColor3 = fromRGB(162, 54, 81),
                            Text = "BUY",
                            Size = fromScale(0.24, 1),

                            [Fusion.OnEvent("MouseButton1Click")] = function()
								for _, shop: Model in workspace.MapComponents.WorldShops:GetDescendants() do
									if not plr:GetAttribute("CurrentShop") then break end
									if shop.Name ~= plr:GetAttribute("CurrentShop") then continue end

									--- distance check
									local distance = self.plr:DistanceFromCharacter(shop.Prompt.Position)
									if distance >= 32 or distance <= 0 then
										Signals.CreateHint:Fire("You are far away from the shop!")
										return
									end

									--- amount check
									local amount = tonumber(Fusion.peek(self.buyAmount)) :: string
									if amount then
										local check = HarukaLib:TypeCheck("MinMax", amount, 0, 99999)
										local check2 = HarukaLib:TypeCheck("Integer", amount)

										if not check or not check2 then
											Signals.CreateHint:Fire("Wrong input number!")
											return
										end

										if amount > 1000 then
											Signals.CreateHint:Fire("You can't buy 1k+ items at once!")
											return
										end
									else
										Signals.CreateHint:Fire("Wrong input number!")
										return
									end

									--- item check
									local item = "None"
									for _, child: ImageButton in Fusion.peek(self.itemFrame):GetChildren() do
										if child:IsA("ImageButton") and child:GetAttribute("Selected") then item = child.Name end
									end
									if item == "None" then return end

									Events.BuyItems:Fire(item, amount)
									break
								end
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
					ItemCostFrame(self)
				},
			}),

			Components.BGShadow(scope)
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
