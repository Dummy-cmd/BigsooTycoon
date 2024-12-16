local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local TycoonModelFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("TycoonModel")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Zone = require(ReplicatedStorage.Packages.Zone)
local Trove = require(ReplicatedStorage.Packages.Trove)

local SystemLogin = require(script.Parent["System.Login"])

local Component = {}

function Component:LoginToPlayer(plotName)
    --[=[
        Log button to the current local player and with his plot name | tycoon name
    ]=]
    local WaitTime = 0
    local ButtonsService = Knit.GetService("ButtonsService")
    if self[Players.LocalPlayer.Name] ~= nil then return end
    self[Players.LocalPlayer.Name] = require(script.Parent.__index.DataLogin)
    self[Players.LocalPlayer.Name].Data = ButtonsService:GetLocalStore(Players.LocalPlayer.UserId).Vls.TycoonProgress or {}
    self[Players.LocalPlayer.Name].ItemId = ButtonsService:GetLocalStore(Players.LocalPlayer.UserId).Vls.IdProgresstion.currentId or 1
    self[Players.LocalPlayer.Name].FlavorId = ButtonsService:GetLocalStore(Players.LocalPlayer.UserId).Vls.IdProgresstion.flavorId or 1
    self[Players.LocalPlayer.Name].TableId = ButtonsService:GetLocalStore(Players.LocalPlayer.UserId).Vls.IdProgresstion.tableId or 1
    if self[Players.LocalPlayer.Name].TableId <= 1 then
        self[Players.LocalPlayer.Name].TableId = self[Players.LocalPlayer.Name].TableId + 1
        ButtonsService:UpdateTableId(Players.LocalPlayer.UserId,self[Players.LocalPlayer.Name].TableId)
        print("Methods for table adding +1 due to button failed on data loading")
    end
    local ClassicItemOnLoad = function()
        if (plotName) then
            -- load classic button
            local LoadedButton = self:LoadButton(self[Players.LocalPlayer.Name],plotName,self[Players.LocalPlayer.Name].Data) -- yield until all button is loaded
            if type(LoadedButton) == "table" then
                if #LoadedButton <= 0 then
                else
                    for index,value in ipairs(LoadedButton) do
                        if (value) then
                            local onConnection = Promise.new(function(resolve,reject)
                                self:BindConnectionToInstance(value,plotName)
                                resolve(value)
                            end):catch(warn):andThen(function(r)
                                if (r) then
                                    print(r.Name , "will get a connection for: @"..Players.LocalPlayer.Name)
                                end
                            end):await()
                        end
                    end
                end
            end
            return LoadedButton
        end
    end
    local FlavorItemOnLoad = function()
        -- load flavor button
        if (plotName) then
            local LoadedButton = self:LoadFlavorButton(self[Players.LocalPlayer.Name],plotName,self[Players.LocalPlayer.Name].Data) -- yield until all button is loaded
            if type(LoadedButton) == "table" then
                if #LoadedButton <= 0 then
                else
                    for index,value in ipairs(LoadedButton) do
                        if (value) then
                            local onConnection = Promise.new(function(resolve,reject)
                                self:BindConnectionToInstance(value,plotName)
                                resolve(value)
                            end):catch(warn):andThen(function(r)
                                if (r) then
                                    print(r.Name , "will get a connection for: @"..Players.LocalPlayer.Name)
                                end
                            end):await()
                        end
                    end
                end
            end
            return LoadedButton
        end
    end 
    local TablesItemOnLoad = function()
        -- Load Tables item
        if (plotName) then
            local LoadedButton = self:LoadTablesButton(self[Players.LocalPlayer.Name],plotName,self[Players.LocalPlayer.Name].Data)
            if type(LoadedButton) == "table" then
                if #LoadedButton <= 0 then
                else
                    for index,value in ipairs(LoadedButton) do
                        if (value) then
                            local onConnection = Promise.new(function(resolve,reject)
                                self:BindConnectionToInstance(value,plotName)
                                resolve(value)
                            end):catch(warn):andThen(function(r)
                                if (r) then
                                    print(r.Name , "will get a connection for: @"..Players.LocalPlayer.Name)
                                end
                            end):await()
                        end
                    end
                end
            end

            return LoadedButton
        end
    end
    local DataLoaderFn = function()
        -- Load data here
        local function resolveModel(model)
            return Promise.resolve(model)
        end 
        for i,model in self[Players.LocalPlayer.Name].Data do
            resolveModel(model):andThen(function(result)
                print(result,model)
                ButtonsService:ConvertButtonToModel(plotName.Name,result)
            end):catch(warn):await()
        end
        warn("<Data finished to load>")
    end
    if #self[Players.LocalPlayer.Name].Data > 0 then -- load data type
        DataLoaderFn()
        WaitTime = 2
    end
    task.wait(WaitTime)
    local Items = ClassicItemOnLoad() -- can yield if the player have alots of loaded model
    local Flavors = FlavorItemOnLoad() -- can yield if the player have alots of loaded model
    local Tables = TablesItemOnLoad() -- can yield if the player have alots of loaded model
    -- this part is for attach some specific object to their collection 
    local Savors = workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name):FindFirstChild(plotName.Name.."|Counter").Savors
    local Flavors = workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name):FindFirstChild(plotName.Name.."|Flavors")
    local FirstTableFolder = workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name):FindFirstChild(plotName.Name)
    local GetVanilla = Flavors:FindFirstChildOfClass("Model")
    local VanillaSyrups = Savors:FindFirstChildOfClass("Model")
    if VanillaSyrups and GetVanilla then
        ButtonsService:AddModelToPlayerListener(VanillaSyrups,plotName.Name)
        ButtonsService:AddModelToPlayerListener(GetVanilla,plotName.Name)
    end
    for i,table in FirstTableFolder:GetChildren() do
        if table:IsA("Model") then
            ButtonsService:AddTableModelToPlayerListener(table,plotName.Name)
        end
    end   
    for i,model in workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name).Items:GetChildren() do
        if (model) then
            if string.find(model.Name,"flavor") then
                ButtonsService:AddModelToPlayerListener(model,plotName.Name)
            elseif string.find(model.name,"Table") or string.find(model.Name,"table") or string.find(model.Name,"sitting") then 
                ButtonsService:AddTableModelToPlayerListener(model,plotName.Name)
            end
        end
    end
    local function ConnectAndReturnAPromise() 
        --[=[
            Return a value; [bool or table], and call the next function if is succes
        ]=]
        return Promise.new(function(resolve,reject)
            local isConnected = SystemLogin:Connect()

            if self[Players.LocalPlayer.Name].ItemId >= 111 then
                print("Tycoon completed badge award function will be called for @",Players.LocalPlayer.Name)
                ButtonsService:ObtainCompletedBadge()
            end
            resolve(isConnected)
        end)
    end
    ConnectAndReturnAPromise():andThen(function(isConnected)
        if type(isConnected) == "table" then
            SystemLogin:IsConnectedAnd(plotName)
        elseif type(isConnected) == "boolean" then
            if isConnected == true then
                SystemLogin:IsConnectedAnd(plotName)
            end
        end
    end):catch(warn)
