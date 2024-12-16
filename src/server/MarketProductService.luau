local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local MarketProduct = Knit.CreateService {
    Name = "MarketProduct",
    Client = {
        ProductPurchased = Knit.CreateSignal()
    },
}


function MarketProduct:PromptGamepass(player,id)
   if (player) then
        return MarketplaceService:PromptGamePassPurchase(player,id)
   end
end

function MarketProduct:PromptDeveloperProduct(player,id)
    if (player) then
        return MarketplaceService:PromptProductPurchase(player,id)
    end
end

function MarketProduct:GiveCashToPlayer(player,cash)
    if (player) then
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            leaderstats.Cash.Value = leaderstats.Cash.Value + cash
        end
    end
end

function MarketProduct.Client:PromptGamepass(player,id)
    return self.Server:PromptGamepass(player,id)
end

function MarketProduct.Client:PromptDeveloperProduct(player,id)
    return self.Server:PromptDeveloperProduct(player,id)
end

function MarketProduct.Client:GiveCashToPlayer(player,cash)
    return self.Server:GiveCashToPlayer(player,cash)
end

function MarketProduct:KnitStart()
    print(self.Name," started")
    MarketplaceService.ProcessReceipt = function(receiptInfo)
		if (receiptInfo) then
			local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
			local getProduct = MarketplaceService:GetProductInfo(receiptInfo.ProductId,Enum.InfoType.Product)
			if (getProduct) then
                self.Client.ProductPurchased:Fire(player,getProduct.ProductId)
			end
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end


function MarketProduct:KnitInit()
    print(self.Name, "initialize")
end


return MarketProduct
