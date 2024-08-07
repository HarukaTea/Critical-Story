--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local Children, Computed = Fusion.Children, Fusion.Computed

local udNew =  UDim.new
local fromScale = UDim2.fromScale

local function Padding(self: table, order: number) : Frame
    return Fusion.New(self.scope, "Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(1, 1),
        LayoutOrder = order
    })
end
local function TransparentUIGradient(scope: Fusion.Scope) : UIGradient
    return Fusion.New(scope, "UIGradient")({
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
    })
end

local function DonationFrame(self: table) : Frame
    local scope = self.scope :: Fusion.Scope

    return Components.Frame(scope, {
		Name = "Quests",
		Position = fromScale(0.496, 0.531),
		Size = fromScale(0.944, 0.7),

		Visible = Fusion.Computed(scope, function(use: Fusion.Use)
			return use(self.frames.Quests)
		end),

		[Children] = {
			Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 3.389 }),

            Components.ScrollingFrame(scope, {
                Name = "QuestsList",
                AnchorPoint = Vector2.new(),
                Position = fromScale(0, 0),
                Size = fromScale(0.5, 1),
                ScrollingDirection = Enum.ScrollingDirection.Y,

                [Fusion.Out("AbsoluteSize")] = self.questListAbsSize,

                CanvasSize = Computed(scope, function(use: Fusion.Use)
                    return if use(self.questListAbsContentSize).Y > use(self.questListAbsSize).Y then UDim2.fromOffset(0, use(self.questListAbsContentSize).Y) else UDim2.fromOffset(0, 0)
                end),
                ScrollingEnabled = Computed(scope, function(use: Fusion.Use)
                    return if use(self.questListAbsContentSize).Y > use(self.questListAbsSize).Y then true else false
                end),

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        Padding = udNew(0, 10),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,

                        [Fusion.Out("AbsoluteContentSize")] = self.questListAbsContentSize
                    }),

                    Padding(self, 0),

                    Fusion.ForPairs(scope, self.questList, function(_, localScope: Fusion.Scope, index: number, quest: IntConstrainedValue)
                        local isSelecting = Fusion.Value(localScope, false)

                        return index, Components.Frame(localScope, {
                            Name = "Quest"..index,
                            Size = fromScale(0.98, 0.15),
                            BackgroundTransparency = 0,
                            LayoutOrder = index,
                            BackgroundColor3 = Color3.fromRGB(),

                            [Children] = {
                                Fusion.New(localScope, "UIAspectRatioConstraint")({ AspectRatio = 11.072 }),

                                Components.RoundUICorner(localScope),
                                Components.UIStroke(localScope, {
                                    Thickness = 2.5,
                                    Enabled = true,

                                    Transparency = Fusion.Tween(localScope, Computed(localScope, function(use: Fusion.Use)
                                        return if use(isSelecting) then 0.3 else 1
                                    end), AssetBook.TweenInfos.twiceHalf),

                                    [Children] = { TransparentUIGradient(localScope) }
                                }),
                                TransparentUIGradient(localScope),

                                Components.HoverImageButton(localScope, {
                                    [Fusion.OnEvent("MouseEnter")] = function()
                                        isSelecting:set(true)
                                    end,
                                    [Fusion.OnEvent("MouseLeave")] = function()
                                        isSelecting:set(false)
                                    end,
                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        self.questRewardsList:set(StoryBook[quest.Name][quest.Value].Rewards)
                                        self.questDesc:set(StoryBook[quest.Name][quest.Value].Desc)
                                    end
                                }),

                                Components.ImageLabel(localScope, {
                                    Name = "Icon",
                                    Size = fromScale(1, 1),
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                    BackgroundTransparency = 0,
                                    Image = ItemBook.ItemImagesEx.QuestMarker,

                                    [Children] = { Components.RoundUICorner(localScope) }
                                }),
                                Components.TextLabel(localScope, {
                                    Name = "QuestName",
                                    Position = fromScale(0.118, 0.1),
                                    Size = fromScale(0.848, 0.45),
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    TextColor3 = AssetBook.QuestColor[quest.Name],
                                    Text = string.upper(StoryBook[quest.Name][quest.Value].Name),
                                }),
                                Components.TextLabel(localScope, {
                                    Name = "QuestTarget",
                                    Position = fromScale(0.118, 0.573),
                                    Size = fromScale(0.848, 0.386),
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    RichText = true,
                                    Text = HarukaLib:RichTextify(StoryBook[quest.Name][quest.Value].Target)
                                })
                            }
                        })
                    end),

                    Padding(self, 999)
                }
            }),
            Fusion.New(scope, "Frame")({
                Name = "QuestDesc",
                Position = fromScale(0.5, 0),
                Size = fromScale(0.5, 1),
                BackgroundTransparency = 1,

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        Padding = udNew(0, 10),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),

                    Components.TextLabel(scope, {
                        Name = "QuestDesc",
                        Size = fromScale(1, 0.6),
                        TextScaled = false,
                        RichText = true,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        LayoutOrder = 1,

                        Text = Computed(scope, function(use: Fusion.Use)
                            return HarukaLib:RichTextify(use(self.questDesc))
                        end),
                        TextSize = Computed(scope, function(use: Fusion.Use)
                            return math.clamp(use(self.questDescAbsSize).Y / (195 / 22), 1, 37)
                        end),

                        [Fusion.Out("AbsoluteSize")] = self.questDescAbsSize,
                    }),
                    Components.Frame(scope, {
                        Name = "QuestRewardsTitle",
                        Size = fromScale(1, 0.08),
                        LayoutOrder = 2,

                        Visible = Computed(scope, function(use: Fusion.Use)
                            return if use(self.questRewardsList).EXP then true else false
                        end),

                        [Children] = {
                            Fusion.New(scope, "UIListLayout")({
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                            }),

                            Components.TextLabel(scope, {
                                Name = "Title",
                                Text = "REWARDS",
                                TextColor3 = Color3.fromRGB(170, 255, 255),
                                TextXAlignment = Enum.TextXAlignment.Left,
                                LayoutOrder = 1,
                                Size = fromScale(0.2, 1)
                            }),
                            Components.Frame(scope, {
                                Name = "Bar",
                                Size = fromScale(0.8, 0.1),
                                BackgroundTransparency = 0,
                                BackgroundColor3 = Color3.fromRGB(170, 255, 255),
                                LayoutOrder = 2,
                            })
                        }
                    }),
                    Components.ScrollingFrame(scope, {
                        Name = "RewardList",
                        AnchorPoint = Vector2.new(),
                        Size = fromScale(1, 0.22),
                        ScrollingDirection = Enum.ScrollingDirection.X,
                        LayoutOrder = 3,

                        [Fusion.Out("AbsoluteSize")] = self.questRewardsListAbsSize,

                        CanvasSize = Computed(scope, function(use: Fusion.Use)
                            return if use(self.questRewardsListAbsContentSize).X > use(self.questRewardsListAbsSize).X then UDim2.fromOffset(use(self.questRewardsListAbsContentSize).X, 0) else UDim2.fromOffset(0, 0)
                        end),
                        ScrollingEnabled = Computed(scope, function(use: Fusion.Use)
                            return if use(self.questRewardsListAbsContentSize).X > use(self.questRewardsListAbsSize).X then true else false
                        end),

                        [Children] = {
                            Fusion.New(scope, "UIListLayout")({
                                Padding = udNew(0, 10),
                                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                FillDirection = Enum.FillDirection.Horizontal,

                                [Fusion.Out("AbsoluteContentSize")] = self.questRewardsListAbsContentSize
                            }),

                            Padding(self, 0),

                            Fusion.ForPairs(scope, self.questRewardsList, function(_, localScope: Fusion.Scope, attr: string, reward: string)
                                local isSelecting = Fusion.Value(localScope, false)

                                return attr, Components.Frame(localScope, {
                                    Name = "Reward"..attr,
                                    Size = fromScale(0.7, 0.7),
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                    BackgroundTransparency = 0,

                                    [Children] = {
                                        Components.RoundUICorner(localScope),
                                        Components.UIStroke(localScope, {
                                            Thickness = 2.5,
                                            Enabled = true,

                                            Transparency = Fusion.Tween(localScope, Computed(localScope, function(use: Fusion.Use)
                                                return if use(isSelecting) then 0.3 else 1
                                            end), AssetBook.TweenInfos.twiceHalf),
                                        }),

                                        Components.HoverImageButton(localScope, {
                                            Image = Computed(localScope, function()
                                                local hasFound = ItemBook:IsItemExist(attr)
                                                if hasFound then return ItemBook:FindItem(attr).Icon end

                                                local hasFound2 = ItemBook.ItemImagesEx[attr]
                                                if hasFound2 then return ItemBook.ItemImagesEx[attr] end

                                                return ItemBook.ItemImagesEx.Unknown
                                            end),

                                            [Fusion.OnEvent("MouseEnter")] = function()
                                                isSelecting:set(true)
                                            end,
                                            [Fusion.OnEvent("MouseLeave")] = function()
                                                isSelecting:set(false)
                                            end
                                        }),
                                        Components.TextLabel(localScope, {
                                            Name = "Amount",
                                            Position = fromScale(0.1, 0.6),
                                            Size = fromScale(1, 0.4),
                                            TextXAlignment = Enum.TextXAlignment.Right,
                                            Text = `x{reward}`,

                                            [Children] = {
                                                Components.TextUIStroke(localScope, { Thickness = 2 })
                                            }
                                        })
                                    }
                                })
                            end),

                            Padding(self, 999)
                        }
                    })
                }
            })
        }
	})
end

return DonationFrame
