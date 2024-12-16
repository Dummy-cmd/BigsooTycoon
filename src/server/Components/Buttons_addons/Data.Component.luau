local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Component = {}

function Component:GetStoreFromPlayerKey(key)
    --[=[
        Return data or a blank table
    ]=]
    if not key then
        return {}
    end
    local GetDataReplicationService = Knit.GetService("GetDataReplicationService")
    if GetDataReplicationService then
        local player = Players:GetPlayerByUserId(key)
        if (player) then
            local SimpleView = GetDataReplicationService:SimpleView(player)
            if (SimpleView) then
                return SimpleView
            end
        else
            return {}
        end
    end
    return {}
end

function Component:AddModelToPlayerStore(value,key)
    --[=[
        Return a boolean ; [true if is uploaded] or [false if is failed]
    ]=]
    if not value then
        return false
    end
    local GetDataReplicationService = Knit.GetService("GetDataReplicationService")
    if GetDataReplicationService then
        local player = Players:GetPlayerByUserId(key)
        if (player) then
            local UpdatePublished,err = pcall(function()
                return GetDataReplicationService:AddToStorageAsync(player,key,value)
            end)
            if UpdatePublished then -- check if the update is published
                return true
            else
                return false
            end
        end
    end
    return false
end

function Component:UpdateItemId(key,newId)
    --[=[
        return a boolean if the given passed id is update or return false if is not Updated correctly
    ]=]
    if not newId then
        return false
    end
    local GetDataReplicationService = Knit.GetService("GetDataReplicationService")
    if GetDataReplicationService then
        local player = Players:GetPlayerByUserId(key)
        local UpdatePublished,err = pcall(function()
            return GetDataReplicationService:UpdateItemId(player,key,math.round(newId))
        end)
        if UpdatePublished then -- check if the update is published
            return true
        else
            return false
        end
    end
    return false
end


function Component:UpdateTableId(key,newId)
    --[=[
        return a boolean if the given passed id is update or return false if is not Updated correctly
    ]=]
    if not newId then
        return false
    end
    local GetDataReplicationService = Knit.GetService("GetDataReplicationService")
    if GetDataReplicationService then
        local player = Players:GetPlayerByUserId(key)
        local UpdatePublished,err = pcall(function()
            return GetDataReplicationService:UpdateTableId(player,key,math.round(newId))
        end)
        if UpdatePublished then -- check if the update is published
            return true
        else
            return false
        end
    end
    return false
end

function Component:UpdateFlavorId(key,newId)
    --[=[
        return a boolean if the given passed id is update or return false if is not Updated correctly
    ]=]
    if not newId then
        return false
    end
    local GetDataReplicationService = Knit.GetService("GetDataReplicationService")
    if GetDataReplicationService then
        local player = Players:GetPlayerByUserId(key)
        local UpdatePublished,err = pcall(function()
            return GetDataReplicationService:UpdateFlavorId(player,key,math.round(newId))
        end)
        if UpdatePublished then -- check if the update is published
            return true
        else
            return false
        end
    end
    return false
end

return Component
