local Players = game:GetService("Players")

local function GetFriendsPage(player)
    local friends = {}
    local succes,page = pcall(function()
        return Players:GetFriendsAsync(player.UserId)
    end)
    if succes then
        repeat
            local info = page:GetCurrentPage()
            for i,userId in pairs(info) do
                table.insert(friends,userId.Id)
            end
            if not page.IsFinished then
                page:AdvanceToNextPageAsync()
            end
        until page.IsFinished
    else    
        table.insert(friends,player.UserId)
    end
    if #friends <= 0 then
        table.insert(friends,player.UserId)
    end
    return  friends
end

local function LoadIndexId(player)
    local friends = GetFriendsPage(player)
    local getFriendsId = friends[math.random(1,#friends)]
    return getFriendsId
end

return LoadIndexId
