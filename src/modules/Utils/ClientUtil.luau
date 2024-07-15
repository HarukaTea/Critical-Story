--!nocheck

local CAS = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Signals = require(RepS.Modules.Data.Signals)

local cfNew = CFrame.new
local random = math.random
local sFind = string.find

local ClientUtil = {}


function ClientUtil:WeldModel(part: Part, welded: Model)
	local C = welded:GetChildren()
	for i = 1, #C do
		if C[i]:IsA("BasePart") or C[i]:IsA("UnionOperation") or C[i]:IsA("CornerWedgePart") then
			local W = Instance.new("Weld")
			W.Part0 = welded.Middle
			W.Part1 = C[i]
			local CJ = cfNew(welded.Middle.Position)
			W.C0 = welded.Middle.CFrame:Inverse() * CJ
			W.C1 = C[i].CFrame:Inverse() * CJ
			W.Parent = welded.Middle
		end
		local Y = Instance.new("Weld")
		Y.Part0 = part
		Y.Part1 = welded.Middle
		Y.C0 = cfNew(Vector3.zero)
		Y.Parent = Y.Part0
	end

	local h = welded:GetChildren()
	for _, child in h do
		if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then child.Anchored = false end
	end
end


function ClientUtil:HitVFX(char: Model)
    pcall(function()
        local hitHighlight = RepS.Package.Effects.HitHighlight:Clone() :: Highlight
        hitHighlight.Adornee = char
        hitHighlight.Parent = char

        Debris:AddItem(hitHighlight, 1)
        TS:Create(hitHighlight, AssetBook.TweenInfos.one, { FillTransparency = 1, OutlineTransparency = 1 }):Play()

        local hitEff = RepS.Package.Effects.HitEffect:Clone() :: BasePart
        hitEff.CFrame = char.Head.CFrame
        hitEff.Parent = workspace

        Debris:AddItem(hitEff, 2)
    end)
end


function ClientUtil:GetKeyStoryLocations() : table
    local pos = {}

    local ok, err = pcall(function()
        for _, child: Model in workspace:WaitForChild("MapComponents").NPCs:GetChildren() do
            pos[child.Name] = child.PrimaryPart.Position
        end
        for _, child: Model in workspace.MapComponents.Statues:GetChildren() do
            pos[child.Name] = child.PrimaryPart.Position
        end
        for _, child: Instance in workspace:WaitForChild("Maps"):GetDescendants() do
            if sFind(child.Name, "StoryLocator") then
                local map, locator = child.Parent.Name, child.Name

                if not pos[map] then pos[map] = {} end

                pos[map][locator] = child.Position
            end
        end
    end)
    if not ok then warn(err) end

    return pos
end


function ClientUtil:FreezePlayerControls(action: string)
    if action == "Freeze" then
        UIS.ModalEnabled = true

        CAS:BindActionAtPriority("FreezeControl", function()
            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value, unpack(Enum.PlayerActions:GetEnumItems()))
    else
        UIS.ModalEnabled = false

        CAS:UnbindAction("FreezeControl")
    end
end