end


function Component:GetLoginPlayer(player)
    --[=[
        return nil if the player is not connection to the module
    ]=]
    if self[player.Name] then
        return self[player.Name]
    else
        return nil
    end
end


function Component:BindConnectionToInstance(Model,plotName)
    --[=[
        Create a connection for a basic item 
    ]=]
    local GetCurrentItemId = self:GetLoginPlayer(Players.LocalPlayer)
    if not GetCurrentItemId then return end
    local GetPrimaryPart = Model.PrimaryPart
    if GetPrimaryPart then
        local ButtonsService = Knit.GetService("ButtonsService")
        local ModelPrice = ButtonsService:GetModelPriceFromName(plotName.Name,Model.Name)
        local ModelZone = Zone.new(Model.Attach)
        local CanBeRelease = false
        local function statement(bool) -- return true if CanBeRelease is set on true
            if bool == true then
                return true
            else
                return false
            end
        end
        ModelZone.localPlayerEntered:Connect(function()
            if ButtonsService:IsAllowedToBuy(ModelPrice) then
                GetPrimaryPart.CanTouch = false
                CanBeRelease = ButtonsService:ConvertButtonToModel(plotName.Name,Model)
                --
                if not table.find(GetCurrentItemId.Data,Model.Name) then -- insert to data if the model is not find
                    table.insert(GetCurrentItemId.Data,Model.Name)
                    ButtonsService:UpdateLocalStore(workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name).Items:WaitForChild(Model.Name).Name,Players.LocalPlayer.UserId)
                end
                --
                GetCurrentItemId.ItemId = math.round(GetCurrentItemId.ItemId + 1) -- add +1 to the ItemId variable
                ButtonsService:UpdateItemId(Players.LocalPlayer.UserId,GetCurrentItemId.ItemId)
                -- 
                if string.find(Model.Name,"flavor") then -- check if a flavor or not
                    GetCurrentItemId.FlavorId = math.round(GetCurrentItemId.FlavorId + 1) -- add +1 to the FlavorId variable
                    ButtonsService:AddModelToPlayerListener(workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name).Items:WaitForChild(Model.Name),plotName.Name)
                    ButtonsService:UpdateFlavorId(Players.LocalPlayer.UserId,GetCurrentItemId.FlavorId)
                elseif string.find(Model.name,"Table") or string.find(Model.Name,"table") or string.find(Model.Name,"sitting") then -- check if is not a table object
                    GetCurrentItemId.TableId = math.round(GetCurrentItemId.TableId + 1) -- add +1 to the TableId variable
                    ButtonsService:AddTableModelToPlayerListener(workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name).Items:WaitForChild(Model.Name),plotName.Name)
                    ButtonsService:UpdateTableId(Players.LocalPlayer.UserId,GetCurrentItemId.TableId)
                    --
                elseif string.find(Model.Name,"Counter2") then
                    GetCurrentItemId.FlavorId = math.round(GetCurrentItemId.FlavorId + 1) -- add +1 to the FlavorId variable [UnLock the next directly]
                    ButtonsService:UpdateFlavorId(Players.LocalPlayer.UserId,GetCurrentItemId.FlavorId)
                elseif string.find(Model.Name,"Floor1") then
                    --give the first table when the player buy the floor
                    ButtonsService:ConvertButtonToModel(
                        plotName.Name,
                        ReplicatedStorage.Packages.TycoonModel:FindFirstChild(Players.LocalPlayer.Name.."/Tycoon"):FindFirstChild(plotName.Name):FindFirstChild("4 Chair table")
                    )
                    -- insert the table to the player data base
                    table.insert(GetCurrentItemId.Data,Model.Name)
                    ButtonsService:UpdateLocalStore(
                        workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name).Items:WaitForChild("4 Chair table").Name,
                        Players.LocalPlayer.UserId
                    )
                    --adding the table on the player id collection
                    ButtonsService:AddTableModelToPlayerListener(
                        workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name).Items:WaitForChild("4 Chair table"),
                        plotName.Name
                    )
                end
                --
                if statement(CanBeRelease) == true then -- run the release function to advance the next button object
                    self:Update(GetCurrentItemId,plotName)
                else
                end
                --
                if table.find(GetCurrentItemId.IsConnected,Model.Name) then -- check if the purchased button is on the connection list and it would remove the button from the list
                    table.remove(GetCurrentItemId.IsConnected,table.find(GetCurrentItemId.IsConnected,Model.Name))
                end
                --
                ButtonsService:ReducePlayerMoney(plotName.Name,Model:GetAttribute("Price"))
                if GetCurrentItemId.ItemId >= 111 then
                    print("Tycoon completed badge award function will be called for @",Players.LocalPlayer.Name)
                    ButtonsService:ObtainCompletedBadge()
                end
                Model:Destroy()
                ModelZone = nil
            else
                GetPrimaryPart.CanTouch = false
                task.delay(1,function()
                    GetPrimaryPart.CanTouch = true
                end)
            end
        end)
    end
