--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)

local Children, Computed = Fusion.Children, Fusion.Computed

local fromScale = UDim2.fromScale

local function TalentMaterialSlot(index: number, material: table, scope: Fusion.Scope) : Frame
    local isSelecting = Fusion.Value(scope, false)

    return Components.Frame(scope, {
        Name = material.Id,
        Size = fromScale(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        BackgroundTransparency = 0,
        LayoutOrder = index,

        [Children] = {
            Components.RoundUICorner(scope),
            Components.UIStroke(scope, {
                Thickness = 3,
                Enabled = true,

                Transparency = Fusion.Tween(scope, Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting) then 0.3 else 1
                end), AssetBook.TweenInfos.twiceHalf)
            }),

            Components.HoverImageButton(scope, {
                Image = if ItemBook:IsItemExist(material.Id) then
                    ClientUtil:CombineRbxId(ItemBook:FindItem(material.Id).Icon) else ItemBook.ItemImagesEx.Unknown,

                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,

                [Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "Amount",
                Position = fromScale(0, 0.65),
                Size = fromScale(1, 0.3),
                TextXAlignment = Enum.TextXAlignment.Right,
                Text = "x"..material.Amount,

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 3 })
                }
            })
        }
    })
end

return TalentMaterialSlot
