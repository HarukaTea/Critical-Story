--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Signals = require(RepS.Modules.Data.Signals)

local OnEvent, Computed, Children, New = Fusion.OnEvent, Fusion.Computed, Fusion.Children, Fusion.New

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local nsNew, nsKPNew = NumberSequence.new, NumberSequenceKeypoint.new
local clamp = math.clamp


local function ProgressCircle(direction: string, self: table, index: number) : Frame
    local scope = self.scope :: table

    return Components.Frame(scope, {
		Name = "ProgressCircle"..direction,
		ClipsDescendants = true,
		AnchorPoint = v2New(),
		Position = if direction == "Right" then fromScale(0.5, 0) else fromScale(0, 0),
		Size = fromScale(0.5, 1),
		ZIndex = 2,

		Visible = Computed(scope, function(use: Fusion.Use)
			return if use(self.activeCDRotationList[index]) > 0 then true else false
		end),

		[Children] = {
			Components.ImageLabel(scope, {
				Name = "ProgressImage",
				Position = if direction == "Right" then fromScale(-1, 0) else fromScale(0, 0),
				Size = fromScale(2, 1),
				Image = "rbxasset://textures/ui/Controls/RadialFill.png",

				[Children] = {
					New(scope, "UIGradient")({
						Rotation = Computed(scope, function(use: Fusion.Use)
							local angle = clamp(use(self.activeCDRotationList[index]) * 360, 0, 360)

							return if direction == "Left" then clamp(angle, 180, 360) else clamp(angle, 0, 180)
						end),
						Transparency = nsNew({
							nsKPNew(0, 0, 0),
							nsKPNew(0.499, 0, 0), nsKPNew(0.5, 1, 0),
							nsKPNew(1, 1, 0)
						})
					})
				}
			})
		}
	})
end

local function ActiveSlot(index: number, self: table): Frame
    local scope = self.scope :: table
    local positions = { 0, 0.355, 0.71 }
    local isSelecting = Fusion.Value(scope, false)

	local function exCategoryOpened()
		isSelecting:set(false)
	end
	table.insert(scope, Signals.ExCategoryOpened:Connect(exCategoryOpened))

	self.activeSlotList[index] = Fusion.Value(scope, New(scope, "Frame")({
		Name = "Active"..index,
		BackgroundColor3 = color3New(),
		Position = fromScale(positions[index], 0),
		Size = fromScale(0.65, 0.65),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		LayoutOrder = index,

		[Children] = {
			Components.RoundUICorner(scope),
			Components.UIStroke(scope, {
				Thickness = 3,
				Enabled = true,

				Transparency = Fusion.Tween(scope, Computed(scope, function(use: Fusion.Use)
					return if use(isSelecting) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.HoverImageButton(scope, {
				Name = "Hover",
				ZIndex = 3,

				[OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
				[OnEvent("MouseButton1Click")] = function()
					self:UseItem(index)
				end,
			}),
			Components.ImageLabel(scope, {
				Name = "Icon",
				Size = fromScale(1, 1),

				Image = Computed(scope, function(use: Fusion.Use)
					local item = use(self.activeEquipList[index]) :: string

					return if ItemBook:IsItemExist(item) then ClientUtil:CombineRbxId(ItemBook:FindItem(item).Icon) else ItemBook.ItemImagesEx.Null
				end)
			}),
			Components.TextLabel(scope, {
				Name = "Amount",
				Position = fromScale(-0.02, 0.72),
				Size = fromScale(1.25, 0.365),
				ZIndex = 4,
				TextStrokeTransparency = 0,
				TextXAlignment = Enum.TextXAlignment.Right,

				Text = Computed(scope, function(use: Fusion.Use, localScope: Fusion.Scope)
					local item = use(self.activeEquipList[index]) :: string

					if item == "Null" then
						return ""
					else
						local amount = Fusion.Value(localScope, self.inventory[item].Value)

						table.insert(localScope, HarukaLib:Hydrate(self.inventory[item], {
							["Prop-Value"] = function(newVal: number)
								amount:set(newVal)
							end
						}))

						return if use(amount) <= 1 then "" else "x"..use(amount)
					end
				end),

				[Children] = {
					Components.TextUIStroke(scope, { Thickness = 2.5 }),
				},
			}),
			Components.TextLabel(scope, {
				Name = "Cooldown",
				AnchorPoint = v2New(0.5, 0.5),
				Position = fromScale(0.5, 0.5),
				Size = fromScale(1, 1),
				BackgroundTransparency = 0.4,
				ZIndex = 2,
				TextStrokeTransparency = 0,

				Text = Computed(scope, function(use: Fusion.Use)
					return use(self.activeCDList[index])
				end),
				Visible = Computed(scope, function(use: Fusion.Use)
					return if tonumber(use(self.activeCDList[index])) > 0 then true else false
				end),

				[Children] = {
					Components.RoundUICorner(scope),
					New(scope, "UIPadding")({
						PaddingTop = udNew(0.2, 0),
						PaddingLeft = udNew(0.2, 0),
						PaddingRight = udNew(0.2, 0),
						PaddingBottom = udNew(0.2, 0),
					}),
					Components.TextUIStroke(scope, { Thickness = 2.5 })
				},
			}),
			Components.TextLabel(scope, {
				Name = "Key",
				AnchorPoint = v2New(0.5, 0),
				BackgroundColor3 = color3New(),
				BackgroundTransparency = 0,
				Position = fromScale(0.5, 1.11),
				Size = fromScale(0.4, 0.4),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ZIndex = 4,
				TextStrokeTransparency = 0,
				Text = index,

				[Children] = { Components.RoundUICorner(scope) },
			}),

			ProgressCircle("Left", self, index),
			ProgressCircle("Right", self, index),
		},
	}))

	return self.activeSlotList[index]
end

return ActiveSlot
