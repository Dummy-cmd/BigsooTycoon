local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")


local FormatNumberAlt = require(ReplicatedStorage.Packages.FormatNumberAlt)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Concur = require(ReplicatedStorage.Packages.Concur)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local PlayerModule = require(Players.LocalPlayer.PlayerScripts.PlayerModule):GetControls()
local Icon = require(ReplicatedStorage.Packages.Icon)
local OnMessageSignaled = require(script.Parent.Parent.Parent.Client_Refs.Utils.TopBarPlus_framework.OnMessageSignaled)

local LoadingFunctions = {}
LoadingFunctions.__index = LoadingFunctions

-- this function is for change the global frame properties
local function callback(frame,changeSize)
    if (frame) then
        if (changeSize) then
            if changeSize.added == false then
                -- do not change the current size
            else
                frame.Size = changeSize.newSize
            end
        end
        if (frame.ClassName == "Frame") then
            frame.BackgroundTransparency = 1
        end
    end
end

local function modifyProperties(frame,t)
    if (frame) and not (t) then
        if string.match(frame.ClassName,"Label") then
            frame.TextTransparency = 1
            if frame:FindFirstChildOfClass("UIStroke") then
                frame.UIStroke.Transparency = 1
            end
        end
        frame.Position = frame.Position - UDim2.fromScale(-0.1,0)
    elseif (frame) and (t) then
        callback(frame,t)
    end
end

function LoadingFunctions:AppearLoading(frame)
   if (frame) then
        Icon.setTopbarEnabled(false)
        modifyProperties(frame.LoadingLabel)
        modifyProperties(frame.AssetLoadedLabel)
        modifyProperties(frame,{added = false})
        modifyProperties(frame.Bar,{added = true,newSize = (frame.Bar.Size - frame.Bar.Size)})
        TweenService:Create(frame.LoadingImage,TweenInfo.new(0.2),{
            ImageTransparency = 0
        }):Play()
        TweenService:Create(frame,TweenInfo.new(0.2),{
                BackgroundTransparency = 0.2
        }):Play()
        TweenService:Create(frame.Bar,TweenInfo.new(0.2),{
            Size = UDim2.fromScale(0.3,0.085),
            BackgroundTransparency = 0.15,
            BackgroundColor3 = Color3.fromRGB(15,15,15),
        }):Play()
        if (frame.LoadingLabel:FindFirstChildOfClass("UIStroke")) then
            TweenService:Create(frame.LoadingLabel:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{
                Transparency = 0
            }):Play()
        end
        if (frame.AssetLoadedLabel:FindFirstChildOfClass("UIStroke")) then
            TweenService:Create(frame.AssetLoadedLabel:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{
                Transparency = 0
            }):Play()
        end
        TweenService:Create(frame.AssetLoadedLabel,TweenInfo.new(0.2),{
             TextTransparency  = 0,
             Position = UDim2.fromScale(0.5,0.6)
        }):Play()
        TweenService:Create(frame.LoadingLabel,TweenInfo.new(0.2),{
            TextTransparency = 0,
            Position = UDim2.fromScale(0.165,0.95),
        }):Play()
   end
end

