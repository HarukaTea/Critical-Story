--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local peek = Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local tFind = table.find
local upper = string.upper

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
	if tFind(MENU_BTNS, id) then
		self.chosenFilter:set(id)

		_closeOther(self, id)
	end
end

local function FilterButton(id: string, self: table): TextButton
	if not self.chosenFilter then self.chosenFilter = Fusion.Value("Character") end

	return Components.TextButton({
		Name = id,
		BackgroundColor3 = COLORS[id],
		Text = upper(id),
		Size = fromScale(0.14, 1),

		[Fusion.Children] = {
			Fusion.New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
			Components.UIStroke({
				Thickness = 3,
				Enabled = true,

				Transparency = Fusion.Tween(Fusion.Computed(function(use)
					return if use(self.chosenFilter) == id then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			})
		},
		[Fusion.OnEvent("MouseButton1Click")] = function()
			_onClick(id, self)
		end,
	})
end

return FilterButton
