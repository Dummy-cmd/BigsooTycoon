local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Buttons = ServerStorage.Objects.Buttons
local Addons = script.Parent.Buttons_addons
local SyrupsAddons = Addons.Syrups_addons

local Promise = require(ReplicatedStorage.Packages.Promise)

local FlavorComponent = require(Addons["Flavor.Component"])
local SyrupsComponent = require(SyrupsAddons["Syrups.Component"])
local TablesComponent = require(Addons["Table.Component"])
local DataComponent = require(Addons["Data.Component"])

local Component = {}

function Component:GetItemFromId(player,plotName,id, _d)
    --[=[
        @return all loaded button egal to id reference
    ]=]
    if not (player) then
        return player
    end
    if not plotName then
        return false
    end
    local CreateDuplicatedButtonFolder
    if (ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon")) then
        CreateDuplicatedButtonFolder = Buttons:FindFirstChild(plotName.Name):Clone() -- create a folder for specified button connector
        CreateDuplicatedButtonFolder.Parent = ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon")
        CreateDuplicatedButtonFolder.Name = "Buttons"
    end
    if plotName and id then
        local loadedButtons = {}
        if CreateDuplicatedButtonFolder then
            for i,model in CreateDuplicatedButtonFolder:GetChildren() do
                local constructLocalPromise = Promise.new(function(resolve,reject)
                    if not model:GetAttribute("id") then 
                        -- do nothing cause is not a basic ItemId
                        resolve(nil)
                    else
                        if model:GetAttribute("id") <= id then

                            if table.find(_d,model.Name) then --_d is the player data table
                                model:Destroy()
                                resolve(nil)
                            end

                            local clone = model:Clone()
                            clone.Parent = workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plotName.Name).Buttons
                            if not table.find(loadedButtons,clone) then
                                table.insert(loadedButtons,clone)
                            end

                            model:Destroy()
                            resolve(clone)
                        else
                            resolve(nil)
                        end
                    end
                end):andThen(function(object)
                    if object then
                        object.Attach.BillboardGui.Frame.TextLabel.Text = object:GetAttribute("Item") .. "/" .. object:GetAttribute("Price").."$"
                        print(object.Name, " loaded for: @"..player.Name)
                    end
                end):catch(warn):await() -- yield the given promise to load the next one
            end
        end
        return loadedButtons
    end
    return false
end

function Component:GetModelPriceFromName(player,plotName,modelName)
    --[=[
        Return a infinite number if the model is nil
    ]=]
    if (player) and plotName and modelName then
        local ButtonsFolder = ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon"):FindFirstChild("Buttons")

        if not ButtonsFolder then 
            return math.huge()
        end
        local GetModel = Buttons:FindFirstChild(plotName):FindFirstChild(modelName)
        if GetModel then
            if GetModel:GetAttribute("Price") then
                return GetModel:GetAttribute("Price")
            else
                return math.huge()
            end
        end

        return math.huge()
    end
    return math.huge()
end

function Component:ConvertButtonToModel(player,plotName,model)
    --[[
        Convert button to a created model with scale animation 0 -> 1
    ]]
    local function Convert(result)
        task.spawn(function()
            local defaultScale = result:GetScale()
            result:ScaleTo(0.01)

            for i = 0.01,defaultScale,0.05 do
                result:ScaleTo(math.abs(i))
                task.wait()
            end

            result:ScaleTo(1)
        end)
    end   
    if plotName and model then
        local GetPlayerTycoon = ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon")
        local FindCorrepsondTycoon = GetPlayerTycoon:FindFirstChild(plotName)
        if FindCorrepsondTycoon then
            local CreateModel = Promise.new(function(resolve,reject)
                local GetModel = FindCorrepsondTycoon:FindFirstChild(model.Name or model)
                if GetModel then
                    local clone = GetModel:Clone()
                    clone.Parent = workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plotName).Items
                    resolve(clone)
                else
                    resolve(nil)
                end
            end):andThen(function(result)
                if result then
                    print(result.Name, " created for: @"..player.Name)
                    Convert(result) -- Convert and scall the model here [See the function for more infos]

                    if type(model) ~= "string" then
                        model:Destroy()
                    end
                end
            end):catch(warn)

            return true
        end
    end
    return false
