--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = HarukaFrameworkClient.Fusion

local New, Computed, peek = Fusion.New, Fusion.Computed, Fusion.peek

local fromScale = UDim2.fromScale
local color3New = Color3.new

local STROKE_ENABLE = Fusion.Value(false)

local function ClassSlot(self: table) : Frame
    return New("Frame")({
        Name = "Class",
        BackgroundColor3 = color3New(),
        Position = fromScale(0.411, -0.275),
        Size = fromScale(0.17, 1.275),

        [Fusion.Children] = {
            Components.RoundUICorner(),
            Components.UIStroke({
                Thickness = 3,
                Enabled = Computed(function(use)
                    return use(STROKE_ENABLE)
                end)
            }),
            Components.HoverImageButton({
                Name = "Hover",
                Image = Computed(function(use)
                    return AssetBook.ClassInfo[use(self.charStatsDict.PlayerData.Class)].Image
                end),

                [Fusion.OnEvent("MouseEnter")] = function()
                    local classInfo = peek(self.classInfo)
                    local skillInfo = peek(self.skillInfo)
                    local class = peek(self.charStatsDict.PlayerData.Class)

                    STROKE_ENABLE:set(true)

                    classInfo.Title.Text = "<u>"..class.."</u>"
                    classInfo.Info.Text = AssetBook.ClassInfo[class].Desc
                    classInfo.Visible = true

                    skillInfo.Title.Text = "<u>"..AssetBook.ClassInfo[class].SkillName.."</u>"
                    skillInfo.Info.Text = AssetBook.ClassInfo[class].SkillDesc
                    skillInfo.Visible = true
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    peek(self.classInfo).Visible = false
                    peek(self.skillInfo).Visible = false

                    STROKE_ENABLE:set(false)
                end,
            })
        },
    })
end

return ClassSlot
