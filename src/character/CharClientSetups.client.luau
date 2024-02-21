--!nocheck

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(RepS.Modules.Data.Events)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local camera = workspace.CurrentCamera
local musics = workspace:WaitForChild("Sounds") :: Folder
local effects = RepS.Package.Effects :: Folder
local mapComponents = workspace:WaitForChild("MapComponents") :: Folder

local fromRGB = Color3.fromRGB
local v3Zero = Vector3.zero
local cfNew = CFrame.new
local insert = table.insert
local floor = math.floor
local wait = task.wait

--// Setup
local function spawn()
	musics.Overworld:Play()

	for _, effect in camera:GetChildren() do
		if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") then effect:Destroy() end
	end
	for _, prompt in mapComponents:GetDescendants() do
		if prompt:IsA("ProximityPrompt") and prompt.Name ~= "Chest" then prompt.Enabled = true end
	end

	effects.UIBlur:Clone().Parent = camera
	effects.WaterColor:Clone().Parent = camera
	effects.WaterBlur:Clone().Parent = camera

	Lighting.ColorShift_Top = fromRGB(220, 255, 255)
	Lighting.ColorShift_Bottom = fromRGB(220, 255, 255)
end
spawn()


--// Connections
local function onDied()
	--- sometimes the reset button did not make server thinks he is dead
	Events.ForceReset:Fire()

	musics.SFXs.Dead:Play()

	for _, prompt in mapComponents:GetDescendants() do
		if prompt:IsA("ProximityPrompt") and prompt.Name ~= "Chest" then prompt.Enabled = false end
	end
	for _, sound in musics:GetChildren() do
		if sound:IsA("Sound") then sound:Stop() end
	end

	effects.DeathBlur:Clone().Parent = camera

	Lighting.ColorShift_Bottom = fromRGB(255, 0, 0)
	Lighting.ColorShift_Top = fromRGB(255, 0, 0)
end
char.Humanoid.Died:Once(onDied)


local markers = {}
local quests = plr:WaitForChild("Quests", 999) :: Folder
local function targetCurrentQuest()
	wait()
	for _, child in camera:GetChildren() do
		if child.Name == "QuestMarker" then child:Destroy() end
	end
	for _, child in mapComponents.NPCs:GetDescendants() do
		if child.Name == "MissionIndicator" then child:Destory() end
	end

    for _, quest: IntConstrainedValue in quests:GetChildren() do
        local realQuest = StoryBook[quest.Name][quest.Value]

        if realQuest.Hint == v3Zero then continue end

        local marker = RepS.Package.Unloads.QuestMarker:Clone() :: Part
        marker:SetAttribute("Location", realQuest.Hint)
		marker.CFrame = cfNew(realQuest.Hint)
		marker.TargetUI.Distance.TextColor3 = AssetBook.QuestColor[quest.Name]
		marker.TargetUI.Frame.BackgroundColor3 = AssetBook.QuestColor[quest.Name]
        marker.Parent = camera

		insert(markers, marker)

		if mapComponents.NPCs:FindFirstChild(StoryBook[quest.Name][quest.Value].NPC) then
			local indicator = RepS.Package.Unloads.QuestIndicator:Clone() :: BillboardGui
			indicator.Title.TextColor3 = AssetBook.QuestColor[quest.Name]
			indicator.Parent = mapComponents.NPCs[StoryBook[quest.Name][quest.Value].NPC]
		end
    end

	local function __distanceCheck()
		for _, marker: Part in markers do
			local magnitude = floor((marker:GetAttribute("Location") - char.PrimaryPart.Position).Magnitude)

			marker.TargetUI.Distance.Text = magnitude.."M"
		end
	end
	RS.Heartbeat:Connect(__distanceCheck)
end
targetCurrentQuest()
quests.ChildAdded:Connect(targetCurrentQuest)
quests.ChildRemoved:Connect(targetCurrentQuest)
