--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)
local Signal = require(RepS.Modules.Packages.Signal)

local peek = Fusion.peek

local fromRGB = Color3.fromRGB

local function BackpackPinia(self: table)
    local plr = self.plr :: Player

    self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    self.inventory = plr:WaitForChild("Inventory", 999)

	self.itemFrame = Value()

	self.items = Value(self.inventory:GetChildren())
	self.noItemsShow = Value(true)
	self.chosenFilter = Value("Passive")

    local camVPSize = workspace.CurrentCamera.ViewportSize

    self.absSize = Value({ camVPSize.X * 0.71, camVPSize.Y * 0.662 })
	self.absCellPadding = Value({ peek(self.absSize)[1] * 0.02, peek(self.absSize)[2] * 0.02 })
	self.absCellSize = Value(peek(self.absSize)[1] / 15.58)
	self.absScrollSize, self.absContentSize = Value(Vector2.new()), Value(Vector2.new())

    self.itemSlotClicked = Signal.new()

    self.filterInfo = {
        Equip = Value("EQUIP"),
        Pin = Value("PIN"),
    }

    self.absStatSize = Value(Vector2.new())
	self.itemName, self.itemStats, self.itemDesc = Value(""),  Value(""), Value("")
	self.itemTierColor = Value(fromRGB())

    function self:DeselectAll()
        for _, element: ImageButton in peek(self.itemFrame):GetChildren() do
            element:SetAttribute("Selected", nil)
        end

        self.itemName:set("")
        self.itemStats:set("")
        self.itemDesc:set("")
    end
end

return BackpackPinia
