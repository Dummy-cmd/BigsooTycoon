local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local InstanceFolder = ReplicatedStorage.Packages.Lib.Instance
 
local Trove = require(ReplicatedStorage.Packages.Trove)
local Promise = require(ReplicatedStorage.Packages.Promise)

local module = {}
module.__index = module

function module.create(parent)
    if not parent then
        return Promise.reject("Failed to get parent from the @parent arg")
    end
    local billboardsGuis = {}    
    for i,gui in InstanceFolder:GetChildren() do
        if gui:IsA("BillboardGui") then
            table.insert(billboardsGuis,gui)
        end
    end
    local self = setmetatable({trove = Trove.new()},module)
    self.trove:Add(function()
        if self.element then
            self.element:Destroy()
        end
        table.clear(self)
        self = nil
    end)
    self.element = billboardsGuis[Random.new():NextInteger(1,#billboardsGuis)]:Clone()
    self.element.Frame.ImageLabel.Size = UDim2.fromScale(1,0.85)
    self.element.Parent = parent
    return self
end

function module:ChangeAndReform(parent,name)
    if not parent or not name then
        return false
    end
    if self.element then
        self.element:Destroy()
        self.element = nil
        self.element = InstanceFolder:FindFirstChild(name):Clone()
        self.element.Parent = parent
        self.element.Frame.ImageLabel.Size = UDim2.fromScale(1,0.65)
        self.element.Frame.ImageLabel.Image = self.element.DefaultImage.Value
        self.element.Frame.ImageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
    end
    return self.element
end

function module:Get()
    if self.element then
        return self.element
    end
end

function module:Destroy()
    if self.trove then
        self.trove:Destroy()
    end
end

return module
