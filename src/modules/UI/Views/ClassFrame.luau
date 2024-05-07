--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ExCategoryOpenBtn = require(RepS.Modules.UI.Components.ExCategoryOpenBtn)
local PassiveSlot = require(RepS.Modules.UI.Components.PassiveSlot)

local Children, peek = Fusion.Children, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local match = string.match

local function ClassFrame(self: table) : Frame
    local scope = self.scope

    local function _equipItem(slot: string, item: string)
		local itemSlot = peek(self.classFrame):FindFirstChild(slot, true)
        if not itemSlot then return end

		itemSlot:SetAttribute("Equipped", if item == "Null" then false else true)
		itemSlot:SetAttribute("ItemEquipped", if item == "Null" then nil else item)

        local index = tonumber(match(itemSlot.Name, "%d+"))
		self.passiveIconList[index]:set(item, true)
	end
	Events.EquipItems:Connect(_equipItem)

    return Components.Frame(scope, {
        Name = "ClassFrame",
		Size = fromScale(1, 1.1),
        [Fusion.Ref] = self.classFrame,

        [Children] = {
            Components.Frame(scope, {
                Name = "AFrame",
                AnchorPoint = v2New(),
                Position = fromScale(0.837, -1),
                Size = fromScale(0.15, 1.5),

                [Children] = {
                    ExCategoryOpenBtn("Menu", self),
                    ExCategoryOpenBtn("Backpack", self)
                }
            }),
            Components.Frame(scope, {
                Name = "PFrame",
                AnchorPoint = v2New(),
                Position = fromScale(0.015, -0.9),
                Size = fromScale(0.15, 1.5),

                [Children] = {
                    PassiveSlot(1, self),
                    PassiveSlot(2, self),
                    PassiveSlot(3, self)
                }
            })
        },
    })
end

return ClassFrame
