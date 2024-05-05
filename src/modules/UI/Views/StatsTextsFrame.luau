--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)

local Children, Value, AttributeChange, Computed =
    Fusion.Children, Fusion.Value, Fusion.AttributeChange, Fusion.Computed

local v2New = Vector2.new
local udNew = UDim.new
local fromScale = UDim2.fromScale

local function StatImage(id: string, self: table) : ImageLabel
    local isSelecting = Value(false)

    return Components.ImageLabel({
        Name = id.."Image",
        BackgroundTransparency = 0,
        Size = fromScale(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,

        Image = Computed(function(use)
            if id == "ClassATK" then
                return AssetBook.ClassInfo[use(self.playerData.Class)].Image

            elseif id == "Gold" then
                return ItemBook.ItemImagesEx.Gold

            elseif id == "RP" then
                return ItemBook.ItemImagesEx.RP
            end
        end),

        [Children] = {
            Components.RoundUICorner(),
            Components.UIStroke({
                Enabled = true,
                Thickness = 2.5,

                Transparency = Fusion.Tween(Computed(function(use)
                    return if use(isSelecting) then 0.3 else 1
                end), AssetBook.TweenInfos.twiceHalf)
            }),
            Components.HoverImageButton({
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,
            })
        }
    })
end

local function StatText(id: string, self: table) : TextLabel
    local char = self.char :: Model
    local charDMGStats = self.charDMGStats

    Fusion.Hydrate(char)({
        [AttributeChange("MinDMG")] = function(newDMG: number)
            charDMGStats.MinDMG:set(newDMG)
        end,
        [AttributeChange("MaxDMG")] = function(newDMG: number)
            charDMGStats.MaxDMG:set(newDMG)
        end,
        [AttributeChange("Magic")] = function(newMagic: number)
            charDMGStats.Magic:set(newMagic)
        end,
    })

    return Components.TextLabel({
        Name = id.."Text",
        AutomaticSize = Enum.AutomaticSize.X,
        Size = fromScale(0, 1),
        Text = Computed(function(use)
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
            Components.TextUIStroke({ Thickness = 2 })
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
            Fusion.New("UIListLayout")({
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
