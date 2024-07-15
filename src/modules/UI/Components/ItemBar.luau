--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Children = Fusion.Children

local fromScale = UDim2.fromScale
local v2New = Vector2.new
local wait = task.wait
local fromRGB = Color3.fromRGB

local function ItemBar(item: string, scope: Fusion.Scope): Frame
	local itemInfo = ItemBook:FindItem(item)
	local info: table?

	if itemInfo.ItemId then
		info = {
			Icon = ClientUtil:CombineRbxId(itemInfo.Icon),
			Name = itemInfo.Name,
			TierColor = AssetBook.TierColor[itemInfo.Tier],
			Position = Fusion.Value(scope, fromScale(-0.5, 0))
		}
	else
		info = {
			Icon = ItemBook.ItemImagesEx.Unknown,
			Name = "???",
			TierColor = AssetBook.TierColor[1],
			Position = Fusion.Value(scope, fromScale(-0.5, 0))
		}
	end
	local isSelecting = Fusion.Value(scope, false)

	Spawn(function()
		wait(0.75)
		workspace.Sounds.SFXs.ItemAcquired:Play()

		info.Position:set(fromScale(-0.02, 0))
	end)
	Spawn(function()
		wait(5.2)
		info.Position:set(fromScale(-0.5, 0))
	end)

	return Components.Frame(scope, {
		Name = "AcquiredItem",
		AnchorPoint = v2New(),

		[Children] = {
			Components.Frame(scope, {
				Name = "Bar",
				BackgroundTransparency = 0.2,
				AnchorPoint = v2New(),
				Size = fromScale(0.2, 1),

				Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
					return use(info.Position)
				end), AssetBook.TweenInfos.twiceHalfOne),

				[Children] = {
					Components.RoundUICorner(scope),
					Components.UIStroke(scope, {
						Enabled = true,
						Thickness = 3,

						Transparency = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
							return if use(isSelecting) then 0.3 else 1
						end), AssetBook.TweenInfos.twiceHalfOne)
					}),
					Components.ImageLabel(scope, {
						Name = "Icon",
						Position = fromScale(0.81, 0),
						Size = fromScale(1, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Image = info.Icon,
						BackgroundTransparency = 0,

						[Children] = { Components.RoundUICorner(scope) },
					}),
					Components.TextLabel(scope, {
						Name = "Title",
						Position = fromScale(0.15, 0.03),
						Size = fromScale(0.62, 0.4),
						Text = "ACQUIRED",
						TextColor3 = fromRGB(156, 156, 156),
						TextXAlignment = Enum.TextXAlignment.Right,
					}),
					Components.TextLabel(scope, {
						Name = "ItemName",
						Position = fromScale(0.15, 0.44),
						Size = fromScale(0.62, 0.45),
						Text = info.Name,
						TextColor3 = info.TierColor,
						TextXAlignment = Enum.TextXAlignment.Right
					}),

					Components.HoverImageButton(scope, {
						[Fusion.OnEvent("MouseEnter")] = function()
							isSelecting:set(true)
						end,
						[Fusion.OnEvent("MouseLeave")] = function()
							isSelecting:set(false)
						end
					})
				},
			}),
		},
	})
end

return ItemBar
