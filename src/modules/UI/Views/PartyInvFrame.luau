--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New, Computed, Value = Fusion.Children, Fusion.New, Fusion.Computed, Fusion.Value

local udNew, ud2New = UDim.new, UDim2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local wait = task.wait

local function OptionButton(option: boolean, self: table) : TextButton
    return Components.TextButton({
        Name = if option then "Accept" else "Reject",
        BackgroundColor3 = if option then fromRGB(71, 143, 106) else fromRGB(213, 71, 107),
        Size = fromScale(0.1, 1),
        Position = if option then fromScale(1.034, 0) else fromScale(1.155, 0),
        Text = if option then "Y" else "N",

        [Children] = {
            Components.RoundUICorner(),
            Components.TextUIStroke({ Thickness = 2.5 })
        },

        [Fusion.OnEvent("MouseButton1Click")] = function()
            if option then
                Events.PartyInvite:Fire("Accept", Fusion.peek(self.invPersonT))
            end

            self.invPerson:set("")
            self.invPersonT:set("")
        end
    })
end

local function PartyInvFrame(self: table) : Frame
    self.invProgressSize, self.invPerson, self.invPersonT = Value(fromScale(1, 1)), Value(""), Value("")

    local function _partyInvite(inviter: Player)
		workspace.Sounds.SFXs.Notification:Play()

		self.invPerson:set(inviter.DisplayName)
		self.invPersonT:set(inviter.Name)
		self.invProgressSize:set(fromScale(0, 1))

		wait(6)
		self.invPerson:set("")
		self.invPersonT:set("")
		self.invProgressSize:set(fromScale(1, 1))
	end
	Events.PartyInvite:Connect(_partyInvite)


    return Components.Frame({
        Name = "PartyInvFrame",
        BackgroundTransparency = 0,
        Position = ud2New(0.45, 0, 0, 25),
        Size = fromScale(0.3, 0.75),
        Visible = Computed(function(use)
            return use(self.invPerson) ~= ""
        end),

        [Children] = {
            New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
            Components.Frame({
                Name = "BGProgress",
                BackgroundTransparency = 0,
                AnchorPoint = v2New(),
                Position = fromScale(0, 0),
                BackgroundColor3 = fromRGB(172, 172, 172),
                Size = Fusion.Tween(Computed(function(use)
                    return use(self.invProgressSize)
                end), AssetBook.TweenInfos.six),

                [Children] = {
                    New("UICorner")({ CornerRadius = udNew(0.2, 0) })
                }
            }),
            Components.TextLabel({
                Name = "PartyInvite",
                Size = fromScale(1, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = Computed(function(use)
                    return "Party Invite From "..use(self.invPerson)
                end),

                [Children] = {
                    New("UIPadding")({
                        PaddingTop = udNew(0.22, 0),
                        PaddingBottom = udNew(0.22, 0),
                        PaddingLeft = udNew(0.05, 0),
                        PaddingRight = udNew(0.05, 0)
                    }),
                    Components.TextUIStroke({ Thickness = 3 })
                }
            }),

            OptionButton(true, self),
            OptionButton(false, self)
        }
    })
end

return PartyInvFrame
