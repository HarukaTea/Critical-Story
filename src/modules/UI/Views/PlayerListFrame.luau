--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local PlayerSlot = require(RepS.Modules.UI.Components.PlayerSlot)

local Computed = Fusion.Computed

local v2New, udNew = Vector2.new, UDim.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local function PlayerListFrame(self: table)
    local scope = self.scope :: Fusion.Scope

    self.list = Fusion.Value(scope, Components.ScrollingFrame(scope, {
        Name = "List",
        AnchorPoint = v2New(),
        Size = fromScale(0.118, 3),
        ZIndex = 2,
        ScrollingDirection = Enum.ScrollingDirection.Y,

        Position = Fusion.Tween(scope, Computed(scope, function(use: Fusion.Use)
            return if use(self.isOpen) then fromScale(0.875, 0) else fromScale(1.2, 0)
        end), AssetBook.TweenInfos.half),
        CanvasSize = Computed(scope, function(use: Fusion.Use)
            return if use(self.absContentSize).Y > use(self.absSize).Y then fromOffset(0, use(self.absContentSize).Y) else fromOffset(0, 0)
        end),
        ScrollingEnabled = Computed(scope, function(use: Fusion.Use)
            return if use(self.absContentSize).Y > use(self.absSize).Y then true else false
        end),

        [Fusion.Out("AbsoluteSize")] = self.absSize,

        [Fusion.Children] = {
            Fusion.New(scope, "UIListLayout")({
                Padding = udNew(0, 2),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,

                [Fusion.Out("AbsoluteContentSize")] = self.absContentSize,
            }),
            Fusion.ForValues(scope, self.players, function(_, localScope: Fusion.Scope, player: Player)
                return PlayerSlot(self, player, localScope)
            end),
        },
    }))

    return self.list
end

return PlayerListFrame