function ClientUtil:OpenUIEx(plr: Player, targetUI: string, isForce: boolean?)
    if not plr:GetAttribute("CurrentMenu") then plr:SetAttribute("CurrentMenu", "None") end
    if not plr.Character then return end
    if not plr.Character.PrimaryPart then return end

    --// In combat check
    if plr.Character:GetAttribute("InCombat") and not isForce then
        Signals.CreateHint:Fire("You can't open it in combat!")
        return
    end
    if plr:GetAttribute("InChatting") and not isForce then
        Signals.CreateHint:Fire("You can't open it right now!")
        return
    end

    local plrGui = plr:FindFirstChildOfClass("PlayerGui")
    local function _setExVisibleState(ui: ScreenGui, state: boolean)
		ui.BG.Visible = state
		ui.Shadow.Visible = state
	end
	local function _setOthersVisibleState(state: boolean)
		plrGui.AdventurerStats.Enabled = state
		plrGui.PlayerList.Enabled = state

		workspace.CurrentCamera.UIBlur.Enabled = not state
	end
    local function _setVisible(curUI: string, ui: ScreenGui)
		plr:SetAttribute("CurrentMenu", curUI)

		_setExVisibleState(ui, if curUI == "None" then false else true)
		_setOthersVisibleState(if curUI == "None" then true else false)

		Signals.ExCategoryOpened:Fire()
	end

    if targetUI == "Menu" then targetUI = "AdventurerMenu" end

    if plr:GetAttribute("CurrentMenu") == "None" then
        _setVisible(targetUI, plrGui[targetUI])

    elseif plr:GetAttribute("CurrentMenu") == targetUI then
        _setVisible("None", plrGui[targetUI])

    else
        plr:SetAttribute("CurrentMenu", targetUI)

        _setExVisibleState(plrGui[targetUI], true)

        local closeList = { "AdventurerMenu", "Backpack", "Shop" }
        for _, closeUI: string in closeList do
            if closeUI == targetUI then continue end

            _setExVisibleState(plrGui[closeUI], false)
        end
    end
end


function ClientUtil:SetupMonster(locator: Part) : Model
	if not RepS.Package.MonsterModels:FindFirstChild(locator.Name) then return end

	local level = locator:GetAttribute("Levels") :: number
	local monster = RepS.Package.MonsterModels[locator.Name]:Clone() :: Model
	monster:PivotTo(cfNew(locator.Position))
	if not monster:GetAttribute("CantRotate") then
        monster:PivotTo(cfNew(locator.Position) * CFrame.Angles(0, math.rad(random(0, 360)), 0))
    end
    monster:SetAttribute("ExclusivePlayer", locator:GetAttribute("ExclusivePlayer"))

	if monster:GetAttribute("Floatable") then
		local vel = Instance.new("BodyVelocity")
		vel.MaxForce = Vector3.one * math.huge
		vel.Velocity = Vector3.zero
		vel.Parent = monster
	end

	if not locator:GetAttribute("SubMonster") then
		local tierDisplay = RepS.Package.Effects.TierDisplay:Clone() :: BillboardGui
		tierDisplay.Monster.Text = AssetBook.MonsterInfo[monster.Name].Name
		tierDisplay.Levels.Text = "Level "..level
		tierDisplay.Parent = monster.Head

		tierDisplay.Enabled = if monster:GetAttribute("HideTag") then false else true
	else
		monster:SetAttribute("SubMonster", true)
	end

	monster:SetAttribute("InCombat", false)

	for _, child: Instance in monster:GetChildren() do
		if child:IsA("Part") and monster:FindFirstChild(child.Name .. "Model") then
			ClientUtil:WeldModel(child, monster[child.Name .. "Model"])
		end
	end
	monster.Parent = locator

	ClientUtil:SetCollisionGroup(monster, "NPC")
	for _, part: Instance in monster:GetDescendants() do
        if part:IsA("UnionOperation") or part:IsA("BasePart") or part:IsA("CornerWedgePart") then
            part.CanTouch = false
            part.CanQuery = false
        end
    end

    --- animator? harder to use lol
    local ok, err = pcall(function()
        local animator = monster.AnimationController.Animator :: Animator
        local ref = AssetBook.MonsterInfo[monster.Name].IdleAnim

        animator:LoadAnimation(RepS.Package.Animations.MonsterAnims[ref]):Play()
    end)
    if not ok then warn(err) end

	return monster
end


function ClientUtil:SetCollisionGroup(object: Instance, group: string)
	if object:IsA("BasePart") or object:IsA("UnionOperation") or object:IsA("CornerWedgePart") then object.CollisionGroup = group end

	for _, child: Instance in object:GetChildren() do ClientUtil:SetCollisionGroup(child, group) end
end


function ClientUtil:CombineRbxId(id: string?)
    if not id then
        warn("[ClientUtil]: Invalid Id")
        return "rbxassetid://0"
    end

    return "rbxassetid://".. id
end

return ClientUtil