end

function Component:CreateLoginProfil(player)
    --[=[
        Create a login profil to not clone already existed button
    ]=]
    if not player then 
        return false
    end
    if not self[player.UserId.."_profil"] then
        self[player.UserId.."_profil"] = {}
        return self[player.UserId.."_profil"]
    else
        return self[player.UserId.."_profil"]
    end
    return false
end

function Component:release(player,NewItemId,plotName)
    --[=[
        release the next button for the given plot and player
    ]=]
    if (player) and NewItemId and plotName then
        if type(NewItemId) ~= "table" then return end
    else
        return false
    end
    local loadedButtons = self:CreateLoginProfil(player) -- return the hold one if is already created
    if not loadedButtons then 
        return false 
    end
    local ButtonsFolder = ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon"):FindFirstChild("Buttons")
    if not ButtonsFolder then
        return false
    end 
    for i,model in ButtonsFolder:GetChildren() do
        local constructLocalPromise = Promise.new(function(resolve,reject)
            if not model:GetAttribute("id") then 
                -- do nothing cause is not a basic ItemId
                resolve(nil)
            else
                if model:GetAttribute("id") <= NewItemId.ItemId then
                    local clone = model:Clone()
                    if not table.find(loadedButtons,clone) then -- check if is not already gived , and clean if is the case
                        clone.Parent = workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plotName.Name).Buttons
                        table.insert(loadedButtons,clone)
                        model:Destroy()
                        resolve(clone)
                    else
                        resolve(nil)
                    end
                else
                    resolve(nil)
                end
            end
        end):andThen(function(object)
            if object then
                object.Attach.BillboardGui.Frame.TextLabel.Text = object:GetAttribute("Item") .. "/" .. object:GetAttribute("Price").."$"
                print(object.Name, " released for: @"..player.Name) -- print the released object to the output
            end
        end):catch(warn):await() -- yield the given promise to load the next one
    end
    return loadedButtons
end

function Component:releaseFlavor(player,NewItemId,plotName)
    --[=[
        Return a release page containing only flavor Buttons
    ]=]
    if (player) and NewItemId and plotName then
        if type(NewItemId) ~= "table" then return end
    else
        return false
    end
    local attach = self:CreateLoginProfil(player) -- return the hold one if is already created
    local ButtonsFolder = ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon"):FindFirstChild("Buttons")
    if not ButtonsFolder then
        return false
    end 
    for i,model in ButtonsFolder:GetChildren() do
        local constructLocalPromise = Promise.new(function(resolve,reject)
            if not model:GetAttribute("FlavorId") then 
                -- do nothing cause is not a basic ItemId
                resolve(nil)
            else
                if model:GetAttribute("FlavorId") <= NewItemId.FlavorId then
                    local clone = model:Clone()
                    if not table.find(attach,clone) then -- check if is not already gived , and clean if is the case
                        clone.Parent = workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plotName.Name).Buttons
                        table.insert(attach,clone)
                        model:Destroy()
                        resolve(clone)
                    else
                        resolve(nil)
                    end
                else
                    resolve(nil)
                end
            end
        end):andThen(function(object)
            if object then
                object.Attach.BillboardGui.Frame.TextLabel.Text = object:GetAttribute("Item") .. "/" .. object:GetAttribute("Price").."$"
                print(object.Name, " released for: @"..player.Name) -- print the released object to the output
            end
        end):catch(warn):await() -- yield the given promise to load the next one
    end
    return attach
end 

