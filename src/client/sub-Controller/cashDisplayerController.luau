local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local FormatNumberAlt = require(ReplicatedStorage.Packages.FormatNumberAlt)

local CashController = Knit.CreateController {
     Name = "CashController" 
}
function CashController:KnitStart()
    print(self.Name, "started")
    local player = Players.LocalPlayer
    task.spawn(function()
        repeat
            local playerGui = player.PlayerGui
            local hud = playerGui:WaitForChild("hud")
            local cashDisplayer = hud:WaitForChild("Coutainer").Children.CashDisplayer
            if (cashDisplayer) then
                cashDisplayer.ImageLabel.TextLabel.Text = FormatNumberAlt.FormatCompact(player:WaitForChild("leaderstats"):FindFirstChild("Cash").Value,2)
            end
            task.wait()
        until player == nil
    end)
end


function CashController:KnitInit()
    print(self.Name, "initialize")
end


return CashController
