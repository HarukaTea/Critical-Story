--!nocheck
--!optimize 2
--!native

local CAS = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Spawn = require(RepS.Modules.Packages.Spawn)
local Signals = require(RepS.Modules.Data.Signals)

local cfNew = CFrame.new
local csNew = ColorSequence.new
local random = math.random
local wait = task.wait
local fromScale = UDim2.fromScale
local sFind = string.find

local ClientUtil = {}

--[[
    The class hit visual effects
]]
function ClientUtil:ClassHitVFX(monster: Model, char: Model)
    --- checks
    if not monster then return end
    if not monster.PrimaryPart then return end

    local plr = Players:GetPlayerFromCharacter(char)
    if not plr then return end

    local class = plr:GetAttribute("Class") :: string
    if not AssetBook.ClassInfo[class] then return end

    --- main
    char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, monster.PrimaryPart.Position)

    local color = AssetBook.ClassInfo[class].Color

    local hitEff = RepS.Package.Effects.HitEffect:Clone() :: Part
    hitEff.CFrame = monster.PrimaryPart.CFrame
    hitEff.Effect.Image.ImageColor3 = color
    hitEff.Particle.Color = csNew(color)
    hitEff.Effect.Image.Rotation = random(1, 360)
    if random(1, 2) == 1 then hitEff.Effect.Image.Image = "rbxassetid://2771196128" end
    hitEff.Parent = workspace

    Debris:AddItem(hitEff, 5)
    Debris:AddItem(hitEff.Particle, 2)

    Spawn(function()
        wait(0.2)
        hitEff.Particle.Enabled = false
    end)

    TS:Create(hitEff.Effect, AssetBook.TweenInfos.fourHalf, { Size = fromScale(30, 30) }):Play()
    TS:Create(hitEff.Effect.Image, AssetBook.TweenInfos.fourHalf, { ImageTransparency = 1 }):Play()
end

--[[
    Character was hit by mobs
]]
function ClientUtil:SetCharTrans(trans: number, char: Model)
    for _, child in char:GetChildren() do
		if child:IsA("Part") and child.Name ~= "HumanoidRootPart" then child.Transparency = trans end
		if child:IsA("Model") then
			for _, descendant in child:GetChildren() do
				if descendant.Name == "Part" then descendant.Transparency = trans end
			end
		end
		if child:IsA("Accessory") then child.Handle.Transparency = trans end
	end
end

--[[
    Get all key locations in story
]]
function ClientUtil:GetKeyStoryLocations() : table
    local pos = {}

    for _, child in workspace:WaitForChild("MapComponents").NPCs:GetChildren() do
        pos[child.Name] = child.PrimaryPart.Position
    end
    for _, child in workspace.MapComponents.Statues:GetChildren() do
        pos[child.Name] = child.PrimaryPart.Position
    end
    for _, child in workspace:GetDescendants() do
        if sFind(child.Name, "StoryLocator") then
            local map, locator = child.Parent.Name, child.Name

            if not pos[map] then pos[map] = {} end

            pos[map][locator] = child.Position
        end
    end

    return pos
end

--[[
    Freeze player's controls, usually used for chat and combat
]]
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

--[[
	Get touching parts includes non-collide parts
]]
function ClientUtil:GetTouchingParts(part: BasePart | UnionOperation) : table
	local connection = part.Touched:Connect(function() end)
	local touchingParts = part:GetTouchingParts()

	connection:Disconnect()

	return touchingParts
end

--[[
    Common functions for menu and backpack UI
]]
function ClientUtil:OpenUI(plr: Player, targetUI: string)
    if not plr:GetAttribute("CurrentMenu") then plr:SetAttribute("CurrentMenu", "None") end
    if not plr.Character then return end

    --// In combat check
    if plr.Character:GetAttribute("InCombat") then
        Signals.CreateHint:Fire("You can't open it in combat!", "Error")
        return
    end

    local plrGui = plr.PlayerGui
    local function _setExVisibleState(ui: ScreenGui, state: boolean)
		ui.BG.Visible = state
		ui.Shadow.Visible = state

        if state then workspace.Sounds.SFXs[if ui.Name == "Backpack" then "Equip" else "MapOpen"]:Play() end
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

    if plr:GetAttribute("CurrentMenu") == "None" then
        _setVisible(targetUI, plrGui[targetUI])

    elseif plr:GetAttribute("CurrentMenu") == targetUI then
        _setVisible("None", plrGui[targetUI])

    else
        plr:SetAttribute("CurrentMenu", targetUI)

        _setExVisibleState(plrGui[targetUI], true)
        _setExVisibleState(if targetUI == "Backpack" then plrGui.AdventurerMenu else plrGui.Backpack, false)
    end
end

return ClientUtil
