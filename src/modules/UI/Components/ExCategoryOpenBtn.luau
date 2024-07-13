--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Signals = require(RepS.Modules.Data.Signals)

local OnEvent, Children, Computed = Fusion.OnEvent, Fusion.Children, Fusion.Computed

local color3New = Color3.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local fontFromEnum = Font.fromEnum

local function ExCategoryOpenBtn(id: string, self: table): Frame
	local scope = self.scope :: Fusion.Scope
	local isSelecting = Fusion.Value(scope, false)

	local function exCategoryOpened()
		isSelecting:set(false)
	end
	Signals.ExCategoryOpened:Connect(exCategoryOpened)

	return Fusion.New(scope, "Frame")({
		Name = id,
		BackgroundColor3 = color3New(),
		Position = if id == "Menu" then fromScale(0.355, -1.1) else fromScale(0.71, -1.1),
		Size = fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,

		Visible = Computed(scope, function(use)
			return if use(self.charStatsDict.IsInCombat) then false else true
		end),

		[Children] = {
			Components.RoundUICorner(scope),
			Components.UIStroke(scope, {
				Thickness = 2.7,
				Enabled = true,

				Transparency = Fusion.Tween(scope, Computed(scope, function(use)
					return if use(isSelecting) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.HoverImageButton(scope, {
				Image = Computed(scope, function(use)
					if id == "Backpack" then
						return ItemBook.ItemImagesEx.Backpack
					else
						return AssetBook.ClassInfo[use(self.playerData.Class)].Image
					end
				end),
				ImageColor3 = if id == "Menu" then color3New(1, 1, 1) else fromRGB(148, 148, 148),
				ZIndex = 3,

				[OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
				[OnEvent("MouseButton1Click")] = function()
					ClientUtil:OpenUIEx(self.plr, if id == "Menu" then "AdventurerMenu" else "Backpack")
				end,
			}),
			Components.TextLabel(scope, {
				Name = "Key",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = color3New(),
				BackgroundTransparency = 0,
				Position = fromScale(0.5, 1.11),
				Size = fromScale(0.4, 0.4),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ZIndex = 4,
				Text = if id == "Menu" then "C" else "B",

				[Children] = { Components.RoundUICorner(scope) },
			}),

			Components.ImageLabel(scope, {
				Name = "Hint",
				BackgroundColor3 = fromRGB(195, 0, 0),
				BackgroundTransparency = 0,
				Position = fromScale(0.65, 0),
				Size = fromScale(0.4, 0.4),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ZIndex = 3,

				Visible = Computed(scope, function(use)
					if id == "Menu" then
						return if use(self.playerData.LvPoints) > 0 then true else false
					else
						return false --// TODO: Implement hint for backpack
					end
				end),

				[Children] = {
					Components.RoundUICorner(scope),
					Components.TextLabel(scope, {
						Name = "Attention",
						Size = fromScale(1, 1),
						FontFace = fontFromEnum(Enum.Font.GothamBlack),
						Text = "!"
					})
				}
			})
		},
	})
end

return ExCategoryOpenBtn
