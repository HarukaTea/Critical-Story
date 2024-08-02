--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ClassBook = require(RepS.Modules.Data.ClassBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Children, Computed = Fusion.Children, Fusion.Computed

local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function ClassesRightPanel(self: table) : Frame
    local scope = self.scope :: Fusion.Scope

    return Fusion.New(scope, "Frame")({
        Name = "ClassList",
        BackgroundTransparency = 1,
        Size = fromScale(1, 0.15),

        [Children] = {
            Fusion.New(scope, "UIGridLayout")({
                CellPadding = fromScale(0.04, 0.1),
                CellSize = fromScale(0.135, 0.9),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),

            Fusion.ForPairs(scope, ClassBook.ClassInfo, function(_, localScope: Fusion.Scope, class: string, info: table)
                local isSelecting = Fusion.Value(localScope, false)
                local clickCD = false

                return class, Components.Frame(localScope, {
                    Name = class,
                    BackgroundColor3 = fromRGB(),
                    BackgroundTransparency = 0,
                    LayoutOrder = info.Order,

                    [Children] = {
                        Components.RoundUICorner(scope),
                        Components.UIStroke(scope, {
                            Thickness = 3,
                            Enabled = true,

                            Transparency = Fusion.Tween(localScope, Computed(localScope, function(use: Fusion.Use)
                                if use(self.playerData.Class) == class then
                                    return 0.3
                                else
                                    return if use(isSelecting) then 0.3 else 1
                                end
                            end), AssetBook.TweenInfos.twiceHalf),
                        }),
                        Components.HoverImageButton(scope, {
                            Image = Computed(localScope, function(use: Fusion.Use)
                                if use(self.playerData.ClassUnlocks[class]) then
                                    return info.Image
                                else
                                    return ItemBook.ItemImagesEx.ClassLock
                                end
                            end),

                            [Fusion.OnEvent("MouseEnter")] = function()
                                isSelecting:set(true)
                            end,
                            [Fusion.OnEvent("MouseLeave")] = function()
                                isSelecting:set(false)
                            end,
                            [Fusion.OnEvent("MouseButton1Click")] = function()
                                if clickCD then return end

                                clickCD = true
                                Spawn(function()
                                    task.wait(0.15)
                                    clickCD = false
                                end)

                                if self.plr:GetAttribute("CLASS_UNLOCK_"..class) then
                                    self.classInfoDesc:set(info.Desc)

                                    if self.plr:GetAttribute("Class") == class then return end
                                    Events.ChangePlayerClass.Fire({ ClassId = class })

                                    workspace.Sounds.SFXs.Equip:Play()
                                else
                                    self.classInfoDesc:set("LOCKED")
                                end
                            end
                        })
                    }
                })
            end)
        }
    })
end

return ClassesRightPanel
