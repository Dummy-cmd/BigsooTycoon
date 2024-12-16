local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Signal = require(Knit.Util.Signal)

local Displayer = Roact.Component:extend("LoadingMenu")

function Displayer:init()
    self.signalForRef = Signal.new()
    self.ref = Roact.createRef()
    self.signalForRef:Connect(function(component)
        if component then
            TweenService:Create(component.UIScale,TweenInfo.new(0.2),{Scale = 0.85}):Play() 
            TweenService:Create(component,TweenInfo.new(0.2),{Rotation = math.random(45,90)}):Play()
            SoundService:PlayLocalSound(SoundService["button.wav"])
            local element = Players.LocalPlayer.PlayerGui:WaitForChild("hud"):FindFirstChild("Coutainer"):FindFirstChild("Children"):FindFirstChild("CashDisplayer"):FindFirstChild("ImageLabel"):FindFirstChild("ImageLabel"):FindFirstChild("Frame")
            task.delay(1.5,function()
                TweenService:Create(component.UIScale,TweenInfo.new(0.7),{Scale = 0}):Play() 
                TweenService:Create(component,TweenInfo.new(0.5),{Position = element.Position,Rotation = math.random(45,360)}):Play()
                TweenService:Create(component.DisplayerImage,TweenInfo.new(0.7),{ImageTransparency = 1}):Play()
            end)
        end
    end)

end

function Displayer:render()
    return Roact.createElement("Frame",{
        Size = UDim2.fromScale(0.075,0.162),
        AnchorPoint = Vector2.new(.5,.5),
        BackgroundTransparency = 1,
        [Roact.Ref] = self.ref
    },{
        UIScale = Roact.createElement("UIScale",{Scale = 0}),
        DisplayerImage = Roact.createElement("ImageLabel",{
            Size = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            Image = "rbxassetid://3580807050"
        }),
    })
end

function Displayer:didMount()
    local rng = Random.new()
    local x,y = rng:NextNumber(0.45,0.9), rng:NextNumber(0.45,0.9)
    self.ref:getValue().Position = UDim2.fromScale(x,y)
    self.signalForRef:Fire(self.ref:getValue())
end

return Displayer"
