--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Tween, Computed, New = Fusion.Children, Fusion.Tween, Fusion.Computed, Fusion.New

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fontFromName, fontFromEnum = Font.fromName, Font.fromEnum
local fromRGB = Color3.fromRGB
local udimNew = UDim.new

local function PlayerPhasePlrBar(plr: Player, self: table) : Frame
    local isSelecting = Fusion.Value(false)

    return Components.Frame({
        Name = plr.Name,
        Size = fromScale(0.18, 1),

        [Children] = {
            Components.RoundUICorner(),
            Components.UIStroke({
                Thickness = 2.7,
                Enabled = true,

                Transparency = Tween(Computed(function(use)
                    return if use(isSelecting) then 0.3 else 1
                end), AssetBook.TweenInfos.twiceHalf)
            }),
            Components.ImageLabel({
                Name = "PlayerClass",
                Image = AssetBook.ClassInfo[plr:GetAttribute("Class")].Image,
                Position = fromScale(0.78, 0),
                Size = fromScale(1, 1),
                BackgroundTransparency = 0,

                [Children] = { Components.RoundUICorner() }
            }),
            Components.TextLabel({
                Name = "MobName",
                Position = fromScale(0, 0.1),
                Size = fromScale(0.745, 0.35),
                Text = plr.DisplayName,
                FontFace = fontFromName("Ubuntu", Enum.FontWeight.Bold),
                TextXAlignment = Enum.TextXAlignment.Right,
                TextColor3 = AssetBook.ClassInfo[plr:GetAttribute("Class")].Color
            }),
            Components.ImageLabel({
                Name = "NextAction",

                [Children] = {
                    Components.RoundUICorner(),
                    Components.UIStroke({
                        Enabled = true,
                        Thickness = 2.7,

                        Transparency = 0 --// TODO
                    }),
                    Components.HoverImageButton()
                }
            }),

            Components.HoverImageButton(),

            Fusion.New("Frame")({
                Name = "HP",
                BackgroundColor3 = fromRGB(),
                Position = fromScale(0.12, 0.55),
                Size = fromScale(0.625, 0.3),

                [Children] = {
                    Components.RoundUICorner(),
                    Components.Frame({
                        Name = "Bar",

                        [Children] = { Components.RoundUICorner() }
                    }),
                    Components.TextLabel({
                        Name = "Stat",
                        Size = fromScale(1, 1),
                        ZIndex = 2,
                        FontFace = fontFromName("Ubuntu", Enum.FontWeight.Bold),
                        TextStrokeTransparency = 0.7,
                        TextXAlignment = Enum.TextXAlignment.Right,

                        [Children] = {
                            New("UIPadding")({ PaddingRight = udimNew(0.04, 0) })
                        }
                    }),
                    Components.TextLabel({
                        Name = "Title",
                        Text = "HP",
                        Size = fromScale(1, 1),
                        ZIndex = 2,
                        FontFace = fontFromName("Ubuntu", Enum.FontWeight.Bold),
                        TextStrokeTransparency = 0.7,
                        TextXAlignment = Enum.TextXAlignment.Left,

                        [Children] = {
                            New("UIPadding")({ PaddingRight = udimNew(0.04, 0) })
                        }
                    })
                }
            })
        }
    })
end

return PlayerPhasePlrBar
