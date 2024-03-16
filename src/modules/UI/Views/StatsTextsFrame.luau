--!strict

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New, Value, AttributeChange =
    Fusion.Children, Fusion.New, Fusion.Value, Fusion.AttributeChange

local v2New = Vector2.new
local udNew = UDim.new
local fromScale = UDim2.fromScale

local function StatImage(id: string, self: table) : ImageLabel
    return Components.ImageLabel({
        Name = id.."Image",
        BackgroundTransparency = 0,
        Image = Fusion.Computed(function(use)
            if id == "ClassATK" then
                return AssetBook.ClassInfo[use(self.playerData.Class)].Image

            elseif id == "Gold" then
                return "rbxassetid://16654275243"

            elseif id == "RP" then
                return "rbxassetid://16002068286"
            end
        end),
        Size = fromScale(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,

        [Children] = { Components.RoundUICorner() }
    })
end

local function StatText(id: string, self: table) : TextLabel
    local char = self.char :: Model

    self.charDMGStats = {
        MinDMG = Value(char:GetAttribute("MinDMG")),
        MaxDMG = Value(char:GetAttribute("MaxDMG")),
        Magic = Value(char:GetAttribute("Magic")),
    }
    local charDMGStats = self.charDMGStats
    Fusion.Hydrate(char)({
        [AttributeChange("MinDMG")] = function(newDMG)
            charDMGStats.MinDMG:set(newDMG)
        end,
        [AttributeChange("MaxDMG")] = function(newDMG)
            charDMGStats.MaxDMG:set(newDMG)
        end,
        [AttributeChange("Magic")] = function(newDMG)
            charDMGStats.Magic:set(newDMG)
        end,
    })

    return Components.TextLabel({
        Name = id.."Text",
        AutomaticSize = Enum.AutomaticSize.X,
        Size = fromScale(0, 1),
        Text = Fusion.Computed(function(use)
            if id == "ClassATK" then
                if AssetBook.ClassInfo[use(self.playerData.Class)].Type == "DMG" then
                    return use(charDMGStats.MinDMG).."-"..use(charDMGStats.MaxDMG)
                else
                    return use(charDMGStats.Magic)
                end

            elseif id == "Gold" then
                return use(self.playerData.Gold)

            elseif id == "RP" then
                return use(self.playerData.RP)
            end
        end),

        [Children] = {
            Components.TextUIStroke({ Thickness = 3 })
        }
    })
end

local function StatsTextsFrame(self: table) : Frame
    return Components.Frame({
        Name = "StatsTextsFrame",
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.5, -0.6),
        Size = fromScale(1, 0.5),

        [Children] = {
            New("UIListLayout")({
                Padding = udNew(0.01, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),

            StatImage("ClassATK", self),
            StatText("ClassATK", self),

            StatImage("Gold", self),
            StatText("Gold", self),

            StatImage("RP", self),
            StatText("RP", self)
        },
    })
end

return StatsTextsFrame
