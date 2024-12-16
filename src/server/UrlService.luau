local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Util.Signal)

local Knit = require(ReplicatedStorage.Packages.Knit)
local Web = require(ReplicatedStorage.Packages.WebhookServices)
local FormatEditor = Web.FormatEditor
local Mention = Web.Mention

local SetupedHook = Web.Setup({
    "https://discord.com/api/webhooks/[I NOT SHOW THE TOKEN]"
})
SetupedHook:SetErrorPrinting(true)


local UrlService = Knit.CreateService {
    Name = "UrlService",
    Client = {},
}

function UrlService:KnitStart()
    print(self.Name," started")
end


function UrlService:KnitInit()
    print(self.Name," initilaze")
end


function UrlService:SendDiscordReportMessage(player,_message)
    if _message then
        local ConvertMessage = SetupedHook.CreateMessage()
        local TextMessage = ConvertMessage:AttachMessage(player.Name.."create a report.")
        local Embed = ConvertMessage:AttachEmbed({
            Settings = {
                Color = Web.ColorConverter(Color3.fromRGB(224, 137, 255))
            },
            Embed = {
                Title = FormatEditor.Bold(player.Name .. "Message"),
                Description = FormatEditor.Bold(_message.UserId),
                Fields = {
                    {name = "Message",
                    value = _message.message,
                    inline = true},
                },
                Thumbnail = Web.SupportedThumbnailAsync(player.UserId,Web.ThumbnailType.Bustshot,Web.ThumbnailSize.Size60x60)
            },
        })
        ConvertMessage:Send()
        return true
    else
        return false
    end
end

function UrlService.Client:SignalReportMessage(player,message)
    return self.Server:SendDiscordReportMessage(player,message)
end

return UrlService
