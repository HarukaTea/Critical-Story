--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local New, Children, OnEvent, Value, Tween, Computed =
	Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.Value, Fusion.Tween, Fusion.Computed

local color3New, ud2New, udNew = Color3.new, UDim2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function ExCategoryTitle(id: string, self: table): Frame
	local scope = self.scope
	local bgColor = Value(scope, fromRGB(30, 30, 30))
	local contentColor = Value(scope, fromRGB(255, 255, 255))
	local plr = self.plr :: Player

	local playerClass = nil
	if id == "Menu" then
		playerClass = Value(scope, plr:GetAttribute("Class"))

		HarukaLib:Hydrate(plr, {
			["Attr-Class"] = function(newClass: string)
				playerClass:set(newClass)
			end
		})
	end

	return New(scope, "Frame")({
		Name = "Top",
		BackgroundTransparency = 1,
		Size = fromScale(0.97, 0.1),
		Position = ud2New(0.01, 0, 0.04, 40),

		[Children] = {
			New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.255 }),
			Components.ImageLabel(scope, {
				Name = "Icon",
				Image = Computed(scope, function(use)
					if id == "Menu" then
						return AssetBook.ClassInfo[use(playerClass)].Image

					elseif id == "Backpack" then
						return ItemBook.ItemImagesEx.Backpack
					end
				end),
				ImageColor3 = id == "Backpack" and fromRGB(148, 148, 148) or color3New(1, 1, 1),
				Position = fromScale(0.01, 0),
				Size = fromScale(0.04, 1),
				BackgroundTransparency = 0,

				[Children] = { Components.RoundUICorner(scope) },
			}),
			Components.TextLabel(scope, {
				Position = fromScale(0.063, 0.195),
				Size = fromScale(0.7, 0.6),
				Text = id,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			Components.TextButton(scope, {
				Position = fromScale(0.948, 0.066),
				Size = fromScale(0.04, 1),
				Text = "X",

				TextColor3 = Tween(scope, Computed(scope, function(use)
					return use(contentColor)
				end), AssetBook.TweenInfos.twiceHalf),
				BackgroundColor3 = Tween(scope, Computed(scope, function(use)
					return use(bgColor)
				end), AssetBook.TweenInfos.twiceHalf),

				[Children] = {
					New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke(scope, {
						Thickness = 3,
						Enabled = true,

						Color = Tween(scope, Computed(scope, function(use)
							return use(contentColor)
						end), AssetBook.TweenInfos.twiceHalf)
					}),
				},

				[OnEvent("MouseEnter")] = function()
					contentColor:set(fromRGB())
					bgColor:set(fromRGB(255, 255, 255))
				end,
				[OnEvent("MouseLeave")] = function()
					contentColor:set(fromRGB(255, 255, 255))
					bgColor:set(fromRGB())
				end,
				[OnEvent("MouseButton1Click")] = function()
					ClientUtil:OpenUI(plr, if id == "Menu" then "AdventurerMenu" else "Backpack")
				end,
			}),
		},
	})
end

return ExCategoryTitle
