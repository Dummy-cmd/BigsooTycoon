local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.Trove)


local module = {}
module.__index = module

function module.new(info)
    --[=[
        create a beam from the start position  to the end position
    ]=]
    local self = setmetatable({},module)
    --[[handle memory and trove]]--
    self._memory = info
    self.trove = Trove.new()
    self.trove:Add(function()
        self.beam:Destroy()
        table.clear(self)
        self = nil
    end)
    --[[handle object properties]]--
    self.beam = Instance.new("Beam")
    self.beam.Attachment0 = info.startPos
    self.beam.Attachment1 = info.endPos
    self.beam.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,255,0))})
    self.beam.TextureSpeed = 1
    self.beam.Texture = info.txt
    self.beam.Width0 = 0.2
    self.beam.Parent = info.startPos
    self.beam.Width1 = 1
    self.beam.TextureLength = 10
    self.beam.FaceCamera = true
    self.beam.Brightness = 3
    self.beam.LightEmission = 1
    return self
end

function module:ChangeState(state)
    if self.beam then
        self.beam.Enabled = state
        return state
    end
    return "failed to change beam state"
end 

function module:Destroy()
    if self.trove then
        self.trove:Destroy()
    end
end 

return module 
