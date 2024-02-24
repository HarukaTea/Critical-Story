--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ActiveSlot = require(RepS.Modules.UI.Components.ActiveSlot)
local ExBindingBtn = require(RepS.Modules.UI.Components.ExBindingBtn)
local PassiveSlot = require(RepS.Modules.UI.Components.PassiveSlot)

local Children, Value, peek = Fusion.Children, Fusion.Value, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local sFind, match, format = string.find, string.match, string.format
local wait = task.wait

local function ClassFrame(self: table) : Frame
    self.activeList = { Value(), Value(), Value(), Value() }
    self.activeInnerCDList = { false, false, false, false }
	self.activeCDRotationList = { Value(0), Value(0), Value(0), Value(0), Value(0) }
	self.activeCDText = { Value(""), Value(""), Value(""), Value(""), Value("") }
    self.activeIconList = { Value("Null"), Value("Null"), Value("Null"), Value("Null") }
    self.activeAmountList = { Value(0), Value(0), Value(0), Value(0) }
    self.passiveIconList = { Value("Null"), Value("Null"), Value("Null"), Value("Null"), Value("Null"), Value("Null") }

    local function __findSlotByItemId(item: string): string
		for _, element in peek(self.classFrame):GetDescendants() do
			if sFind(element.Name, "Active") then
				if element:GetAttribute("ItemEquipped") == item then
					return element.Name
				end
			end
		end

		return "None"
	end
    local function _applyCDToSlot(cd: number, item: string)
		local slot, classFrame, activeCDRotationList, activeCDText =
			__findSlotByItemId(item), peek(self.classFrame), self.activeCDRotationList, self.activeCDText

		--- cancel the cd
		if cd == 0 then
			local itemSlot = item
			if not classFrame:FindFirstChild(itemSlot, true) then return end

            local activeSlot = classFrame:FindFirstChild(itemSlot, true)
			activeSlot:SetAttribute("InCD", false)
			return
		end
		--- final check
		if slot == "None" then return end

		local itemSlot = classFrame:FindFirstChild(slot, true)
		local percentage = 0
		local index = tonumber(match(slot, "%d+"))
        if not itemSlot then return end

		itemSlot.Cooldown.Visible = true
		itemSlot:SetAttribute("InCD", true)

		for i = cd, 0.1, -0.1 do
			if itemSlot:GetAttribute("InCD") == false then break end

			local pattern = if i > 10 then "%.0f" else "%.1f"
			activeCDText[index]:set(format(pattern, i))

			percentage += 1/(cd * 10)
			activeCDRotationList[index]:set(percentage)

			wait(0.1)
		end

		if not classFrame:FindFirstChild(slot, true) then return end

		itemSlot.Cooldown.Visible = false
		itemSlot:SetAttribute("InCD", false)
		activeCDRotationList[index]:set(0)
	end
	Events.ItemCD:Connect(_applyCDToSlot)

    local function _equipItem(type: string, slot: string, item: string)
		local itemSlot = peek(self.classFrame):FindFirstChild(slot, true)
        if not itemSlot then return end
        if not self.inventory:FindFirstChild(item) then return end

		itemSlot:SetAttribute("Equipped", true)
		itemSlot:SetAttribute("ItemEquipped", item)

        local index = tonumber(match(itemSlot.Name, "%d+"))
		if type == "Passive" then
            self.passiveIconList[tonumber(index)]:set(item, true)

		elseif type == "Active" then
            self.activeIconList[index]:set(item, true )
            self.activeAmountList[index]:set(self.inventory[item].Value, true)
		end
	end
	Events.EquipItems:Connect(_equipItem)

    local function _refreshEquippedItems()
		local classFrame, inventory = peek(self.classFrame), self.inventory

		for _, element in classFrame:GetDescendants() do
			if sFind(element.Name, "Active") then
                local index = tonumber(match(element.Name, "%d+"))

				element:SetAttribute("Equipped", false)
				element:SetAttribute("ItemEquipped", "")

                self.activeIconList[index]:set("Null", true)
                self.activeAmountList[index]:set(0, true)

			elseif sFind(element.Name, "Passive") then
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

		for _, item in inventory:GetChildren() do
			if item.Value > 0 and AssetBook.Items.ItemType[item.Name] == "Active" and item:GetAttribute("Equipped") then
				local slot = item:GetAttribute("Slot")
				local itemSlot = classFrame:FindFirstChild(slot, true)
                if not itemSlot then continue end

                local index = tonumber(match(itemSlot.Name, "%d+"))
                self.activeIconList[index]:set(item.Name, true)
                self.activeAmountList[index]:set(inventory[item.Name].Value, true)

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
                    ActiveSlot(1, self),
                    ActiveSlot(2, self),
                    ActiveSlot(3, self),

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
