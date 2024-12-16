local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Value = Fusion.Value
local Observer = Fusion.Observer
local Knit = require(ReplicatedStorage.Packages.Knit)
local OnMessageSignaled = require(script.Parent.Parent.Client_Refs.Utils.TopBarPlus_framework.OnMessageSignaled)

local shouldBuildBoolean = true
local db = false
local maid = Maid.new()

local function _m(frame)
    if (frame) then
        maid:giveTask(frame.MouseEnter:Connect(function()
            SoundService:PlayLocalSound(SoundService.Mouse_hover)
            TweenService:Create(frame.UIScale,TweenInfo.new(.25),{Scale = 0.9}):Play()
        end))

        maid:giveTask(frame.MouseLeave:Connect(function()
            TweenService:Create(frame.UIScale,TweenInfo.new(.25),{Scale = 1}):Play()
        end))
    end
end

return {
    imageId = "rbxassetid://4458873815",
    label = "Report",
    caption = "Open report menu",
    align = "Right",
    _callback = function()
        local player = Players.LocalPlayer
        local playerGui = player.PlayerGui or player:WaitForChild("PlayerGui")
        local bg,reportFrame = playerGui:WaitForChild("ReportMenu"):WaitForChild("bg"),playerGui:WaitForChild("ReportMenu"):WaitForChild("ReportFrame")
        local webhook = Knit.GetService("UrlService")

        if (bg) and (reportFrame) then
            if not (maid) then
                maid = Maid.new()
            end

            _m(reportFrame.SendFrame)
            _m(reportFrame.ImageButton)

            maid:giveTask(reportFrame.ImageButton.Activated:Connect(function()
                SoundService:PlayLocalSound(SoundService.Click)
                TweenService:Create(bg,TweenInfo.new(.25),{BackgroundTransparency = 1}):Play()
                TweenService:Create(reportFrame.UIScale,TweenInfo.new(.25),{Scale = 0}):Play()
                shouldBuildBoolean = true
                if (maid) then
                    maid:doCleaning()
                    maid = nil
                end
            end))

            maid:giveTask(reportFrame.SendFrame.TextButton.Activated:Connect(function()
                SoundService:PlayLocalSound(SoundService.Click)
                if not db then
                    if string.len(reportFrame.TextCoutainerFrame.TextBox.Text) < 5 then
                        return OnMessageSignaled("5 caracters minimum",Color3.fromRGB(210,0,0),Color3.new(0,0,0),"Warning")
                    end

                    webhook:SignalReportMessage({
                        ["UserId"] = player.UserId,
                        ["message"] = reportFrame.TextCoutainerFrame.TextBox.Text
                    })
                    db = true
                    
                    OnMessageSignaled("Message received , you will receive a feedback soon ",Color3.fromRGB(65,210,0),Color3.new(0,0,0),"Succes")
                    reportFrame.TextCoutainerFrame.TextBox.Text = ""
                    task.delay(20,function()
                        db = false
                    end)
                else
                    return OnMessageSignaled("Cooldown enable please wait 20 seconds to send a new report",Color3.fromRGB(210,0,0),Color3.new(0,0,0),"Warning")
                end
            end))

            if shouldBuildBoolean == false  or not shouldBuildBoolean then
                TweenService:Create(bg,TweenInfo.new(.25),{BackgroundTransparency = 1}):Play()
                TweenService:Create(reportFrame.UIScale,TweenInfo.new(.25),{Scale = 0}):Play()
                shouldBuildBoolean = true
                if (maid) then
                    maid:doCleaning()
                    maid = nil
                end
            elseif shouldBuildBoolean == true then
                TweenService:Create(bg,TweenInfo.new(.25),{BackgroundTransparency = 0.4}):Play()
                TweenService:Create(reportFrame.UIScale,TweenInfo.new(.25),{Scale = 1}):Play()
                shouldBuildBoolean = false

                if not (maid) then
                    maid = Maid.new()
                    _m(reportFrame.SendFrame)
                    _m(reportFrame.ImageButton)
        
                    maid:giveTask(reportFrame.ImageButton.Activated:Connect(function()
                        TweenService:Create(bg,TweenInfo.new(.25),{BackgroundTransparency = 1}):Play()
                        TweenService:Create(reportFrame.UIScale,TweenInfo.new(.25),{Scale = 0}):Play()
                        shouldBuildBoolean = true
                        if (maid) then
                            maid:doCleaning()
                            maid = nil
                        end
                    end))

                    maid:giveTask(reportFrame.SendFrame.TextButton.Activated:Connect(function()
                        SoundService:PlayLocalSound(SoundService.Click)
                    end))
                end    

            end
        end
    end,
}  
