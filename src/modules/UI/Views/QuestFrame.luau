--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local QuestBar = require(RepS.Modules.UI.Components.QuestBar)

local fromScale = UDim2.fromScale
local udNew = UDim.new
local wait = task.wait

local function QuestFrame(self: table) : Frame
    local scope = self.scope :: Fusion.Scope
    local quests = self.plr:WaitForChild("Quests", 999) :: Folder

    local function _changeQuests()
        wait()
        self.quests:set(quests:GetChildren())
    end
    table.insert(scope, quests.ChildAdded:Connect(_changeQuests))
    table.insert(scope, quests.ChildRemoved:Connect(_changeQuests))

    return Components.Frame(scope, {
        Name = "QuestsFrame",
        Size = fromScale(1, 0.7),

        [Fusion.Children] = {
            Fusion.New(scope, "UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = udNew(0.5, 0),
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),
            Fusion.ForValues(scope, self.quests, function(_, localScope: Fusion.Scope, quest: IntValue)
                return QuestBar(quest, localScope)
            end)
        }
    })
end

return QuestFrame
