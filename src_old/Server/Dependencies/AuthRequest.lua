local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RudimentaryFolder = ReplicatedStorage:WaitForChild("Rudimentary")
local Shared = RudimentaryFolder:WaitForChild("Shared")
local BetterSignal = require(Shared.BetterSignal)

local AuthRequest = {}
AuthRequest.__index = AuthRequest

function AuthRequest.new(player: Player)
  local self = setmetatable({}, AuthRequest)
  self.Player = player
  self.KeySend = BetterSignal.new()
  return self
end

function AuthRequest:Complete()
  self.KeySend:Disconnect()
  setmetatable(self, nil)
  for index, _ in self do
    self[index] = nil
  end
  self = nil
end

return AuthRequest