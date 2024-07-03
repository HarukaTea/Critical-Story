--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Signals = require(RepS.Modules.Data.Signals)

local isMobile = HarukaLib:GetDevice() == "Mobile"

local Value = Fusion.Value

local color3New = Color3.new
local fromScale = UDim2.fromScale

local function PassiveSlot(index: number, self: table): Frame
	local scope = self.scope
	local positions = {
		fromScale(0, 0),
		fromScale(0.355, 0),
		fromScale(0.71, 0)
	}
	local isSelecting = Value(scope, false)

	local function exCategoryOpened()
		isSelecting:set(false)
	end
	Signals.ExCategoryOpened:Connect(exCategoryOpened)

	return Fusion.New(scope, "Frame")({
		Name = "Passive" .. index,
		BackgroundColor3 = color3New(),
		Position = positions[index],
		Size = fromScale(0.281, 0.658),
		[Fusion.Ref] = self.passiveSlotList[index],

		[Fusion.Children] = {
			Components.RoundUICorner(scope),
			Components.UIStroke(scope, {
				Thickness = 2.7,
				Enabled = true,

				Transparency = Fusion.Tween(scope, Fusion.Computed(scope, function(use)
					return if use(isSelecting) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.ImageLabel(scope, {
				Name = "Icon",
				Size = fromScale(1, 1),
				Image = Fusion.Computed(scope, function(use)
					local item = use(self.passiveEquipList[index]) :: string

					return if ItemBook:IsItemExist(item) then ClientUtil:CombineRbxId(ItemBook:FindItem(item).Icon) else ItemBook.ItemImagesEx.Null
				end),
			}),
			Components.HoverImageButton(scope, {
				Visible = if isMobile then false else true,

				[Fusion.OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
			}),
		},
	})
end

return PassiveSlot
