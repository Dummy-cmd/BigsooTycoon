local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")


local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Util.Signal)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Flavors = ReplicatedStorage.Packages.Lib.Instance.Flavors
local Cups = Flavors.Parent.Cups

local module = {}
module.__index = module

function module.addToCharacterHand(character,typeName)
    --[=[
        create a tool (cups from the ServerStorage service using the cups model name <string.split(n," ")[1]> )
    ]=]
    if not character then
        return false
    end
    if not typeName then
        return false
    end
    local self = setmetatable({
        trove = Trove.new(),
    },module)
    self.trove:Add(function()
        if self.tool then
            StarterGui:SetCore("ResetButtonCallback",true)
            local enregisteredName = self.tool.Name
            Promise.delay(1):andThen(function()
                if character:FindFirstChild(enregisteredName) then
                    character:FindFirstChild(enregisteredName):Destroy()
                end
            end):catch(warn)
            if self.TrackId then
                self.TrackId:Stop()
                self.TrackId.Looped = false
                self.TrackId = nil
                self.animation:Destroy()
                self.animation = nil
            end
            self.tool:Destroy()
            table.clear(self)
            self = nil
        end
    end)
    for i,instance in Flavors:GetChildren() do
        if instance then
            if string.find(instance.Name,typeName) then
                self.tool = instance:Clone()
                break
            end
        end
    end
    if not self.tool then
        return false
    end
    StarterGui:SetCore("ResetButtonCallback",false)
    self.tool.Parent = character
    self.defaultParent = character
    local motor6D = Instance.new("Motor6D",self.tool)
    motor6D.Part0 = character:WaitForChild("RightHand")
    motor6D.Part1 = self.tool.PrimaryPart
    motor6D.C1 = CFrame.new(0,-1,0) * CFrame.fromOrientation(math.rad(90),math.rad(90),0)
    for i,part in self.tool:GetChildren() do
        if part then
            if part.Name ~= "Main" and part.Name ~= "Cup" then
                if part:IsA("BasePart") then
                    part.Transparency = 1
                end
            end
        end
    end
    self.animation = Instance.new("Animation",script)
    self.animation.Name = HttpService:GenerateGUID(false)
    self.animation.AnimationId = "http://www.roblox.com/asset/?id=507768375"
    self:PlayAnimation(character,self.animation)
    return self
end

function module:PlayAnimation(character,animation)
    if not character or not animation then
        return "failed"
    end
    if self.TrackId then return self.TrackId end
    self.TrackId = character:FindFirstChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(animation)
    self.TrackId.Priority = Enum.AnimationPriority.Action
    self.TrackId:Play()
    self.TrackId.Looped = true
    return self.TrackId
end

function module:GetTrack()
    if self.TrackId then
        return self.TrackId
    end
end

function module:ApplyChange(partName)
    if not partName then
        return false
    end
    if self:Get() then
        local tool = self:Get()
        for i,part in tool:GetChildren() do
            if string.find(part.Name,partName) then
                part.Transparency = 0
            end
        end
    end
end

function module:ChangeParent(parent)
    if self.tool then
        self.tool.Parent = parent
    end
end

function module:MoveToDefaultParent()
    if self.tool and self.defaultParent then
        self.tool.Parent = self.defaultParent
    end
end

function module:Get()
    if self.tool then
        return self.tool
    else
        return false
    end
end

function module:Destroy()
    if self.trove then
        self.trove:Destroy()
    end
end

return module
