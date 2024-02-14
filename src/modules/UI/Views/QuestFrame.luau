--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local fromScale = UDim2.fromScale
local udNew = UDim.new

local function QuestFrame(self: table) : Frame
    self.quests = Fusion.Value({})

    return Components.Frame({
        Name = "QuestsFrame",
        Size = fromScale(1, 0.7),

        [Fusion.Children] = {
            Fusion.New("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = udNew(0.5, 0),
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),
            Fusion.ForValues(self.quests, function(use, quest)
                
            end)
        }
    })
end

return QuestFrame
