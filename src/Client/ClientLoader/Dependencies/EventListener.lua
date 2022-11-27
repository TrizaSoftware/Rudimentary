local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RudimentaryFolder = ReplicatedStorage:WaitForChild("Rudimentary")
local Shared = RudimentaryFolder:WaitForChild("Shared")
local BetterSignal = require(Shared.BetterSignal)

local EventListener = {}
EventListener.__index = EventListener

function EventListener.new(callback)
  local self = setmetatable({}, EventListener)
  self.Callback = callback
  return self
end

return EventListener