--!strict

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Bin = require(RepS.Modules.Packages.Bin)
local Clock = require(RepS.Modules.Packages.Clock)
local Events = require(RepS.Modules.Data.Events)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local camera = workspace.CurrentCamera
local musics = workspace:WaitForChild("Sounds") :: Folder
local effects = RepS.Package.Effects :: Folder
local map = workspace:WaitForChild("Maps") :: Folder
local mapComponents = workspace:WaitForChild("MapComponents") :: Folder

local Add, Empty = Bin()

local fromRGB = Color3.fromRGB
local v3Zero, yAxis = Vector3.zero, Vector3.yAxis
local cfNew, cfAngles = CFrame.new, CFrame.Angles
local clear = table.clear
local floor, rad = math.floor, math.rad
local wait = task.wait

--// Setups
local function setup()
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
Spawn(setup)

local function worldAnims()
    for _, child in map:GetDescendants() do
        if child.Name == "Wings" and child.Parent.Name == "Windmill" then
			Clock(0.01, function()
				if not char then return end
				if not char.PrimaryPart then return end
				if (child.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude > 555 then return end

				child:PivotTo(child.PrimaryPart.CFrame * cfAngles(rad(-1.5), 0, 0))
			end)

        elseif child.Name == "Sky Galleon" then
            Spawn(function()
                while wait(0.01) do
					if not char then continue end
					if not char.PrimaryPart then continue end
					if (child.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude > 256 then continue end

                    for _ = 1, 100 do
                        child:PivotTo(child.PrimaryPart.CFrame + yAxis * 0.03)
                        wait(0.01)
                    end
                    for _ = 1, 100 do
                        child:PivotTo(child.PrimaryPart.CFrame - yAxis * 0.03)
                        wait(0.01)
                    end
                end
            end)
        end
    end
end
Spawn(worldAnims)


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

	Empty()
end
char.Humanoid.Died:Once(onDied)

--// Quest connections
local markers = {}
local quests = plr:WaitForChild("Quests", 999) :: Folder

local function __distanceCheck()
	for _, marker: Part in markers do
		local magnitude = floor((marker:GetAttribute("Location") - char.PrimaryPart.Position).Magnitude)

		marker.TargetUI.Distance.Text = magnitude.."M"
	end
end
local function targetCurrentQuest()
	wait()
	for _, child in camera:GetChildren() do
		if child.Name == "QuestMarker" then child:Destroy() end
	end
	for _, child in mapComponents.NPCs:GetDescendants() do
		if child.Name == "QuestIndicator" then child:Destroy() end
	end
	clear(markers)

    for _, quest: IntConstrainedValue in quests:GetChildren() do
        local realQuest = StoryBook[quest.Name][quest.Value]

        if realQuest.Hint == v3Zero then continue end

        local marker = RepS.Package.Unloads.QuestMarker:Clone() :: Part
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
Spawn(targetCurrentQuest)
Add(quests.ChildAdded:Connect(targetCurrentQuest))
Add(quests.ChildRemoved:Connect(targetCurrentQuest))
Add(RS.Heartbeat:Connect(__distanceCheck))