end


function Component:Update(informations,plotName)
    --[=[
        Update signal called after a player buy a new button object
        ButtonsService call release to give the button to the correspond plot
    ]=]
    local ButtonsService = Knit.GetService("ButtonsService")
    if type(informations) ~= "table" then
        return false
    else
        if not plotName then 
            return false
        end
        if informations.ItemId == nil then
            return false
        end
    end
    local UpdatedResult = ButtonsService:release(informations,plotName)
    local UpdateFlavorResult = "Check"
    local UpdateTableResult = "Check"
    --check table type
    if informations.TableId >= 7 then
        if workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name).Items:FindFirstChild("Floor1") then
            UpdateTableResult = ButtonsService:releaseTable(informations,plotName) 
        end
    else
        if workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name).Items:FindFirstChild("Floor1") then
            -- do nothing here is just a check state
        end
        UpdateTableResult = ButtonsService:releaseTable(informations,plotName) -- run until TableId is superior or egal to 7
    end
    --check flavor type
    if informations.FlavorId >= 5 then
        if workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name).Items:FindFirstChild("Counter2") then
            UpdateFlavorResult = ButtonsService:releaseFlavor(informations,plotName)
        end
     else
        if workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plotName.Name).Items:FindFirstChild("Counter2") then
            -- do nothing here is just a check state
        end
        UpdateFlavorResult = ButtonsService:releaseFlavor(informations,plotName) -- run until FlavorId is superior or egal to 5
     end
    --insert flavor to main
    if type(UpdateFlavorResult) == "table" and #UpdateFlavorResult > 0 then
        for i,v in UpdateFlavorResult do
            if not table.find(UpdatedResult,v) then
                table.insert(UpdatedResult,v)
            else
            end
        end
    end
    --insert table object to main
    if type(UpdateTableResult) == "table" and #UpdateTableResult > 0 then
        for i,v in UpdateTableResult do
            if not table.find(UpdatedResult,v) then
                table.insert(UpdatedResult,v)
            else
            end
        end
    end
    local UpdateInformation = informations
    if type(UpdatedResult) == "table" and #UpdatedResult > 0 then
        local ClassicItem = function()
            for index,value in ipairs(UpdatedResult) do
                if (value) then
                    local onConnection = Promise.new(function(resolve,reject)
                        if not table.find(UpdateInformation.IsConnected,value.Name) then -- check if is not already binded
                            table.insert(UpdateInformation.IsConnected,value.Name) -- update the connection list to not make alots of bindings
                            self:BindConnectionToInstance(value,plotName)
                            resolve(value)
                        else
                            resolve(nil)
                        end
                    end):catch(warn):andThen(function(r)
                        if (r) then
                            print(r.Name , "will get a connection for: @"..Players.LocalPlayer.Name)
                        end
                    end):await()
                end
            end
        end 
        local IsFinishedToLoadItem = ClassicItem() -- can yield
        table.clear(UpdatedResult)
        return true
    else
        return false
    end
    return false
