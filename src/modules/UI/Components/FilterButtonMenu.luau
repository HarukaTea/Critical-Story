--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local peek = Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local tFind = table.find

local COLORS = {
	Character = fromRGB(172, 113, 86),
	Party = fromRGB(52, 104, 156),
	Settings = fromRGB(53, 107, 79),

	Disband = fromRGB(128, 0, 0),
}
local MENU_BTNS = { "Character", "Settings", "Party" }

local function _closeOther(self: table, id: string)
	local mainFrames = { "BottomLeft", "Top" }
	for _, frame in peek(self.UI).BG:GetChildren() do
		if frame:IsA("Frame") and not tFind(mainFrames, frame.Name) then
			frame.Visible = false
		end
	end

	peek(self.UI).BG[id].Visible = true
end
local function _onClick(id: string, self: table)
	if tFind(MENU_BTNS, id) then
		_closeOther(self, id)

		peek(self.UI).BG.BottomRight.Visible = if id == "Party" then true else false

	elseif id == "Disband" then
		Events.PartyInvite:Fire("Leave")
	end
end

local function FilterButton(id: string, self: table): TextButton
	return Components.TextButton({
		Name = id,
		BackgroundColor3 = COLORS[id],
		Text = id,
		Size = fromScale(0.116, 1),
		Visible = Fusion.Computed(function(use)
			if id == "Disband" then
				return if use(self.partyMembers)[1] and workspace.MapComponents.Parties:FindFirstChild(self.plr.Name)
					then true
					else false
			else
				return true
			end
		end),

		[Fusion.Children] = {
			Fusion.New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
		},
		[Fusion.OnEvent("MouseButton1Click")] = function()
			_onClick(id, self)
		end,
	})
end

return FilterButton
