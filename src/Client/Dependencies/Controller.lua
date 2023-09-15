local Controllers = {}

local Controller = {}
Controller.__index = Controller

function Controller.new(name: string)
  local self: typeof(Controller) = setmetatable({}, Controller)
  self.Name = name
  self.Started = false
  self.Initialized = false

  Controllers[name] = self

  return self
end

function Controller.get(name: string): typeof(Controllers[name])
  return Controllers[name]
end

return Controller