end


function Component:LoadButton(informations,plotName,data)
    --[=[
        Load Button only for the client side to not make the server laggy
        @return a table containing local button from the tycoon
    ]=]
    local ButtonsService = Knit.GetService("ButtonsService")
    if type(informations) ~= "table" then
        return false
    else
        if informations.ItemId == nil then
            return false
        end
    end
    local playerTycoon = TycoonModelFolder:FindFirstChild(Players.LocalPlayer.Name.."/Tycoon")
    if not plotName then
        plotName = playerTycoon:FindFirstChildOfClass("Folder")
    end
    if playerTycoon:FindFirstChild(plotName.Name) then
        local buttons = nil
        buttons = ButtonsService:GetItems(plotName,informations.ItemId,data)
        return buttons
    end
    return false
end

function Component:LoadFlavorButton(informations,plotName,_d) 
    --[=[
        Load flavor button only for the client side, to not make the server laggy
        @return a table containing local flavor button from the tycoon
    ]=]
    local ButtonsService = Knit.GetService("ButtonsService")
    if type(informations) ~= "table" then
        return false
    else
        if informations.FlavorId == nil then
            return false
        end
    end
    local playerTycoon = TycoonModelFolder:FindFirstChild(Players.LocalPlayer.Name.."/Tycoon")
    if not plotName then
        plotName = playerTycoon:FindFirstChildOfClass("Folder")
    end
    if playerTycoon:FindFirstChild(plotName.Name) then
        local buttons = nil
        buttons = ButtonsService:GetFlavorItemsId(plotName,informations.FlavorId,_d)
        return buttons
    end
    return false
end

function Component:LoadTablesButton(informations,plotName,_d)
    --[=[
        Load table button only for the client side, to not make the server laggy
        @return a table containing local table from the tycoon
    ]=]
    local ButtonsService = Knit.GetService("ButtonsService")
    if type(informations) ~= "table" then
        return false
    else
        if informations.TableId == nil then
            return false
        end
    end
    local playerTycoon = TycoonModelFolder:FindFirstChild(Players.LocalPlayer.Name.."/Tycoon")
    if not plotName then
        plotName = playerTycoon:FindFirstChildOfClass("Folder")
    end
    if playerTycoon:FindFirstChild(plotName.Name) then
        local buttons = nil
        buttons = ButtonsService:GetTablesFromId(plotName,informations.TableId,_d)    
        return buttons
    end
    return false
end

function Component:CleanOnDisconnecting()
    --[=[
        Clean the login table registered by the local player
    ]=]
    if self[Players.LocalPlayer.Name] then
        table.clear(self[Players.LocalPlayer.Name])
        self[Players.LocalPlayer.Name] = nil
        return true
    end
    return false
end

return Component
