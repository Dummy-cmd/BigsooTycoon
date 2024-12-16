local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RewardsStore = DataStoreService:GetDataStore("RewardsStore-config-terminal-3")
local GroupStorage = DataStoreService:GetDataStore("GroupStorage-config-terminal")

local Knit = require(ReplicatedStorage.Packages.Knit)
local _rewardIndex = require(script.Parent._index.RewardsIndex)

local h24 = 60 * 60 * 24

local RewardsService = Knit.CreateService {
    Name = "RewardsService",
    Client = {
        LoadedRewardSignal = Knit.CreateSignal(),
        ClaimedRewardsSignal = Knit.CreateSignal(),
    },
}

function RewardsService:KnitStart()
    print(self.Name, "started")
    Players.PlayerAdded:Connect(function(player)
        if (player) then
            return self.Client.LoadedRewardSignal:Fire(player,{
                data = RewardsStore:GetAsync(player.UserId) or {},
                IsInGroup = player:IsInGroup(33939812),
                GroupRewardAlreadyClaimed = GroupStorage:GetAsync(player.UserId)
            })
        end
    end)
end

function RewardsService:ConvertTime(player,t)
    if (player) then
        if RewardsStore:GetAsync(player.UserId) then
            local now = workspace:GetServerTimeNow()
            local timediff = now - RewardsStore:GetAsync(player.UserId).lastTime
            return h24 - timediff
        end
    end
end

function RewardsService:GroupReward(player)
    if (player) then
        local leaderstats = player.leaderstats 
        if leaderstats then
            if player:IsInGroup(33939812) then
                leaderstats.Cash.Value = leaderstats.Cash.Value + 500
            end
        end
    end
end


function RewardsService:ApplyChangeToDataStore(player,change)
    if (player) then
        --check if the player have the leaderstats folder
        local leaderstats = player.leaderstats
        if leaderstats then
            local Cash = leaderstats.Cash
            if (RewardsStore:GetAsync(player.UserId)) then
                Cash.Value = Cash.Value + _rewardIndex[change.day]
            else
                Cash.Value = Cash.Value + _rewardIndex[1]
            end
        end
        -- fire a signal to the player [return string used to make a ui notification]
        self.Client.ClaimedRewardsSignal:Fire(player,"Day "..tostring(change.day).." Claimed, ".._rewardIndex[change.day].."$")
        -- check if the day is upper than 4
        if RewardsStore:GetAsync(player.UserId) then
            if RewardsStore:GetAsync(player.UserId).day > 4 then
                change.day = 1
            elseif change.day >= 4 then
                change.day = 1
            else
                change.day = change.day + 1
            end
        else
            if change.day >= 4 then
                change.day = 1
            else
                change.day = change.day + 1
            end
        end
        --save change to the current player
        RewardsStore:SetAsync(player.UserId,{
            day = change.day,
            lastTime = workspace:GetServerTimeNow(),
        })
    end
end

function RewardsService:VerifyCooldown(player,cooldown)
    if (player) then
        local serverTime = workspace:GetServerTimeNow()
        local timediff = serverTime - cooldown
        if timediff < h24 then
            return false
        end
        return true
    end
end

function RewardsService:IsGroupRewardClaimed(player)
    if (player) then
        local IsClaimed = GroupStorage:GetAsync(player.UserId) or false
        if (IsClaimed == true) then
            return IsClaimed
        end
    end
    return false
end

function RewardsService:GetStore(player)
    return RewardsStore:GetAsync(player.UserId)
end

function RewardsService.Client:IsGroupRewardClaimed(player)
    return self.Server:IsGroupRewardClaimed(player)
end

function RewardsService.Client:GetStore(player)
    return self.Server:GetStore(player)
end

function RewardsService.Client:GroupReward(player)
    return self.Server:GroupReward(player)
end

function RewardsService.Client:ApplyChangeToDataStore(player,change)
    return self.Server:ApplyChangeToDataStore(player,change)
end

function RewardsService.Client:ConvertTime(player,t)
    return self.Server:ConvertTime(player,t)
end

function RewardsService.Client:VerifyCooldown(player,cooldown)
    return self.Server:VerifyCooldown(player,cooldown)
end

function RewardsService:KnitInit()
    print(self.Name,"initialize")  
end


return RewardsService
