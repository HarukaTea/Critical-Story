--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)

local New, Children, Computed = Fusion.New, Fusion.Children, Fusion.Computed

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function PlayerItemSlot(id: number, self: table): ImageLabel
    local scope = self.scope
    local POSITIONS = {
        fromScale(0.164, 0.391),
        fromScale(0.401, 0.391),
        fromScale(0.637, 0.391),
        fromScale(0.048, 0.558),
        fromScale(0.28, 0.558),
        fromScale(0.516, 0.558),
        fromScale(0.753, 0.558),
    }

	return New(scope, "ImageLabel")({
		Name = "Slot" .. id,
		BackgroundColor3 = color3New(),
		Position = POSITIONS[id],
		Size = fromScale(0.19, 0.165),

		Image = Computed(scope, function(use)
            return if use(self.playerItemIconList[id]) == "Null" then
                ItemBook.ItemImagesEx.Null else "rbxassetid://"..ItemBook:FindItem(use(self.playerItemIconList[id])).Icon
        end),

		[Children] = {
			Components.RoundUICorner(scope),
			Components.UIStroke(scope, { Thickness = 3 }),
		},
	})
end

local function PlayerDescFrame(self: table) : Frame
    local scope = self.scope

    return Components.Frame(scope, {
        Name = "Desc",
        AnchorPoint = v2New(),
        Position = fromScale(0.715, 0),
        Size = fromScale(0.15, 4.5),

        Visible = Fusion.Computed(scope, function(use)
            return use(self.playerDescVisible)
        end),

        [Children] = {
            Components.Frame(scope, {
                Name = "BG",
                AnchorPoint = v2New(),
                Position = fromScale(0, 0),
                BackgroundTransparency = 0.1,
                ZIndex = 0,

                Size = Fusion.Computed(scope, function(use)
                    return use(self.playerDescBGSize)
                end),

                [Children] = {
                    New(scope, "UICorner")({ CornerRadius = udNew(0.03, 0) }),
                }
            }),
            New(scope, "ImageLabel")({
                Name = "Class",
                BackgroundColor3 = color3New(),
                Position = fromScale(0.05, 0.055),
                Size = fromScale(0.205, 0.175),

                Image = Computed(scope, function(use)
                    return use(self.classImage)
                end),

                [Children] = { Components.RoundUICorner(scope) },
            }),
            Components.TextLabel(scope, {
                Name = "DisplayName",
                Position = fromScale(0.3, 0.05),
                Size = fromScale(0.63, 0.095),
                TextXAlignment = Enum.TextXAlignment.Left,

                Text = Computed(scope, function(use)
                    return use(self.displayName)
                end)
            }),
            Components.TextLabel(scope, {
                Name = "UserName",
                Position = fromScale(0.3, 0.15),
                Size = fromScale(0.63, 0.06),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = fromRGB(193, 193, 193),

                Text = Computed(scope, function(use)
                    return use(self.userName)
                end)
            }),
            Components.TextLabel(scope, {
                Name = "Level",
                Position = fromScale(0.06, 0.245),
                Size = fromScale(0.866, 0.077),
                TextColor3 = fromRGB(255, 255, 0),

                Text = Computed(scope, function(use)
                    return use(self.level)
                end)
            }),
            New(scope, "Frame")({
                Name = "HorizonLine",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.35),
                Size = fromScale(0.9, 0.005),
                BackgroundTransparency = 0.7
            }),

            PlayerItemSlot(1, self),
            PlayerItemSlot(2, self),
            PlayerItemSlot(3, self),
            PlayerItemSlot(4, self),
            PlayerItemSlot(5, self),
            PlayerItemSlot(6, self),
            PlayerItemSlot(7, self),

            Components.TextLabel(scope, {
                Name = "Role",
                Position = fromScale(0.06, 0.751),
                Size = fromScale(0.865, 0.06),
                TextTransparency = 0.2,

                Text = Computed(scope, function(use)
                    return use(self.role)
                end)
            }),
        },
    })
end

return PlayerDescFrame
