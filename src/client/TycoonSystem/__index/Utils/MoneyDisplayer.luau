local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Promise = require(ReplicatedStorage.Packages.Promise)

local initiazeDisplay = require(script.Parent.Parent.Parent.Parent.r_init["roact.displayer.initialize"])

local displayer = {}

function displayer:animRandomPositionDisplay()
    local rng = Random.new()
    local framesNumber = rng:NextInteger(1,4)
    local PlayerGui = Players.LocalPlayer.PlayerGui
    task.spawn(function()
        for i = 0,framesNumber,1 do
            self[i] = Roact.mount(Roact.createElement(initiazeDisplay),PlayerGui:WaitForChild("MoneyDisplayer"),"DisplayFrame"..i)
            task.wait(0.1)
        end
    end)
    task.delay(5,function()
        for i,frame in self do
            if frame and type(frame) ~= "function" then
                Roact.unmount(frame)
            end
        end
    end)
end

return displayer
