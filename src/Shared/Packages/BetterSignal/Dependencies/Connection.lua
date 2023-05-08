local BetterSignalConnection = {}
BetterSignalConnection.__index = BetterSignalConnection

function BetterSignalConnection.new(func)
  assert(typeof(func) == "function", "Connections must include a function.")
  local self = setmetatable({}, BetterSignalConnection)
  self.Function = func
  return self
end

function BetterSignalConnection:Disconnect()
  setmetatable(self, nil)
  for property, _ in self do
    self[property] = nil
  end
  self = nil
end

return BetterSignalConnection