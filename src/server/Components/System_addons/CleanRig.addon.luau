local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")


local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(Knit.Util.Signal)

local module = {}

function module.addDelay(player,n,character,parent,seat)
    --[=[
        Create promise.delay and when is executed that created a flavor infront of the model after he done eating.
    ]=]
    if not seat then
        return false
    end
    if not player then
        return false
    end
    if not character then 
        return false
    end
    if not parent then
        return false
    end
    if not n then
        n = 20
    end
    local SystemConnector = Knit.GetService("SystemConnector")
    local CleanFlavorsFolder = ServerStorage.Objects.Model.CleanFlavors 
    local rng = Random.new()
    local nextInteger = rng:NextInteger(1,#CleanFlavorsFolder:GetChildren())
    local model = CleanFlavorsFolder:GetChildren()[nextInteger]
    if not model then
        return false
    end
    local promise = Promise.delay(n):andThen(function()
        if not MarketplaceService:UserOwnsGamePassAsync(player.UserId,800487581) then
            local cloneModel = model:Clone()
            local pos = character.HumanoidRootPart.Position + character.HumanoidRootPart.CFrame.LookVector * 2.5
            local cf =  CFrame.new(pos) 
            cloneModel:PivotTo(cf * CFrame.new(0,0.75,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),math.rad(15),0))
            cloneModel.Parent = parent
            SystemConnector:ComputeDirtyCupsForClient(player,cloneModel,seat) -- fire a event for the given dirty cups and player
        else
            CollectionService:AddTag(seat,player.Name.."_T")
        end
        if character then
            character:Destroy()
        end
    end):catch(function()
        warn("[System]","@"..player.Name,"leaved during the cleaning step")
    end)
    return true
end

return module
