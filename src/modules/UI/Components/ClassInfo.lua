--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.HarukaFrameworkClient).Fusion

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local NAMES = { "ClassInfo", "SkillInfo" }
local POSITION = { fromScale(0.2, -3.145), fromScale(0.8, -3.145) }
local COLORS = { fromRGB(255, 170, 127), fromRGB(85, 170, 255) }

local function ClassInfo(self: table, index: number) : Frame
    return Components.Frame({
        Name = NAMES[index],
        BackgroundTransparency = 0,
        Position = POSITION[index],
        Size = fromScale(0.515, 2.765),
        Visible = false,
        [Fusion.Ref] = if index == 1 then self.classInfo else self.skillInfo,

        [Fusion.Children] = {
            Fusion.New("UICorner")({ CornerRadius = udNew(0.05, 0) }),
            Components.UIStroke({
                Thickness = 3,
                Enabled = true,
            }),
            Components.TextLabel({
                Name = "Title",
                Position = fromScale(0, 0.05),
                Size = fromScale(1, 0.18),
                TextColor3 = COLORS[index],
                RichText = true
            }),
            Components.TextLabel({
                Name = "Info",
                Position = fromScale(0.042, 0.28),
                Size = fromScale(0.925, 0.63)
            }),
        },
    })
end

return ClassInfo