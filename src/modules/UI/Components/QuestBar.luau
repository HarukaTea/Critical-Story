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
local fontFromName = Font.fromName

local function QuestBar(quest: IntValue, scope: Fusion.Scope) : Frame
    local questType = quest.Name
    local questDesc = StoryBook[questType][quest.Value].Target

    local questDescTable = {}
    local questColor = {}
    local lastPos = 1
    local colorList = {
		["blue"] = Color3.fromHex('#70a1ff'),
		["purple"] = Color3.fromHex('#5352ed'),
		["red"] = Color3.fromHex('#ff4757'),
		["orange"] = Color3.fromHex('#ffa502'),
		["yellow"] = Color3.fromHex('#ffda79'),
		["green"] = Color3.fromHex('#7bed9f')
	}

    while true do
        local startTag, endTag = string.find(questDesc, "<([^>]+)>(.-)</font>", lastPos)
        if not startTag then
            table.insert(questDescTable, string.sub(questDesc, lastPos))
            table.insert(questColor, fromRGB(255, 255, 255))
            break
        end

        --- before
        table.insert(questDescTable, string.sub(questDesc, lastPos, startTag - 1))
        table.insert(questColor, fromRGB(255, 255, 255))

        --- tag
        local tagName, tagContent = string.match(questDesc, "<([^>]+)>(.-)</font>", startTag)
        local color = colorList[tagName] or fromRGB(255, 255, 255)

        table.insert(questDescTable, tagContent)
        table.insert(questColor, color)

        lastPos = endTag + 1
    end

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
            Components.Frame(scope, {
                Name = "Info",
                AnchorPoint = v2New(),
                Position = fromScale(0.041, 0.585),
                Size = fromScale(1, 0.45),

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
                    }),

                    Fusion.ForPairs(scope, questDescTable, function(_, localScope: Fusion.Scope, index: number, _)
                        return index, Components.TextLabel(localScope, {
                            Name = "Desc"..index,
                            AutomaticSize = Enum.AutomaticSize.X,
                            Size = fromScale(0, 1),
                            LayoutOrder = index,
                            FontFace = fontFromName("Ubuntu", Enum.FontWeight.Bold),
                            TextColor3 = questColor[index],
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Text = questDescTable[index],

                            [Children] = {
                                Components.TextUIStroke(scope, { Thickness = 2 })
                            }
                        })
                    end)
                }
            })
        }
    })
end

return QuestBar
