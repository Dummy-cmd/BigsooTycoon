local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ButtonsComponent = require(script.Parent.Components["Buttons.Component"])

local ButtonsService = Knit.CreateService {
    Name = "ButtonsService",
    Client = {},
}


function ButtonsService:KnitStart()
    print(self.Name," started")
end

function ButtonsService:KnitInit()
    print(self.Name, " initialize")
end

--Primary functions

function ButtonsService:GetItems(player,plotName,id,data)
    --[=[
        Load a item page [Used only on loading]
    ]=]
    if not plotName or not id then return end
    return ButtonsComponent:GetItemFromId(player,plotName,id,data)
end

function ButtonsService:IsAllowedToBuy(player,value)
    --[=[
        Verify if the player have current money to buy the button
    ]=]
    if (player) then
        local leaderstats = player:WaitForChild("leaderstats")
        local Cash = leaderstats.Cash
        if (Cash.Value >= value) then
            return true
        end
    end
    return false
end

function ButtonsService:GetModelPriceFromName(player,plotName,modelName)
    --[=[
        Get the price for the given model Name
    ]=]
    if modelName then
        return ButtonsComponent:GetModelPriceFromName(player,plotName,modelName)
    end
end

function ButtonsService:ConvertButtonToModel(player,plotName,model)
    --[=[
        Create a model from a button
    ]=]
    return ButtonsComponent:ConvertButtonToModel(player,plotName,model)
end

function ButtonsService:release(player,Login,plotName)
    --[=[
        Return a released button object
    ]=]
    return ButtonsComponent:release(player,Login,plotName)
end

function ButtonsService:releaseFlavor(player,Login,plotName)
    --[=[
        Return a released flavor object
    ]=]
    return ButtonsComponent:releaseFlavor(player,Login,plotName)
end

function ButtonsService:releaseTable(player,Login,plotName) 
    --[=[
        Return a released table object
    ]=]
    return ButtonsComponent:releaseTable(player,Login,plotName)
end

function ButtonsService:GetFlavorItemsId(player,plotName,Id,_d)
    --[=[
        Return a flavor item page (loaded only 1 time when a player claim a tycoon)
    ]=]
    return ButtonsComponent:GetFlavorItemsId(player,plotName,Id,_d)
end

function ButtonsService:GetTablesFromId(player,plotName,id,_d) 
    --[=[
        Return a tables item page (loaded only 1 time when a player claim a tycoon)
    ]=] 
    return ButtonsComponent:GetTablesFromId(player,plotName,id,_d)
end

function ButtonsService:AddModelToPlayerListener(player,model,plotName)
    --[=[
        Return a boolean if the current model passed is uploaded or not
    ]=]
    return ButtonsComponent:AddToListener(player,model,plotName)
end

function ButtonsService:AddTableModelToPlayerListener(player,model,plotName)
    --[=[
        Return a boolean if the current passed is uploaded or not [Table attachment |Seat only]
    ]=]
    return ButtonsComponent:AttachTableToPlayerListener(player,model,plotName)
end

function ButtonsService:GetLocalStore(player,key)
    --[=[
        Return a table containing data, return a blank table is the player didn't have any object stored in
    ]=]
    return ButtonsComponent:GetLocalStore(player,key)
end

function ButtonsService:UpdateLocalStore(player,value,key)
    --[=[
        Return a result if the given value are updated or no
    ]=]
    return ButtonsComponent:AddToLocalStore(player,value,key)
end

function ButtonsService:UpdateItemId(player,key,item_id)
    --[=[
        return a result if the given value are updated or no
    ]=]
    return ButtonsComponent:UpdateItemId(player,key,item_id)
end 

function ButtonsService:UpdateTableId(player,key,table_id)
    --[=[
        return a result if the given value are updated or no
    ]=]
    return ButtonsComponent:UpdateTableId(player,key,table_id)
end 

function ButtonsService:UpdateFlavorId(player,key,flavor_id)
    --[=[
        return a result if the given value are updated or no
    ]=]
    return ButtonsComponent:UpdateFlavorId(player,key,flavor_id)
end 

function ButtonsService:ObtainCompletedBadge(player)
    if not player then return "Failed" end
    if BadgeService:UserHasBadgeAsync(player.UserId,2558623844392119) == false then
        BadgeService:AwardBadge(player.UserId,2558623844392119)
    else
        return "Already owned"
    end
    return true
end

function ButtonsService:ReducePlayerMoney(player,plot,price)
    --[=[
        -price to the player leaderstats [Cash]
    ]=]
    if not plot or not price then
        return false
    end
    local leaderstats = player.leaderstats
    if not leaderstats then
        return false
    end
    leaderstats:FindFirstChild("Cash").Value = math.abs(leaderstats:FindFirstChild("Cash").Value - price)
    if leaderstats:FindFirstChild("Cash").Value <= 0 then
        leaderstats:FindFirstChild("Cash").Value = 0
    end
    return true
end

function ButtonsService.Client:ObtainCompletedBadge(player)
    return self.Server:ObtainCompletedBadge(player)
end

function ButtonsService.Client:ReducePlayerMoney(player,plot,price)
    return self.Server:ReducePlayerMoney(player,plot,price)
end

function ButtonsService.Client:release(player,Login,plotName)
    return self.Server:release(player,Login,plotName)
end

function ButtonsService.Client:releaseFlavor(player,Login,plotName)
    return self.Server:releaseFlavor(player,Login,plotName)
end

function ButtonsService.Client:releaseTable(player,Login,plotName)
    return self.Server:releaseTable(player,Login,plotName)
end

function ButtonsService.Client:ConvertButtonToModel(player,plotName,model)
    return self.Server:ConvertButtonToModel(player,plotName,model)
end

function ButtonsService.Client:GetModelPriceFromName(player,plotName,modelName)
    return self.Server:GetModelPriceFromName(player,plotName,modelName)
end

function ButtonsService.Client:IsAllowedToBuy(player,value)
    return self.Server:IsAllowedToBuy(player,value)
end

function ButtonsService.Client:GetItems(player,plotName,id,data)
    return self.Server:GetItems(player,plotName,id,data)
end

function ButtonsService.Client:GetFlavorItemsId(player,plotName,Id,_d)
    return self.Server:GetFlavorItemsId(player,plotName,Id,_d)
end

function ButtonsService.Client:GetTablesFromId(player,plotName,id,_d)
    return self.Server:GetTablesFromId(player,plotName,id,_d)
end

function ButtonsService.Client:AddModelToPlayerListener(player,model,plotName)
    return self.Server:AddModelToPlayerListener(player,model,plotName)
end

function ButtonsService.Client:AddTableModelToPlayerListener(player,model,plotName)
    return self.Server:AddTableModelToPlayerListener(player,model,plotName)
end

function ButtonsService.Client:GetLocalStore(player,key)
    return self.Server:GetLocalStore(player,key)
end

function ButtonsService.Client:UpdateLocalStore(player,value,key)
    return self.Server:UpdateLocalStore(player,value,key)
end

function ButtonsService.Client:UpdateItemId(player,key,value)
    return self.Server:UpdateItemId(player,key,value)
end

function ButtonsService.Client:UpdateTableId(player,key,value)
    return self.Server:UpdateTableId(player,key,value)
end

function ButtonsService.Client:UpdateFlavorId(player,key,value)
    return self.Server:UpdateFlavorId(player,key,value)
end

return ButtonsService
