local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Component = {}

function Component:AddInstanceToTags(instance,tag)
    --[=[
        Add instance to the given tag string
    ]=]
    assert(type(tag) == "string","tag arg must be a string")
    if not self[instance.Name] then
        self[instance.Name] = Trove.new()
    end
    self[instance.Name]:AttachToInstance(instance)
    self[instance.Name]:Add(function()
        self:RemoveInstanceFromTag(instance,tag)
    end)
    if CollectionService:HasTag(instance,tag) then
        CollectionService:RemoveTag(instance,tag)
    end
    CollectionService:AddTag(instance,tag)
    return true
end

function Component:RemoveInstanceFromTag(instance,tag)
     --[=[
        remove a instance from the given tag string
    ]=]
    assert(type(tag) == "string","tag arg must be a string")
    if not CollectionService:HasTag(instance,tag) then
        return false
    end
    CollectionService:RemoveTag(instance,tag)
    return true
end

function Component:IsAddedToTag(instance,tag)
    if CollectionService:HasTag(instance,tag) then
        return true
    else
        return false
    end
end

function Component:GetComponents(tag)
    assert(type(tag) == "string", "tag arg must be a string")
    print("Getting components with tag:", tag)
    local taggedInstances = CollectionService:GetTagged(tag)
    print("Found", #taggedInstances, "instances with tag:", tag)
    return taggedInstances
end

return Component
