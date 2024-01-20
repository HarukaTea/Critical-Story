--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Fusion = HarukaFrameworkClient.Fusion

local MonsterHPBar = require(RepS.Modules.UI.Components.MonsterHPFrame)

local Children, New, Value = Fusion.Children, Fusion.New, Fusion.Value

local v2New, udNew = Vector2.new, UDim.new
local fromScale = UDim2.fromScale

local function MonsterHPFrame(self: table) : Frame
    return Components.Frame({
        Name = "MonsterHPFrame",
        AnchorPoint = v2New(0.5, 0),
        Position = Fusion.Tween(
            Fusion.Computed(function(use)
                return use(self.monsterHPPos)
            end),
            AssetBook.TweenInfos.half
        ),
        Size = fromScale(1, 1.085),

        [Children] = {
            New("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = udNew(0.15, 0),
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
            }),
            Fusion.ForValues(self.charStatsDict.MonsterAmount, function(use, symbol)
                local monster = symbol.Value

                local info = {
                    Model = monster,
                    HP = Value(monster:GetAttribute("Health")),
                    MaxHP = Value(monster:GetAttribute("MaxHealth")),
                    Name = monster.Name,
                    Level = monster:GetAttribute("Levels"),
                    Avatar = AssetBook.MonsterAvatars[monster.Name],
                    EffectsList = Value({}),
                    Targeting = if self.charData.TargetMonster.Value == monster
                        then Value(true)
                        else Value(false),
                }

                return MonsterHPBar(info, self)
            end, Fusion.cleanup),
        },
    })
end

return MonsterHPFrame