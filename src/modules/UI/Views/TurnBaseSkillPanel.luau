--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed, Value, OnEvent, OnChange =
	Fusion.Children, Fusion.Computed, Fusion.Value, Fusion.OnEvent, Fusion.OnChange

local TurnBaseUI = {}
TurnBaseUI.__index = TurnBaseUI

local v2New = Vector2.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local udNew = UDim.new
local wait = task.wait

local function TurnBaseSkillPanel(self: table) : ScrollingFrame
    self.skillPanelAbsContentSize, self.skillPanelAbsSize = Value(0), Value(0)
    self.skills = Value({})
    self.skillPanelVisible = Value(false)

    local function _handleSkills()
        wait()
        local items = self.inventory:GetChildren()
        local realSkills = {}

        for _, item: IntValue in items do
            if AssetBook.Items.IsSkill[item.Name]
                and AssetBook.Items.ItemType[item.Name] == "Active"
                and item.Value > 0 then

                realSkills[#realSkills + 1] = item.Name
            end
        end

        self.skills:set(realSkills)
    end
    _handleSkills()
    Fusion.Hydrate(self.inventory)({
		[OnEvent("ChildAdded")] = _handleSkills,
		[OnEvent("ChildRemoved")] = function()
			if not self.plr:IsDescendantOf(Players) then return end --- cuz plr left also triggers ChildRemoved

			_handleSkills()
		end,
	})

    return Components.ScrollingFrame({
        Name = "SkillPanel",
        ClipsDescendants = true,
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.668, -3.2),
        Size = fromScale(0.173, 3),
        ScrollingDirection = Enum.ScrollingDirection.Y,

        Visible = Computed(function(use)
            return use(self.skillPanelVisible)
        end),
        CanvasSize = Computed(function(use)
            return if use(self.skillPanelAbsContentSize) > use(self.skillPanelAbsSize) then fromOffset(0, use(self.skillPanelAbsContentSize) + 20) else fromOffset(0, 0)
        end),
        ScrollingEnabled = Computed(function(use)
            return if use(self.skillPanelAbsContentSize) > use(self.skillPanelAbsSize) then true else false
        end),

        [Fusion.OnChange("AbsoluteSize")] = function(newSize: Vector2)
            self.skillPanelAbsSize:set(newSize.Y)
        end,

        [Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,

                [Fusion.OnChange("AbsoluteContentSize")] = function(newSize: Vector2)
                    self.skillPanelAbsContentSize:set(newSize.Y)
                end
            }),
            Components.Frame({
                Name = "PaddingTop",
                Size = fromScale(0.95, 0.01)
            }),
            Fusion.ForValues(self.skills, function(_, skill: string)
                local isSelecting = Value(false)
                local itemAmount = Value(self.inventory[skill].Value)

                Fusion.Hydrate(self.inventory[skill])({
                    [OnChange("Value")] = function(newAmount: number)
                        itemAmount:set(newAmount)
                    end
                })

                return Components.Frame({
                    Name = skill,
                    BackgroundTransparency = 0,
                    Size = fromScale(0.95, 0.224),

                    [Children] = {
                        Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 6.158 }),
                        Components.RoundUICorner(),
                        Components.UIStroke({
                            Thickness = 2.3,
                            Enabled = Computed(function(use)
                                return use(isSelecting)
                            end)
                        }),
                        Components.ImageLabel({
                            Name = "Icon",
                            Size = fromScale(1, 1),
                            SizeConstraint = Enum.SizeConstraint.RelativeYY,
                            Image = AssetBook.Items.ItemImages[skill],

                            [Children] = { Components.RoundUICorner() }
                        }),
                        Components.TextLabel({
                            Name = "Skill",
                            AnchorPoint = v2New(0, 0.5),
                            Position = fromScale(0.228, 0.5),
                            Size = fromScale(0.712, 0.6),
                            Text = Computed(function()
                                return AssetBook.Items.ItemName[skill]
                            end),
                            TextXAlignment = Enum.TextXAlignment.Left
                        }),

                        Components.HoverImageButton({
                            [OnEvent("MouseEnter")] = function()
                                isSelecting:set(true)
                            end,
                            [OnEvent("MouseLeave")] = function()
                                isSelecting:set(false)
                            end,
                            [OnEvent("MouseButton1Click")] = function()
                                if self.actionClickCD then return end

                                self.actionClickCD = true
                                self.panelPos:set(fromScale(0.5, 5))
                                self.transHPBarSize:set(fromScale(0, 0.875))

                                Events.NextActionRequest:Fire("Items", skill)

                                wait(1)
                                self.actionClickCD = false
                            end
                        })
                    }
                })
            end, Fusion.cleanup)
        }
    })
end

return TurnBaseSkillPanel
