local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local module = {}

function module:_send(text)
    --create the message here
    local player = Players.LocalPlayer
    local playerGui = player.PlayerGui
    local AnimationController = playerGui:WaitForChild("AnimationController")
    local Countainer = AnimationController:FindFirstChild("Coutainer")
    if not Countainer then
        return warn("Message not created cause the Countainer is null")
    end
    local textLabel = ReplicatedStorage.Packages.Lib.Instance.TextLabel:Clone()
    textLabel.Text = text
    textLabel.Parent = Countainer
    TweenService:Create(textLabel.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
    SoundService:PlayLocalSound(SoundService.Notification)
    task.delay(3,function()
        local OnCompleted = TweenService:Create(textLabel.UIScale,TweenInfo.new(0.2),{Scale = 0})
        TweenService:Create(textLabel,TweenInfo.new(0.2),{TextTransparency = 1})
        OnCompleted:Play()
        OnCompleted.Completed:Wait()
        textLabel:Destroy()
    end)
    return textLabel
end 

function module:Send(text)
    --[=[
        send a message to the client with the given text
    ]=]
    if not text then
        return self:_send("failed")
    end
    if type(text) ~= "string" then
        return self:_send("text type is not a string")
    end
    return self:_send(text)
end 

return module
