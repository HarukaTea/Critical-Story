--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Components = require(RepS.Modules.UI.Vanilla)
local DialogueBook = require(RepS.Modules.Data.DialogueBook)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local TypeWriter = require(RepS.Modules.Packages.TypeWriter)

local OptionFrame = require(RepS.Modules.UI.Components.OptionFrame)

local Computed, Value = Fusion.Computed, Fusion.Value

local udNew =  UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local tFind, insert = table.find, table.insert
local match, sFind = string.match, string.find

local function ChatFrame(self: table) : Frame
    self.chatDialogueAbsSize = Value(24)
    self.chatText = Value("")
    self.chatSpeaker = Value("")
    self.chatChoices = Value({})
    self.triangleVisible = Value(true)
    self.isChatting = Value(false)

    local dialoguesChatting = nil
    local dialogueIndexChatting = 1
    local dialogueChoiceIndex = 0
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

        CAS:UnbindAction("NextDialogue")
        CAS:UnbindAction("FreezeControl")
        UIS.ModalEnabled = false

        promptChatting.Enabled = true

        Events.NPCChatEnded:Fire(npcChatting, seriesDoing)
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
        if match(dialoguesChatting[dialogueIndexChatting], "CHOICE") then
            canContinueChat = false

            local series = match(dialoguesChatting[dialogueIndexChatting], "%d+")
            local choices = dialoguesChatting["Choice"..series]
            local realChoices = {}

            dialogueChoiceIndex = series

            for i = 1, #choices do
                insert(realChoices, choices[i])
            end

            self.chatChoices:set(realChoices)
            return
        end

        Typer:TypeText(dialoguesChatting[dialogueIndexChatting])
    end
    local function _nextDialogue(_, inputState: Enum.UserInputState)
        if inputState ~= Enum.UserInputState.Begin then return end
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

        --- freeze player control
        UIS.ModalEnabled = true
        CAS:BindActionAtPriority("FreezeControl", function()
            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value, unpack(Enum.PlayerActions:GetEnumItems()))
        CAS:BindAction("NextDialogue", _nextDialogue, false, Enum.KeyCode.Space)

        local quests = self.plr.Quests:GetChildren() :: Folder

        --- main quest is at the highest priority
        dialogueIndexChatting = 1

        local function __priorityChoose(series: string)
            local found = false
            for _, quest in quests do
                if quest.Name == series and DialogueBook[speaker][series..quest.Value] then
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
        dialoguesChatting = DialogueBook[speaker].Else
        Typer:TypeText(dialoguesChatting[dialogueIndexChatting])
    end
    Events.NPCChat:Connect(_startChatting)

    local function _chooseOption(series: number)
        dialoguesChatting = dialoguesChatting["Choice"..dialogueChoiceIndex]["Option"..series]
        dialogueIndexChatting = 1

        Typer:TypeText(dialoguesChatting[dialogueIndexChatting])

        canContinueChat = true
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
                Enabled = true
            }),
            Components.HoverImageButton({
                Name = "Hover",
                ZIndex = 2,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    _nextDialogue("NextDialogue", Enum.UserInputState.Begin)
                end
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
                        if sFind(option, "BUY") then way = "Exit" end
                        if sFind(option, "CRAFT") then way = "Exit" end
                        local index = tFind(Fusion.peek(self.chatChoices), option)

                        return OptionFrame(option, way, self, index)
                    end, Fusion.cleanup)
                }
            })
        }
    })
end

return ChatFrame
