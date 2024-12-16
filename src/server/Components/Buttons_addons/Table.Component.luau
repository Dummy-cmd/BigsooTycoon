local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")


local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Component = {}
Component.__index = Component

function Component.AttachTable(player)
    --[=[
        Create a attachTable class by the given player name
    ]=]
    if not player then
        return false
    end
    local self = setmetatable({
        _TROVE = Trove.new(),
        _owner = player, -- its just a reference to get the correspond metaData
        _key = player.Name.."_T",
        _instances = {
            _connections = {}
        }
    },Component)
    Players.PlayerRemoving:Connect(function(plr)
        if plr ==  player then
            self:Destroy(plr)
        else
            return
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
            print("[T] Class succesfull cleaned for @"..player.Name.." /",self,"/")
        end)
    end) 
    self._instances._connections["AttachedInstance"] = self._TROVE:Connect(CollectionService:GetInstanceAddedSignal(self._key),function(instance)
        if (instance) then
            if not table.find(self._instances,instance) then
                table.insert(self._instances,instance)
                print(instance.Name,"[",tostring(HttpService:GenerateGUID(false)).." ] ".." is now added for: @"..self._owner.Name)
            end
        end
    end)
    self._instances._connections["RemovedInstance"] = self._TROVE:Connect(CollectionService:GetInstanceRemovedSignal(self._key),function(instance)
        if (instance) then
            if table.find(self._instances,instance) then
                table.remove(self._instances,table.find(self._instances,instance))
                print(instance.Name,"[",tostring(HttpService:GenerateGUID(false)).." ] ".. "is now removed from: @",self._owner.Name)
            end
        end
    end)
    return self
end

function Component:find(player)
    --[=[
        try to find the correspond meta from the given player name
    ]=]
    if (self._owner) then
        if (self._owner == player) then
            return self
        else
            return false
        end
    end
    return false
end

function Component:Destroy(player)
    --[=[
        Destroy self by the given player name
    ]=]
    local meta = self:find(player)
    if (meta) then
        meta._TROVE:Destroy()
    end
    return false
end

function Component:AddSeat(player,seat)
    if not player then
        return false
    end
    if not seat then
        return false
    end
    CollectionService:AddTag(seat,player.Name.."_T")
    return false
end

return Component
