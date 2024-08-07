--!nocheck

local MarketplaceService = game:GetService("MarketplaceService")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Spawn = require(RepS.Modules.Packages.Spawn)

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
local function ProductBar(index: number, scope: Fusion.Scope, self: table, productInfo: table)
    local isSelecting = Fusion.Value(scope, false)

    Spawn(function()
        local info = MarketplaceService:GetProductInfo(productInfo.Id, productInfo.Type)

        productInfo.Name:set(info.Name)
        productInfo.IconImageAssetId:set(info.IconImageAssetId)
        productInfo.PriceInRobux:set(info.PriceInRobux)
    end)

    return Components.Frame(scope, {
        Name = "Pack"..index,
        Size = fromScale(0.98, 0.18),
        BackgroundTransparency = 0,
        LayoutOrder = index,
        BackgroundColor3 = Color3.fromRGB(),

        [Children] = {
            Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 9.226 }),

            Components.RoundUICorner(scope),
            Components.UIStroke(scope, {
                Thickness = 2.5,
                Enabled = true,

                Transparency = Fusion.Tween(scope, Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting) then 0.3 else 1
                end), AssetBook.TweenInfos.twiceHalf),

                [Children] = { TransparentUIGradient(scope) }
            }),
            TransparentUIGradient(scope),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    workspace.Sounds.SFXs.Click:Play()

                    if productInfo.Type == Enum.InfoType.GamePass then
                        MarketplaceService:PromptGamePassPurchase(self.plr, productInfo.Id)

                    elseif productInfo.Type == Enum.InfoType.Product then
                        MarketplaceService:PromptProductPurchase(self.plr, productInfo.Id)
                    end
                end
            }),

            Components.ImageLabel(scope, {
                Name = "Icon",
                Size = fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                BackgroundTransparency = 0,

                Image = Computed(scope, function(use: Fusion.Use)
                    return `rbxassetid://{use(productInfo.IconImageAssetId)}`
                end),

                [Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "ProductName",
                Position = fromScale(0.129, 0.102),
                Size = fromScale(0.8, 0.403),
                TextXAlignment = Enum.TextXAlignment.Left,

                Text = Computed(scope, function(use: Fusion.Use)
                    return string.upper(use(productInfo.Name))
                end)
            }),
            Components.TextLabel(scope, {
                Name = "ProductPrice",
                Position = fromScale(0.129, 0.495),
                Size = fromScale(0.8, 0.369),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(255, 255, 0),

                Text = Computed(scope, function(use: Fusion.Use)
                    return `{use(productInfo.PriceInRobux)} Robux`
                end),
            })
        }
    })
end

