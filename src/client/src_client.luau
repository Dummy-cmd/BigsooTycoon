--[[
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local function OnIncomingMessage(message)
    if not message.TextSource then
        return
    end
    local properties = Instance.new("TextChatMessageProperties")
    local player = Players:GetPlayerByUserId(message.TextSource.UserId)
    local hasVip = player:GetAttribute("IsVip")
    local getPlayerRank = player:GetRoleInGroup(33939812)
    local htmlPrefix = ""
    if hasVip then
        if getPlayerRank == "༊ | Developer" then
            htmlPrefix = `<font color= "{"#10ffff"}">[DEVELOPER] </font><font color= "{"#ffdc00"}">[VIP] </font>{message.PrefixText}`
        elseif getPlayerRank == "ꤠ | Owner" then
            htmlPrefix = `<font color= "{"##9000ff"}">[OWNER] </font><font color= "{"#ffdc00"}">[VIP] </font>{message.PrefixText}`
        elseif getPlayerRank == "♱ | Admin" then
            htmlPrefix = `<font color= "{"##ff5070"}">[ADMIN]  </font><font color= "{"#ffdc00"}">[VIP] </font>{message.PrefixText}`
        else
            htmlPrefix = `<font color= "{"#ff8000"}">  [VIP]  </font>{message.PrefixText}`
        end
    else
        if getPlayerRank == "༊ | Developer" then
            htmlPrefix = `<font color= "{"#10ffff"}">[DEVELOPER] </font>{message.PrefixText}`
        elseif getPlayerRank == "ꤠ | Owner" then
            htmlPrefix = `<font color= "{"##9000ff"}">[OWNER] </font>{message.PrefixText}`
        elseif getPlayerRank == "♱ | Admin" then
            htmlPrefix = `<font color= "{"##ff5070"}">[ADMIN] </font>{message.PrefixText}`
        else
            htmlPrefix = `{message.PrefixText}`
        end
    end
    properties.PrefixText = htmlPrefix
    return properties
end

TextChatService.OnIncomingMessage = OnIncomingMessage
