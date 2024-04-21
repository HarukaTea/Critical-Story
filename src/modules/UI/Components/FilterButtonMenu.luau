--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local peek = Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local tFind = table.find

local COLORS = {
	Character = fromRGB(172, 113, 86),
	Settings = fromRGB(53, 107, 79),
}
local MENU_BTNS = { "Character", "Settings" }

local function _closeOther(self: table, id: string)
	local mainFrames = { "BottomLeft", "BottomRight", "Top" }
	for _, frame in peek(self.UI).BG:GetChildren() do
		if frame:IsA("Frame") and not tFind(mainFrames, frame.Name) then
			frame.Visible = false
		end
	end

	peek(self.UI).BG[id].Visible = true
end
local function _onClick(id: string, self: table)
	if tFind(MENU_BTNS, id) then _closeOther(self, id) end
end

local function FilterButton(id: string, self: table): TextButton
	return Components.TextButton({
		Name = id,
		BackgroundColor3 = COLORS[id],
		Text = id,
		Size = fromScale(0.116, 1),

		[Fusion.Children] = {
			Fusion.New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
		},
		[Fusion.OnEvent("MouseButton1Click")] = function()
			_onClick(id, self)
		end,
	})
end

return FilterButton
