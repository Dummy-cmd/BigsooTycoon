local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Util.Signal)
local Maid = require(Knit.Util.Maid)
local Concur = require(Knit.Util.Concur)
local OnMessageSignaled = require(script.Parent.Parent.Parent.Client_Refs.Utils.TopBarPlus_framework.OnMessageSignaled)

local reward = {
    _isFinisedSignal = Signal.new()
}

local function TransformServerTimeToRealTime(timeDiff)
	local hours = math.floor(timeDiff / 60 / 60)
	local minutes = math.floor(timeDiff / 60) % 60
	local seconds = math.floor(timeDiff % 60)	
	if minutes < 10 then
		minutes = "0" .. minutes
	end
	if seconds < 10 then
		seconds = "0" .. seconds
	end
	return hours .. ":" .. minutes .. ":" .. seconds 
end

function reward:Construct(frame,info)
    if (frame) then
        self._info = info
        --delete concur object signal
        self._isFinisedSignal:Connect(function()
            if (self._concur) then
                self._concur = nil
            end
        end)
        return createBinding(self,frame)
    end
end

function createBinding(self,frame)
    if (frame) then
        if (self._info) then
            local DailyCoutainer = frame.main.DailyCoutainer
            local RewardsService = Knit.GetService("RewardsService")
            if (DailyCoutainer) then
                local findButtonFromCurrentDay = nil
                local updatedCooldown = 0
                if (self._info.data) then
                    local check = self._info.data.day or false
                    if (self._info.data.lastTime) and (check) then
						updatedCooldown = self._info.data.lastTime
						if (self._info.data.day > 4) then
							self._info.data.day = 1
						end
                        DailyCoutainer:FindFirstChild("Button1").Image = "rbxassetid://17442462748"
                        DailyCoutainer:FindFirstChild("Button"..self._info.data.day).Image = "rbxassetid://17442463565"
                        if not self._concur then
                            self._concur = Concur.spawn(function()
                                while task.wait(1) do
                                    local TimeText = TransformServerTimeToRealTime(RewardsService:ConvertTime(updatedCooldown))
                                    DailyCoutainer.ImageLabel.TextLabel.Text = TimeText
                                    local isFinished = RewardsService:VerifyCooldown(updatedCooldown)
                                    if isFinished then
                                        break
                                    end
                                end
                                DailyCoutainer.ImageLabel.TextLabel.Text = "Claim rewards !"
                                self._isFinisedSignal:Fire()
                            end)
                        end
                    end
                end
                local CloseButton = bind(self,DailyCoutainer.ImageButton,function()
                    changeBlurSize(0)
                    TweenPlayerFOV(70)
                    TweenService:Create(DailyCoutainer.Parent.UIScale,TweenInfo.new(0.2),{Scale = 0}):Play()
                end)
                if not self._info.data.day then
                    findButtonFromCurrentDay = bind(self,DailyCoutainer:FindFirstChild("Button1"),function()
                        local cooldownIsUpperThan24Hours = RewardsService:VerifyCooldown(updatedCooldown)
                        if (cooldownIsUpperThan24Hours == true) then
                            DailyCoutainer:FindFirstChild("Button1").Image = "rbxassetid://17442462748"
                            unbind(self,DailyCoutainer:FindFirstChild("Button1"))
                            RewardsService:ApplyChangeToDataStore({day = 1})
                            updatedCooldown = RewardsService:GetStore().lastTime

                            if not self._concur then
                                self._concur = Concur.spawn(function()
                                    while task.wait(1) do
                                        local TimeText = TransformServerTimeToRealTime(RewardsService:ConvertTime(updatedCooldown))
                                        DailyCoutainer.ImageLabel.TextLabel.Text = TimeText
                                        local isFinished = RewardsService:VerifyCooldown(updatedCooldown)
                                        if isFinished then
                                            break
                                        end   
                                    end
                                    DailyCoutainer.ImageLabel.TextLabel.Text = "Claim rewards !"
                                    self._isFinisedSignal:Fire()
                                end)
                            else
                                self._isFinisedSignal:Fire()
                                self._concur = Concur.spawn(function()
                                    while task.wait(1) do
                                        local TimeText = TransformServerTimeToRealTime(RewardsService:ConvertTime(workspace:GetServerTimeNow()))
                                        DailyCoutainer.ImageLabel.TextLabel.Text = TimeText
                                        local isFinished = RewardsService:VerifyCooldown(updatedCooldown)
                                        if isFinished then
                                            break
                                        end        
                                    end
                                    DailyCoutainer.ImageLabel.TextLabel.Text = "Claim rewards !"
                                end)
                            end 
                            DailyCoutainer:FindFirstChild("Button"..RewardsService:GetStore().day).Image = "rbxassetid://17442463565"
                            bind(self,DailyCoutainer:FindFirstChild("Button"..RewardsService:GetStore().day),function()
                                local isFinished = RewardsService:VerifyCooldown(updatedCooldown)
                                if isFinished then
                                    OnMessageSignaled("Please rejoin before claiming your new reward",Color3.fromRGB(255, 129, 129),Color3.new(0,0,0),"Warning")
                                else
                                    OnMessageSignaled("Please wait "..TransformServerTimeToRealTime(RewardsService:ConvertTime(updatedCooldown)).." until your next reward",Color3.fromRGB(255, 129, 129),Color3.new(0,0,0),"Warning")
                                end
                            end)
                        else
                            OnMessageSignaled("Please wait "..TransformServerTimeToRealTime(RewardsService:ConvertTime(updatedCooldown)).." until your next reward",Color3.fromRGB(255, 129, 129),Color3.new(0,0,0),"Warning")
                        end
                    end)
                else
                    findButtonFromCurrentDay = bind(self,DailyCoutainer:FindFirstChild("Button"..self._info.data.day),function()
                        local cooldownIsUpperThan24Hours = RewardsService:VerifyCooldown(updatedCooldown)
                        if (cooldownIsUpperThan24Hours == true) then
                            DailyCoutainer:FindFirstChild("Button"..self._info.data.day).Image = "rbxassetid://17442462748"
                            unbind(self,DailyCoutainer:FindFirstChild("Button"..self._info.data.day))
                            RewardsService:ApplyChangeToDataStore({day = RewardsService:GetStore().day })
                            updatedCooldown = RewardsService:GetStore().lastTime
                            if not self._concur then
                                self._concur = Concur.spawn(function()
                                    while task.wait(1) do
                                        local TimeText = TransformServerTimeToRealTime(RewardsService:ConvertTime(updatedCooldown))
                                        DailyCoutainer.ImageLabel.TextLabel.Text = TimeText
                                        local isFinished = RewardsService:VerifyCooldown(updatedCooldown)
                                        if isFinished then
                                            break
                                        end   
                                    end
                                    DailyCoutainer.ImageLabel.TextLabel.Text = "Claim rewards !"
                                    self._isFinisedSignal:Fire()
                                end)
                            else
                                self._isFinisedSignal:Fire()
                                self._concur = Concur.spawn(function()
                                    while task.wait(1) do
                                        local TimeText = TransformServerTimeToRealTime(RewardsService:ConvertTime(workspace:GetServerTimeNow()))
                                        DailyCoutainer.ImageLabel.TextLabel.Text = TimeText
                                        local isFinished = RewardsService:VerifyCooldown(updatedCooldown)
                                        if isFinished then
                                            break
                                        end      
                                    end
                                    DailyCoutainer.ImageLabel.TextLabel.Text = "Claim rewards !"
                                end)
                            end
                            DailyCoutainer:FindFirstChild("Button"..RewardsService:GetStore().day).Image = "rbxassetid://17442463565"
                            bind(self,DailyCoutainer:FindFirstChild("Button"..RewardsService:GetStore().day),function()
                                local isFinished = RewardsService:VerifyCooldown(updatedCooldown)
                                if isFinished then
                                    OnMessageSignaled("Please rejoin before claiming your new reward",Color3.fromRGB(255, 129, 129),Color3.new(0,0,0),"Warning")
                                else
                                    OnMessageSignaled("Please wait "..TransformServerTimeToRealTime(RewardsService:ConvertTime(updatedCooldown)).." until your next reward",Color3.fromRGB(255, 129, 129),Color3.new(0,0,0),"Warning")
                                end     
                            end)
                        else
                            OnMessageSignaled("Please wait "..TransformServerTimeToRealTime(RewardsService:ConvertTime(updatedCooldown)).." until your next reward",Color3.fromRGB(255, 129, 129),Color3.new(0,0,0),"Warning")
                        end
                    end)
                end
                RewardsService.ClaimedRewardsSignal:Connect(function(message)
                    OnMessageSignaled(message,Color3.fromRGB(189, 150, 255),Color3.new(0,0,0),"Succes")
                end)
            end
        end
    end

    return self
