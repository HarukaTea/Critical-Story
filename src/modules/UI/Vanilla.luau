--!nocheck

local Fusion = require(game:GetService("ReplicatedStorage").Modules.Packages.Fusion)

local Components = {}

local color3New, v2New, ud2New, udNew = Color3.new, Vector2.new, UDim2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function _createNewCompoent(props: table, uiType: string, default: table) : GuiObject
	for i, v in props do
		default[i] = v
	end
	return Fusion.New(uiType)(default)
end

--[[
	Return a ScreenGui, without clips and insets
]]
function Components.ScreenGui(props: table) : ScreenGui
	return _createNewCompoent(props, "ScreenGui", {
		ClipToDeviceSafeArea = false,
		ScreenInsets = Enum.ScreenInsets.None,
		IgnoreGuiInset = true
	})
end

--[[
	Return a transparent frame, with a center anchor, and max size
]]
function Components.Frame(props: table) : Frame
	return _createNewCompoent(props, "Frame", {
		AnchorPoint = v2New(0.5, 0.5),
		Position = fromScale(0.5, 0.5),
		Size = fromScale(1, 1),
		BackgroundColor3 = fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
	})
end

--[[
	Return a transparent scrollable frame, with a center anchor, and no clips
]]
function Components.ScrollingFrame(props: table) : ScrollingFrame
	return _createNewCompoent(props, "ScrollingFrame", {
		BackgroundColor3 = fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		AnchorPoint = v2New(0.5, 0.5),
		Position = fromScale(0.5, 0.5),
		CanvasSize = fromScale(0, 0),
		ScrollBarThickness = 0,
		ClipsDescendants = false,
	})
end

--[[
	Return a transparent background text, with SourceSansPro bold font, white color
]]
function Components.TextLabel(props: table) : TextLabel
	return _createNewCompoent(props, "TextLabel", {
		BackgroundColor3 = fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		TextScaled = true,
		TextColor3 = color3New(1, 1, 1),
		TextStrokeColor3 = color3New(),
	})
end

--[[
	The same as Components.TextLabel, but with center anchor, and left XAlignment
]]
function Components.CenterTextLabel(props: table) : TextLabel
	return _createNewCompoent(props, "TextLabel", {
		BackgroundColor3 = fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		TextScaled = true,
		TextColor3 = color3New(1, 1, 1),
		AnchorPoint = v2New(0.5, 0.5),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

--[[
	Return a textbox, with SourceSansPro bold font, white color
]]
function Components.TextBox(props: table) : TextBox
	return _createNewCompoent(props, "TextBox", {
		BackgroundColor3 = color3New(),
		ClearTextOnFocus = false,
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		Text = "",
		TextColor3 = color3New(1, 1, 1),
		TextScaled = true,
	})
end

--[[
	Return an empty transparent background image
]]
function Components.ImageLabel(props: table) : ImageLabel
	return _createNewCompoent(props, "ImageLabel", {
		BackgroundColor3 = color3New(),
		BackgroundTransparency = 1,
		Image = "",
	})
end

--[[
	Return a clickable empty transparent image, but with center anchor and full size
]]
function Components.HoverImageButton(props: table) : ImageButton
	return _createNewCompoent(props, "ImageButton", {
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 1,
		AnchorPoint = v2New(0.5, 0.5),
		Position = fromScale(0.5, 0.5),
		Size = ud2New(1, 0, 1, 0),
		Image = "",
	})
end

--[[
	Return a clickable text, with SourceSansPro bold font, and black background
]]
function Components.TextButton(props: table) : TextButton
	return _createNewCompoent(props, "TextButton", {
		AutoButtonColor = true,
		BackgroundColor3 = fromRGB(30, 30, 30),
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		TextColor3 = color3New(1, 1, 1),
		TextScaled = true,
	})
end

--[[
	Return a disabled border UIStroke, with a little transparent
]]
function Components.UIStroke(props: table) : UIStroke
	return _createNewCompoent(props, "UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color3New(1, 1, 1),
		Transparency = 0.3,
		Enabled = false,
	})
end

--[[
	Same as Components.UIStroke, but it's black and usually used for text
]]
function Components.TextUIStroke(props: table) : UIStroke
	return _createNewCompoent(props, "UIStroke", {
		Transparency = 0.3,
	})
end

--[[
	Return a UICorner which can let GuiObject become round like a circle
]]
function Components.RoundUICorner() : UICorner
	return Fusion.New("UICorner")({ CornerRadius = udNew(0.5, 0) })
end

--[[
	Return a UIPadding with 4px in total, usually used for text
]]
function Components.NormalUIPadding() : UIPadding
	return Fusion.New("UIPadding")({
		PaddingTop = udNew(0, 2),
		PaddingBottom = udNew(0, 2),
	})
end

return Components
