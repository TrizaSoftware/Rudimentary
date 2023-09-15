local Services = {}

local Service = {}
Service.__index = Service

function Service.new(name: string)
  local self: typeof(Service) = setmetatable({}, Service)
  self.Name = name
  self.Started = false
  self.Initialized = false

  Services[name] = self

  return self
end

function Service.get(name: string): typeof(Services[name])
  return Services[name]
end

return Service