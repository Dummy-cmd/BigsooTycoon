local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)


local LeaderboardService = Knit.CreateService {
    Name = "LeaderboardService",
    Client = {},
}

function LeaderboardService:KnitStart()
    print(self.Name , "started")
    local Component = require(script.Parent.Components["Leaderboard.Component"])
    if (Component) then
        Component:StartLoading()
        task.spawn(function()
            while task.wait(60) do
                Component:OnUpdate()
            end
        end)
    end
end


function LeaderboardService:KnitInit()
    print(self.Name, "initialize")
end


return LeaderboardService
