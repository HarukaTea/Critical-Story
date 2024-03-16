--!strict

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Children, New = Fusion.Children, Fusion.New

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local udNew = UDim.new

local function PartyInviteSlot(player: Player, envir: string, self: table) : Frame

    local state = Fusion.Value(true)
    Fusion.Hydrate(player)({
        [Fusion.AttributeChange("InviteAccess")] = function(newState: boolean)
            state:set(newState)
        end
    })

    return Components.Frame({
        Name = player.Name,
        Size = fromScale(1, 0.15),
        BackgroundTransparency = 0,
        AnchorPoint = v2New(),

        [Children] = {
            New("UIAspectRatioConstraint")({ AspectRatio = if envir == "Invite" then 10.554 else 8.085 }),
            Components.RoundUICorner(),

            Components.TextLabel({
                Name = "PlayerName",
                Size = fromScale(1, 1),
                Text = player.DisplayName,
                TextXAlignment = Enum.TextXAlignment.Left,

                [Children] = {
                    New("UIPadding")({
                        PaddingBottom = udNew(0.2, 0),
                        PaddingTop = udNew(0.2, 0),
                        PaddingLeft = udNew(0.07, 0),
                        PaddingRight = udNew(0.1, 0)
                    })
                }
            }),
            Components.TextButton({
                BackgroundColor3 = Fusion.Tween(Fusion.Computed(function(use)
                    if envir == "Invite" then
                        return if use(state) then fromRGB(0, 132, 97) else fromRGB(182, 61, 91)

                    elseif envir == "Member" then
                        return fromRGB(182, 61, 91)
                    end
                end), AssetBook.TweenInfos.half),
                Position = if envir == "Invite" then fromScale(0.9, 0) else fromScale(0.871, 0),
                Size = if envir == "Invite" then fromScale(0.1, 1) else fromScale(0.129, 1),
                FontFace = if envir == "Invite"
                    then Font.fromName("GothamSSm", Enum.FontWeight.Bold)
                    else Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
                Text = if envir == "Invite" then "?" else "X",
                Visible = if player.Name == self.plr.Name then false else true,

                [Children] = { Components.RoundUICorner() },

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if envir == "Invite" then
                        if not Fusion.peek(state) then
                            Signals.CreateHint:Fire("You can't invite that player due to privacy settings!", "Error")
                            return
                        end

                        if player:GetAttribute("InviteTicket") then
                            Signals.CreateHint:Fire("Player is busying handling with the requests from other players!", "Error")
                            return
                        end

                        if player:GetAttribute("InParty") then
                            Signals.CreateHint:Fire("Player already have a party!", "Error")
                            return
                        end

                        local plr = self.plr :: Player
                        if plr:GetAttribute("InParty") then
                            if not workspace.MapComponents.Parties:FindFirstChild(plr.Name) then
                                Signals.CreateHint:Fire("You can't invite others if you are not party owner!", "Error")
                                return
                            end
                        end

                        Events.PartyInvite:Fire("Invite", player)

                    elseif envir == "Member" then
                        local plr = self.plr :: Player

                        if not workspace.MapComponents.Parties:FindFirstChild(plr.Name) then
                            Signals.CreateHint:Fire("You can't kick others if you are not party owner!", "Error")
                            return
                        end

                        if player.Name == plr.Name then
                            Events.PartyInvite:Fire("Leave", player)
                            return
                        end

                        Events.PartyInvite:Fire("Kick", player)
                    end
                end
            })
        }
    })
end

return PartyInviteSlot
