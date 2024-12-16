local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local RewardsFunction = require(script.Parent.Parent.functions.RewardsFunction)

local RewardsController = Knit.CreateController { Name = "RewardsController" }
local OnMessageSignaled = require(script.Parent.Parent.Parent.Client_Refs.Utils.TopBarPlus_framework.OnMessageSignaled)


function RewardsController:KnitStart()
    print(self.Name , "started")
    local RewardsService = Knit.GetService("RewardsService")
    if (RewardsService) then
        local player = Players.LocalPlayer
        local playerGui = player.PlayerGui
        local rewards = playerGui:WaitForChild("rewards")
        RewardsService.LoadedRewardSignal:Connect(function(info)
            if (info) then
                RewardsFunction:Construct(rewards,info)                
            end
        end)
    end
end


function RewardsController:KnitInit()
    print(self.Name, "initialize")
end


return RewardsController
