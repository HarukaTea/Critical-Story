--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Fusion = require(RepS.Modules.Packages.Fusion)

local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local tFind = table.find
local clamp = math.clamp

local function BottomProgressBar(id: string, self: table) : Frame
    local whiteList = { "EXP", "PlayerPhase" }

    return Fusion.New("Frame")({
        Name = id.."Bar",
        BackgroundColor3 = fromRGB(30, 30, 30),
        Position = fromScale(0, 0.8),
        Size = fromScale(1, 0.1),
        ZIndex = 2,

        Visible = Fusion.Computed(function(use)
            if id == "EXP" then
                return true

            elseif id == "MonsterPhase" then
                return use(self.phase)
            end
        end),

        [Fusion.Children] = {
            Fusion.New("Frame")({
                Name = "Bar",
                BackgroundTransparency = 0.4,
                BackgroundColor3 = if tFind(whiteList, id) then fromRGB(217, 193, 144) else fromRGB(255, 255, 255),

                Size = Fusion.Tween(Fusion.Computed(function(use)
                    if id == "EXP" then
                        local x = clamp(use(self.playerData.EXP[1]) / use(self.playerData.EXP[2]), 0, 1)

                        return fromScale(x, 1)
                    else
                        return use(self.phaseBarProgress)
                    end
                end), if self.phaseBarTweenInfo then self.phaseBarTweenInfo else AssetBook.TweenInfos.halfBack)
            })
        }
    })
end

return BottomProgressBar
