local Types = require(script.Parent.Types)

local Connection = {}
Connection.__index = Connection

function Connection.new(callback: Types.ConnectionCallback)
    local self = setmetatable({}, Connection)
    self._callback = callback
    return self
end

function Connection:Disconnect()
    for property in self do
        self[property] = nil
    end
    setmetatable(self, nil)
    self = nil
end

return Connection