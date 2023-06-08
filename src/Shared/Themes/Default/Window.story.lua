local Window = require(script.Parent.Window)

return function (target: Instance)
  local TestWindow = Window {
    Title = "Test",
    Parent = target,
    Size = UDim2.new(0.2, 0, 1, 0)
  }

  return function ()
    TestWindow:Destroy()
  end
end