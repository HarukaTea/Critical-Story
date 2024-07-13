--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Events = require(RepS.Modules.Data.Events)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Signals = require(RepS.Modules.Data.Signals)

local isMobile = HarukaLib:GetDevice() == "Mobile"

local Value = Fusion.Value

local color3New = Color3.new
local fromScale = UDim2.fromScale

local function PassiveSlot(index: number, self: table): Frame
	local scope = self.scope :: Fusion.Scope
	local isSelecting = Value(scope, false)

	local function exCategoryOpened()
		isSelecting:set(false)
	end
	Signals.ExCategoryOpened:Connect(exCategoryOpened)

	local children: ImageButton?
	if not isMobile then
		Components.HoverImageButton(scope, {
			[Fusion.OnEvent("MouseEnter")] = function()
				isSelecting:set(true)
			end,
			[Fusion.OnEvent("MouseLeave")] = function()
				isSelecting:set(false)
			end,
			[Fusion.OnEvent("MouseButton1Click")] = function()
				local item = Fusion.peek(self.passiveEquipList[index]) :: string

				if item == "Null" then return end
				if item == "" then return end

				Events.EquipItems:Fire("ClearPassive", "Passive"..index, item)

				workspace.Sounds.SFXs.Equip:Play()
			end
		})
	end

	self.passiveSlotList[index] = Fusion.Value(scope, Fusion.New(scope, "Frame")({
		Name = "Passive" .. index,
		BackgroundColor3 = color3New(),
		Size = fromScale(0.65, 0.65),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		LayoutOrder = index,

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

			children
		},
	}))

	return self.passiveSlotList[index]
end

return PassiveSlot
