local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Component = {}

function Component.ComputeClass(player)
    if not player then
        return {}
    end
    local computed = {}
    if MarketplaceService:UserOwnsGamePassAsync(player.UserId,800306705) then
        computed.Cashier = 1
    end
    if MarketplaceService:UserOwnsGamePassAsync(player.UserId,800487580) then
        computed.TipsJar = 1
    end
    if MarketplaceService:UserOwnsGamePassAsync(player.UserId,800962193) then
        computed.Double = 2
    end
    if MarketplaceService:UserOwnsGamePassAsync(player.UserId,800272641) then
        computed.Vip = 1
    end
    return computed
end

return Component
