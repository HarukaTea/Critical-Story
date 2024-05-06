--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local color = script:GetAttribute("Color") :: Color3
local text = script:GetAttribute("Text") :: string
local power = script:GetAttribute("Power") :: number

ServerUtil:ShowText(char, text, color)

HarukaLib:Add(char, "Defense", power)

HarukaLib:Hydrate(script, {
    ["Attr-Turn"] = function(newTurn: number)
        if newTurn <= 0 then
            HarukaLib:Add(char, "Defense", -power)

            script:Destroy()
        end
    end
})