end

function changeBlurSize(newSize)
    TweenService:Create(Lighting.Blur,TweenInfo.new(0.2),{Size = newSize}):Play()
end

function TweenPlayerFOV(newFOV)
    local camera = workspace.CurrentCamera
    TweenService:Create(camera,TweenInfo.new(0.2),{FieldOfView = newFOV}):Play()
end

function bind(self,frame,fn)
    --bind connection from the current frame gived
    if not self._bind then
        self._bind = {}
    end
    if (frame) then
        if self._bind[frame.Name] then
            return frame
        else
            self._bind[frame.Name] = Maid.new()
            self._bind[frame.Name]:giveTask(frame.MouseEnter:Connect(function()
                SoundService:PlayLocalSound(SoundService.Mouse_hover)  
                TweenService:Create(frame.UIScale,TweenInfo.new(0.2),{Scale = 0.9}):Play()
            end))
            self._bind[frame.Name]:giveTask(frame.MouseLeave:Connect(function()
                TweenService:Create(frame.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
            end))
            if (frame.Activated) then
                self._bind[frame.Name]:giveTask(frame.Activated:Connect(function()
                    SoundService:PlayLocalSound(SoundService.Click)
                    if (fn) then
                        fn()
                    end
                end))
            end
        end
        return frame
    end

    return false
end

function unbind(self,frame)
    if self._bind then
        if self._bind[frame.Name] then
            self._bind[frame.Name]:doCleaning()
            self._bind[frame.Name] = nil
            TweenService:Create(frame.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
            return true
        end
    end
    return false
end

return reward
