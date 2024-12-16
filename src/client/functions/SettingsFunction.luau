--[[
    same for the shop functions but this for settings.
]]

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Maid = require(ReplicatedStorage.Packages.Maid)

local setting = {}
setting.__index = setting

local function returnSettingsFrame()
    local player = Players.LocalPlayer
    local SettingsFrame = player.PlayerGui:WaitForChild("settings")
    if (SettingsFrame) then
        return SettingsFrame
    end
end

local function createAutobindingForSettings(self)
    -- function runned automaticly when a client join the game
    local SettingsFrame = returnSettingsFrame()
    if (SettingsFrame) then
        local main = SettingsFrame:FindFirstChild("main")
        local Coutainer = main.Coutainer
        local Global = Coutainer.Global
        local Variables = Global.Variables
        local soundsVolume = {}
        for i,sound in SoundService:GetChildren() do
            if (sound) then
                soundsVolume[sound.Name] = sound.Volume
            end
        end
        local MusicButton = bind(self,Variables.ImageLabel.MusicButton,function()
            if SoundService:FindFirstChild("Lobby music").Volume > 0 then
                SoundService:FindFirstChild("Lobby music").Volume = 0
                Variables.ImageLabel.MusicButton.Image = "rbxassetid://17485073929"
                Variables.ImageLabel.MusicButton.TextLabel.Text = "Off"
            else
                SoundService:FindFirstChild("Lobby music").Volume = 0.15
                Variables.ImageLabel.MusicButton.Image = "rbxassetid://17485081438"
                Variables.ImageLabel.MusicButton.TextLabel.Text = "On"
            end
        end)
        local SfxButton = bind(self,Variables.ImageLabel.SfxButton,function()
            if Variables.ImageLabel.SfxButton.TextLabel.Text == "On" then
                for i, sound in SoundService:GetChildren() do
                    if (sound) then
                        if (sound.Name == "Lobby music") then
                            -- do nothing cause is the music sound
                        else
                            sound.Volume = 0
                        end
                    end
                end
                Variables.ImageLabel.SfxButton.TextLabel.Text = "Off"
                Variables.ImageLabel.SfxButton.Image = "rbxassetid://17485073929"
            elseif Variables.ImageLabel.SfxButton.TextLabel.Text == "Off" then
                for i, sound in SoundService:GetChildren() do
                    if (sound) then
                        if (sound.Name == "Lobby music") then
                            -- do nothing cause is the music sound
                        else
                            sound.Volume = soundsVolume[sound.Name]
                        end
                    end
                end
                Variables.ImageLabel.SfxButton.Image = "rbxassetid://17485081438"
                Variables.ImageLabel.SfxButton.TextLabel.Text = "On"
            end
        end)
        local ShadowsButton = bind(self,Variables.ImageLabel.ShadowsButton,function()
            if Lighting.GlobalShadows == true then
                Lighting.GlobalShadows = false
                Variables.ImageLabel.ShadowsButton.TextLabel.Text = "Off"
                Variables.ImageLabel.ShadowsButton.Image = "rbxassetid://17485073929"
            else
                Lighting.GlobalShadows = true
                Variables.ImageLabel.ShadowsButton.Image = "rbxassetid://17485081438"
                Variables.ImageLabel.ShadowsButton.TextLabel.Text = "On"
            end
        end)
        local CloseButton = bind(self,Coutainer.CloseButton,function()
            changeBlurSize(0)
            TweenPlayerFOV(70)
            TweenService:Create(returnSettingsFrame():FindFirstChild("main").UIScale,TweenInfo.new(.2),{Scale = 0}):Play()
        end)
    end
end

function changeBlurSize(newSize)
    TweenService:Create(Lighting.Blur,TweenInfo.new(0.2),{Size = newSize}):Play()
end

function TweenPlayerFOV(newFOV)
    local camera = workspace.CurrentCamera
    TweenService:Create(camera,TweenInfo.new(0.2),{FieldOfView = newFOV}):Play()
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

function setting:Construct()
    createAutobindingForSettings(self)
end

return setting
