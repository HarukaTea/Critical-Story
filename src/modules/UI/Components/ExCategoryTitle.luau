--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local New, Children, OnEvent, Value, Computed =
	Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.Value, Fusion.Computed

local color3New, ud2New, udNew = Color3.new, UDim2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function ExCategoryTitle(id: string, self: table): Frame
	local scope = self.scope :: Fusion.Scope
	local plr = self.plr :: Player

	local playerClass = nil
	if id == "Menu" then
		playerClass = Value(scope, plr:GetAttribute("Class"))

		table.insert(scope, HarukaLib:Hydrate(plr, {
			["Attr-Class"] = function(newClass: string)
				playerClass:set(newClass)
			end
		}))
	end

	local isSelecting = Fusion.Value(scope, false)

	return New(scope, "Frame")({
		Name = "Top",
		BackgroundTransparency = 1,
		Size = fromScale(0.97, 0.1),
		Position = ud2New(0.015, 0, 0.04, 40),

		[Children] = {
			New(scope, "UIAspectRatioConstraint")({ AspectRatio = 24.168 }),
			New(scope, "UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = udNew(0.015, 0),
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),

			Components.ImageLabel(scope, {
				Name = "Icon",
				ImageColor3 = id == "Backpack" and fromRGB(148, 148, 148) or color3New(1, 1, 1),
				Position = fromScale(0.01, 0),
				Size = fromScale(0.04, 1),
				BackgroundTransparency = 0,

				Image = Computed(scope, function(use)
					if id == "Menu" then
						return AssetBook.ClassInfo[use(playerClass)].Image

					elseif id == "Backpack" then
						return ItemBook.ItemImagesEx.Backpack

					elseif id == "Shop" then
						return AssetBook.ClassInfo.Illusionist.Image

					elseif id == "Crafting" then
						return ItemBook:FindItem("MiningPickaxe").Icon
					end
				end),

				[Children] = { Components.RoundUICorner(scope) },
			}),
			Components.TextLabel(scope, {
				Name = "Title",
				Position = fromScale(0.063, 0.195),
				Size = fromScale(0.87, 0.6),
				Text = id,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			Components.TextButton(scope, {
				Name = "Close",
				Position = fromScale(0.948, 0.066),
				Size = fromScale(0.04, 1),
				Text = "X",

				BackgroundColor3 = Computed(scope, function(use)
					return if use(isSelecting) then fromRGB(255, 255, 255) else fromRGB()
				end),
				TextColor3 = Computed(scope, function(use)
					return if not use(isSelecting) then fromRGB(255, 255, 255) else fromRGB()
				end),

				[OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
				[OnEvent("MouseButton1Click")] = function()
					if id == "Shop" or id == "Crafting" then self.items:set({}) end

					ClientUtil:OpenUIEx(plr, if id == "Menu" then "AdventurerMenu" else id)
				end,

				[Children] = {
					New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke(scope, {
						Thickness = 3,
						Enabled = true,

						Color = Computed(scope, function(use)
							return if not use(isSelecting) then fromRGB(255, 255, 255) else fromRGB()
						end),
					}),
				},
			}),
		},
	})
end

return ExCategoryTitle
