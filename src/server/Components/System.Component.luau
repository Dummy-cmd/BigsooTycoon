local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")

local System_addons = script.Parent.System_addons

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Option = require(ReplicatedStorage.Packages.Option)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Path = require(ReplicatedStorage.Packages.PathfindingModule)
local AnimationsModule = require(ReplicatedStorage.Packages.PathfindingModule.Animations.AddAnim)

local SyrupComponent = require(script.Parent.Buttons_addons.Syrups_addons["Syrups.Component"])
local FlavorComponent = require(script.Parent.Buttons_addons["Flavor.Component"])

local Toppings_addons = require(System_addons["Toppings.addons"])
local CleanRig_adoons = require(System_addons["CleanRig.addons"])
local Table_Component = require(script.Parent.Buttons_addons["Table.Component"])
local ComputeMultiplier = require(System_addons["Multiplier.Component"])

local function CreateRig(parent,name,cf)
    if not parent then -- get the parent if parent is nil
        parent = workspace
    end
    local DefaultRig = ReplicatedStorage.Packages.Rig:Clone()
    DefaultRig.Parent = parent
    DefaultRig.Name = tostring(HttpService:GenerateGUID(false)).." @"..tostring(name)
    local succes, failed = pcall(function()
        DefaultRig.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(Players:GetUserIdFromNameAsync(name)))
    end)
    if not succes then
        warn("canno't apply the humanoid description <Id is null>")
    end
    DefaultRig:PivotTo(cf)
    return DefaultRig
end

local Component = {}

function Component:InsertPlayerLocation(player)
    --[=[
        return a table containing the current inserted player with some specific values in
    ]=]
    assert(type(player) == "userdata","player arg must need to be a player")
    if (self[player.UserId]) then
        return self[player.UserId] 
    end
    self[player.UserId] = {
        _PlayerRemovingTrove = Trove.new()
    }
    self[player.UserId]._PlayerRemovingTrove:Connect(Players.PlayerRemoving,function(plr)
        if (plr == player) then
            self[player.UserId]._PlayerRemovingTrove:Destroy()
        end
    end)
    self[player.UserId]._PlayerRemovingTrove:Add(function()
        self:RemovePlayerLocation(player)
    end)
    print("[System] @"..player.Name.." is now connected to the system")
    return self[player.UserId] 
end

function Component:RemovePlayerLocation(player)
    --[=[
        return true if the given player is deleted correctly
    ]=]
    assert(type(player) == "userdata","player arg must need to be a player")
    if (self[player.UserId]) then
        table.clear(self[player.UserId])
        self[player.UserId] = nil
        for i,u in self do
            if string.find(tostring(i),player.UserId) then
                self[i] = nil
            end
        end
        print("[System] @"..player.Name.." is now disconnected from the system")
    else
        return false
    end
    return true
end

function Component:ConfigPathComponent(player,path)
    --[=[
        Create a pathfinding object with pathfindingModule at ReplicatedStorage.Packages.pathfindingModule
    ]=]
    if not player then
        return false
    end
    if not path then
        return false
    end
    local SystemConnector = Knit.GetService("SystemConnector")
    local function CreateClass()
        return Promise.resolve(Path.Create(path._data.Info))
    end
    CreateClass():andThen(function(IsCreatedAsync)
        if IsCreatedAsync then
            if self[player.UserId.."-async"] then return end
            local cf =  IsCreatedAsync._data.Info.base.Position + IsCreatedAsync._data.Info.base.CFrame.LookVector * -45
            local model = CreateRig(IsCreatedAsync._data.Info.base.Parent.Parent.Parent,IsCreatedAsync._data.Info.Friend,CFrame.new(cf))
            for i,part in model:GetChildren() do
                if part:IsA("BasePart") then
                    part.CollisionGroup = "NPC"
                end
            end
            IsCreatedAsync._data.Info.Origin = model:WaitForChild("HumanoidRootPart").Position
            local result = IsCreatedAsync:ComputeAsync()
            if not result then 
                return
            end
            IsCreatedAsync:RunPathFor(model,true)
            self[player.UserId.."_rig"] = model
            self[player.UserId.."-async"] = true
            IsCreatedAsync:HandleSignalConnection(function()
                local magnitude = (model.HumanoidRootPart.Position - IsCreatedAsync._data.Info.base.Position).Magnitude
                if magnitude > 10 then
                    model:PivotTo(IsCreatedAsync._data.Info.base:GetPivot())        
                end
                SystemConnector:CallRemoveEvent(player,model)
                IsCreatedAsync:Clean()
            end)
        end
    end):catch(warn)
    return true
