local Services = {}

local Service = {}
Service.__index = Service

export type Service = {
  Name: string,
  Initialize: () -> nil,
  Start: () -> nil
}

function Service.new(name: string)
  local self: Service = setmetatable({}, Service)
  self.Name = name
  Services[name] = self
  return self
end

function Service:GetService(serviceName: string): Service
  return Services[serviceName]
end

return Service