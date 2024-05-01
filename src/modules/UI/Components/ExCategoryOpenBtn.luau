--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local OnEvent, Children, Computed = Fusion.OnEvent, Fusion.Children, Fusion.Computed

local color3New = Color3.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local udNew = UDim.new
local fontFromEnum = Font.fromEnum

local function ExCategoryOpenBtn(id: string, self: table): Frame
	local isSelecting = Fusion.Value(false)

	local children: ImageLabel?
	if id == "Menu" then
		children = Components.ImageLabel({
			Name = "Hint",
			BackgroundColor3 = fromRGB(195, 0, 0),
			BackgroundTransparency = 0,
			Position = fromScale(0.65, 0),
			Size = fromScale(0.4, 0.4),
			ZIndex = 3,

			Visible = Computed(function(use)
				return if use(self.playerData.LvPoints) > 0 then true else false
			end),

			[Children] = {
				Components.RoundUICorner(),
				Components.TextLabel({
					Name = "Attention",
					Size = fromScale(1, 1),
					FontFace = fontFromEnum(Enum.Font.GothamBlack),
					Text = "!"
				})
			}
		})
	end

	local function exCategoryOpened()
		isSelecting:set(false)
	end
	Signals.ExCategoryOpened:Connect(exCategoryOpened)

	return Fusion.New("Frame")({
		Name = id,
		BackgroundColor3 = color3New(),
		Position = if id == "Menu" then fromScale(0.355, 0) else fromScale(0.71, 0),
		Size = fromScale(0.281, 0.658),

		[Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({
				Thickness = 2.7,
				Enabled = true,

				Transparency = Fusion.Tween(Computed(function(use)
					return if use(isSelecting) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.HoverImageButton({
				Image = Computed(function(use)
					if id == "Backpack" then
						return AssetBook.Items.ItemImages.Backpack
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
					ClientUtil:OpenUI(self.plr, if id == "Menu" then "AdventurerMenu" else "Backpack")
				end,
			}),
			Components.TextLabel({
				Name = "Key",
				BackgroundColor3 = color3New(),
				BackgroundTransparency = 0,
				Position = fromScale(0.316, 1.109),
				Size = fromScale(0.361, 0.362),
				ZIndex = 4,
				TextStrokeTransparency = 0,
				Text = if id == "Menu" then "C" else "B",

				[Children] = { Fusion.New("UICorner")({ CornerRadius = udNew(0.3, 0) })},
			}),

			children
		},
	})
end

return ExCategoryOpenBtn
