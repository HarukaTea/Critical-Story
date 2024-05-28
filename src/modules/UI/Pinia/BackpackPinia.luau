--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signal = require(RepS.Modules.Packages.Signal)

local peek = Fusion.peek

local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function BackpackPinia(self: table)
    local plr = self.plr :: Player

    self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    self.Add, self.Empty = HarukaLib.Bin()

    self.inventory = plr:WaitForChild("Inventory", 999)

	self.itemFrame = Value()

	self.items = Value(self.inventory:GetChildren())
	self.noItemsShow = Value(true)
	self.chosenFilter = Value("Passive")

    local camVPSize = workspace.CurrentCamera.ViewportSize

    self.absSize = Value({ camVPSize.X * 0.71, camVPSize.Y * 0.662 })
	self.absCellPadding = Value({ peek(self.absSize)[1] * 0.02, peek(self.absSize)[2] * 0.02 })
	self.absCellSize = Value(peek(self.absSize)[1] / 15.58)
	self.absScrollSize, self.absContentSize = Value(90), Value(30)

    self.itemSlotClicked = Signal.new()

    self.filterInfo = {
        Equip = Value("EQUIP"),
        Pin = Value("PIN"),
    }

    self.absStatSize = Value(0)
	self.itemName, self.itemStats, self.itemDesc = Value(""),  Value(""), Value("")
	self.itemTierColor = Value(fromRGB()), Value(fromRGB())


     --[[
        Deselect all items, and hide the item description
    ]]
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