function Component:releaseTable(player,NewItemId,plotName) 
    --[=[
        Return a released page containing only tables Buttons
    ]=]
    if (player) and NewItemId and plotName then
        if type(NewItemId) ~= "table" then return end
    else
        return false
    end
    local attach = self:CreateLoginProfil(player) -- return the hold one if is already created
    local ButtonsFolder = ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon"):FindFirstChild("Buttons")
    if not ButtonsFolder then
        return false
    end 
    for i,model in ButtonsFolder:GetChildren() do
        local constructLocalPromise = Promise.new(function(resolve,reject)
            if not model:GetAttribute("TableId") then 
                -- do nothing cause is not a basic ItemId
                resolve(nil)
            else
                if model:GetAttribute("TableId") <= NewItemId.TableId then
                    local clone = model:Clone()
                    if not table.find(attach,clone) then -- check if is not already gived , and clean if is the case
                        clone.Parent = workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plotName.Name).Buttons
                        table.insert(attach,clone)
                        model:Destroy()
                        resolve(clone)
                    else
                        resolve(nil)
                    end
                else
                    resolve(nil)
                end
            end
        end):andThen(function(object)
            if object then
                object.Attach.BillboardGui.Frame.TextLabel.Text = object:GetAttribute("Item") .. "/" .. object:GetAttribute("Price").."$"
                print(object.Name, " released for: @"..player.Name) -- print the released object to the output
            end
        end):catch(warn):await() -- yield the given promise to load the next one
    end
    return attach
end

function Component:GetFlavorItemsId(player,plotName,Id,_d)
    --[=[
        Create a listener for collection service when a flavor is added to the player Tycoon,
        and is automaticly cleaned when the player leave see more informations at Flavor.Component.lua 
    ]=]
    if not (player) then
        return false
    end
    if not plotName then
        return false
    end
    local listener = FlavorComponent.listenToNewPlayer(player)
    local GetListener = listener:find(listener._host or player)
    if not GetListener then
        return false
    end
    local CreateDuplicatedButtonFolder
    if (ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon")) then
        CreateDuplicatedButtonFolder = ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon").Buttons
    end
    if plotName and Id then
        local loadedButtons = {}
        if CreateDuplicatedButtonFolder then
            for i,model in CreateDuplicatedButtonFolder:GetChildren() do
                local constructLocalPromise = Promise.new(function(resolve,reject)
                    if not model:GetAttribute("FlavorId") then 
                        -- do nothing cause is not a basic ItemId
                        resolve(nil)
                    else
                        if model:GetAttribute("FlavorId") <= Id then

                            if table.find(_d,model.Name) then --_d is the player data table
                                model:Destroy()
                                resolve(nil)
                            end

                            local clone = model:Clone()
                            clone.Parent = workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plotName.Name).Buttons
                            if not table.find(loadedButtons,clone) then
                                table.insert(loadedButtons,clone)
                            end
                            model:Destroy()
                            resolve(clone)
                        else
                            resolve(nil)
                        end
                    end
                end):andThen(function(object)
                    if object then
                        object.Attach.BillboardGui.Frame.TextLabel.Text = object:GetAttribute("Item") .. "/" .. object:GetAttribute("Price").."$"
                        print(object.Name, " loaded for: @"..player.Name)
                    end
                end):catch(warn):await() -- yield the given promise to load the next one
            end
        end
        return loadedButtons
    end
    return false
end

function Component:GetTablesFromId(player,plotName,id,_d)
    --[=[
        return a table  that can be purchased | load button only for table
    ]=]
    if not (player) then
        return false
    end
    if not plotName then
        return false
    end
    local AttachMeta = TablesComponent.AttachTable(player)
    local GetAttached = AttachMeta:find(player)
    if not GetAttached then
        return false
    end
    local CreateDuplicatedButtonFolder
    if (ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon")) then
        CreateDuplicatedButtonFolder = ReplicatedStorage.Packages.TycoonModel:WaitForChild(player.Name.."/Tycoon").Buttons
    end
    if plotName and id then
        local loadedButtons = {}
        if CreateDuplicatedButtonFolder then
            for i,model in CreateDuplicatedButtonFolder:GetChildren() do
                local constructLocalPromise = Promise.new(function(resolve,reject)
                    if not model:GetAttribute("TableId") then 
                        -- do nothing cause is not a basic ItemId
                        resolve(nil)
                    else
                        if model:GetAttribute("TableId") <= id then    
                            if table.find(_d,model.Name) then --_d is the player data table
                                model:Destroy()
                                resolve(nil)
                            end
                            local clone = model:Clone()
                            clone.Parent = workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plotName.Name).Buttons
                            if not table.find(loadedButtons,clone) then
                                table.insert(loadedButtons,clone)
                            end
                            model:Destroy()
                            resolve(clone)
                        else
                            resolve(nil)
                        end
                    end
                end):andThen(function(object)
                    if object then
                        object.Attach.BillboardGui.Frame.TextLabel.Text = object:GetAttribute("Item") .. "/" .. object:GetAttribute("Price").."$"
                        print(object.Name, " loaded for: @"..player.Name)
                    end
                end):catch(warn):await() -- yield the given promise to load the next one
            end
        end
        return loadedButtons
    end    
    return false