end

function Component:InsertFlavor(player,plot)
    --[=[
        return a resolve promise value (can be nil)
    ]=]
    if not player then
        return Promise.reject("Player arg must be a player pls, fix it")
    end
    local client = nil
    local promise = Promise.new(function(resolve,reject)
        local GetTaggedInstances = FlavorComponent:GetListenedInstance(player) 
        if #GetTaggedInstances <= 0 then
            reject("Something went wrong while trying to get player flavor")
        end
        local rng = Random.new()
        local index = rng:NextInteger(1,#GetTaggedInstances)
        local flavor = GetTaggedInstances[index]
        if (flavor) then
            print("[System]",flavor.Name,"will be connected to the client for:","@"..player.Name)
            resolve(flavor)
        else
            reject("error while trying to get the flavor from GetTaggedInstances[index]")
        end
    end):catch(warn):andThen(function(value)
        if (value) then
            client = value
        end
    end):catch(warn)
    return client
end 

function Component:InsertBlender(player,plot)
    --[=[
        return a resolve promise (canno't be nil [!])
    ]=]
    if not player then
        return Promise.reject("Player arg must be a player pls, fix it")
    end
    local client = nil
    local promise = Promise.new(function(resolve,reject)
        local BlenderFolder = workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plot):FindFirstChild(plot.."|Blender")
        local blender = BlenderFolder.Blender

        if not blender then
            reject("Blender is null the rejoin part will be runned.")
        end

        print("[System]",blender,"will be connected to the client for:","@"..player.Name)
        resolve(blender)
    end):catch(warn):andThen(function(value)
        if (value) then
            client = value
        end
    end):catch(warn)
    return client
end

function Component:InsertSyrup(player,flavor,plot)
    --[=[
        return a resolved promise (Syrup instance)
    ]=]
    if not player then
        return Promise.reject("Player arg must be a player pls, fix it")
    end
    if not flavor then
        return Promise.reject("Flavor type is null,Promise.reject() executed")
    end
    local client = nil
    local SplitFlavorType = string.split(flavor," ")[1]
    if SplitFlavorType == "Banana" then -- just a quick fix cause some basic flavor are name "Banana flavor", the default name is : "Vanilla flavor"
        SplitFlavorType = "Vanilla"
    end
    local promise = Promise.new(function(resolve,reject)
        local GetTaggedSyrup = SyrupComponent:GetComponents(player.Name.."_syrups") 
        if #GetTaggedSyrup <= 0 then
            reject('GetTaggedSyrup is lower or egal to 0')
        end
        for i,instance in GetTaggedSyrup do
            if string.find(instance.Name,SplitFlavorType) then
                client = instance
                break
            end
        end
        resolve(client)
    end):catch(warn):andThen(function(obj)
        if (obj) then
            print("[System]",obj,"will be connected to the client for:","@"..player.Name)
        end
    end):catch(warn)
    return client
end 

function Component:RetryToGetSyrup(player,plot,flavor)
    --[=[
        return a resolved promise (Syrup instance) RETRY !!!
    ]=]
    if not player then
        return Promise.reject("Player arg must be a player pls, fix it")
    end
    if not plot then
        return Promise.reject("Failed to get player plot from the retry blender function")
    end
    if not flavor then
        return Promise.reject("Flavor type is null,Promise.reject() executed")
    end
    local client = nil
    local SplitFlavorType = string.split(flavor," ")[1]
    if SplitFlavorType == "Banana" then -- just a quick fix cause some basic flavor are name "Banana flavor", the default name is : "Vanilla flavor"
        SplitFlavorType = "Vanilla"
    end
    local GetItemsFolder = workspace.DummyFolder:FindFirstChild(player.Name.."Tycoon"):FindFirstChild(plot).Items
    local GetDefaultSavor = workspace.DummyFolder:FindFirstChild(player.Name.."Tycoon"):FindFirstChild(plot):FindFirstChild(plot.."|Counter").Savors
    local syrups = {}
    if GetItemsFolder and GetDefaultSavor then
        --first try
        for i,item in GetItemsFolder:GetChildren() do
            if string.find(item.Name,"syrup") then
                table.insert(syrups,item)
            end
        end
        for i,default in GetDefaultSavor:GetChildren() do
            if string.find(default.Name,"syrup") then
                table.insert(syrups,default)
            end
        end
        task.spawn(function()
            -- this task see if every owned syrup is added to the CollectionService 
            for i,v in syrups do
                if v then
                    if not SyrupComponent:IsAddedToTag(v,player.Name.."_syrups") then -- if is not added then its gonna add it
                        SyrupComponent:AddInstanceToTags(v,player.Name.."_syrups")
                    end
                end
            end
        end)
        for i,v in syrups do
            if string.find(v.Name,SplitFlavorType) then
                client = v
                break
            end
        end
    end
    return client
end

function Component:InsertToppings(player,syrup)
    --[=[
        return a resolved promise (Topping instance)
    ]=]
    if not player then
        return Promise.reject("Player arg must be a player pls, fix it")
    end
    if not syrup then
        return Promise.reject("Syrup type is null,Promise.reject() executed")
    end
    local client = nil
    local SplitSyrupType = string.split(syrup.Name," ")[1]
    local promise = Promise.new(function(resolve,reject)
        local Topping = Toppings_addons(SplitSyrupType)
        if Topping then
            client = Topping.Name
            resolve(client)
        else
            reject("Topping variable still null,name statement failed.")
        end
    end):catch(warn):andThen(function(obj)
        if (obj) then
            print("[System]",obj,"will be connected to the client for:","@"..player.Name)
        end
    end):catch(warn)
    return client
end

function Component:MoveRigToASeat(player,plot)
    --[=[
        moove the given rig , using  self[player.UserId.."_rig"]
    ]=]
    if not player then
        return Promise.reject("Failed to get the player.")
    end
    if not self[player.UserId.."_rig"] then
        return Promise.reject("Failed to get the rig for :".." @"..player.Name)
    end
    local SeatInstances = CollectionService:GetTagged(player.Name.."_T")
    if #SeatInstances <= 0 then 
        return false 
    end
    local rng = Random.new()
    local NextInteger = rng:NextInteger(1,#SeatInstances)
    local seat = SeatInstances[NextInteger]
    local pack = AnimationsModule:AddAnimPack({
        FolderName = "Rig-Animations",
        walk = "http://www.roblox.com/asset/?id=507777826",
        jump = "http://www.roblox.com/asset/?id=507765000",
        fall = "http://www.roblox.com/asset/?id=507765000",
        idle = "http://www.roblox.com/asset/?id=507766666",
        swing = "http://www.roblox.com/asset/?id=507765000",
        seat = "http://www.roblox.com/asset/?id=2506281703",
    })
    local SeatTrack = nil
    local Humanoid = self[player.UserId.."_rig"]:FindFirstChild("Humanoid")
    if seat then
        self[player.UserId.."_rig"]:PivotTo(seat:GetPivot() * CFrame.new(0,-1.5,0) * CFrame.fromEulerAnglesXYZ(0,0,0))
        Humanoid.Sit = true  
        SeatTrack = Humanoid.Animator:LoadAnimation(pack:FindFirstChild("SeatAnimation"))
        SeatTrack:Play()
        SeatTrack.Looped = true
        self[player.UserId.."_rig"].HumanoidRootPart.Anchored = true
        self[player.UserId.."-async"] = false
        self[player.UserId.."-async"] = nil
        pack:Destroy()
        CollectionService:RemoveTag(seat,player.Name.."_T")
    end
    CleanRig_adoons.addDelay(
        player,
        nil,
        self[player.UserId.."_rig"],
        workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plot).cleans,
        seat
    )
    return true
end

function Component:GetCups(player,plot)
    --[=[
        return a array coutaining instance [Model]
    ]=]
    if not player then
        return Promise.reject("Failed to get the player")    
    end
    if not plot then
        return Promise.reject("Failed to get the player.plot object")
    end
    local array = {}
    for i,model in workspace.DummyFolder:WaitForChild(player.Name.."Tycoon"):FindFirstChild(plot).cleans:GetChildren() do
        if model then
            model.Name = tostring(HttpService:GenerateGUID(false))
            table.insert(array,model)
        end
    end
    return array
end

function Component:GetSeatRemaining(player)
    --[=[
        return a number 
    ]=]
    if not player then
        return Promise.reject("failed to get player for GetSeatRemaining()")
    end
    local SeatInstances = CollectionService:GetTagged(player.Name.."_T")
    return #SeatInstances
end

function Component:AddSeat(player,seat)
    return Table_Component:AddSeat(player,seat)
end

function Component:CreateCompute(player)
    return ComputeMultiplier.ComputeClass(player)
end

return Component
