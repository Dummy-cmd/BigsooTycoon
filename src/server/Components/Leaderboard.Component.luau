local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local MoneyLeaderboardService = DataStoreService:GetOrderedDataStore("MoneyLeaderboardServiceFinished_config")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Knit = require(ReplicatedStorage.Packages.Knit)  
local FormatNumberAlt = require(ReplicatedStorage.Packages.FormatNumberAlt)

local Component = {}

local function _refPlayerName(key)
    return Promise.new(function(resolve,reject)
        local succes,result = pcall(function()
            return "@"..Players:GetNameFromUserIdAsync(key)
        end)
        if succes then
            resolve(result)
        else
            reject(result)
        end    
    end):catch(warn)
end

function Component:StartLoading(_dataPage)  
    --[[
        @Dummy
    ]]
    local FrameTemplateService = Knit.GetService("FrameTemplateService")
    local GetDataReplicationService = Knit.GetService("GetDataReplicationService")
    local Model = workspace:WaitForChild("Money leaderboard")
    local Model2 = workspace:WaitForChild("Money leaderboard2")
    local SurfaceGui = Model.FrontPage.SurfaceGui
    if (_dataPage == nil) then
        _dataPage = GetDataReplicationService:LoadLeaderboard("[S]",MoneyLeaderboardService)
    end
    if not self.loadedPages then
        self.loadedPages = {}
    else
        warn("Canno't recreate self.loadedPages you must need to clean up first")
    end
    if _dataPage then
        for i,data in _dataPage do
            _refPlayerName(data.key):andThen(function(result)
                local LoadTemplate = FrameTemplateService:GetTemplate("[S]","template")
                if LoadTemplate then
                    local s,e = pcall(function()
                        LoadTemplate.ImageLabel.Image = Players:GetUserThumbnailAsync(data.key,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
                        LoadTemplate.TextLabel.Text = "#"..tostring(i).. " " .. tostring(result) .. " " .. tostring(FormatNumberAlt.FormatCompact(data.value,2)) .." $"
                        LoadTemplate.TextLabel.TextColor3 = Color3.new(1,1,1)
                    end)
                    if (s) then
                        LoadTemplate.Name = result
                        LoadTemplate.Parent = SurfaceGui.Coutainer:FindFirstChild("ScrollingFrame")
                        if not table.find(self.loadedPages,LoadTemplate) then
                            table.insert(self.loadedPages,LoadTemplate.Name)
                        end

                        local cloneFor2ndLeaderboard = LoadTemplate:Clone()
                        cloneFor2ndLeaderboard.Parent = Model2.FrontPage.SurfaceGui.Coutainer:FindFirstChild("ScrollingFrame")
                    else    
                        warn(debug.traceback(e,2))
                    end
                else
                    -- do nothing and wait for the next index from the data page
                end
            end):catch(function()
                warn("failed: ",data.key,"async in the leaderboard index skipped [not a error]")
            end):await() -- call catch for catching error and await for yield the current promise
        end

        return true
    end

    return false
end

function Component:doCleaning()
    --[[
        Clean all frames, and reset the self.loadedPages table to a empty table
    ]]
    if self.loadedPages then
        table.clear(self.loadedPages)
        local Model = workspace:WaitForChild("Money leaderboard")
        local SurfaceGui = Model.FrontPage.SurfaceGui
        for i,child in SurfaceGui.Coutainer:FindFirstChild("ScrollingFrame"):GetChildren() do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        local Model2 = workspace:WaitForChild("Money leaderboard2")
        local SurfaceGui2 = Model2.FrontPage.SurfaceGui

        for i,child in SurfaceGui2.Coutainer:FindFirstChild("ScrollingFrame"):GetChildren() do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        return true
    end
    return false
end

function Component:OnUpdate(_dataPage)
    --[[
        Function called every minute, Same as @StartLoading()
    ]]
    if #self.loadedPages > 0 then
       local resultOnCleaning = self:doCleaning()
       if resultOnCleaning == false then
            print("Something went wrong while cleaning frame and table ",debug.traceback("| Cleaning task",2))
       end
    end
    local FrameTemplateService = Knit.GetService("FrameTemplateService")
    local GetDataReplicationService = Knit.GetService("GetDataReplicationService")
    local Model = workspace:WaitForChild("Money leaderboard")
    local Model2 = workspace:WaitForChild("Money leaderboard2")
    local SurfaceGui = Model.FrontPage.SurfaceGui
    if (_dataPage == nil) then
        _dataPage = GetDataReplicationService:LoadLeaderboard("[S]",MoneyLeaderboardService)
    end
    if _dataPage then
        for i,data in _dataPage do
            _refPlayerName(data.key):andThen(function(result)
                local LoadTemplate = FrameTemplateService:GetTemplate("[S]","template")
                if LoadTemplate then
                    local s,e = pcall(function()
                        LoadTemplate.ImageLabel.Image = Players:GetUserThumbnailAsync(data.key,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
                        LoadTemplate.TextLabel.Text = "#"..tostring(i).. " " .. tostring(result) .. " " .. tostring(FormatNumberAlt.FormatCompact(data.value,2)) .." $"
                        LoadTemplate.TextLabel.TextColor3 = Color3.new(1,1,1)
                    end)
                    if (s) then
                        LoadTemplate.Name = result
                        LoadTemplate.Parent = SurfaceGui.Coutainer:FindFirstChild("ScrollingFrame")
                        if not table.find(self.loadedPages,LoadTemplate) then
                            table.insert(self.loadedPages,LoadTemplate.Name)
                        end
                        local cloneFor2ndLeaderboard = LoadTemplate:Clone()
                        cloneFor2ndLeaderboard.Parent = Model2.FrontPage.SurfaceGui.Coutainer:FindFirstChild("ScrollingFrame")
                    else    
                        warn(debug.traceback(e,2))
                    end
                else
                    -- do nothing and wait for the next index from the data page
                end
            end):catch(function()
                warn("failed: ",data.key,"async in the leaderboard index skipped [not a error]")
            end):await() -- call catch for catching error and await for yield the current promise
        end
        return true
    end
    return false
end

return Component
