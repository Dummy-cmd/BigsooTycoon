local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local functionsFolder = script.Parent.Parent.functions
local LoadingFunctionModule = require(functionsFolder.LoadingFunction)

local initRoactLoading = require(script.Parent.Parent.r_init["roact.loading.initialize"])
local Roact = require(ReplicatedStorage.Packages.Roact)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui or Player:WaitForChild("PlayerGui")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local LoadingController = Knit.CreateController{
     Name = "LoadingController"
}


function LoadingController:KnitInit()
    print(self.Name, "initialize")
end


function LoadingController:KnitStart()
    print(self.Name, "started")
    self.handleLoadingElement = Roact.mount(Roact.createElement(initRoactLoading),PlayerGui:WaitForChild("LoadingScreen"),"LoadingFrame")
    self.frame = PlayerGui:WaitForChild("LoadingScreen"):WaitForChild("LoadingFrame")
    LoadingFunctionModule:AppearLoading(self.frame)
    LoadingFunctionModule:StartLoading(self.frame)
end


return LoadingController
