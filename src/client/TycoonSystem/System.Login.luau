local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Util = script.Parent.__index.Utils

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Option = require(ReplicatedStorage.Packages.Option)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Path = require(ReplicatedStorage.Packages.PathfindingModule)
local Proxi = require(ReplicatedStorage.Packages.ProximityPrompt)
local Signal = require(Knit.Util.Signal)
local Message = require(ReplicatedStorage.Packages.Message)

local LoadFriend = require(script.Parent.__index.LoadFriend)
local OpenFridge = require(Util.OpenFridge)
local CupsModule = require(Util.CupsArray)
local Beam_util = require(Util["Beam.util"])
local signal_message = require(Util["Message.signal"])
local tools_addons = require(Util["Tools.addons"])
local Overhead_util = require(Util["Overhead.util"])
local MoneyDisplayer = require(Util.MoneyDisplayer)
local Board_util = require(Util["Board.util"])

local System = {}
System.__index = System

function System:Connect()
    --[=[
        Connect the local player to the System.Component:InsertPlayerLocation(player:Player) -> {} or "false"
    ]=]
    local SystemConnector = Knit.GetService("SystemConnector")
    local IsConnected = SystemConnector:ConstructAndConnect()
    return IsConnected
end

function System:LoadConnectedProfile()
    --[=[
        create a loaded table containing , {Cups:number,UsedCups:number,IsConnected:boolean, _signal:Signal.new}
    ]=]
    if not self[Players.LocalPlayer.UserId] then
        self[Players.LocalPlayer.UserId] = {
            Cups = 8,
            UsedCups = 0,
            IsConnected = true,
            FridgeStarted = false,
            LockStepEnable = false,
            _signal = {
                FlavorSignal = Signal.new(),
                BlenderSignal = Signal.new(),
                SyrupSignal = Signal.new(),
                ToppingSignal = Signal.new(),
                ServeSignal = Signal.new(),
                RestartSignal = Signal.new(),
            },
            _cupsTransparencyIndex = 0
        }   
    end
    return self[Players.LocalPlayer.UserId]
end

function System:GetProfile()
    return self[Players.LocalPlayer.UserId]
end

