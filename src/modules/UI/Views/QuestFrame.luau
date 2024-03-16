--!strict

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local QuestBar = require(RepS.Modules.UI.Components.QuestBar)

local fromScale = UDim2.fromScale
local udNew = UDim.new
local wait = task.wait

local function QuestFrame(self: table) : Frame
    local quests = self.plr:WaitForChild("Quests") :: Folder

    self.quests = Fusion.Value(quests:GetChildren())
    local function _changeQuests()
        wait()
        self.quests:set(quests:GetChildren())
    end
    quests.ChildAdded:Connect(_changeQuests)
    quests.ChildRemoved:Connect(_changeQuests)

    return Components.Frame({
        Name = "QuestsFrame",
        Size = fromScale(1, 0.7),

        [Fusion.Children] = {
            Fusion.New("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = udNew(0.5, 0),
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),
            Fusion.ForValues(self.quests, function(use, quest: IntValue)
                return QuestBar(quest)
            end, Fusion.cleanup)
        }
    })
end

return QuestFrame
