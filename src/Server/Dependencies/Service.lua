local Service = {}
Service.__index = Service

function Service.new(name: string)
  local self: typeof(Service) = setmetatable({}, Service)
  self.Name = name
  self.Started = false
  self.Initialized = false
  return self
end

return Service