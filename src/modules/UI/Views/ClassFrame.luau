--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ExBindingBtn = require(RepS.Modules.UI.Components.ExBindingBtn)
local PassiveSlot = require(RepS.Modules.UI.Components.PassiveSlot)

local Children, Value, peek = Fusion.Children, Fusion.Value, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local sFind, match = string.find, string.match

local function ClassFrame(self: table) : Frame
    self.passiveIconList = { Value("Null"), Value("Null"), Value("Null"), Value("Null"), Value("Null"), Value("Null") }

    local function _equipItem(type: string, slot: string, item: string)
		local itemSlot = peek(self.classFrame):FindFirstChild(slot, true)
        if not itemSlot then return end
        if not self.inventory:FindFirstChild(item) then return end

		itemSlot:SetAttribute("Equipped", true)
		itemSlot:SetAttribute("ItemEquipped", item)

        local index = tonumber(match(itemSlot.Name, "%d+"))
		if type == "Passive" then
            self.passiveIconList[tonumber(index)]:set(item, true)
		end
	end
	Events.EquipItems:Connect(_equipItem)

    local function _refreshEquippedItems()
		local classFrame, inventory = peek(self.classFrame), self.inventory

		for _, element in classFrame:GetDescendants() do
			if sFind(element.Name, "Passive") then
                local index = tonumber(match(element.Name, "%d+"))

				element:SetAttribute("Equipped", false)
				element:SetAttribute("ItemEquipped", "")

				self.passiveIconList[index]:set("Null", true)
			end
		end

		for _, item in inventory:GetChildren() do
			if item.Value > 0 and AssetBook.Items.ItemType[item.Name] == "Passive" and item:GetAttribute("Equipped") then
				local slot = item:GetAttribute("Slot")
				local itemSlot = classFrame:FindFirstChild(slot, true)
                if not itemSlot then continue end

                local index = tonumber(match(itemSlot.Name, "%d+"))
                self.passiveIconList[index]:set(item.Name, true)

				itemSlot:SetAttribute("Equipped", true)
				itemSlot:SetAttribute("ItemEquipped", item.Name)
			end
		end
	end
	Events.RefreshBackpack:Connect(_refreshEquippedItems)

    return Components.Frame({
        Name = "ClassFrame",
		Size = fromScale(1, 1.1),
        [Fusion.Ref] = self.classFrame,

        [Children] = {
            Components.Frame({
                Name = "AFrame",
                AnchorPoint = v2New(),
                Position = fromScale(0.837, -1),
                Size = fromScale(0.15, 1.5),

                [Children] = {
                    ExBindingBtn("Menu", self),
                    ExBindingBtn("Backpack", self)
                }
            }),
            Components.Frame({
                Name = "PFrame",
                AnchorPoint = v2New(),
                Position = fromScale(0.015, -0.9),
                Size = fromScale(0.15, 1.5),

                [Children] = {
                    PassiveSlot(1, self),
                    PassiveSlot(2, self),
                    PassiveSlot(3, self),
                    PassiveSlot(4, self),
                    PassiveSlot(5, self)
                }
            })
        },
    })
end

return ClassFrame
