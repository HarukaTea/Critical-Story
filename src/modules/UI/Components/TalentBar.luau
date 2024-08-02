--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed = Fusion.Children, Fusion.Computed

local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function TalentBar(index: number, talent: table, self: table, scope: Fusion.Scope) : Frame
    local isSelecting = Fusion.Value(scope, false)

    return Components.Frame(scope, {
        Name = "Talent"..index.."_"..talent.Id,
        Size = fromScale(1, 0.15),
        LayoutOrder = index,

        [Children] = {
            Components.ImageLabel(scope, {
                Name = "Icon",
                Size = fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                BackgroundTransparency = 0,

                Image = ItemBook.ItemImagesEx.ClassLock, --// TODO: implemnt talent images

                [Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "TalentName",
                Position = fromScale(0.2, 0),
                Size = fromScale(0.7, 0.45),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = talent.Name
            }),
            Components.TextLabel(scope, {
                Name = "TalentLevel",
                Position = fromScale(0.2, 0.5),
                Size = fromScale(0.7, 0.35),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = fromRGB(255, 255, 0),

                Text = Computed(scope, function(use: Fusion.Use)
                    return "Lv.NaN" --// TODO: implement talent levels
                end)
            }),

            Components.Frame(scope, {
                Name = "BGShadows",
                AnchorPoint = Vector2.new(0, 0.5),
                Position = fromScale(-0.03, 0.5),
                Size = fromScale(1.1, 1.1),
                BackgroundTransparency = 0,
                ZIndex = 0,

                Visible = Computed(scope, function(use: Fusion.Use)
                    return use(isSelecting)
                end),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Fusion.New(scope, "UIGradient")({
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1)
                        })
                    })
                }
            }),
            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    self.currentTalent:set(talent)
                    self.currentMaterialsNeeded:set(talent.Materials)
                end
            })
        }
    })
end

return TalentBar
