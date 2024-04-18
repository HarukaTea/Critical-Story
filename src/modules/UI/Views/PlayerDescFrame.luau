--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local PlayerItemSlot = require(RepS.Modules.UI.Components.PlayerItemSlot)

local New = Fusion.New

local color3New, v2New, udNew, ud2New = Color3.new, Vector2.new, UDim.new, UDim2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function PlayerDescFrame(self: table) : Frame
    return Components.Frame({
        Name = "Desc",
        BackgroundTransparency = 0.1,
        AnchorPoint = v2New(),
        Position = ud2New(0.7, 0, 0.013, 20),
        Size = fromScale(0.16, 0.475),
        Visible = false,
        [Fusion.Ref] = self.desc,

        [Fusion.Children] = {
            New("UIAspectRatioConstraint")({ AspectRatio = 0.859 }),
            New("UICorner")({ CornerRadius = udNew(0.03, 0) }),
            New("ImageLabel")({
                Name = "Class",
                BackgroundColor3 = color3New(),
                Position = fromScale(0.05, 0.055),
                Size = fromScale(0.205, 0.175),

                [Fusion.Children] = { Components.RoundUICorner() },
            }),
            Components.TextLabel({
                Name = "DisplayName",
                Position = fromScale(0.3, 0.05),
                Size = fromScale(0.63, 0.095),
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Components.TextLabel({
                Name = "UserName",
                Position = fromScale(0.3, 0.15),
                Size = fromScale(0.63, 0.06),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = fromRGB(193, 193, 193),
            }),
            Components.TextLabel({
                Name = "Level",
                Position = fromScale(0.06, 0.245),
                Size = fromScale(0.866, 0.077),
                TextColor3 = fromRGB(255, 255, 0),
            }),
            New("Frame")({
                Name = "HorizonLine",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.35),
                Size = fromScale(0.9, 0.005),
                BackgroundTransparency = 0.7
            }),

            PlayerItemSlot(1),
            PlayerItemSlot(2),
            PlayerItemSlot(3),
            PlayerItemSlot(4),
            PlayerItemSlot(5),
            PlayerItemSlot(6),
            PlayerItemSlot(7),
            PlayerItemSlot(8),
            PlayerItemSlot(9),
            PlayerItemSlot(10),

            Components.TextLabel({
                Name = "Role",
                Position = fromScale(0.06, 0.91),
                Size = fromScale(0.865, 0.06),
                TextTransparency = 0.2,
            }),
        },
    })
end

return PlayerDescFrame
