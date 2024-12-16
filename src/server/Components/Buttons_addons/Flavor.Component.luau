local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Trove = require(ReplicatedStorage.Packages.Trove)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Promise = require(ReplicatedStorage.Packages.Promise)

local Component = {}
Component.__index = Component

function Component.listenToNewPlayer(player)
    --[=[
        Create a flavor that listen every time a instance is added and removed
        @return self
    ]=]
    local self = setmetatable({
        _host = player,
        _key = player.Name.."_key",
        _TROVE = Trove.new(),
        listener = {
            _instance ={},
        },
    },Component)
    Players.PlayerRemoving:Connect(function(plr)
        if plr ==  player then
            self:Destroy(plr)
        else
            return
        end
    end)
    self.listener["AddedSignal"] = self._TROVE:Connect(CollectionService:GetInstanceAddedSignal(self._key),function(instance)
        if (instance) then
            if not table.find(self.listener._instance,instance) then
                table.insert(self.listener._instance,instance)
                print(instance.Name , "is now connected for : @",self._host.Name)
            end
        end
    end)
    self.listener["RemovedSignal"] = self._TROVE:Connect(CollectionService:GetInstanceRemovedSignal(self._key),function(instance)
        if (instance) then
            if table.find(self.listener._instance,instance) then
                table.remove(self.listener._instance,table.find(self.listener._instance,instance))
                print(instance.Name," is now disconnected from: @",self._host.Name)
            end 
        end
    end)
    self._TROVE:Add(function()
        local function resolveAddedInstance() 
            return Promise.resolve(CollectionService:GetTagged(self._key))
        end 
        resolveAddedInstance():andThen(function(t)
            for i,v in t do
                if CollectionService:HasTag(v,self._key) then
                    CollectionService:RemoveTag(v,self._key)
                end
            end
        end):catch(warn):finally(function()
            table.clear(self)
            print("[F] Class succesfull cleaned for @"..player.Name.." /",self,"/")
        end)
    end)
    return self
end


function Component:find(player)
    --[=[
        find the listener from the given player
        @return self or false if is not find
    ]=]
    if (self._host) then
        if self._host == player then
            return self
        else
            return false
        end
    end
    return false
end

function Component:Destroy(player)
    --[=[
        destroy the class from the given player
        @return nil, if is cleaned or false if is not cleaned
    ]=]
    if self._host then
        if self._host == player then
            self._TROVE:Destroy()
        else
            return false
        end
    end
    return false
end

function Component:GetListenedInstance(player)
    return CollectionService:GetTagged(player.Name.."_key")
end

return Component
