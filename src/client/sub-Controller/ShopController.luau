local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Maid = require(ReplicatedStorage.Packages.Maid)

local Shop = require(script.Parent.Parent.functions.ShopFunction)
local ShopController = Knit.CreateController { Name = "ShopController" }

function ShopController:KnitStart()
    print(self.Name, 'started')
    -- start code
    local player = Players.LocalPlayer
    local playerGui = player.PlayerGui or player:WaitForChild("PlayerGui")
    local hud = playerGui:WaitForChild("hud")
    local Coutainer = hud:WaitForChild("Coutainer")
    local Children = Coutainer.Children
    Shop:Construct(Children:GetChildren())
end


function ShopController:KnitInit()
    print(self.Name, "initialize")
end


return ShopController
