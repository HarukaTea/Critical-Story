--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ActiveSlot = require(RepS.Modules.UI.Components.ActiveSlot)
local PassiveSlot = require(RepS.Modules.UI.Components.PassiveSlot)

local Children, peek = Fusion.Children, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local match, sFind, format = string.match, string.find, string.format
local wait = task.wait

local function ClassFrame(self: table) : Frame
    local scope = self.scope :: Fusion.Scope

    local function _equipItem(slot: string, item: string)
        local index = tonumber(match(slot, "%d"))
        local checkList = if sFind(slot, "Active") then self.activeEquipList else self.passiveEquipList
        local checkList2 = if sFind(slot, "Active") then self.activeSlotList else self.passiveSlotList

        checkList[index]:set(item, true)

        peek(checkList2[index]):SetAttribute("Equipped", if item == "Null" then false else true)
        peek(checkList2[index]):SetAttribute("ItemEquipped", if item == "Null" then nil else item)
	end
	Events.EquipItems:Connect(_equipItem)

    local function __findSlotByItemId(item: string) : string
        for index, element: Frame in self.activeEquipList do
            if peek(element) == item then return "Active"..index end
		end

		return "None"
    end
    local function _applyCDToSlot(cd: number, item: string)
        local slot, activeCDRotationList, activeCDList =
            __findSlotByItemId(item), self.activeCDRotationList, self.activeCDList

        --- final check
        if slot == "None" then return end

        local percentage = 0
        local index = tonumber(match(slot, "%d"))

        for i = cd, 0.1, -0.1 do
            local pattern = if i >= 10 then "%.0f" else "%.1f"
            activeCDList[index]:set(format(pattern, i))

            percentage += 1/(cd * 10)
            activeCDRotationList[index]:set(percentage)

            wait(0.1)
        end

        activeCDList[index]:set(0)
        activeCDRotationList[index]:set(0)
    end
    Events.ItemCD:Connect(_applyCDToSlot)

    return Components.Frame(scope, {
        Name = "ClassFrame",
		Size = fromScale(1, 1.1),

        [Children] = {
            Components.Frame(scope, {
                Name = "AFrame",
                AnchorPoint = v2New(),
                Position = fromScale(0.837, -1.2),
                Size = fromScale(0.15, 1.5),

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        Padding = UDim.new(0.08, 0),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right
                    }),

                    ActiveSlot(1, self),
                    ActiveSlot(2, self),
                    ActiveSlot(3, self)
                }
            }),
            Components.Frame(scope, {
                Name = "PFrame",
                AnchorPoint = v2New(),
                Position = fromScale(0.015, -0.9),
                Size = fromScale(0.15, 1.5),

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        Padding = UDim.new(0.08, 0),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal
                    }),

                    PassiveSlot(1, self),
                    PassiveSlot(2, self),
                    PassiveSlot(3, self)
                }
            })
        },
    })
end

return ClassFrame
