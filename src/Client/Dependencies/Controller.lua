local Controller = {}
Controller.__index = Controller

function Controller.new(name: string)
  local self: typeof(Controller) = setmetatable({}, Controller)
  self.Name = name
  self.Started = false
  self.Initialized = false
  return self
end

return Controller