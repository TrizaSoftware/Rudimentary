local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local Value = Fusion.Value

local CategoryItem = require(script.Parent.CategoryItem)

return function (target)
  local ServerTimeValue = Value(0)

  local Item = CategoryItem {
    Parent = target,
    Size = UDim2.new(0.5,0,0.2,0),
    Icon = "Schedule",
    ItemName = "Server Age",
    ItemValue = ServerTimeValue
  }
  
  local Thread = coroutine.create(function()
    while true do
      ServerTimeValue:set(ServerTimeValue:get() + 1)
      task.wait(1)
    end
  end)

  coroutine.resume(Thread)

  return function()
    coroutine.close(Thread)
    Item:Destroy()
  end
end