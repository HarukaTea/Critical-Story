--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)
local Signal = require(RepS.Modules.Packages.Signal)

local peek = Fusion.peek

local fromRGB = Color3.fromRGB

local function BackpackPinia(self: table)
    self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    local camVPSize = workspace.CurrentCamera.ViewportSize

    self.absSize = Value({ camVPSize.X * 0.71, camVPSize.Y * 0.662 })
	self.absCellPadding = Value({ peek(self.absSize)[1] * 0.02, peek(self.absSize)[2] * 0.02 })
	self.absCellSize = Value(peek(self.absSize)[1] / 15.58)
	self.absScrollSize, self.absContentSize = Value(Vector2.new()), Value(Vector2.new())

    self.itemSlotClicked = Signal.new()

    self.absStatSize = Value(Vector2.new())
	self.itemName, self.itemStats, self.itemDesc = Value(""),  Value(""), Value("")
	self.itemTierColor = Value(fromRGB())
    self.itemCost = Value(0)
    self.itemCostColor = Value(fromRGB(255, 255, 0))
    self.buyAmount = Value("1")

    self.items = Value({})
    self.itemFrame = Value()

    function self:DeselectAll()
        for _, element: ImageButton in peek(self.itemFrame):GetChildren() do
            element:SetAttribute("Selected", nil)
        end

        self.itemName:set("")
        self.itemStats:set("")
        self.itemDesc:set("")
        self.itemCost:set(0)
        self.itemCostColor:set(fromRGB(255, 255, 0))
    end
end

return BackpackPinia
