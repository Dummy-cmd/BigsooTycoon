local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

--Return a function, value -> @Instance, args : @name:string

return function(name)
    if not name then
        return
    elseif type(name) ~= "string" then
        return
    end
    local Toppings = ServerStorage.Objects.Model.Toppings
    if not Toppings then return end
    local model = nil
    for i,Model in Toppings:GetChildren() do
        if Model.Name == name then
            model = Model
            break
        elseif string.find(Model.Name,name) then
            model = Model
            break
        end
    end
    if not model then
        return false
    end
    return model
end
