--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Children, Computed = Fusion.Children, Fusion.Computed

local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function TalentsCenterPanel(self: table) : Frame
    local scope = self.scope :: table

    return Components.Frame(scope, {
        Name = "Talents",

        Visible = Computed(scope, function(use: Fusion.Use)
            return use(self.panelFilterFrames.Character.Talents)
        end),

        [Children] = {
            Fusion.New(scope, "Frame")({
                Name = "Title",
                BackgroundColor3 = fromRGB(30, 30, 30),
                Size = fromScale(1, 0.09),

                BackgroundTransparency = Computed(scope, function(use: Fusion.Use)
                    return if use(self.currentTalent).Name then 0 else 1
                end),

                [Fusion.Out("AbsoluteSize")] = self.talentAbsSize,

                [Children] = {
                    Components.RoundUICorner(scope),

                    Components.TextLabel(scope, {
                        Name = "TalentName",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = fromScale(0.5, 0.5),
                        Size = fromScale(0.9, 0.8),
                        TextXAlignment = Enum.TextXAlignment.Left,

                        Text = Computed(scope, function(use: Fusion.Use)
                            return use(self.currentTalent).Name or ""
                        end),
                        TextTransparency = Computed(scope, function(use: Fusion.Use)
                            return if use(self.currentTalent).Name then 0 else 1
                        end),

                        [Children] = {
                            Components.TextLabel(scope, {
                                Name = "TalentLevel",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = fromScale(0.5, 0.5),
                                Size = fromScale(1, 1),
                                TextXAlignment = Enum.TextXAlignment.Right,
                                TextColor3 = fromRGB(255, 255, 0),

                                Text = Computed(scope, function(use: Fusion.Use)
                                    return "Lv.NaN" --// TODO: implent level display
                                end),
                                TextTransparency = Computed(scope, function(use: Fusion.Use)
                                    return if use(self.currentTalent).Name then 0 else 1
                                end),
                            })
                        }
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "Desc",
                Position = fromScale(0, 0.11),
                Size = fromScale(1, 0.89),
                TextScaled = false,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                LineHeight = 1.2,
                RichText = true,

                TextSize = Computed(scope, function(use: Fusion.Use)
                    return math.ceil(use(self.talentAbsSize).Y / (29 / 20))
                end),
                Text = Computed(scope, function(use: Fusion.Use)
                    return HarukaLib:RichTextify(use(self.currentTalent).Desc) or ""
                end),
                TextTransparency = Computed(scope, function(use: Fusion.Use)
                    return if use(self.currentTalent).Name then 0 else 1
                end),
            })
        }
    })
end

return TalentsCenterPanel
