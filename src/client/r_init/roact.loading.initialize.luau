local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui or Player:WaitForChild("PlayerGui")

local Loading = Roact.Component:extend("LoadingMenu")

function Loading:init()
    self.connectOnce = false
    self.LoadingSkippedBindableFunction = Instance.new("BindableFunction",script.Parent)
    self.LoadingSkippedBindableFunction.Name = "LoadingSkippedBindableFunction"
    Lighting.Blur.Size = 24
end

function Loading:render()
    for i,Screen in PlayerGui:GetChildren() do
        if Screen:IsA("ScreenGui") then
            if Screen.Name == "LoadingScreen" then       
            else
                Screen.Enabled = false
            end
        end
    end
    return Roact.createElement("Frame",{
        Size = UDim2.fromScale(1,1),
        BackgroundColor3 = Color3.fromRGB(255, 157, 244),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundTransparency = 0.2,
        Position = UDim2.fromScale(.5,.5),
    },{
        LoadingImage = Roact.createElement("ImageLabel",{
            Image = "rbxassetid://17493823562",
            ImageTransparency = 1,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(.5,.5),
            AnchorPoint = Vector2.new(.5,.5),
            Position = UDim2.fromScale(.5,.2),
        }),
        LoadingLabel = Roact.createElement("TextLabel",{
            Text = "Welcome @" .. tostring(Players.LocalPlayer.Name),
            BackgroundTransparency = 1,
            TextScaled = true,
            TextColor3 = Color3.fromRGB(255,255,255),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.fromScale(0.165,0.95),
            Font = Enum.Font.FredokaOne,
            Size = UDim2.fromScale(0.25,0.05),
        },{
            UIStroke = Roact.createElement("UIStroke",{Thickness = 2})
        }),
        AssetLoadedLabel = Roact.createElement("TextLabel",{
            Text = "preloading assets",
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255,255,255),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.fromScale(0.5,0.6),
            Font = Enum.Font.FredokaOne,
            TextScaled = true,
            Size = UDim2.fromScale(0.15,0.05),
        },{
            UIStroke = Roact.createElement("UIStroke",{Thickness = 2})
        }),
        Bar = Roact.createElement("Frame",{
            Size = UDim2.fromScale(0.3,0.085),
            BackgroundColor3 = Color3.fromRGB(2, 2, 2),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.fromScale(.5,.5),
        },{
            UICorner = Roact.createElement("UICorner"),
            UIStroke = Roact.createElement("UIStroke",{Thickness = 2,Color = Color3.new(1,1,1)}),
            Coutainer = Roact.createElement("Frame",{
                Size = UDim2.fromScale(0,1),
                AnchorPoint = Vector2.new(0,.5),
                Position = UDim2.fromScale(0,0.5),
                BackgroundColor3 = Color3.fromRGB(235, 188, 247)
            },{UICorner = Roact.createElement("UICorner")}),
        }),

        SkipFrame = Roact.createElement("Frame",{
            Size = UDim2.fromScale(0.15,0.085),
            BackgroundColor3 = Color3.fromRGB(235, 188, 247),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.fromScale(.9,.935),
            Visible = false,
        },{
            UICorner = Roact.createElement("UICorner"),
            UIStroke = Roact.createElement("UIStroke",{Thickness = 2,Color = Color3.fromRGB(255,255,255)}),
            UIScale = Roact.createElement("UIScale",{Scale = 0}),
            Button = Roact.createElement("TextButton",{
                Size = UDim2.fromScale(1,1),
                AnchorPoint = Vector2.new(0.5,0.5),
                Position = UDim2.fromScale(.5,.5),
                Text = "Skip",
                Font = Enum.Font.FredokaOne,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255,255,255),
                BackgroundTransparency = 1,
                [Roact.Event.Activated] = function(rbx)
                    SoundService:PlayLocalSound(SoundService.Click)
                   if not self.connectOnce then
                        self.LoadingSkippedBindableFunction:Invoke(rbx)
                        self.connectOnce = true
                   else
                    end
                end,
            })
        })
    })
end


return Loading
