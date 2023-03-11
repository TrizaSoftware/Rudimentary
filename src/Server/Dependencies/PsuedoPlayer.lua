export type PsuedoPlayer = {
  Player: Player,
  AdminLevel: number,
  Destroy: () -> nil
}

local PsuedoPlayer = {}
PsuedoPlayer.__index = PsuedoPlayer

function PsuedoPlayer.new(player: Player)
  local self: PsuedoPlayer = setmetatable({}, PsuedoPlayer)
  self.Player = player
  self.AdminLevel = 0
  return self
end

function PsuedoPlayer:Destroy()
  setmetatable(self, nil)
  for property, _ in self do
    self[property] = nil
  end
  self = nil
end

return PsuedoPlayer