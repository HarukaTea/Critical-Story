--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children = Fusion.Children

local fromScale = UDim2.fromScale
local v2New = Vector2.new
local delay = task.delay
local fromRGB = Color3.fromRGB

local function ItemBar(info: table): Frame
	delay(0.1, function()
		info.Position:set(fromScale(-0.04, 0))
	end)
	delay(3.2, function()
		info.Position:set(fromScale(-0.25, 0))
	end)

	return Components.Frame({
		AnchorPoint = v2New(),

		[Children] = {
			Components.Frame({
				BackgroundTransparency = 0.2,
				AnchorPoint = v2New(),
				Position = Fusion.Tween(Fusion.Computed(function(use)
					return use(info.Position)
				end), AssetBook.TweenInfos.twiceHalfOne),
				Size = fromScale(0.2, 1),

				[Children] = {
					Components.RoundUICorner(),
					Components.ImageLabel({
						Name = "Icon",
						Position = fromScale(0.8, 0),
						Size = fromScale(0.196, 1),
						Image = info.Icon,
						BackgroundTransparency = 0,

						[Children] = { Components.RoundUICorner() },
					}),
					Components.TextLabel({
						Name = "Title",
						Position = fromScale(0, 0.03),
						Size = fromScale(0.771, 0.4),
						Text = "Acquired",
						TextColor3 = fromRGB(156, 156, 156),
						TextXAlignment = Enum.TextXAlignment.Right,
					}),
					Components.TextLabel({
						Name = "ItemName",
						Position = fromScale(0, 0.44),
						Size = fromScale(0.771, 0.45),
						Text = info.Name,
						TextColor3 = info.TierColor,
						TextXAlignment = Enum.TextXAlignment.Right
					}),
				},
			}),
		},
	})
end

return ItemBar
