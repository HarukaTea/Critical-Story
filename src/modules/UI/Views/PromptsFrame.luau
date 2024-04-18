--!nocheck
--!optimize 2
--!native

local PPS = game:GetService("ProximityPromptService")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Prompt = require(RepS.Modules.UI.Components.Prompt)

local v2New, udNew = Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local wait = task.wait
local insert, tFind, remove = table.insert, table.find, table.remove

--[[
    TODO: multi-prompt actions
]]
local function PromptsFrame(self: table) : Frame
    self.promptsList = Fusion.Value({})

    local function _addPrompt(prompt: ProximityPrompt)
		local nowPrompts = Fusion.peek(self.promptsList)

		insert(nowPrompts, prompt)
		self.promptsList:set(nowPrompts)
	end
	local function _removePrompt(prompt: ProximityPrompt)
		local afterPrompts = Fusion.peek(self.promptsList)

		remove(afterPrompts, tFind(afterPrompts, prompt))
		self.promptsList:set(afterPrompts)
	end
	local function _triggerPrompt(prompt: ProximityPrompt)
		workspace.Sounds.SFXs.Interact:Play()

		prompt.Enabled = false
		wait(1)
		local blacklist = { "Chest", "PublicJoin", "PartyJoin", "Chat" }
		if not tFind(blacklist, prompt.Name) then prompt.Enabled = true end
	end
	self.Add(PPS.PromptShown:Connect(_addPrompt))
	self.Add(PPS.PromptHidden:Connect(_removePrompt))
	self.Add(PPS.PromptTriggered:Connect(_triggerPrompt))

    return Components.Frame({
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.65, 0),
        Size = fromScale(1, 0.7),
        Name = "PromptsFrame",

        [Fusion.Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0.2, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            Fusion.ForValues(self.promptsList, function(use, prompt: ProximityPrompt)
                return Prompt(prompt, 1)
            end, Fusion.cleanup)
        },
    })
end

return PromptsFrame