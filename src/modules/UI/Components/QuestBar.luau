--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local Children = Fusion.Children

local fromRGB = Color3.fromRGB
local fromScale = UDim2.fromScale
local udNew = UDim.new
local v2New = Vector2.new

local function QuestBar(quest: IntValue, scope: table) : Frame
    local questType = quest.Name

    return Components.Frame(scope, {
        Name = quest.Name,

        [Children] = {
            Components.Frame(scope, {
                Name = "Point",
                BackgroundColor3 = AssetBook.QuestColor[questType],
                BackgroundTransparency = 0,
                AnchorPoint = v2New(),
                Position = fromScale(0.015, 0.2),
                Size = fromScale(0.017, 0.63),
                Rotation = 45,

                [Children] = {
                    Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
                    Components.UIStroke(scope, {
                        Thickness = 3,
                        Enabled = true,
                        Color = fromRGB()
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "Series",
                Position = fromScale(0.04, -0.1),
                Size = fromScale(1, 0.675),
                TextColor3 = AssetBook.QuestColor[questType],
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = StoryBook[questType][quest.Value].Name,

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 2 })
                }
            }),
            Components.TextLabel(scope, {
                Name = "Info",
                Position = fromScale(0.041, 0.575),
                Size = fromScale(1, 0.5),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = StoryBook[questType][quest.Value].Target,

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 2 })
                }
            })
        }
    })
end

return QuestBar
