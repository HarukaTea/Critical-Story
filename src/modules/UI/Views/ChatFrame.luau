--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local DialogueBook = require(RepS.Modules.Data.DialogueBook)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)
local TypeWriter = require(RepS.Modules.Packages.TypeWriter)

local ChatOption = require(RepS.Modules.UI.Components.ChatOption)

local Computed = Fusion.Computed

local udNew =  UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local tFind, insert = table.find, table.insert
local match, sFind, gsub = string.match, string.find, string.gsub

local function ChatFrame(self: table) : Frame
    local scope = self.scope :: Fusion.Scope

    local originDialoguesChatting = nil
    local dialoguesChatting = nil
    local dialogueIndexChatting = 1
    local dialogueChoiceIndex = 1
    local canContinueChat = true
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
        self.plr:SetAttribute("InChatting", false)

        ClientUtil:OpenUIEx(self.plr, "NPCChat", true)

        ---// revert back to initial state
        originDialoguesChatting = nil
        dialoguesChatting = nil
        dialogueIndexChatting = 1
        dialogueChoiceIndex = 1
        canContinueChat = true

        ClientUtil:FreezePlayerControls("Unfreeze")
        CAS:UnbindAction("NextDialogue")

        Events.NPCChatEnded.Fire({ NPC = npcChatting, Series = seriesDoing })

        npcChatting = nil
        seriesDoing = nil
    end
    local function __nextText(method: string)
        if method == "Skip" then
            Typer:Stop()

            self.chatText:set(HarukaLib:RichTextify(dialoguesChatting[dialogueIndexChatting]))
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

            Events.NewQuest.Fire({ NPC = npcChatting, Series = series, QuestId = tonumber(questWillDo) })

            __endChatting()
            return
        end

        Typer:TypeText(HarukaLib:RichTextify(dialoguesChatting[dialogueIndexChatting]))
    end
    local function _nextDialogue(_, inputState: Enum.UserInputState)
        if inputState ~= Enum.UserInputState.Begin then return end
        if not canContinueChat then return end

        __nextText(if Typer:IsTyping() then "Skip" else "Continue")
    end
    local function _startChatting(npc: Model)
        npcChatting = npc

        local speaker = npc.Name
        self.chatSpeaker:set(gsub(speaker, "%d+", ""))
        self.plr:SetAttribute("InChatting", true)

        ClientUtil:FreezePlayerControls("Freeze")
        ClientUtil:OpenUIEx(self.plr, "NPCChat", true)

        CAS:BindActionAtPriority("NextDialogue", function(action: string, inputState: Enum.UserInputState)
            if action == "NextDialogue" and inputState == Enum.UserInputState.Begin then
                _nextDialogue(nil, inputState)
            end

            return if (self.plr:GetAttribute("IsChatting") and inputState == Enum.UserInputState.Begin) then
                Enum.ContextActionResult.Sink else Enum.ContextActionResult.Pass
        end, false, 3000, Enum.KeyCode.Space)

        local quests = self.plr.Quests:GetChildren() :: Folder

        --- main quest is at the highest priority
        dialogueIndexChatting = 1

        local function __priorityChoose(series: string)
            local found = false
            for _, quest: IntConstrainedValue in quests do
                if quest.Name == series and DialogueBook[speaker][series..quest.Value] then

                    originDialoguesChatting = DialogueBook[speaker][series..quest.Value]
                    dialoguesChatting = DialogueBook[speaker][series..quest.Value]

                    Typer:TypeText(HarukaLib:RichTextify(dialoguesChatting[dialogueIndexChatting]))

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

        Typer:TypeText(HarukaLib:RichTextify(dialoguesChatting[dialogueIndexChatting]))
    end
    table.insert(scope, Events.EnterNPCChat.On(function(data)
        _startChatting(data.NPC)
    end))
    table.insert(scope, Signals.EnterNPCChat:Connect(_startChatting))

    local function _chooseOption(series: number)
        dialoguesChatting = originDialoguesChatting["Choice"..dialogueChoiceIndex]["Option"..series]
        dialogueIndexChatting = 1

        canContinueChat = true

        Typer:TypeText(HarukaLib:RichTextify(dialoguesChatting[dialogueIndexChatting]))
    end
    table.insert(scope, Signals.ContinueNPCChat:Connect(_chooseOption))


    return Components.Frame(scope, {
        BackgroundTransparency = 0,
        Name = "ChatFrame",
        AnchorPoint = v2New(0.5, 0.9),
        Position = fromScale(0.5, -0.1),
        Size = fromScale(0.585, 2.5),

        [Fusion.Children] = {
            Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.07, 0)  }),
            Components.UIStroke(scope, {
                Thickness = 3,
                Color = fromRGB(254, 254, 254),
                Enabled = true
            }),
            Components.HoverImageButton(scope, {
                ZIndex = 2,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    _nextDialogue(nil, Enum.UserInputState.Begin)
                end
            }),
            Components.ImageLabel(scope, {
                Name = "Triangle",
                Position = fromScale(0.953, 0.778),
                Size = fromScale(0.024, 0.134),
                Rotation = 180,
                Image = "rbxassetid://7130292537",
                ImageColor3 = fromRGB(218, 218, 218),
                ImageTransparency = 0.1,

                Visible = Computed(scope, function(use: Fusion.Use)
                    return use(self.triangleVisible)
                end)
            }),
            Components.TextLabel(scope, {
                Name = "Speaker",
                Position = fromScale(0.035, 0.051),
                Size = fromScale(0.943, 0.247),
                RichText = true,
                TextColor3 = fromRGB(255, 170, 127),
                TextXAlignment = Enum.TextXAlignment.Left,

                Text = Computed(scope, function(use: Fusion.Use)
                    return "<u>"..use(self.chatSpeaker).."</u>"
                end)
            }),
            Components.TextLabel(scope, {
                Name = "Dialogue",
                Position = fromScale(0.033, 0.349),
                Size = fromScale(0.943, 0.563),
                TextColor3 = fromRGB(218, 218, 218),
                TextScaled = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                RichText = true,

                [Fusion.Out("AbsoluteSize")] = self.chatDialogueAbsSize,

                Text = Computed(scope, function(use: Fusion.Use)
                    return use(self.chatText)
                end),
                TextSize = Computed(scope, function(use: Fusion.Use)
                    return use(self.chatDialogueAbsSize).Y / 2.5
                end)
            }),

            Components.Frame(scope, {
                Name = "ChoicesFrame",
                AnchorPoint = v2New(),
                Position = fromScale(0.7, -1.2),
                Size = fromScale(0.509, 1),

                [Fusion.Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        Padding = udNew(0.12, 0),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
                    }),
                    Fusion.ForValues(scope, self.chatChoices, function(_, localScope: Fusion.Scope, option: string)
                        local way = "Chat"
                        if sFind(option, "EXIT") then way = "Exit" end
                        if sFind(option, "BUY") then way = "Buy" end
                        if sFind(option, "CRAFT") then way = "Craft" end
                        if sFind(option, "QUEST") then way = "Quest" end
                        local index = tFind(Fusion.peek(self.chatChoices), option)

                        return ChatOption(option, way, self, index, localScope)
                    end)
                }
            })
        }
    })
end

return ChatFrame
