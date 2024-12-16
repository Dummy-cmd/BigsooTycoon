local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local gamepass = ServerStorage.Objects.Gamepass

local Knit = require(ReplicatedStorage.Packages.Knit)

return function(player)
	local PothService = Knit.GetService("PothService")
	if PothService then
		local getPlayerTycoon = PothService:Get(player.UserId)
		if getPlayerTycoon then
			local localTycoon = getPlayerTycoon.Tycoon
			if localTycoon then
				local GetTipsJarGamepass = ServerStorage.Objects.Gamepass:WaitForChild(localTycoon.Name):WaitForChild("TipsJar")
				local DefaultsCashier = localTycoon:FindFirstChild(localTycoon.Name.."|Counter").PrincipalCounter:WaitForChild("Cashier")
				if DefaultsCashier then
					local cloneGamepass = GetTipsJarGamepass:Clone()
					cloneGamepass.Parent = localTycoon:FindFirstChild(localTycoon.Name.."|Counter").PrincipalCounter:WaitForChild("Cashier")
					cloneGamepass.Name = "TipsJar"
				end
			else
				repeat 
					getPlayerTycoon = PothService:Get(player.UserId)
					task.wait()
				until getPlayerTycoon.Tycoon ~= nil
				if (getPlayerTycoon) then
					local localTycoon = getPlayerTycoon.Tycoon
					if localTycoon then
						local GetTipsJarGamepass = ServerStorage.Objects.Gamepass:WaitForChild(localTycoon.Name):WaitForChild("TipsJar")
						local DefaultsCashier = localTycoon:FindFirstChild(localTycoon.Name.."|Counter").PrincipalCounter:WaitForChild("Cashier")
						if DefaultsCashier then
							local cloneGamepass = GetTipsJarGamepass:Clone()
							cloneGamepass.Parent = localTycoon:FindFirstChild(localTycoon.Name.."|Counter").PrincipalCounter:WaitForChild("Cashier")
							cloneGamepass.Name = "TipsJar"
						end
					end
				end
			end
		else
			repeat 
				getPlayerTycoon = PothService:Get(player.UserId)
				task.wait()
			until getPlayerTycoon ~= nil
			if (getPlayerTycoon) then
				local localTycoon = getPlayerTycoon.Tycoon
				if localTycoon then
                    local GetTipsJarGamepass = ServerStorage.Objects.Gamepass:WaitForChild(localTycoon.Name):WaitForChild("TipsJar")
                    local DefaultsCashier = localTycoon:FindFirstChild(localTycoon.Name.."|Counter").PrincipalCounter:WaitForChild("Cashier")
                    if DefaultsCashier then
						local cloneGamepass = GetTipsJarGamepass:Clone()
						cloneGamepass.Parent = localTycoon:FindFirstChild(localTycoon.Name.."|Counter").PrincipalCounter:WaitForChild("Cashier")
						cloneGamepass.Name = "TipsJar"
                    end
				end
			end
		end
	end
end
