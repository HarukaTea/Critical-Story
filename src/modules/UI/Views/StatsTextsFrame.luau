--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local Children, Value, Computed = Fusion.Children, Fusion.Value, Fusion.Computed

local v2New = Vector2.new
local udNew = UDim.new
local fromScale = UDim2.fromScale

local function StatImage(id: string, self: table) : ImageLabel
    local scope = self.scope :: Fusion.Scope
    local isSelecting = Value(scope, false)

    local function exCategoryOpened()
        isSelecting:set(false)
    end
    Signals.ExCategoryOpened:Connect(exCategoryOpened)

    return Components.ImageLabel(scope, {
        Name = id.."Image",
        BackgroundTransparency = 0,
        Size = fromScale(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,

        Image = Computed(scope, function(use: Fusion.Use)
            if id == "ClassATK" then
                return AssetBook.ClassInfo[use(self.playerData.Class)].Image

            elseif id == "Gold" then
                return ItemBook.ItemImagesEx.Gold

            elseif id == "RP" then
                return ItemBook.ItemImagesEx.RP
            end
        end),

        [Children] = {
            Components.RoundUICorner(scope),
            Components.UIStroke(scope, {
                Enabled = true,
                Thickness = 2.5,

                Transparency = Fusion.Tween(scope, Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting) then 0.3 else 1
                end), AssetBook.TweenInfos.twiceHalf)
            }),
            Components.HoverImageButton(scope, {
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
    local scope = self.scope :: Fusion.Scope
    local charDMGStats = self.charDMGStats

    return Components.TextLabel(scope, {
        Name = id.."Text",
        AutomaticSize = Enum.AutomaticSize.X,
        Size = fromScale(0, 1),
        TextColor3 = if id == "ClassATKBuff" then Color3.fromRGB(85, 255, 255) else Color3.fromRGB(255, 255, 255),

        Text = Computed(scope, function(use: Fusion.Use)
            if id == "ClassATK" then
                if AssetBook.ClassInfo[use(self.playerData.Class)].Type == "DMG" then
                    local minDMG, maxDMG = use(charDMGStats.MinDMG) :: number, use(charDMGStats.MaxDMG) :: number

                    return if minDMG >= maxDMG then maxDMG else minDMG.."-"..maxDMG
                else
                    return use(charDMGStats.Magic)
                end

            elseif id == "ClassATKBuff" then
                if AssetBook.ClassInfo[use(self.playerData.Class)].Type == "DMG" then
                    local minDMG, maxDMG = use(charDMGStats.MinDMGBuff) :: number, use(charDMGStats.MaxDMGBuff) :: number

                    if minDMG > 0 and maxDMG <= 0 then
                        return "(+"..minDMG.."-0)"

                    elseif minDMG <= 0 and maxDMG > 0 then
                        return "(+0-"..maxDMG..")"

                    elseif minDMG <= 0 and maxDMG <= 0 then
                        return "(+0)"

                    else
                        return "(+"..minDMG.."-"..maxDMG..")"
                    end
                else
                    local magic = use(charDMGStats.MagicBuff) :: number

                    return if magic > 0 then "(+"..magic..")" else "(+0)"
                end

            elseif id == "Gold" then
                return use(self.playerData.Gold)

            elseif id == "RP" then
                return use(self.playerData.RP)
            end
        end),

        [Children] = {
            Components.TextUIStroke(scope, { Thickness = 2 })
        }
    })
end

local function StatsTextsFrame(self: table) : Frame
    local scope = self.scope :: Fusion.Scope

    return Components.Frame(scope, {
        Name = "StatsTextsFrame",
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.5, -0.6),
        Size = fromScale(1, 0.5),

        [Children] = {
            Fusion.New(scope, "UIListLayout")({
                Padding = udNew(0.01, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),

            StatImage("ClassATK", self),
            StatText("ClassATK", self),
            StatText("ClassATKBuff", self),

            StatImage("Gold", self),
            StatText("Gold", self),

            StatImage("RP", self),
            StatText("RP", self)
        },
    })
end

return StatsTextsFrame
