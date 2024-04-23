--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local New, Children, peek = Fusion.New, Fusion.Children, Fusion.peek

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local sFind, format, match = string.find, string.format, string.match

local function PlayerSlot(self: table, player: Player): Frame
	local class = Fusion.Value("Warrior")
	Fusion.Hydrate(player)({
		[Fusion.AttributeChange("Class")] = function(newClass: string)
			class:set(newClass)
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
					local realClass = use(class)
					return if AssetBook.ClassInfo[realClass] then AssetBook.ClassInfo[realClass].Image else ""
				end),

				[Children] = { Components.RoundUICorner() },
			}),
			Components.TextLabel({
				Name = "PlayerName",
				Position = fromScale(0.24, 0),
				Size = fromScale(0.721, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = player.DisplayName,
				TextColor3 = if player:GetAttribute("Role") then fromRGB(170, 255, 255) else color3New(1, 1, 1),

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

					for _, element in list:GetChildren() do
						if element:IsA("Frame") then
							local roleColor = if Players[element.Name]:GetAttribute("Role") then fromRGB(170, 255, 255) else color3New(1, 1, 1)

							element.BackgroundColor3 = fromRGB(30, 30, 30)
							element.PlayerName.TextColor3 = roleColor
						end
					end
					for _, element in desc:GetChildren() do
						if sFind(element.Name, "Slot") then
							element.Image = AssetBook.Items.ItemImages.Null
						end
					end

					list[player.Name].BackgroundColor3 = color3New(1, 1, 1)
					list[player.Name].PlayerName.TextColor3 = color3New()

					desc.Role.Text = ""
					desc.DisplayName.Text = player.DisplayName
					desc.UserName.Text = "@" .. player.Name
					desc.Class.Image = AssetBook.ClassInfo[peek(class)].Image
					desc.Level.Text = "Lv."
						.. player:GetAttribute("Levels")
						.. " - "
						.. format("%.1f", player:GetAttribute("PlayTime") / 3600)
						.. " Hours"

					if player:GetAttribute("Role") then
						desc.Role.Text = "- " .. player:GetAttribute("Role") .. " -"
					end

					local items = player:WaitForChild("Inventory", 999) :: Folder

					for _, item in items:GetChildren() do
						if AssetBook.Items.ItemType[item.Name] == "Passive" and item:GetAttribute("Equipped") then
							local index = tonumber(match(item:GetAttribute("Slot"), "%d"))

							desc["Slot"..index].Image = AssetBook.Items.ItemImages[item.Name]
						end
					end
					desc.Visible = true
				end,
			}),
		},
	})
end

return PlayerSlot