end

function Component:AddToListener(player,model,plotName)
    --[=[
        Add flavor model to the player listener collection,
        i will be clean automaticly when the player leave
        @return true if is added , false if is not added
    ]=]
    if not (player) then
        return false
    end
    if not model then
        return false
    end
    local FlavorType = string.split(model.Name," ")
    local isCorrespond = nil
    local function resolveIndex()
        --[=[
            return a resolved promise if the item is find or reject the promise if is not find.
        ]=]
        return Promise.new(function(resolve,reject)
            for i,item in ServerStorage.Objects.Model.Syrops:FindFirstChild(plotName):GetChildren() do
                if string.find(item.Name,FlavorType[1]) then
                    isCorrespond = item
                    break
                end
            end
            if string.find(model.Name,"syrup") then
                isCorrespond = "Type <"..model.Name..">"
            end
            if (isCorrespond ~= nil) then
                resolve(isCorrespond)
            else
                resolve(nil)
            end
        end)
    end
    resolveIndex():andThen(function(instance)
        if (instance) and type(instance) ~= "string" then
            local clone = instance:Clone()
            clone.Parent = workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plotName).Items
            SyrupsComponent:AddInstanceToTags(clone,player.Name.."_syrups")
        elseif type(instance) == "string" then
            SyrupsComponent:AddInstanceToTags(model,player.Name.."_syrups")
        end
    end):catch(warn):finally(function()
        if type(isCorrespond) == "string" then
        else
            if CollectionService:HasTag(model,player.Name.."_key") then
                return false
            else
                CollectionService:AddTag(model,player.Name.."_key")
            end
        end
    end)
    return true
end

function Component:AttachTableToPlayerListener(player,model,plotName)
    --[=[
        return the new updated list if is the table model is attached or return false if is not attached or already attached
    ]=]
    if not (player) then
        return false
    end
    if not model then
        return false
    end
    local seats = {}
    for i,v in model:GetDescendants() do
        if v:IsA("Seat") then
            table.insert(seats,v)
        end
    end
    if #seats <= 0 then
        return false
    end
    for i,seat in seats do
        if not CollectionService:HasTag(seat,player.Name.."_T") then
            CollectionService:AddTag(seat,player.Name.."_T")
        end
    end
    return CollectionService:GetTagged(player.Name.."_T")
end

function Component:GetLocalStore(player,key)
    --[=[
        return Data
    ]=]
    if not (player) then
        return false
    end
    if not key then 
        key = player.UserId
    end
    return DataComponent:GetStoreFromPlayerKey(key)
end
 
function Component:AddToLocalStore(player,value,key)
    --[=[
        return a updated data result see DataComponent:AddModelToPlayerStore() for more info
    ]=]
    if not (player) then
        return false
    end
    if not value then 
        return false
    end
    if not key then 
        key = player.UserId
    end
    return DataComponent:AddModelToPlayerStore(value,key)
end

function Component:UpdateItemId(player,key,newId)
    --[=[
        update the ItemId variable to the local store
    ]=]
    if not (player) then
        return false
    end
    if not key then 
        key = player.UserId
    end
    return DataComponent:UpdateItemId(key,newId)
end

function Component:UpdateTableId(player,key,newId)
     --[=[
        update the TableId variable to the local store
    ]=]
    if not (player) then
        return false
    end
    if not key then 
        key = player.UserId
    end
    return DataComponent:UpdateTableId(key,newId)
end

function Component:UpdateFlavorId(player,key,newId)
    --[=[
        update the FlavorId variable to the local store
    ]=]
    if not (player) then
        return false
    end
    if not key then 
        key = player.UserId
    end
    return DataComponent:UpdateFlavorId(key,newId)
end


return Component
