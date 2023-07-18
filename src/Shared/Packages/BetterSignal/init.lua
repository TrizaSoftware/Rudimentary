local Dependencies = script:WaitForChild("Dependencies")
local ConnectionCreator = require(Dependencies.Connection)

local BetterSignal = {}
BetterSignal.__index = BetterSignal

function BetterSignal.new()
  local self = setmetatable({}, BetterSignal)
  self.Connections = {}
  return self
end

function BetterSignal:Fire(...)
  for _, connection in self.Connections do
      if connection.Function then
        task.spawn(connection.Function, ...)
      else
        table.remove(self.Connections, table.find(self.Connections, connection))
      end
   end
end

function BetterSignal:Connect(...)
  local Connection = ConnectionCreator.new(...)
  table.insert(self.Connections, Connection)
  return Connection
end

function BetterSignal:Wait()
  local WaitingCoroutine = coroutine.running()
  local Connection
  Connection = self:Connect(function()
    Connection:Disconnect()
    task.spawn(WaitingCoroutine)
  end)
  return coroutine.yield()
end

return BetterSignal