local function DonationFrame(self: table) : Frame
    local scope = self.scope :: Fusion.Scope

    return Components.Frame(scope, {
		Name = "Donation",
		Position = fromScale(0.496, 0.531),
		Size = fromScale(0.944, 0.7),

		Visible = Fusion.Computed(scope, function(use: Fusion.Use)
			return use(self.frames.Donation)
		end),

		[Children] = {
			Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 3.389 }),

            Components.ScrollingFrame(scope, {
                Name = "PackList",
                AnchorPoint = Vector2.new(),
                Position = fromScale(0, 0),
                Size = fromScale(0.5, 1),
                ScrollingDirection = Enum.ScrollingDirection.Y,

                [Fusion.Out("AbsoluteSize")] = self.packListAbsSize,

                CanvasSize = Computed(scope, function(use: Fusion.Use)
                    return if use(self.packListAbsContentSize).Y > use(self.packListAbsSize).Y then UDim2.fromOffset(0, use(self.packListAbsContentSize).Y) else UDim2.fromOffset(0, 0)
                end),
                ScrollingEnabled = Computed(scope, function(use: Fusion.Use)
                    return if use(self.packListAbsContentSize).Y > use(self.packListAbsSize).Y then true else false
                end),

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        Padding = udNew(0, 12),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,

                        [Fusion.Out("AbsoluteContentSize")] = self.packListAbsContentSize
                    }),

                    Padding(self, 0),

                    Fusion.ForPairs(scope, AssetBook.GamepassInfo, function(_, localScope: Fusion.Scope, gamepassId: number, donationVal: number)
                        local productInfo = {
                            Name = Fusion.Value(localScope, "LOADING..."),
                            IconImageAssetId = Fusion.Value(localScope, ""),
                            PriceInRobux = Fusion.Value(localScope, 0),

                            Id = gamepassId,
                            Type = Enum.InfoType.GamePass
                        }

                        return gamepassId, ProductBar(donationVal, localScope, self, productInfo)
                    end),
                    Fusion.ForPairs(scope, AssetBook.ProductsInfo, function(_, localScope: Fusion.Scope, productId: number, donationVal: number)
                        local productInfo = {
                            Name = Fusion.Value(localScope, "LOADING..."),
                            IconImageAssetId = Fusion.Value(localScope, ""),
                            PriceInRobux = Fusion.Value(localScope, 0),

                            Id = productId,
                            Type = Enum.InfoType.Product
                        }

                        return productId, ProductBar(donationVal, localScope, self, productInfo)
                    end),

                    Padding(self, 999)
                }
            }),
            Components.ScrollingFrame(scope, {
                Name = "DonationList",
                AnchorPoint = Vector2.new(),
                Position = fromScale(0.5, 0),
                Size = fromScale(0.5, 0.9),
                ScrollingDirection = Enum.ScrollingDirection.Y,

                [Fusion.Out("AbsoluteSize")] = self.donationListAbsSize,

                CanvasSize = Computed(scope, function(use: Fusion.Use)
                    return if use(self.donationListAbsContentSize).Y > use(self.donationListAbsSize).Y then UDim2.fromOffset(0, use(self.donationListAbsContentSize).Y) else UDim2.fromOffset(0, 0)
                end),
                ScrollingEnabled = Computed(scope, function(use: Fusion.Use)
                    return if use(self.donationListAbsContentSize).Y > use(self.donationListAbsSize).Y then true else false
                end),

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        Padding = udNew(0, 10),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,

                        [Fusion.Out("AbsoluteContentSize")] = self.donationListAbsContentSize
                    }),

                    Padding(self, 0),

                    Fusion.ForPairs(scope, self.donationList, function(_, localScope: Fusion.Scope, index: number, donation: IntValue)
                        if donation.Value <= 0 then return index, nil end

                        local isSelecting = Fusion.Value(localScope, false)

                        return index, Components.Frame(localScope, {
                            Name = "Donation"..index,
                            LayoutOrder = index,
                            Size = fromScale(0.98, 0.11),
                            BackgroundTransparency = 0,
                            BackgroundColor3 = Color3.fromRGB(),

                            [Children] = {
                                Fusion.New(localScope, "UIAspectRatioConstraint")({ AspectRatio = 16.775 }),

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
                                    end
                                }),

                                Components.ImageLabel(localScope, {
                                    Name = "Avatar",
                                    Size = fromScale(1, 1),
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                    Image = donation:GetAttribute("AvatarImage"),
                                    BackgroundTransparency = 0,

                                    [Children] = { Components.RoundUICorner(localScope) }
                                }),
                                Components.TextLabel(localScope, {
                                    Name = "PlayerName",
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    Position = fromScale(0.085, 0.5),
                                    Size = fromScale(0.8, 0.6),
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    Text = donation:GetAttribute("PlayerName"),

                                    TextColor3 = Computed(localScope, function()
                                        if index == 1 then return Color3.fromRGB(255, 255, 0) end
                                        if index == 2 then return Color3.fromRGB(170, 255, 255) end
                                        if index == 3 then return Color3.fromRGB(0, 255, 127) end
                                        if index > 3 then return Color3.fromRGB(255, 255, 255) end
                                    end)
                                }),
                                Components.TextLabel(localScope, {
                                    Name = "Donation",
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    Position = fromScale(0.085, 0.5),
                                    Size = fromScale(0.8, 0.6),
                                    TextXAlignment = Enum.TextXAlignment.Right,
                                    Text = `{donation.Value} Robux`,
                                    TextColor3 = Color3.fromRGB(255, 255, 0)
                                }),
                            }
                        })
                    end),

                    Padding(self, 999)
                }
            }),
            Components.TextLabel(scope, {
                Name = "Tip",
                Position = fromScale(0.5, 0.9),
                Size = fromScale(0.5, 0.085),
                Text = "Every donation is greatly appreciated! Leaderboard has refresh delays, so wait patiently.",
                FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold, Enum.FontStyle.Italic)
            })
		},
	})
end

return DonationFrame
