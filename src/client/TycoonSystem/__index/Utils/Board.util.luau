local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Message = require(ReplicatedStorage.Packages.Message)
local signal_message = require(script.Parent["Message.signal"])

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Maid = require(ReplicatedStorage.Packages.Maid)

local module = {}
module.__index = module

function module.board(t)
    --create a billboard gui object--
    local self = setmetatable({},module)
    self.trove = Trove.new() -- create trove
    self.maid = Maid.new()
    self.instance = Instance.new("BillboardGui")
    self.instance.Name = Players.LocalPlayer.Name.."_(input)"
    self.instance.StudsOffset = Vector3.new(0,2.5,0)
    self.instance.LightInfluence = 0
    self.instance.Size = UDim2.fromScale(12,2)
    self.bindLabel = Instance.new("TextLabel",self.instance)
    self.bindLabel.Text = t.typeMessage
    self.bindLabel.RichText = true
    self.bindLabel.TextSize = 37
    self.bindLabel.TextWrapped = true
    self.bindLabel.TextScaled = true
    self.bindLabel.Size = UDim2.fromScale(1,1)
    self.bindLabel.TextColor3 = Color3.fromRGB(255,255,255)
    self.bindLabel.BackgroundTransparency = 1
    local textSizeConstraint = Instance.new("UITextSizeConstraint",self.bindLabel)
    textSizeConstraint.MaxTextSize = self.bindLabel.TextSize
    textSizeConstraint.MinTextSize = 1
    self.trove:Add(function()
        self.maid:clean()
        table.clear(self)
        self = nil
    end)
    return self
end

function module:ChangeText(t)
    if self.bindLabel then
        self.bindLabel.Text = t
    end
end

function module:Adornee(object)
    if self.instance then
        self.instance.Adornee = object
    end
end

function module:SetParent(parent)
    if self.instance then
        self.instance.Parent = parent
    end
end 

function module:Clean()
    if self.trove then
        self.trove:Destroy()
    end
end 

return module
