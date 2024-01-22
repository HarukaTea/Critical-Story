--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local New = Fusion.New

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local sFind, format, match = string.find, string.format, string.match

local function PlayerSlot(self: table, player: Player): Frame
	return Components.Frame({
		BackgroundTransparency = 0,
		Size = fromScale(1, 0.205),
		Name = player.Name,

		[Fusion.Children] = {
			New("UIAspectRatioConstraint")({ AspectRatio = 4.891 }),
			New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
			New("ImageLabel")({
				Name = "Class",
				AnchorPoint = v2New(0, 0.5),
				BackgroundColor3 = Color3.new(),
				Position = fromScale(0.055, 0.5),
				Size = fromScale(0.14, 0.665),
				Image = AssetBook.ClassInfo[player:GetAttribute("Class")].Image,

				[Fusion.Children] = { Components.RoundUICorner() },
			}),
			Components.TextLabel({
				Name = "PlayerName",
				AnchorPoint = v2New(0, 0.5),
				Position = fromScale(0.245, 0.5),
				Size = fromScale(0.7, 0.62),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = player.DisplayName,
				TextColor3 = if player:GetAttribute("Role") then fromRGB(170, 255, 255) else color3New(1, 1, 1)
			}),
			Components.HoverImageButton({
				Name = "Hover",
				ZIndex = 2,

				[Fusion.OnEvent("MouseEnter")] = function()
					local list, desc = Fusion.peek(self.list), Fusion.peek(self.desc)

					for _, element in list:GetChildren() do
						if element:IsA("Frame") and element.BackgroundColor3 == color3New(1, 1, 1) then
							element.BackgroundColor3 = fromRGB(30, 30, 30)
							element.PlayerName.TextColor3 = if player:GetAttribute("Role") then fromRGB(170, 255, 255) else color3New(1, 1, 1)
						end
					end
					for _, element in desc:GetChildren() do
						if sFind(element.Name, "Slot") then
							element.Image = AssetBook.Items.ItemImages.Null
						end
					end

					list[player.Name].BackgroundColor3 = color3New(1, 1, 1)
					list[player.Name].PlayerName.TextColor3 = color3New()

					desc.DisplayName.Text = player.DisplayName
					desc.UserName.Text = "@" .. player.Name
					desc.Class.Image = AssetBook.ClassInfo[player:GetAttribute("Class")].Image
					desc.Level.Text = "Lv."
						.. player:GetAttribute("Levels")
						.. " - "
						.. format("%.1f", player:GetAttribute("PlayTime") / 3600)
						.. " Hours"

					if player:GetAttribute("Role") then
						desc.Role.Text = "- " .. player:GetAttribute("Role") .. " -"
					end

					local items = player:WaitForChild("Inventory", 999)
					local class = player:GetAttribute("Class")
					local cosmeticIndex = 8

					for _, item in items:GetChildren() do
						if AssetBook.Items.ItemType[item.Name] == "Passive" and item:GetAttribute("Equipped") then
							local index = match(item:GetAttribute("Slot"), "%d")

							desc["Slot"..index].Image = AssetBook.Items.ItemImages[item.Name]
						end
					end
					desc.Slot4.Image = AssetBook.ClassInfo[class].SkillImage
					desc.Slot4.ImageColor3 = if AssetBook.ClassInfo[class].CAIcon then color3New(1, 1, 1) else AssetBook.ClassInfo[class].Color
					for _, item in items:GetChildren() do
						if AssetBook.Items.ItemType[item.Name] == "Active" and item:GetAttribute("Equipped") then
							local index = match(item:GetAttribute("Slot"), "%d") + 4

							desc["Slot"..index].Image = AssetBook.Items.ItemImages[item.Name]
						end
					end
					for _, item in items:GetChildren() do
						if AssetBook.Items.ItemType[item.Name] == "Cosmetic" and item:GetAttribute("Equipped") then
							desc["Slot" .. cosmeticIndex].Image = AssetBook.Items.ItemImages[item.Name]

							cosmeticIndex += 1
						end
					end
					desc.Visible = true
				end,
			}),
		},
	})
end

return PlayerSlot
