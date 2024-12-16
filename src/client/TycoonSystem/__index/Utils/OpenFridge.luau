local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(Knit.Util.Signal)

local module = {}
module.__index = module

function module.open(topping)
    --[=[
        Create a open class for the fridge
    ]=]
    local self = setmetatable({
        trove = Trove.new(),
        maid = Maid.new(),
        FinishedSignal = Signal.new(),
        selectioned = false,
    },module)
    local playerGui = Players.LocalPlayer.PlayerGui
    local playerScripts = Players.LocalPlayer.PlayerScripts
    local Toppings = playerGui:WaitForChild("Toppings")
    local ScrollingFrame = Toppings.Global.ToppingsCoutainer.ScrollingFrame
    local Close = Toppings.Global.ToppingsCoutainer.ImageButton
    local SplitToppingType = string.split(topping," ")[1]
    local frame = nil
    for i,v in ScrollingFrame:GetChildren() do
        if v.Name == topping then
            frame = v
            break
        elseif string.find(v.Name,SplitToppingType) then
            frame = v
            break
        end
    end
    if not frame then
        return Promise.reject("Failed to get a frame with the correspond topping name")        
    end
    frame.ImageButton.ImageColor3 = Color3.fromRGB(0,170,255)
    frame.ImageButton.TextLabel.TextColor3 = Color3.fromRGB(255,255,255) 
    TweenService:Create(Toppings.Global.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
    self:AutobindCorrespond(frame)
    self.maid:giveTask(Close.MouseEnter:Connect(function()
        SoundService:PlayLocalSound(SoundService.Mouse_hover)
        TweenService:Create(Close.UIScale,TweenInfo.new(0.2),{Scale = 0.9}):Play()
    end))
    self.maid:giveTask(Close.MouseLeave:Connect(function()
        SoundService:PlayLocalSound(SoundService.Mouse_hover)
        TweenService:Create(Close.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
    end))
    self.maid:giveTask(Close.Activated:Connect(function()
        TweenService:Create(Toppings.Global.UIScale,TweenInfo.new(0.2),{Scale = 0}):Play()
        if self.selectioned == true then
            frame.ImageButton.ImageColor3 = Color3.fromRGB(255,255,255)
            frame.ImageButton.TextLabel.TextColor3 = Color3.fromRGB(0,0,0) 
            self.FinishedSignal:Fire()
            self:Destroy()
        end
    end))
    self.trove:Add(function()
        self:Clean()
    end)
    return self
end

function module:OpenUi()
    local playerGui = Players.LocalPlayer.PlayerGui
    local playerScripts = Players.LocalPlayer.PlayerScripts
    local Toppings = playerGui:WaitForChild("Toppings")
    local ScrollingFrame = Toppings.Global.ToppingsCoutainer.ScrollingFrame
    TweenService:Create(Toppings.Global.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
end

function module:AutobindCorrespond(frame)
    if self.maid then
        if not frame then
            return
        end
        self.maid:giveTask(frame.MouseEnter:Connect(function()
            SoundService:PlayLocalSound(SoundService.Mouse_hover)
            TweenService:Create(frame.UIScale,TweenInfo.new(0.2),{Scale = 0.9}):Play()
        end))
        self.maid:giveTask(frame.MouseLeave:Connect(function()
            SoundService:PlayLocalSound(SoundService.Mouse_hover)
            TweenService:Create(frame.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
        end))
        self.maid:giveTask(frame.ImageButton.Activated:Once(function()
            SoundService:PlayLocalSound(SoundService.Click)
            if self.selectioned == false then
                TweenService:Create(frame.ImageButton,TweenInfo.new(0.2),{ImageColor3 = Color3.fromRGB(176, 207, 135)}):Play()
                self.selectioned = true
            end
        end))
    end
end

function module:Destroy()
    if self.trove then
        self.trove:Destroy()
    end
    table.clear(self)
    self = nil
end

function module:Clean()
    if self.maid then
        self.maid:clean()
    end
end

return module
