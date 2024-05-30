--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children = Fusion.Children

local function FilterOption(option: string, self: table) : TextLabel
    local scope = self.scope

    return Components.TextLabel(scope, {
        Name = option,
        Text = string.upper(option),
        Size = UDim2.fromScale(0.5, 1),
        Position = if option == "Client" then UDim2.fromScale(0, 0) else UDim2.fromScale(0.5, 0),
        ZIndex = 2,

        TextColor3 = Fusion.Computed(scope, function(use)
            return if use(self.chosenErrorFilter) == option then Color3.new() else Color3.new(1, 1, 1)
        end),

        [Children] = {
            Fusion.New(scope, "UIPadding")({
                PaddingTop = UDim.new(0.1, 0),
                PaddingBottom = UDim.new(0.1, 0)
            })
        }
    })
end
local function ErrorReport(scope: table, errorVal: StringValue) : TextLabel
    return Components.TextLabel(scope, {
        Name = "Record",
        Size = UDim2.fromScale(1, 0.08),
        TextColor3 = Color3.fromRGB(255, 255, 127),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = errorVal.Value,

        [Children] = {
            Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 48.2 })
        }
    })
end
local function LogFrame(self: table) : Frame
    local scope = self.scope :: table

    local scriptErrors = workspace:WaitForChild("MapComponents", 999).ScriptErrors :: Folder
    local function _handleErrors()
        task.wait()
        self.errorList:set(scriptErrors:GetChildren())
    end
    _handleErrors()
    self.Add(scriptErrors.ChildAdded:Connect(_handleErrors))
    self.Add(scriptErrors.ChildAdded:Connect(_handleErrors))

    return Components.Frame(scope, {
        Name = "Log",
		Position = UDim2.fromScale(0.496, 0.567),
		Size = UDim2.fromScale(0.944, 0.627),

		Visible = Fusion.Computed(scope, function(use)
			return use(self.frames.Log)
		end),

        [Children] = {
            Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 3.856 }),

            Fusion.New(scope, "Frame")({
                Name = "Top",
                Size = UDim2.fromScale(1, 0.1),
                BackgroundTransparency = 1,

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal
                    }),
                    Components.TextLabel(scope, {
                        Name = "Title",
                        Text = "FILTER:",
                        Size = UDim2.fromScale(0.1, 1),

                        [Children] = {
                            Fusion.New(scope, "UIPadding")({
                                PaddingTop = UDim.new(0.1, 0),
                                PaddingBottom = UDim.new(0.1, 0)
                            })
                        }
                    }),
                    Fusion.New(scope, "Frame")({
                        Name = "ToggleBtn",
                        Size = UDim2.fromScale(0.2, 1),
                        BackgroundColor3 = Color3.new(),

                        [Children] = {
                            Components.RoundUICorner(scope),

                            FilterOption("Client", self),
                            FilterOption("Server", self),

                            Components.HoverImageButton(scope, {
                                Name = "Switch",
                                ZIndex = 3,

                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    workspace.Sounds.SFXs.SwitchOn:Play()

                                    self.chosenErrorFilter:set(if Fusion.peek(self.chosenErrorFilter) == "Client" then "Server" else "Client")
                                end
                            }),
                            Fusion.New(scope, "Frame")({
                                Name = "SlideBlock",
                                Size = UDim2.fromScale(0.5, 1),

                                Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use)
                                    return if use(self.chosenErrorFilter) == "Client" then UDim2.fromScale(0, 0) else UDim2.fromScale(0.5, 0)
                                end), AssetBook.TweenInfos.twiceHalf),

                                [Children] = { Components.RoundUICorner(scope) }
                            })
                        }
                    })
                }
            }),
            Components.ScrollingFrame(scope, {
                Name = "Records",
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Position = UDim2.fromScale(0, 0.15),
                Size = UDim2.fromScale(1, 0.8),
                AnchorPoint = Vector2.new(),

                CanvasSize = Fusion.Computed(scope, function(use)
                    return if use(self.errorAbsContentSize) > use(self.errorAbsSize) then UDim2.fromOffset(0, use(self.errorAbsContentSize)) else UDim2.fromOffset(0, 0)
                end),
                ScrollingEnabled = Fusion.Computed(scope, function(use)
                    return if use(self.errorAbsContentSize) > use(self.errorAbsSize) then true else false
                end),

                [Fusion.OnChange("AbsoluteSize")] = function(newSize: Vector2)
                    self.errorAbsSize:set(newSize.Y)
                end,

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        Padding = UDim.new(0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder,

                        [Fusion.OnChange("AbsoluteContentSize")] = function(newSize: Vector2)
                            self.errorAbsContentSize:set(newSize.Y)
                        end
                    }),
                    Fusion.ForValues(scope, self.errorList, function(use, localScope: table, errorVal: StringValue)
                        if use(self.chosenErrorFilter) == "Client" then
                            if errorVal:GetAttribute("Owner") ~= self.plr.Name then return nil end
                        end
                        if errorVal.Name ~= use(self.chosenErrorFilter) then return nil end

                        return ErrorReport(localScope, errorVal)
                    end)
                }
            })
        }
    })
end

return LogFrame
