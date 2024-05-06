--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Bin = require(RepS.Modules.Packages.Bin)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local camera = workspace.CurrentCamera
local mapComponents = workspace:WaitForChild("MapComponents") :: Folder

local Add, Empty = Bin()

local v3Zero = Vector3.zero
local cfNew = CFrame.new
local clear = table.clear
local floor = math.floor
local wait = task.wait

local markers = {} :: { BasePart }
local quests = plr:WaitForChild("Quests", 999) :: Folder

local function __distanceCheck()
	for _, marker: BasePart in markers do
		local magnitude = floor((marker:GetAttribute("Location") - char.PrimaryPart.Position).Magnitude)

		marker.TargetUI.Distance.Text = magnitude.."M"
	end
end
local function targetCurrentQuest()
	wait()
	for _, child: Instance in camera:GetChildren() do
		if child.Name == "QuestMarker" then child:Destroy() end
	end
	for _, child: Instance in mapComponents.NPCs:GetDescendants() do
		if child.Name == "QuestIndicator" then child:Destroy() end
	end
	clear(markers)

    for _, quest: IntConstrainedValue in quests:GetChildren() do
        local realQuest = StoryBook[quest.Name][quest.Value]

        if realQuest.Hint == v3Zero then continue end

        local marker = RepS.Package.Unloads.QuestMarker:Clone() :: BasePart
        marker:SetAttribute("Location", realQuest.Hint)
		marker.CFrame = cfNew(realQuest.Hint)
		marker.TargetUI.Distance.TextColor3 = AssetBook.QuestColor[quest.Name]
		marker.TargetUI.Frame.BackgroundColor3 = AssetBook.QuestColor[quest.Name]
        marker.Parent = camera

		markers[#markers + 1] = marker

		if mapComponents.NPCs:FindFirstChild(StoryBook[quest.Name][quest.Value].NPC) then
			local indicator = RepS.Package.Unloads.QuestIndicator:Clone() :: BillboardGui
			indicator.Title.TextColor3 = AssetBook.QuestColor[quest.Name]
			indicator.Parent = mapComponents.NPCs[StoryBook[quest.Name][quest.Value].NPC]
		end
    end
end
targetCurrentQuest()

Add(quests.ChildAdded:Connect(targetCurrentQuest))
Add(quests.ChildRemoved:Connect(targetCurrentQuest))
Add(RS.Heartbeat:Connect(__distanceCheck))

char.Humanoid.Died:Once(function()
	Empty()

	script:Destroy()
end)
