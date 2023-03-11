local Dependencies = script.Parent.Parent.Dependencies

-- MODULES
local Service = require(Dependencies.Service)
local PseudoPlayer = require(Dependencies.PsuedoPlayer)

-- SERVICE

local PlayerService = Service.new("PlayerService")
PlayerService.RegisteredPlayers = {}

function PlayerService:InitializePlayer(player: Player): PseudoPlayer.PsuedoPlayer
  
end

return PlayerService