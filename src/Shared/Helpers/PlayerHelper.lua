local Players = game:GetService("Players")
local PlayerHelper = {}

function PlayerHelper:GetPlayerFromName(name: string)
    name = name:lower()

    for _, player in Players:GetPlayers() do
        if player.Name:sub(1,name:len()):lower() == name or player.DisplayName:sub(1,name:len()):lower() == name then
            return player
        end
    end
end

return PlayerHelper