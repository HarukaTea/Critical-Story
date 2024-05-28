--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local AssetBook = require(ReplicatedStorage.Modules.Data.AssetBook)

local function _onIncomingMessage(message: TextChatMessage): TextChatMessageProperties
	local properties = Instance.new("TextChatMessageProperties")

    if message.TextSource then
        --// Player message
        local plr = Players:GetPlayerByUserId(message.TextSource.UserId)
        if not plr:IsDescendantOf(Players) then return properties end

        properties.PrefixText = string.format("%s", message.PrefixText)

        if plr:GetAttribute("Role") then
            local role = plr:GetAttribute("Role") :: string
            local roleInfo: table?

            for _, roleinfo: table in AssetBook.RankRoleInfo do
                if roleinfo.Role == role then roleInfo = roleinfo break end
            end
            for _, roleinfo: table in AssetBook.CustomRoleInfo do
                if roleinfo.Role == role then roleInfo = roleinfo break end
            end

            properties.PrefixText = string.format(
                "<font color='#%s'><b>[%s]</b></font> %s",
                roleInfo.Color,
                string.upper(roleInfo.ChatRole),
                properties.PrefixText)
        end
    else
        --// System message
        properties.PrefixText = string.format(
            "<font color='#%s'><b>%s</b></font>",
            Color3.new(255, 255, 0):ToHex(),
            "[WORLD]"
        )

        properties.Text = string.format(
            "<font color='#%s'>%s</font>",
            Color3.new(1, 1, 1):ToHex(),
            message.Text
        )
    end

    return properties
end
TextChatService.OnIncomingMessage = _onIncomingMessage

