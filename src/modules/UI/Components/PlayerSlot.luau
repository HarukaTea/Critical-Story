--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local New, Children = Fusion.New, Fusion.Children

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local format, match = string.format, string.match

local function PlayerSlot(self: table, player: Player, scope: table): Frame
	local class = Fusion.Value(scope, player:GetAttribute("Class") or "Warrior") --// This often errors lol
	local role = player:GetAttribute("Role")

	scope[#scope + 1] = HarukaLib:Hydrate(player, {
		["Attr-Class"] = function(newClass: string)
			class:set(newClass)
		end
	})

	return Components.Frame(scope, {
		BackgroundTransparency = 0,
		Size = fromScale(1, 0.2),
		Name = player.Name,

		[Children] = {
			New(scope, "UIAspectRatioConstraint")({ AspectRatio = 4.993 }),
			New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
			New(scope, "ImageLabel")({
				Name = "Class",
				AnchorPoint = v2New(0, 0.5),
				BackgroundColor3 = color3New(),
				Position = fromScale(0.055, 0.5),
				Size = fromScale(0.13, 0.665),

				Image = Fusion.Computed(scope, function(use)
					return AssetBook.ClassInfo[use(class)].Image
				end),

				[Children] = { Components.RoundUICorner(scope) },
			}),
			Components.TextLabel(scope, {
				Name = "PlayerName",
				Position = fromScale(0.24, 0),
				Size = fromScale(0.721, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = player.DisplayName,

				TextColor3 = if role then fromRGB(170, 255, 255) else color3New(1, 1, 1),

				[Children] = {
					New(scope, "UIPadding")({
						PaddingBottom = udNew(0.18, 0),
						PaddingTop = udNew(0.18, 0)
					})
				}
			}),
			Components.HoverImageButton(scope, {
				ZIndex = 2,

				[Fusion.OnEvent("MouseEnter")] = function()
					local list = Fusion.peek(self.list) :: Frame

					for _, element: Frame in list:GetChildren() do
						if element:IsA("Frame") then
							local roleColor = if Players[element.Name]:GetAttribute("Role") then fromRGB(170, 255, 255) else color3New(1, 1, 1)

							element.BackgroundColor3 = fromRGB(30, 30, 30)
							element.PlayerName.TextColor3 = roleColor
						end
					end
					for _, element: any in self.playerItemIconList do element:set("Null", true) end

					list[player.Name].BackgroundColor3 = color3New(1, 1, 1)
					list[player.Name].PlayerName.TextColor3 = color3New()

					if not player:GetAttribute("PlayerDataLoaded") then return end

					self.displayName:set(player.DisplayName)
					self.userName:set("@" .. player.Name)
					self.classImage:set(AssetBook.ClassInfo[Fusion.peek(class)].Image)
					self.level:set("Lv."
						.. player:GetAttribute("Levels")
						.. " - "
						.. format("%.1f", player:GetAttribute("PlayTime") / 3600)
						.. " Hours")
					self.role:set(if player:GetAttribute("Role") then "- " .. player:GetAttribute("Role") .. " -" else "")
					self.playerDescBGSize:set(if player:GetAttribute("Role") then fromScale(1, 0.86) else fromScale(1, 0.77))

					local items = player:WaitForChild("Inventory", 999) :: Folder

					for _, item: IntValue in items:GetChildren() do
						local itemInfo = ItemBook:FindItem(item.Name)

						if itemInfo.Type == "Passive" and item:GetAttribute("Equipped") then
							local index = tonumber(match(item:GetAttribute("Slot"), "%d"))

							self.playerItemIconList[index]:set(item.Name, true)

						elseif itemInfo.Type == "Active" and item:GetAttribute("Equipped") then
							local index = tonumber(match(item:GetAttribute("Slot"), "%d")) + 3

							self.playerItemIconList[index]:set(item.Name, true)
						end
					end

					self.playerDescVisible:set(true)
				end
			})
		}
	})
end

return PlayerSlot
