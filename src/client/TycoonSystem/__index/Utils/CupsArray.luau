local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")


local ProximityPromptModule = require(ReplicatedStorage.Packages.ProximityPrompt)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Message = require(ReplicatedStorage.Packages.Message)


local signal_message = require(script.Parent["Message.signal"])
local Beam_util = require(script.Parent["Beam.util"])

local Cups = {}

function Cups:addHandler(plot,model,profile,seat)
    --[=[
        add a proximity class to the table on SystemLogin script
    ]=]
    if not plot then
        return Promise.reject("Failed to get player plot [instance error]")
    end
    if not profile then
        return Promise.reject("Failed to get the profile of the localPlayer")
    end
    if not seat then
        return Promise.rejec("Faield to get retired seat of the localPlayer")
    end
    local part = model:GetChildren()[Random.new():NextInteger(1,#model:GetChildren())]
    if part:IsA("Highlight") then
        warn("[System-Client] attachment parented to a Highlight, parent will be changed to a BasePart")
        part = model:GetChildren()[Random.new():NextInteger(3,#model:GetChildren())]
    end
    local attachment = Instance.new("Attachment",part)
    attachment.CFrame = attachment.CFrame * CFrame.new(2,math.random(0,1.5),0)
    if attachment:FindFirstChildOfClass("ProximityPrompt") then
        return Promise.reject("[System-Client-cleanStep] proxi not created cause its already created")
    end
    local hightLight = Instance.new("Highlight",model)
    hightLight.FillColor = Color3.fromRGB(255,255,255)
    hightLight.OutlineColor = Color3.fromRGB(255,0,0)
    hightLight.OutlineTransparency = 0.2
    local SystemConnector = Knit.GetService("SystemConnector")
    local handler = ProximityPromptModule.new({
        Name = tostring(HttpService:GenerateGUID(false)),
        parent = attachment,
        activationDistance = 10,
        holdDuration = 0.2,
        action = "Clean",
        object = "Cups",
        keyboardKeyCode = Enum.KeyCode.E
    })
    handler.object.RequiresLineOfSight = false
    handler:HandleTriggeredConnection(function(player)
        profile.UsedCups = profile.UsedCups - 1
        SystemConnector:GetRetiredSeat(seat)
        handler:DisconnectTriggerConnection()
        handler:Clean()
        SystemConnector:DestroyModel(model)
    end)
    return handler
end

function Cups:MoveToCleanStep(parent,profile,plot,class,board)
    --[=[
        create a proximity for the sink or the dishwasher
    ]=]
    if not board then
        return false
    end
    if not class then
        return false
    end
    if not profile then
        return false
    end
    if not parent then
        return false
    end
    if not plot then
        return false
    end
    local CleanCupsMessage = Message.new({
        message = "Cups cleaned !",
        color = "rgb(255, 255, 255)",
        style = "b"
    })
    if MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId,800371766) or game:GetService("RunService"):IsStudio() then
        --dishwasher
        parent = workspace.DummyFolder:WaitForChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plot).Items:WaitForChild("Dishwasher")
        local handler = ProximityPromptModule.new({
            Name = tostring(HttpService:GenerateGUID(false)),
            parent = parent.EnabledPart:WaitForChild("Attachment"),
            activationDistance = 10,
            holdDuration = 0.2,
            action = "Clean",
            object = "Cups",
            keyboardKeyCode = Enum.KeyCode.E
        })
        local beam = Beam_util.new({
            startPos = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment"),
            endPos = handler._memory.Info.parent,
            txt = "rbxassetid://13458740792"
        })
        handler:HandleTriggeredConnection(function(player)
            parent.EnabledPart:WaitForChild("ParticleEmitter").Enabled = true
            handler:DisconnectTriggerConnection()
            handler:Clean()
            beam:Destroy()
            task.wait(10)
            print("cups cleaned")
            signal_message:Send(CleanCupsMessage:Get())
            CleanCupsMessage:Clean()
            if class then
                class:ChangeState(true)
            end
            profile.UsedCups = 0
            profile.Cups = 8
            board:ChangeText(
                Message.new({prefix = "Cups remainings:",
                message = tostring(profile.Cups),
                suffix = "🙂",
                color = "rgb(85, 170, 127)",
                style = "b",}):Get()
            )
            self:ResetBoard(plot)
            profile._cupsTransparencyIndex = 0
            parent.EnabledPart:WaitForChild("ParticleEmitter").Enabled = false
            profile.CleanTypeEnable = false
            profile.LockStepEnable = false
        end)
    else
        --normal sink
        local handler = ProximityPromptModule.new({
            Name = tostring(HttpService:GenerateGUID(false)),
            parent = parent.Water:WaitForChild("Attachment"),
            activationDistance = 10,
            holdDuration = 0.2,
            action = "Clean",
            object = "Cups",
            keyboardKeyCode = Enum.KeyCode.E
        })
        local beam = Beam_util.new({
            startPos = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment"),
            endPos = handler._memory.Info.parent,
            txt = "rbxassetid://13458740792"
        })
        handler:HandleTriggeredConnection(function(player)
            parent.Water:WaitForChild("ParticleEmitter").Enabled = true
            handler:DisconnectTriggerConnection()
            handler:Clean()
            beam:Destroy()
            task.wait(25)
            print("cups cleaned")
            signal_message:Send(CleanCupsMessage:Get())
            CleanCupsMessage:Clean()
            if class then
                class:ChangeState(true)
            end
            profile.UsedCups = 0
            profile.Cups = 8
            board:ChangeText(
                Message.new({prefix = "Cups remainings:",
                message = tostring(profile.Cups),
                suffix = "🙂",
                color = "rgb(85, 170, 127)",
                style = "b",}):Get()
            )
            self:ResetBoard(plot)
            profile._cupsTransparencyIndex = 0
            parent.Water:WaitForChild("ParticleEmitter").Enabled = false
            profile.CleanTypeEnable = false
            profile.LockStepEnable = false
        end)
    end
end

function Cups:CompactWithBoard(plot,value)
    --significate that every time the cups used value is changed the cups on the counter is transparent
    if not plot or not value then
        return warn("Failed to update the transparency of used cups",debug.traceback("<[CompactWithBoard]>",2))
    end
    local DefaultCounterObject = workspace.DummyFolder:FindFirstChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plot):FindFirstChild(plot.."|Counter")
    local Counter1 = DefaultCounterObject.Counter1
    if Counter1 then
        if Counter1.Cups then
            for i,v in Counter1.Cups:GetChildren() do
                if v then
                    if string.find(v.Name,tostring(value)) then
                        v.Transparency = 1
                    elseif v.Name == tostring(value) then
                        v.Transparency = 1
                    end
                end
            end
        end
    end
end

function Cups:ResetBoard(plot)
    if not plot then
        return false
    end
    local DefaultCounterObject = workspace.DummyFolder:FindFirstChild(Players.LocalPlayer.Name.."Tycoon"):FindFirstChild(plot):FindFirstChild(plot.."|Counter")
    local Counter1 = DefaultCounterObject.Counter1
    if Counter1 then
        if Counter1.Cups then
            for i,v in Counter1.Cups:GetChildren() do
                v.Transparency = 0.4
            end
        end
    end
end

function Cups:IsDone(callback)
    if type(callback) == "function" then
        return callback()
    end
end

return Cups
