local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local SettingsFunction = require(script.Parent.Parent.functions.SettingsFunction)

local SettingsController = Knit.CreateController{ 
    Name = "SettingsController" 
}


function SettingsController:KnitStart()
   print(self.Name, "started")
    SettingsFunction:Construct()
end


function SettingsController:KnitInit()
    print(self.Name, "initialize")
end


return SettingsController
