--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Fusion = require(RepS.Modules.Packages.Fusion)

local New, Children, OnEvent, Value, Tween, Computed =
	Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.Value, Fusion.Tween, Fusion.Computed

local color3New, ud2New, udNew = Color3.new, UDim2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function ExCategoryTitle(id: string, self: table): Frame
	local bgColor = Value(fromRGB(30, 30, 30))
	local contentColor = Value(fromRGB(255, 255, 255))
	local plr = self.plr :: Player

	local playerClass = nil
	if id == "Menu" then
		playerClass = Value(plr:GetAttribute("Class"))

		Fusion.Hydrate(plr)({
			[Fusion.AttributeChange("Class")] = function(newClass: string)
				playerClass:set(newClass)
			end
		})
	end

	return New("Frame")({
		Name = "Top",
		BackgroundTransparency = 1,
		Size = fromScale(0.97, 0.1),
		Position = ud2New(0.01, 0, 0.04, 40),

		[Children] = {
			New("UIAspectRatioConstraint")({ AspectRatio = 25.255 }),
			Components.ImageLabel({
				Name = "Icon",
				Image = Computed(function(use)
					if id == "Menu" then
						return AssetBook.ClassInfo[use(playerClass)].Image

					elseif id == "Backpack" then
						return AssetBook.Items.ItemImages.Backpack
					end
				end),
				ImageColor3 = id == "Backpack" and fromRGB(148, 148, 148) or color3New(1, 1, 1),
				Position = fromScale(0.01, 0),
				Size = fromScale(0.04, 1),
				BackgroundTransparency = 0,

				[Children] = { Components.RoundUICorner() },
			}),
			Components.TextLabel({
				Position = fromScale(0.063, 0.195),
				Size = fromScale(0.7, 0.6),
				Text = id,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			Components.TextButton({
				Position = fromScale(0.948, 0.066),
				Size = fromScale(0.04, 1),
				Text = "X",

				TextColor3 = Tween(Computed(function(use)
					return use(contentColor)
				end), AssetBook.TweenInfos.twiceHalf),
				BackgroundColor3 = Tween(Computed(function(use)
					return use(bgColor)
				end), AssetBook.TweenInfos.twiceHalf),

				[Children] = {
					New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke({
						Thickness = 3,
						Enabled = true,

						Color = Tween(Computed(function(use)
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
