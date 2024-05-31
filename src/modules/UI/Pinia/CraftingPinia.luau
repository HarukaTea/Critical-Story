--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signal = require(RepS.Modules.Packages.Signal)

local peek = Fusion.peek

local fromRGB = Color3.fromRGB

local function BackpackPinia(self: table)
    self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    self.Add, self.Empty = HarukaLib.Bin()

    self.visible = Value(false)

    local camVPSize = workspace.CurrentCamera.ViewportSize

    self.absSize = Value({ camVPSize.X * 0.71, camVPSize.Y * 0.662 })

    self.itemSlotClicked = Signal.new()

    self.absStatSize = Value(0)
	self.itemName, self.itemStats, self.itemDesc = Value(""),  Value(""), Value("")
	self.itemTierColor = Value(fromRGB())
    self.itemCost = Value(0)
    self.itemCostColor = Value(fromRGB(255, 255, 0))
    self.buyAmount = Value("1")
    self.currentShop = Value("None")

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
