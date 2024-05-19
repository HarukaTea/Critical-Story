--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local upper = string.upper

local function FilterButtonMenu(id: string, self: table): TextButton
	local scope = self.scope
	local COLORS = {
		Character = fromRGB(172, 113, 86),
		Settings = fromRGB(53, 107, 79),
	}

	return Components.TextButton(scope, {
		Name = id,
		BackgroundColor3 = COLORS[id],
		Text = upper(id),
		Size = fromScale(0.14, 1),

		[Fusion.Children] = {
			Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
			Components.UIStroke(scope, {
				Thickness = 3,
				Enabled = true,

				Transparency = Fusion.Tween(scope, Fusion.Computed(scope, function(use)
					return if use(self.chosenFilter) == id then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			})
		},
		[Fusion.OnEvent("MouseButton1Click")] = function()
			self.chosenFilter:set(id)

			for _, frame: any in self.frames do frame:set(false) end
			self.frames[id]:set(true)
		end,
	})
end

return FilterButtonMenu
