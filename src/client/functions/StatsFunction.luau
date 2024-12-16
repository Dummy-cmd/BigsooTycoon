local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

--singular Promise handler cause we just need to update text on player stats frame

local Promise = require(ReplicatedStorage.Packages.Promise)
local Knit = require(ReplicatedStorage.Packages.Knit)

function changeBlurSize(newSize)
    TweenService:Create(Lighting.Blur,TweenInfo.new(0.2),{Size = newSize}):Play()
end

function TweenPlayerFOV(newFOV)
    local camera = workspace.CurrentCamera
    TweenService:Create(camera,TweenInfo.new(0.2),{FieldOfView = newFOV}):Play()
end

function BindCloseButton()
    task.delay(2,function()
        local player  = Players.LocalPlayer
        local playerGui = player.PlayerGui
        local StatsDisplayer = playerGui:WaitForChild("StatsDisplayer")
        local StatsCoutainer = StatsDisplayer.Insider.StatsCoutainer
        StatsCoutainer.ImageButton.MouseEnter:Connect(function()
            SoundService:PlayLocalSound(SoundService.Mouse_hover)
            TweenService:Create(StatsCoutainer.ImageButton.UIScale,TweenInfo.new(0.2),{Scale = 1.05}):Play()
        end)
        StatsCoutainer.ImageButton.MouseLeave:Connect(function()
            TweenService:Create(StatsCoutainer.ImageButton.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
        end)
        StatsCoutainer.ImageButton.Activated:Connect(function()
            SoundService:PlayLocalSound(SoundService.Click)
            changeBlurSize(0)
            TweenPlayerFOV(70)
            TweenService:Create(StatsDisplayer.Insider.UIScale,TweenInfo.new(0.2),{Scale = 0}):Play()
        end)
    end)
end 

BindCloseButton()

return function() 
    Promise.new(function(resolve,reject)
        local GetDataReplicationService = Knit.GetService("GetDataReplicationService")
        if not GetDataReplicationService then reject("Failed to load data service") end
        local GettingLocalStorage = GetDataReplicationService:SimpleView()
        if not GettingLocalStorage then reject("Failed to get local storage") end
        local player  = Players.LocalPlayer
        local playerGui = player.PlayerGui
        local StatsDisplayer = playerGui:WaitForChild("StatsDisplayer")
        local StatsCoutainer = StatsDisplayer.Insider.StatsCoutainer
        StatsCoutainer.UnlockedItemLabel.Text = "Unlocked items: "..tostring(#GettingLocalStorage.Vls.TycoonProgress)
        StatsCoutainer.TotalMoneyLabel.Text = "Total money: "..tostring(GettingLocalStorage.Vls.Cash)..'$'
        StatsCoutainer.IntroductionLabel.Text = "@"..player.Name
        resolve(true)
    end):catch(warn):andThen(function(result)
        if result then
            print("Stats loaded succesfull. (client)")
        end
    end):catch(warn)
end
