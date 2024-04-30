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

local function FilterButtonMenu(id: string, self: table): TextButton
	local COLORS = {
		Character = fromRGB(172, 113, 86),
		Settings = fromRGB(53, 107, 79),

		--//TODO: New UIs
		--Donation = ?
		--Party = ?
	}

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
			self.chosenFilter:set(id)

			local mainFrames = { "BottomLeft", "BottomRight", "Top" }
			for _, frame: Frame in peek(self.UI).BG:GetChildren() do
				if frame:IsA("Frame") and not tFind(mainFrames, frame.Name) then frame.Visible = false end
			end

			peek(self.UI).BG[id].Visible = true
		end,
	})
end

return FilterButtonMenu
