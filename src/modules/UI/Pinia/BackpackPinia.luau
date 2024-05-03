--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)
local Signal = require(RepS.Modules.Packages.Signal)

local Value, peek = Fusion.Value, Fusion.peek

local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function BackpackPinia(self: table)
    local plr = self.plr :: Player

    self.inventory = plr:WaitForChild("Inventory", 999)

	self.itemFrame = Value()

	self.items = Value(self.inventory:GetChildren())
	self.noItemsShow = Value(if Fusion.peek(self.items)[1] then false else true)
	self.chosenFilter = Value("Passive")

    local camVPSize = workspace.CurrentCamera.ViewportSize

    self.absSize = Value({ camVPSize.X * 0.71, camVPSize.Y * 0.662 })
	self.absCellPadding = Value({ peek(self.absSize)[1] * 0.02, peek(self.absSize)[2] * 0.02 })
	self.absCellSize = Value(peek(self.absSize)[1] / 15.58)
	self.absScrollSize, self.absContentSize = Value(90), Value(30)

    self.itemSlotClicked = Signal()

    self.filterInfo = {
        Equip = {
            Visible = Value(false),
            Text = Value("EQUIP")
        },
        Pin = {
            Visible = Value(false),
            Text = Value("PIN"),
            Size = Value(fromScale(0.116, 1))
        },
    }

    self.absStatSize = Value(0)
	self.itemName, self.itemType, self.itemTier, self.itemStats, self.itemDesc =
		Value(""), Value(""), Value(""), Value(""), Value("")
	self.horizonLineVisible = Value(false)
	self.itemTypeColor, self.itemTierColor = Value(fromRGB()), Value(fromRGB())


     --[[
        Deselect all items, and hide the item description
    ]]
    function self:DeselectAll()
        for _, element: ImageButton in peek(self.itemFrame):GetChildren() do
            element:SetAttribute("Selected", nil)
        end

        self.horizonLineVisible:set(false)
        self.itemName:set("")
        self.itemType:set("")
        self.itemTier:set("")
        self.itemStats:set("")
        self.itemDesc:set("")

        self.filterInfo.Equip.Visible:set(false)
        self.filterInfo.Pin.Visible:set(false)
    end
end

return BackpackPinia