function LoadingFunctions:CreateSkip(frame)
    if (frame) then
        local SkipFrame = frame.SkipFrame
        if (SkipFrame) then
            if self._skip then return  end
            self._skip = Maid.new()
            self._skip:giveTask(SkipFrame.MouseEnter:Connect(function()
                SoundService:PlayLocalSound(SoundService.Mouse_hover)
                TweenService:Create(SkipFrame.UIScale,TweenInfo.new(0.2),{Scale = 0.9}):Play()
            end))
            self._skip:giveTask(SkipFrame.MouseLeave:Connect(function()
                TweenService:Create(SkipFrame.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
            end))
        end
    end
end

function LoadingFunctions:DestroySkip()
    if self._skip then
        self._skip:doCleaning()
        self._skip = nil
    end
end

function LoadingFunctions:Clear(frame)
    if not frame then frame = Players.LocalPlayer.PlayerGui:WaitForChild("LoadingScreen"):WaitForChild("LoadingFrame") end
    if self._skip then
        self._skip:doCleaning()
        self._skip = nil
    end
    TweenService:Create(Lighting.Blur,TweenInfo.new(0.2),{
        Size = 0
    }):Play()
    TweenService:Create(frame.LoadingImage,TweenInfo.new(0.2),{
        ImageTransparency = 1
    }):Play()
    TweenService:Create(frame,TweenInfo.new(0.2),{
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(frame.Bar,TweenInfo.new(0.2),{
        Size = UDim2.fromScale(0,0),
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(frame.Bar.UIStroke,TweenInfo.new(0.2),{
        Transparency = 1,
    }):Play()
    if (frame.LoadingLabel:FindFirstChildOfClass("UIStroke")) then
        TweenService:Create(frame.LoadingLabel:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{
            Transparency = 1
        }):Play()
    end
    if (frame.AssetLoadedLabel:FindFirstChildOfClass("UIStroke")) then
        TweenService:Create(frame.AssetLoadedLabel:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{
            Transparency = 1
        }):Play()
    end
    TweenService:Create(frame.AssetLoadedLabel,TweenInfo.new(0.2),{
        TextTransparency  = 1,
        Position = UDim2.fromScale(0.4,0.6)
    }):Play()
    TweenService:Create(frame.LoadingLabel,TweenInfo.new(0.2),{
        TextTransparency = 1,
        Position = UDim2.fromScale(0,0.95),
    }):Play()
    TweenService:Create(frame.SkipFrame.UIScale,TweenInfo.new(0.2),{
        Scale = 0
    }):Play()
    PlayerModule:Enable()
    StarterGui:SetCore("ResetButtonCallback",true)
    Icon.setTopbarEnabled(true)
    for i,Screen in Players.LocalPlayer.PlayerGui:GetChildren() do
        if Screen:IsA("ScreenGui") then
            if Screen.Name == "LoadingScreen" then       
            else
                Screen.Enabled = true
            end
        end
    end
    local hud = Players.LocalPlayer.PlayerGui:WaitForChild("hud")
    local Children = hud:WaitForChild("Coutainer"):WaitForChild("Children")
    TweenService:Create(Children.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
    local RewardsService = Knit.GetService("RewardsService")
    if (RewardsService) then
        local isClaimed = RewardsService:IsGroupRewardClaimed()
        if isClaimed == false then
            local isInGroup = RewardsService:GroupReward()
            if isInGroup then
                OnMessageSignaled("You received 500$ because you joined the group !",Color3.fromRGB(153, 217, 252),Color3.new(0,0,0),"Succes")
            end
        end
    end
    task.delay(1,function()
        local InitLoadingController = Knit.GetController("LoadingController")
        if InitLoadingController then
            Roact.unmount(InitLoadingController.handleLoadingElement)
        end
    end)
end

function LoadingFunctions:StartLoading(frame)
    if (frame) then
        local gameAssets = game:GetDescendants()
        local loadTask 
        loadTask = Promise.new(function(resolve,reject,onCancel)
            PlayerModule:Disable()
            StarterGui:SetCore("ResetButtonCallback",false)
            local thread = Concur.spawn(function()
                for i = 1,#gameAssets / 2 do
                    local asset = gameAssets[i]
                    local percentage = math.round(i / (#gameAssets / 2) * 100)
                    ContentProvider:PreloadAsync({asset})
                    frame.AssetLoadedLabel.Text = "Loading assets: "..FormatNumberAlt.FormatCompact(i,2).."/"..FormatNumberAlt.FormatCompact(#gameAssets / 2,2)
                    TweenService:Create(frame.Bar.Coutainer,TweenInfo.new(0.2),{Size = UDim2.fromScale(percentage/100,1)}):Play()
                    if (i == #gameAssets) then
                    end
                    if i == 1000 then
                        frame.SkipFrame.Visible = true
                        TweenService:Create(frame.SkipFrame.UIScale,TweenInfo.new(0.2),{
                            Scale = 1
                        }):Play()
                        self:CreateSkip(frame)
                    end
                end
                loadTask:cancel()
            end)
            if (script.Parent.Parent.r_init:FindFirstChild("LoadingSkippedBindableFunction")) then
                local bindableFunction = script.Parent.Parent.r_init:FindFirstChild("LoadingSkippedBindableFunction")
                bindableFunction.OnInvoke = function(rbx)
                    loadTask:cancel()
                    bindableFunction:Destroy()
                end
            end
            onCancel(function()
                self:Clear(frame)
                if thread then
                    thread:Stop()
                    thread = nil
                end
                self:DestroySkip()
                if (script.Parent.Parent.r_init:FindFirstChild("LoadingSkippedBindableFunction")) then
                    script.Parent.Parent.r_init:FindFirstChild("LoadingSkippedBindableFunction"):Destroy()
                end
            end)
        end):catch(warn)
     end
end  

return LoadingFunctions
