--[[
    @Dummy
    this module coutain shop and daily rewards gui 
    basically is only for shop but daily rewards are in just to open the gui.
]]

local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local FormatNumberAlt = require(ReplicatedStorage.Packages.FormatNumberAlt)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Concur = require(ReplicatedStorage.Packages.Concur)
local Maid = require(ReplicatedStorage.Packages.Maid)local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local PlayerModule = require(Players.LocalPlayer.PlayerScripts.PlayerModule):GetControls()
local OnMessageSignaled = require(script.Parent.Parent.Parent.Client_Refs.Utils.TopBarPlus_framework.OnMessageSignaled)
local StatsPromiser = require(script.Parent.StatsFunction)

local Shop = {}
Shop.__index = Shop

--[[ self_id coutain every gamepass with properties in, but DON'T dev product ]]
Shop._id = {
    [1] = {id = 800054762,image = "rbxassetid://17425915400",desc = "Give a extra speed !"},
	[2] = {id = 800272641,image = "rbxassetid://17425917998",desc = "+ 1x money & VIP chat tag"},
	[3] = {id = 800962193,image = "rbxassetid://17425932910",desc = "Earn x2 more money"},
	[4] = {id = 800487580,image = "rbxassetid://17425919774",desc = "Receive tips from customer, 10% from order revenue"},
	[5] = {id = 800487581,image = "rbxassetid://17425924915",desc = "Automatically cleans the tables"},
	[6] = {id = 800380746,image = "rbxassetid://17425929230",desc = "Automatically put toppings when you use the fridge"},
	[7] = {id = 800306705,image = "rbxassetid://17425923141",desc = "Upgrade your cashier and earn 1x more"},	
	[8] = {id = 800371766,image = "rbxassetid://17425930893",desc = "Automatically washes the dishes"},
	[9] = {id = 800114720,image = "rbxassetid://17425921836",desc = "Removes the 10 second delay"},
}

-- get all developer product
Shop._productId = {
    [1] = MarketplaceService:GetProductInfo(1829122015,Enum.InfoType.Product),
    [2] = MarketplaceService:GetProductInfo(1829122011,Enum.InfoType.Product),
    [3] = MarketplaceService:GetProductInfo(1829122014,Enum.InfoType.Product),
    [4] = MarketplaceService:GetProductInfo(1829122013,Enum.InfoType.Product),
    [5] = MarketplaceService:GetProductInfo(1829122012,Enum.InfoType.Product), 
    [6] = MarketplaceService:GetProductInfo(1829122010,Enum.InfoType.Product),
}

for i,t in ipairs(Shop._productId) do
    if (t) then
        if not t["Value"] then
            if t.ProductId == 1829122011 then
                t["Value"] = 500
            elseif t.ProductId == 1829122010 then
                t["Value"] = 30000
            elseif t.ProductId == 1829122014 then
                t["Value"] = 2000
            elseif t.ProductId == 1829122015 then
                t["Value"] = 100
            elseif t.ProductId == 1829122013 then
                t["Value"] = 5000
            elseif t.ProductId == 1829122012 then
                t["Value"] = 15000
            end
        end
    end
end

local function ReturnShopFrame()
    local player = Players.LocalPlayer
    local shop = player.PlayerGui:WaitForChild("shop")
    if (shop) then
        return shop
    end
end

local function returnSettingsFrame()
    local player = Players.LocalPlayer
    local SettingsFrame = player.PlayerGui:WaitForChild("settings")
    if (SettingsFrame) then
        return SettingsFrame
    end
end

local function returnRewardsFrame()
    local player = Players.LocalPlayer
    local RewardsFrame = player.PlayerGui:WaitForChild("rewards")
    if (RewardsFrame) then
        return RewardsFrame
    end
end

local function returnStatsFrame()
    local player = Players.LocalPlayer
    local Main = player.PlayerGui:WaitForChild("StatsDisplayer")
    if Main then
        return Main
    end
end

local function createAutobindingForShop(self)
    -- function run automaticly when a client join the game
    local shop = ReturnShopFrame()
    if (shop) then
        local loaded = gamepassLoader(self) -- return a boolean value.
        local MarketProductService = Knit.GetService("MarketProduct") -- prompt gamepass Service
        local Background = shop:FindFirstChild("Background")
        local Coutainer = Background.Coutainer
        local Global = Coutainer.Global
        local Categories = Global.Insider.Categories
        local Gamepass = bind(self,Categories.Gamepass,function()
            gamepassLoader(self)
        end)
        local Coins = bind(self,Categories.Coins,function()
            developerProductLoader(self)
        end)
        local CloseButton = bind(self,Coutainer.CloseButton,function()
            changeBlurSize(0)
            TweenPlayerFOV(70)
            TweenService:Create(ReturnShopFrame():FindFirstChild("Background").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
        end)
        local gamepassLoaderFrame = shop:WaitForChild("Background").Coutainer.Global.Insider.GamepassLoaderFrame
        local GestionFrame = gamepassLoaderFrame.Parent.GestionFrame
        local BuyButton = bind(self,GestionFrame.ImageButton,function()
           if GestionFrame:GetAttribute("SelectionedGamepass") then
                local isDeveloperProductAsync = false
                for i,product in self._productId do
                    if product then
                        if product.ProductId == GestionFrame:GetAttribute("SelectionedGamepass") then
                            isDeveloperProductAsync = true
                            break
                        end
                    end
                end

                if not isDeveloperProductAsync then
                    MarketProductService:PromptGamepass(GestionFrame:GetAttribute("SelectionedGamepass"))
                else
                    MarketProductService:PromptDeveloperProduct(GestionFrame:GetAttribute("SelectionedGamepass"))
                end
           end
        end)
        MarketProductService.ProductPurchased:Connect(function(id)
            local playerWillReceived = 0
            for i,product in self._productId do
                if product then
                    if product.ProductId == id then
                        if product["Value"] then
                            playerWillReceived = product["Value"]
                            break
                        else
                        end
                    end
                end
            end
            if playerWillReceived > 0 then
                MarketProductService:GiveCashToPlayer(playerWillReceived)
            end
            OnMessageSignaled("Product purchased tysm :D, "..tostring(FormatNumberAlt.FormatCompact(playerWillReceived,1)).."$ received.",Color3.fromRGB(153, 193, 124),Color3.new(0,0,0),"Succes")
        end)
    end
end

function gamepassLoader(self)
    -- this function is used to load gamepass image and bind them to the bind function.
   local shop = ReturnShopFrame()
    if (shop) then
        local gamepassLoaderFrame = shop:WaitForChild("Background").Coutainer.Global.Insider.GamepassLoaderFrame
        local GestionFrame = gamepassLoaderFrame.Parent.GestionFrame

        if (gamepassLoaderFrame) then
            for i,imageButton in gamepassLoaderFrame._image:GetChildren() do
                if imageButton:IsA("ImageButton") then
                    if not imageButton:FindFirstChild("UIScale") then
                        local scale = Instance.new("UIScale",imageButton)
                    end
                    unbind(self,imageButton)
                    imageButton.Image = self._id[i].image
                    imageButton:SetAttribute("gamepass",self._id[i].id)
                    imageButton.Name = tostring(self._id[i].id)
                    imageButton:SetAttribute("Description",self._id[i].desc)
                    --bind
                    local result = bind(self,imageButton,function()
                        GestionFrame.ImageLabel.Image = self._id[i].image
                        GestionFrame:SetAttribute("SelectionedGamepass",imageButton:GetAttribute("gamepass"))
                        GestionFrame:SetAttribute("SelectionedDescription",imageButton:GetAttribute("Description"))
                        GestionFrame.TextLabel.Text = GestionFrame:GetAttribute("SelectionedDescription")
                    end)
                end
            end
        end
        return true
    end
   return false
end

function developerProductLoader(self)
    local shop = ReturnShopFrame()
    if self._productId then
        local gamepassLoaderFrame = shop:WaitForChild("Background").Coutainer.Global.Insider.GamepassLoaderFrame
        local GestionFrame = gamepassLoaderFrame.Parent.GestionFrame

        for i,image in gamepassLoaderFrame._image:GetChildren() do
            if image:IsA("ImageButton") then
                unbind(self,image)
                if not image:FindFirstChild("UIScale") then
                    local scale = Instance.new("UIScale",image)
                end
                if (self._productId[i]) then
                    image:SetAttribute("DeveloperProductId",self._productId[i].ProductId)
                    image:SetAttribute("Description","Received: "..tostring(FormatNumberAlt.FormatCompact(self._productId[i].Value),1).. " Cash.")
                    if self._productId[i].Value >= 5500 then
                        image.Image = "http://www.roblox.com/asset/?id=17473679144"
                    elseif self._productId[i].Value >= 10000 then
                        image.Image = "http://www.roblox.com/asset/?id=17473680155"
                    elseif self._productId[i].Value >= 501 then
                        image.Image = "http://www.roblox.com/asset/?id=17473678007"
                    elseif self._productId[i].Value <= 500 then
                        image.Image = "http://www.roblox.com/asset/?id=17483424941"  
                    end

                    local result = bind(self,image,function()
                        GestionFrame.ImageLabel.Image = image.Image
                        GestionFrame:SetAttribute("SelectionedGamepass",image:GetAttribute("DeveloperProductId"))
                        GestionFrame:SetAttribute("SelectionedDescription",image:GetAttribute("Description"))
                        GestionFrame.TextLabel.Text = GestionFrame:GetAttribute("SelectionedDescription")
                    end)
                else
                    image.Image = "rbxassetid://17484477897"
                end
            end
        end
    end
end

function unbind(self,frame)
    if self._bind then
        if self._bind[frame.Name] then
            self._bind[frame.Name]:doCleaning()
            self._bind[frame.Name] = nil
            return true
        end
    end
    return false
end

function bind(self,frame,fn)
    --bind connection from the current frame gived
    if not self._bind then
        self._bind = {}
    end
    if (frame) then
        if self._bind[frame.Name] then
            return frame
        else
            self._bind[frame.Name] = Maid.new()
            self._bind[frame.Name]:giveTask(frame.MouseEnter:Connect(function()
                SoundService:PlayLocalSound(SoundService.Mouse_hover)  
                TweenService:Create(frame.UIScale,TweenInfo.new(0.2),{Scale = 0.9}):Play()
            end))
            self._bind[frame.Name]:giveTask(frame.MouseLeave:Connect(function()
                TweenService:Create(frame.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
            end))
            if (frame.Activated) then
                self._bind[frame.Name]:giveTask(frame.Activated:Connect(function()
                    SoundService:PlayLocalSound(SoundService.Click)
                    if (fn) then
                        fn()
                    end
                end))
            end
        end
        return frame
    end
    return false
end

function changeBlurSize(newSize)
    TweenService:Create(Lighting.Blur,TweenInfo.new(0.2),{Size = newSize}):Play()
end

function TweenPlayerFOV(newFOV)
    local camera = workspace.CurrentCamera
    TweenService:Create(camera,TweenInfo.new(0.2),{FieldOfView = newFOV}):Play()
end

function Shop:Construct(parent)
    if not self.constructed then
        self.constructed = {}
        createAutobindingForShop(self)
        if type(parent) == "table" then
            for i,child in parent do
                if child:IsA("Frame") then
                    self.constructed[child.Name] = {}
                    self.constructed[child.Name]._maid = Maid.new()
                    self.constructed[child.Name]._maid:giveTask(child.MouseEnter:Connect(function()
                        SoundService:PlayLocalSound(SoundService.Mouse_hover)
                        TweenService:Create(child.UIScale,TweenInfo.new(.2),{Scale = 0.95}):Play()
                    end))
                    self.constructed[child.Name]._maid:giveTask(child.MouseLeave:Connect(function()
                        TweenService:Create(child.UIScale,TweenInfo.new(.2),{Scale = 1}):Play()
                    end))
                    if child:FindFirstChildOfClass("ImageButton") then
                        self.constructed[child.Name]._maid:giveTask(child:FindFirstChildOfClass("ImageButton").Activated:Connect(function()
                            SoundService:PlayLocalSound(SoundService.Click)
                            if child.Name == "ShopDisplayer" then
                                if ReturnShopFrame():FindFirstChild("Background").UIScale.Scale >= 1 then
                                    changeBlurSize(0)
                                    TweenPlayerFOV(70)
                                    TweenService:Create(ReturnShopFrame():FindFirstChild("Background").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                else
                                    changeBlurSize(24)
                                    TweenPlayerFOV(40)
                                    TweenService:Create(ReturnShopFrame():FindFirstChild("Background").UIScale,TweenInfo.new(.2),{Scale = 1}):Play()
                                    TweenService:Create(returnSettingsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                    TweenService:Create(returnRewardsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                    TweenService:Create(returnStatsFrame().Insider.UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                end
                            elseif child.Name == "Settings" then
                                if returnSettingsFrame():FindFirstChild("main").UIScale.Scale >= 1 then
                                    changeBlurSize(0)
                                    TweenPlayerFOV(70)
                                    TweenService:Create(returnSettingsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                else
                                    changeBlurSize(24)
                                    TweenPlayerFOV(40)
                                    TweenService:Create(returnSettingsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 1}):Play()
                                    TweenService:Create(ReturnShopFrame():FindFirstChild("Background").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                    TweenService:Create(returnStatsFrame().Insider.UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                    TweenService:Create(returnRewardsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                end
                            elseif child.Name == "Dailyrewards" then
                                if returnRewardsFrame():FindFirstChild("main").UIScale.Scale >= 1 then
                                    changeBlurSize(0)
                                    TweenPlayerFOV(70)
                                    TweenService:Create(returnRewardsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                else
                                    changeBlurSize(24)
                                    TweenPlayerFOV(40)
                                    TweenService:Create(returnRewardsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 1}):Play()
                                    TweenService:Create(ReturnShopFrame():FindFirstChild("Background").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                    TweenService:Create(returnStatsFrame().Insider.UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                    TweenService:Create(returnSettingsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                end
                            elseif child.Name == "StatsDisplayer" then
                                if returnStatsFrame().Insider.UIScale.Scale >= 1 then
                                    changeBlurSize(0)
                                    TweenPlayerFOV(70)
                                    TweenService:Create(returnStatsFrame().Insider.UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                else
                                    changeBlurSize(24)
                                    TweenPlayerFOV(40)
                                    StatsPromiser()
                                    TweenService:Create(returnStatsFrame().Insider.UIScale,TweenInfo.new(.2),{Scale = 1}):Play()
                                    TweenService:Create(returnRewardsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                    TweenService:Create(ReturnShopFrame():FindFirstChild("Background").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                    TweenService:Create(returnSettingsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
                                end
                            end
                        end))
                    end
                end
            end
        else
            self.constructed[parent.Name] = parent
        end
    else
    end
    return self.constructed
end

function Shop:Destroy()
    if self.constructed then
        table.clear(self.constructed)
        self.constructed = nil
        return true
    else
        return false
    end
end

return Shop
