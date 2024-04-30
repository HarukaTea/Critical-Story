--!nocheck
--!optimize 2
--!native

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local DialogueBook = require(RepS.Modules.Data.DialogueBook)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local TypeWriter = require(RepS.Modules.Packages.TypeWriter)

local OptionFrame = require(RepS.Modules.UI.Components.OptionFrame)

local Computed = Fusion.Computed

local udNew =  UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local tFind, insert = table.find, table.insert
local match, sFind = string.match, string.find

local function ChatFrame(self: table) : Frame
    local originDialoguesChatting = nil
    local dialoguesChatting = nil
    local dialogueIndexChatting = 1
    local dialogueChoiceIndex = 1
    local canContinueChat = true
    local promptChatting: ProximityPrompt = nil
    local npcChatting: Model = nil
    local seriesDoing: string = nil

    --// Connections
    local Typer = TypeWriter.new()
    local function _setText(text: string)
        if text == nil then return end

        self.chatText:set(text)
        self.triangleVisible:set(false)
    end
    local function _endText(text: string)
        self.chatText:set(text)
        self.triangleVisible:set(true)
    end
    Typer.onTextUpdated:Connect(_setText)
    Typer.onTyperFinished:Connect(_endText)

    local function __endChatting()
        self.isChatting:set(false)

        ---// revert back to initial state
        originDialoguesChatting = nil
        dialoguesChatting = nil
        dialogueIndexChatting = 1
        dialogueChoiceIndex = 1
        canContinueChat = true

        ClientUtil:FreezePlayerControls("Unfreeze")

        promptChatting.Enabled = true

        Events.NPCChatEnded:Fire(npcChatting, seriesDoing)

        promptChatting = nil
        npcChatting = nil
        seriesDoing = nil
    end
    local function __nextText(method: string)
        if method == "Skip" then
            Typer:Stop()

            self.chatText:set(dialoguesChatting[dialogueIndexChatting])
            return
        end

        dialogueIndexChatting += 1

        --- chat ended
        if dialogueIndexChatting > #dialoguesChatting then
            __endChatting()
            return
        end

        workspace.Sounds.SFXs.Next:Play()

        --- enter choices
        if sFind(dialoguesChatting[dialogueIndexChatting], "CHOICE") then
            canContinueChat = false

            local series = match(dialoguesChatting[dialogueIndexChatting], "%d+")
            local choices = originDialoguesChatting["Choice"..series]
            local realChoices = {}

            dialogueChoiceIndex = tonumber(series)

            for i = 1, #choices do
                insert(realChoices, choices[i])
            end

            self.chatChoices:set(realChoices)
            return
        end
        --- enter quests
        if sFind(dialoguesChatting[dialogueIndexChatting], "QUEST") then
            local series = if sFind(dialoguesChatting[dialogueIndexChatting], "TOWN") then "Town" else "Side"
            local questWillDo = match(dialoguesChatting[dialogueIndexChatting], "%d+")

            Events.NewQuest:Fire(npcChatting, series, tonumber(questWillDo))

            __endChatting()
            return
        end

        Typer:TypeText(dialoguesChatting[dialogueIndexChatting])
    end
    local function _nextDialogue()
        if not canContinueChat then return end

        __nextText(if Typer:IsTyping() then "Skip" else "Continue")
    end
    local function _startChatting(npc: Model, prompt: ProximityPrompt)
        prompt.Enabled = false

        promptChatting = prompt
        npcChatting = npc

        local speaker = StoryBook.NPCs[npc.Name]
        self.chatSpeaker:set(speaker)
        self.isChatting:set(true)

        ClientUtil:FreezePlayerControls("Freeze")

        local quests = self.plr.Quests:GetChildren() :: Folder

        --- main quest is at the highest priority
        dialogueIndexChatting = 1

        local function __priorityChoose(series: string)
            local found = false
            for _, quest: IntConstrainedValue in quests do
                if quest.Name == series and DialogueBook[speaker][series..quest.Value] then

                    originDialoguesChatting = DialogueBook[speaker][series..quest.Value]
                    dialoguesChatting = DialogueBook[speaker][series..quest.Value]

                    Typer:TypeText(dialoguesChatting[dialogueIndexChatting])

                    found = true
                    seriesDoing = series
                    break
                end
            end

            return found
        end
        if __priorityChoose("Main") then return end
        if __priorityChoose("Side") then return end
        if __priorityChoose("Town") then return end

        --- all of above don't match
        originDialoguesChatting = DialogueBook[speaker].Else
        dialoguesChatting = DialogueBook[speaker].Else

        Typer:TypeText(dialoguesChatting[dialogueIndexChatting])
    end
    Events.NPCChat:Connect(_startChatting)

    local function _chooseOption(series: number)
        dialoguesChatting = originDialoguesChatting["Choice"..dialogueChoiceIndex]["Option"..series]
        dialogueIndexChatting = 1

        canContinueChat = true

        Typer:TypeText(dialoguesChatting[dialogueIndexChatting])
    end
    Signals.NPCChat:Connect(_chooseOption)


    return Components.Frame({
        BackgroundTransparency = 0,
        Name = "ChatFrame",
        Position = fromScale(0.5, -2.1),
        Size = fromScale(0.585, 2.5),

        Visible = Computed(function(use)
            return use(self.isChatting)
        end),

        [Fusion.Children] = {
            Fusion.New("UICorner")({ CornerRadius = udNew(0.07, 0)  }),
            Components.UIStroke({
                Thickness = 3.5,
                Color = fromRGB(254, 254, 254),
                Enabled = true
            }),
            Components.HoverImageButton({
                ZIndex = 2,

                [Fusion.OnEvent("MouseButton1Click")] = _nextDialogue
            }),
            Components.ImageLabel({
                Name = "Triangle",
                Position = fromScale(0.953, 0.778),
                Size = fromScale(0.024, 0.134),
                Rotation = 180,
                Image = "rbxassetid://7130292537",
                ImageColor3 = fromRGB(218, 218, 218),
                ImageTransparency = 0.1,

                Visible = Computed(function(use)
                    return use(self.triangleVisible)
                end)
            }),
            Components.TextLabel({
                Name = "Speaker",
                Position = fromScale(0.035, 0.051),
                Size = fromScale(0.943, 0.247),
                RichText = true,
                TextColor3 = fromRGB(255, 170, 127),
                TextXAlignment = Enum.TextXAlignment.Left,

                Text = Computed(function(use)
                    return "<u>"..use(self.chatSpeaker).."</u>"
                end)
            }),
            Components.TextLabel({
                Name = "Dialogue",
                Position = fromScale(0.033, 0.349),
                Size = fromScale(0.943, 0.563),
                TextColor3 = fromRGB(218, 218, 218),
                TextScaled = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                RichText = true,

                [Fusion.OnChange("AbsoluteSize")] = function(size)
                    self.chatDialogueAbsSize:set(size.Y)
                end,

                Text = Computed(function(use)
                    return use(self.chatText)
                end),
                TextSize = Computed(function(use)
                    return use(self.chatDialogueAbsSize) / 2.5
                end)
            }),

            Components.Frame({
                Name = "ChoicesFrame",
                AnchorPoint = v2New(),
                Position = fromScale(0.7, -1.2),
                Size = fromScale(0.509, 1),

                [Fusion.Children] = {
                    Fusion.New("UIListLayout")({
                        Padding = udNew(0.12, 0),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
                    }),
                    Fusion.ForValues(self.chatChoices, function(use, option)
                        local way = "Chat"
                        if sFind(option, "EXIT") then way = "Exit" end
                        if sFind(option, "BUY") then way = "Buy" end
                        if sFind(option, "CRAFT") then way = "Craft" end
                        if sFind(option, "QUEST") then way = "Quest" end
                        local index = tFind(Fusion.peek(self.chatChoices), option)

                        return OptionFrame(option, way, self, index)
                    end, Fusion.cleanup)
                }
            })
        }
    })
end

return ChatFrame
