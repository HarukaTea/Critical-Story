--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local New, Children, Computed, peek = Fusion.New, Fusion.Children, Fusion.Computed, Fusion.peek

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local sFind, format, match = string.find, string.format, string.match

local function PlayerSlot(self: table, player: Player): Frame
	local class = Fusion.Value(player:GetAttribute("Class"))
	local role = Fusion.Value(player:GetAttribute("Role"))

	Fusion.Hydrate(player)({
		[Fusion.AttributeChange("Class")] = function(newClass: string)
			class:set(newClass)
		end,
		[Fusion.AttributeChange("Role")] = function(newRole: string)
			role:set(newRole)
		end
	})

	return Components.Frame({
		BackgroundTransparency = 0,
		Size = fromScale(1, 0.2),
		Name = player.Name,

		[Children] = {
			New("UIAspectRatioConstraint")({ AspectRatio = 4.993 }),
			New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
			New("ImageLabel")({
				Name = "Class",
				AnchorPoint = v2New(0, 0.5),
				BackgroundColor3 = color3New(),
				Position = fromScale(0.055, 0.5),
				Size = fromScale(0.13, 0.665),

				Image = Fusion.Computed(function(use)
					return AssetBook.ClassInfo[use(class)].Image
				end),

				[Children] = { Components.RoundUICorner() },
			}),
			Components.TextLabel({
				Name = "PlayerName",
				Position = fromScale(0.24, 0),
				Size = fromScale(0.721, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = player.DisplayName,

				TextColor3 = Computed(function(use)
					return if use(role) ~= "" then fromRGB(170, 255, 255) else color3New(1, 1, 1)
				end),

				[Children] = {
					New("UIPadding")({
						PaddingBottom = udNew(0.18, 0),
						PaddingTop = udNew(0.18, 0)
					})
				}
			}),
			Components.HoverImageButton({
				ZIndex = 2,

				[Fusion.OnEvent("MouseEnter")] = function()
					local list, desc = Fusion.peek(self.list) :: Frame, Fusion.peek(self.desc) :: Frame

					for _, element: Frame in list:GetChildren() do
						if element:IsA("Frame") then
							local roleColor = if Players[element.Name]:GetAttribute("Role") then fromRGB(170, 255, 255) else color3New(1, 1, 1)

							element.BackgroundColor3 = fromRGB(30, 30, 30)
							element.PlayerName.TextColor3 = roleColor
						end
					end
					for _, element: ImageLabel in desc:GetChildren() do
						if sFind(element.Name, "Slot") then element.Image = AssetBook.Items.ItemImages.Null end
					end

					list[player.Name].BackgroundColor3 = color3New(1, 1, 1)
					list[player.Name].PlayerName.TextColor3 = color3New()

					self.displayName:set(player.DisplayName)
					self.userName:set("@" .. player.Name)
					self.classImage:set(AssetBook.ClassInfo[peek(class)].Image)
					self.level:set("Lv."
						.. player:GetAttribute("Levels")
						.. " - "
						.. format("%.1f", player:GetAttribute("PlayTime") / 3600)
						.. " Hours")
					self.role:set(if player:GetAttribute("Role") then "- " .. player:GetAttribute("Role") .. " -" else "")
					self.playerDescBGSize:set(if player:GetAttribute("Role") then fromScale(1, 0.86) else fromScale(1, 0.77))

					local items = player:WaitForChild("Inventory", 999) :: Folder

					for _, item: IntValue in items:GetChildren() do
						if AssetBook.Items.ItemType[item.Name] == "Passive" and item:GetAttribute("Equipped") then
							local index = tonumber(match(item:GetAttribute("Slot"), "%d"))

							desc["Slot"..index].Image = AssetBook.Items.ItemImages[item.Name]
						end
					end

					self.playerDescVisible:set(true)
				end,
			}),
		},
	})
end

return PlayerSlot
