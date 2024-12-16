local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = script.Parent.Components
local SystemComponent = require(Component["System.Component"])

local SystemConnector = Knit.CreateService {
    Name = "SystemConnector",
    Client = {
        OnRemovePathSignal = Knit.CreateSignal(),
        OnDirtyCupsAddedSignal = Knit.CreateSignal(),
    },
}

function SystemConnector:KnitStart()
    print(self.Name, "started")
end

function SystemConnector:KnitInit()
    print(self.Name, "initialize")
end

function SystemConnector:ConstructAndConnect(player)
    --[=[
        Construct And Connect the given player to the SystemComponent 
    ]=]
    return SystemComponent:InsertPlayerLocation(player)
end

function SystemConnector:CreateConfigPath(player,path,point)
    --[=[
        Create a pathfinding class
    ]=]
    return SystemComponent:ConfigPathComponent(player,path,point)
end

function SystemConnector:CallRemoveEvent(player,model)
    --[=[
        Fire the remove path signal | see more informations at SystemComponent.lua
    ]=]
    if (player) then
        return self.Client.OnRemovePathSignal:Fire(player,model)
    end
end

function SystemConnector:InsertFlavor(player,plot)
    --[=[
        return a resolve promise value (can be nil)
    ]=]
    return SystemComponent:InsertFlavor(player,plot)
end

function SystemConnector:InsertBlender(player,plot)
    --[=[
        return a resolve promise (canno't be nil)
    ]=]
    return SystemComponent:InsertBlender(player,plot)
end 

function SystemConnector:InsertSyrup(player,flavor,plot)
    --[=[
        return the given syrup with the same type has flavor
    ]=]
    return SystemComponent:InsertSyrup(player,flavor,plot)
end

function SystemConnector:InsertToppings(player,syrup)
    --[=[
        return then given toppings with same type has syrup
    ]=]
    return SystemComponent:InsertToppings(player,syrup)
end

function SystemConnector:MoveRigToASeat(player,plot)
    --[=[
        return a boolean, get the rig and placing it to a seat
    ]=]
    return SystemComponent:MoveRigToASeat(player,plot)
end

function SystemConnector:GetCups(player,plot)
    --[=[
        return a array countaining cups need to be cleaned.
    ]=]
    return SystemComponent:GetCups(player,plot)
end

function SystemConnector:DestroyModel(player,model)
    --[=[
        destroy the given model (fn used for cups on the cleaning step)
    ]=]
    if (model) then
        model:Destroy()
    end
end

function SystemConnector:SeatRemaining(player)
    --[=[
        return a number containg how many seat is remaining
    ]=]
    return SystemComponent:GetSeatRemaining(player)
end

function SystemConnector:AddCashToPlayer(player,value)
    --[=[
        add cash for the given player
    ]=]
    if not value or type(value) ~= "number" then
        return 
    end
    local leaderstats = player.leaderstats
    if not leaderstats then return end
    local Cash = leaderstats.Cash
    if not Cash then return end
    Cash.Value = Cash.Value + value
end

function SystemConnector:ComputeDirtyCupsForClient(player,model,seat)
    --fire a signal for the given dirty cups
    if not model then
        return false
    end
    return self.Client.OnDirtyCupsAddedSignal:Fire(player,model,seat)
end

function SystemConnector:GetRetiredSeat(player,seat)
    --add the seat has retired before
    if not seat then
        return false
    end
    return SystemComponent:AddSeat(player,seat)
end

function SystemConnector:CreateCompute(player)
    return SystemComponent:CreateCompute(player) 
end

function SystemConnector:RetryToGetSyrup(player,plot,item)
    return SystemComponent:RetryToGetSyrup(player,plot,item)
end

function SystemConnector:Debug(player)
    return player:Kick("Sorry you've been kicked due to a bug i'm sorry for that try to rejoin and if you keep getting kicked send a report with the report button on the top")
end

function SystemConnector.Client:Debug(player)
    return self.Server:Debug(player)
end 

function SystemConnector.Client:RetryToGetSyrup(player,plot,item)
    return self.Server:RetryToGetSyrup(player,plot,item)
end

function SystemConnector.Client:CreateCompute(player) 
    return self.Server:CreateCompute(player)
end

function SystemConnector.Client:GetRetiredSeat(player,seat)
    return self.Server:GetRetiredSeat(player,seat)
end

function SystemConnector.Client:AddCashToPlayer(player,value)
    return self.Server:AddCashToPlayer(player,value)
end

function SystemConnector.Client:SeatRemaining(player)
    return self.Server:SeatRemaining(player)
end

function SystemConnector.Client:DestroyModel(player,model)
    return self.Server:DestroyModel(player,model)
end

function SystemConnector.Client:GetCups(player,plot)
    return self.Server:GetCups(player,plot)
end

function SystemConnector.Client:MoveRigToASeat(player,plot)
    return self.Server:MoveRigToASeat(player,plot)
end

function SystemConnector.Client:InsertToppings(player,syrup)
    return self.Server:InsertToppings(player,syrup)
end

function SystemConnector.Client:InsertSyrup(player,flavor,plot)
    return self.Server:InsertSyrup(player,flavor,plot)
end

function SystemConnector.Client:InsertBlender(player,plot)
    return self.Server:InsertBlender(player,plot)
end

function SystemConnector.Client:InsertFlavor(player,plot)
    return self.Server:InsertFlavor(player,plot)
end
 
function SystemConnector.Client:CreateConfigPath(player,path,point)
    return self.Server:CreateConfigPath(player,path,point)
end

function SystemConnector.Client:ConstructAndConnect(player)
    return self.Server:ConstructAndConnect(player)
end

return SystemConnector