function System:IsConnectedAnd(plot)
    --[=[
        when the system created the player profil the step 1 for the system can start succesfully
    ]=]
    local Profile = self:LoadConnectedProfile()
    local SystemConnector = Knit.GetService("SystemConnector")
    local getFriendId = LoadFriend(Players.LocalPlayer)
    local getFriendName = ""
    local succes,value = pcall(function()
        return Players:GetNameFromUserIdAsync(getFriendId)
    end)
    if succes then
        getFriendName = value   
    else
        getFriendName = "failed"
    end
    print("@"..getFriendName," is loaded for : @"..Players.LocalPlayer.Name)
    local OnFirstEnterMessage = Message.new({
        message = "@"..getFriendName,
        suffix = "has entered your restaurant",
        color = "rgb(85, 170, 255)",
        style = "b"
    })
    signal_message:Send(OnFirstEnterMessage:Get())
    OnFirstEnterMessage:Clean()
    local CreateBoard = Board_util.board({
        typeMessage = Message.new({
        prefix = "Cups remainings:",
        message = tostring(Profile.Cups),
        suffix = "🙂",
        color = "rgb(85, 170, 127)",
        style = "b",}):Get()

    })
    CreateBoard:SetParent(
        workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plot.Name):FindFirstChild(plot.Name.."|Counter").Counter1:FindFirstChild("SurfaceLabel")
    )
    local MultiplierClass = SystemConnector:CreateCompute()
    local MatchPlotToOption = Option.Some(plot)
    MatchPlotToOption:Match{
        Some = function(model) 
            local MainPart = workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(model.Name):FindFirstChild(model.Name.."|Counter").PrincipalCounter.Main
            if not MainPart then return end
            SystemConnector:CreateConfigPath(
                Path.Create({Origin = Vector3.zero,Target = MainPart.Position,Friend = getFriendName,base = MainPart})
            )   
            ---------Detected-Path-Ended-Signal-[RE_CLIENT]-----------------
            SystemConnector.OnRemovePathSignal:Connect(function(rig) -- create a proximity prompt to take the order from the loaded rig
                local reception = Proxi.new(
                    {Name = "reception",
                    parent = workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(model.Name):FindFirstChild(model.Name.."|Counter").PrincipalCounter.Cashier.ToolGiver,
                    action = "Take",
                    object = tostring(getFriendName),
                    activationDistance = 10,
                    holdDuration = 0.2, 
                    keyboardKeyCode = Enum.KeyCode.E
                    })
                local beam = Beam_util.new({
                    startPos = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment"),
                    endPos = reception._memory.Info.parent:FindFirstChild("Attachment"),
                    txt = "rbxassetid://13458740792"
                })
                self.element = Overhead_util.create(rig:FindFirstChild("Head"))
                reception:HandleTriggeredConnection(function(player)
                    -- handle the reception step
                    if self:GetProfile().Cups <= 0 then
                        reception:ChangeState(false) -- disable the proxi
                        local CleanCupsMessage = Message.new({
                            message = "Please clean your cups before taking a command.",
                            color = "rgb(255, 0, 0)",
                            style = "b"
                        })
                        signal_message:Send(CleanCupsMessage:Get()) -- send a notification to the client.
                        CleanCupsMessage:Clean()
                        --check if player have the janitor gamepass
                        if MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId,800487581) then
                            --bind the wahsing step directly
                            CupsModule:MoveToCleanStep(
                                workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plot.Name):FindFirstChild(plot.Name.."|Counter").Sink
                                ,Profile
                                ,plot.Name
                                ,reception
                                ,CreateBoard
                            )
                        else -- if the player didn't have the gamepass
                            CupsModule:IsDone(function()
                                repeat  
                                    task.wait()
                                until self:GetProfile().UsedCups <= 0 or Players.LocalPlayer == nil -- yield until all cups is cleaned and then the next step is connected for the client
                                local IsDoneMessage = Message.new({
                                    message = "Every diry cups are cleaned now go wash your cups.",
                                    color = "rgb(255, 255, 255)",
                                    style = "b"
                                })
                                CreateBoard:ChangeText(IsDoneMessage:Get())
                                signal_message:Send(IsDoneMessage:Get())
                                IsDoneMessage:Clean()
                                CupsModule:MoveToCleanStep(
                                    workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plot.Name):FindFirstChild(plot.Name.."|Counter").Sink
                                    ,Profile
                                    ,plot.Name
                                    ,reception
                                    ,CreateBoard
                                )
                            end)
                        end
                    else -- if is not egal to 0 or lower than 0
                        --check if all seat is taken...
                        if SystemConnector:SeatRemaining() <= 0 then
                            local OnNoSeatRemainingMessage = Message.new({
                                message = "Please clean your tables...",
                                color = "rgb(85, 170, 255)",
                                style = "b"
                            })
                            signal_message:Send(OnNoSeatRemainingMessage:Get())
                            OnNoSeatRemainingMessage:Clean()
                            return print("please wait..")
                        end
                        --class the component again for a new order
                        local ClientFlavor = SystemConnector:InsertFlavor(plot.Name)
                        self._component = tools_addons.addToCharacterHand(
                            Players.LocalPlayer.Character,
                            string.split(ClientFlavor.Name," ")[1]
                        )
                        self.element:ChangeAndReform(
                            rig:FindFirstChild("Head"),
                            string.split(ClientFlavor.Name," ")[1]
                        )
                        if ClientFlavor then
                            Profile.UsedCups = Profile.UsedCups + 1
                            Profile.Cups = Profile.Cups - 1
                            CreateBoard:ChangeText(
                                Message.new({prefix = "Cups remainings:",
                                message = tostring(Profile.Cups),
                                suffix = "🙂",
                                color = "rgb(85, 170, 127)",
                                style = "b",}):Get()
                            )
                            if Profile.Cups <= 0 then
                                CreateBoard:ChangeText("All cups are picked up, please clean them in the kitchen")
                            end
                            self:GetProfile()._cupsTransparencyIndex =  self:GetProfile()._cupsTransparencyIndex + 1
                            CupsModule:CompactWithBoard(plot.Name,self:GetProfile()._cupsTransparencyIndex)
                            Profile._signal.FlavorSignal:Fire(ClientFlavor)
                            beam:Destroy()
                            reception:DisconnectTriggerConnection()
                            reception:Clean()
                        end

                    end
                end)
            end)
            -------Flavor-Signal-----------
            Profile._signal.FlavorSignal:Connect(function(flavor)
                --[=[
                    create proximity for the given flavor and when is triggered the blender will be loaded
                ]=]
                if not flavor then 
                    return 
                end
                print("[System-Client]",flavor," is connected for the client.")
                local handle = Proxi.new({
                    Name = "handle",
                    parent = flavor.Tittle:FindFirstChildOfClass("Attachment"),
                    action = "Equip",
                    object = flavor.Name,
                    activationDistance = 10,
                    holdDuration = 0.2,
                    keyboardKeyCode = Enum.KeyCode.E
                })
                local beam = Beam_util.new({
                    startPos = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment"),
                    endPos = handle._memory.Info.parent,
                    txt = "rbxassetid://13458740792"
                })
                handle:HandleTriggeredConnection(function(player)
                    --handle the flavor step 
                    local ClientBlender = SystemConnector:InsertBlender(plot.Name)
                    if self._component then
                        self._component:ApplyChange("flavor")
                    end
                    if ClientBlender then
                        Profile._signal.BlenderSignal:Fire(ClientBlender,flavor.Name)
                        beam:Destroy()
                        handle:DisconnectTriggerConnection()
                        handle:Clean()       
                    end
                end)
            end)
            ------Blender-Signal------------
            Profile._signal.BlenderSignal:Connect(function(blender,flavor)
                --[=[
                    create proximity for the given blender
                ]=]
                if not blender then
                    return
                end
                warn(flavor,"|Item")
                print("[System-Client]",blender," is connected for the client.")
                local connectionInstance = Proxi.new({
                    Name = "Blender",
                    parent = blender:FindFirstChild("ParticlePart"),
                    action = "Blend",
                    object = "Blender",
                    activationDistance = 10,
                    holdDuration = 0.2,
                    keyboardKeyCode = Enum.KeyCode.E
                })
                local beam = Beam_util.new({
                    startPos = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment"),
                    endPos = connectionInstance._memory.Info.parent:FindFirstChild("Attachment"),
                    txt = "rbxassetid://13458740792"
                })
                local WAIT_TIME_FOR_BLENDER = 10
                connectionInstance:HandleTriggeredConnection(function(player)
                    -- handle the blender step
                    local ClientSyrup = SystemConnector:InsertSyrup(flavor,plot)
                    if MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId,800114720) then
                        WAIT_TIME_FOR_BLENDER = 0.01
                    else
                        if self._component then
                            self._component:ChangeParent(ReplicatedStorage)
                            local track = self._component:GetTrack()
                            if track then
                                track:Stop()
                                track.Looped = false
                            end
                        end
                    end
                     if ClientSyrup then
                        connectionInstance:DisconnectTriggerConnection()
                        beam:Destroy()
                        connectionInstance:Clean() 
                        blender:FindFirstChild("ParticlePart"):FindFirstChildOfClass("ParticleEmitter").Enabled = true
                        task.wait(WAIT_TIME_FOR_BLENDER)
                        local track = self._component:GetTrack()
                        if track then
                            track:Play()
                            track.Looped = true
                        end
                        self._component:MoveToDefaultParent()
                        blender:FindFirstChild("ParticlePart"):FindFirstChildOfClass("ParticleEmitter").Enabled = false
                        Profile._signal.SyrupSignal:Fire(ClientSyrup)
                    else
                        local recursive = SystemConnector:RetryToGetSyrup(plot.Name,flavor)
                        signal_message:Send(Message.new({
                            message = "Blender skiped due to a error",
                            style = "b",
                            color = "rgb(255,0,0)",
                        }):Get()) -- send a message to the client...
                        if (recursive) then
                            self._component:MoveToDefaultParent() 
                            connectionInstance:DisconnectTriggerConnection()
                            beam:Destroy()
                            connectionInstance:Clean() 
                            Profile._signal.SyrupSignal:Fire(recursive)
                        else
                            return SystemConnector:Debug()
                        end
                    end
                end)
            end)
            --------Syrup-Signal----------
            Profile._signal.SyrupSignal:Connect(function(syrup)
                --[=[
                    create a proximity for the given syrup [syrup]
                ]=]
                if not syrup then
                    return
                end
                print("[System-Client]",syrup,"is now connected for the client")
                local event = Proxi.new({
                    Name = "syrup",
                    parent = syrup:FindFirstChild("Bottom").Attachment,
                    action = "Equip",
                    object = syrup.Name,
                    activationDistance = 10,
                    holdDuration = 0.2,
                    keyboardKeyCode = Enum.KeyCode.E
                })
                local beam = Beam_util.new({
                    startPos = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment"),
                    endPos = event._memory.Info.parent,
                    txt = "rbxassetid://13458740792"
                })
                event:HandleTriggeredConnection(function(player)
                    --[=[
                        handle the syrup step
                    ]=]
                    local ClientToppings = SystemConnector:InsertToppings(syrup)
                    if self._component then
                        self._component:ApplyChange("syrup")
                    end
                    if ClientToppings then
                        Profile._signal.ToppingSignal:Fire(ClientToppings)
                        beam:Destroy()
                        event:DisconnectTriggerConnection()
                        event:Clean()    
                    end
                end)
            end)
            ----------Toppings-Signal-------------
            Profile._signal.ToppingSignal:Connect(function(topping)
                --[=[
                    Create a proximity for the fridge and connect the correspond ui from the topping Name
                ]=]
                if not topping then
                    return
                end
                print("[System-Client]",topping,"<[Fridge Part]/> is now connected for the client")
                local fridge = Proxi.new({
                    Name = "Fridge",
                    parent = workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(model.Name):FindFirstChild(model.Name.."|Counter").Fridge.Door.Attachment,
                    action = "Interact",
                    object = "Open",
                    activationDistance = 10,
                    holdDuration = 0.2,
                    keyboardKeyCode = Enum.KeyCode.E
                })
                local beam = Beam_util.new({
                    startPos = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment"),
                    endPos = fridge._memory.Info.parent,
                    txt = "rbxassetid://13458740792"
                })
                local class = nil
                fridge:HandleTriggeredConnection(function(player)
                    --[=[
                        handle the fridge step
                    ]=]
                    if Profile.FridgeStarted ~= true and not class then
                        if not MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId,800380746) then -- auto toppings owned or not
                            class = OpenFridge.open(topping)
                                Profile.FridgeStarted = true
                                class.FinishedSignal:Once(function() -- this signal is important for cancelling from the local player.
                                Profile._signal.ServeSignal:Fire()
                                Profile.FridgeStarted = false     
                                if self._component then
                                    self._component:ApplyChange("toppings")
                                end
                                class:Destroy()
                                beam:Destroy()
                                fridge:DisconnectTriggerConnection()
                                fridge:Clean()                        
                            end)
                        else
                            Profile._signal.ServeSignal:Fire()
                            Profile.FridgeStarted = false

                            if self._component then
                                self._component:ApplyChange("toppings")
                            end
                            
                            beam:Destroy()
                            fridge:DisconnectTriggerConnection()
                            fridge:Clean()     
                        end
                    else
                        class:OpenUi()
                    end
                end)
            end)
            -------Serve-NPC-Order-Signal-----------
            Profile._signal.ServeSignal:Connect(function()
                --[=[
                    Create a proximity for serve the rig
                ]=]
                print("[System-Client] Server signal connected.")
                local BackToReception = Proxi.new(
                    {Name = "reception",
                    parent = workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(model.Name):FindFirstChild(model.Name.."|Counter").PrincipalCounter.Cashier.ToolGiver,
                    action = "Serve",
                    object = tostring(getFriendName),
                    activationDistance = 10,
                    holdDuration = 0.2, 
                    keyboardKeyCode = Enum.KeyCode.E
                    })
                local beam = Beam_util.new({
                    startPos = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment"),
                    endPos = BackToReception._memory.Info.parent:FindFirstChild("Attachment"),
                    txt = "rbxassetid://13458740792"
                })
                local value = 35
                if MultiplierClass.Double then -- if the player have the double 2x money
                    value = 70
                    if MultiplierClass.TipsJar and not MultiplierClass.Cashier and not MultiplierClass.Vip then -- tips
                        value = 75
                    elseif MultiplierClass.TipsJar and MultiplierClass.Cashier and not MultiplierClass.Vip then -- tips + cashier
                        value = 85
                    elseif not MultiplierClass.TipsJar and MultiplierClass.Cashier and MultiplierClass.Vip  then -- vip + cashier
                        value = 132
                    elseif MultiplierClass.Tips and not MultiplierClass.Cahiser and MultiplierClass.Vip then -- tips + vip
                        value = 127
                    elseif MultiplierClass.TipsJar and MultiplierClass.Cashier and MultiplierClass.Vip then -- all
                        value = 137
                    elseif not MultiplierClass.TipsJar and MultiplierClass.Cashier and not MultiplierClass.Vip then -- cashier
                        value = 80
                    elseif not MultiplierClass.Tips and not MultiplierClass.Cashier and MultiplierClass.Vip then -- vip
                        value = 122
                    end
                else
                    if MultiplierClass.TipsJar and not MultiplierClass.Cashier and not MultiplierClass.Vip then -- tips
                        value = 40
                    elseif MultiplierClass.TipsJar and MultiplierClass.Cashier and not MultiplierClass.Vip then -- tips + cashier
                        value = 50
                    elseif not MultiplierClass.TipsJar and MultiplierClass.Cashier and MultiplierClass.Vip  then -- vip + cashier
                        value = 97
                    elseif MultiplierClass.Tips and not MultiplierClass.Cahiser and MultiplierClass.Vip then -- tips + vip
                        value = 55
                    elseif MultiplierClass.TipsJar and MultiplierClass.Cashier and MultiplierClass.Vip then -- all
                        value = 102
                    elseif not MultiplierClass.TipsJar and MultiplierClass.Cashier and not MultiplierClass.Vip then -- cashier
                        value = 45
                    elseif not MultiplierClass.Tips and not MultiplierClass.Cashier and MultiplierClass.Vip then -- vip
                        value = 52
                    end
                end
                local OnServeMessage = Message.new({
                    prefix = "You won",
                    message = tostring(value).."$",
                    suffix = "😎",
                    color = "rgb(85, 255, 127)",
                    stlye = "b",
                })
                BackToReception:HandleTriggeredConnection(function(player)
                    --[=[
                        handle the last step before the next order
                    ]=]
                    local RigMovedToASeat = SystemConnector:MoveRigToASeat(plot.Name)
                    if RigMovedToASeat then
                        if self._component then
                            self._component:Destroy()
                            self._component = nil
                        end
                        if self.element then
                            self.element:Destroy()
                            self.element = nil
                        end
                        SystemConnector:AddCashToPlayer(value)
                        MoneyDisplayer:animRandomPositionDisplay()
                        signal_message:Send(OnServeMessage:Get())
                        Profile._signal.RestartSignal:Fire()
                        beam:Destroy()
                        OnServeMessage:Clean()
                        BackToReception:DisconnectTriggerConnection()
                        BackToReception:Clean()
                    else
                        return Promise.reject("Failed to move the rig to a seat.")
                    end
                end)
            end)
             -----Restart-Process-Signal-----
            Profile._signal.RestartSignal:Connect(function()
                --[=[
                    restart the signal to the step 1
                ]=]
                local MainPart = workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(model.Name):FindFirstChild(model.Name.."|Counter").PrincipalCounter.Main
                if not MainPart then return end
                getFriendId = LoadFriend(Players.LocalPlayer)
                local s,v = pcall(function()
                    return Players:GetNameFromUserIdAsync(getFriendId)
                end)
                if succes then
                    getFriendName = v   
                else
                    getFriendName = "failed"
                end
                local OnRestartEnterMessage = Message.new({
                    message = "@"..getFriendName,
                    suffix = "has entered your restaurant",
                    color = "rgb(85, 170, 255)",
                    style = "b"
                })
                signal_message:Send(OnRestartEnterMessage:Get())
                OnRestartEnterMessage:Clean()
                SystemConnector:CreateConfigPath(
                    Path.Create({Origin = Vector3.zero,Target = MainPart.Position,Friend = getFriendName,base = MainPart})
                 )
             end)
             -------Adding-Dirty-Cups-Signal---------
             SystemConnector.OnDirtyCupsAddedSignal:Connect(function(model,seat)
                if (model) and (seat) then
                    CupsModule:addHandler(
                        plot,
                        model,
                        Profile,
                        seat
                    )
                end
             end)
        end,
        None = function()  
            -- reject a promise , to handle the error without impacting the code
            return Promise.reject("Something went wrong trying to get the local player plot"):catch(warn)
        end

    }
end

return System
