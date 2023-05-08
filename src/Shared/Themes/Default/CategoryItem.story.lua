local CategoryItem = require(script.Parent.CategoryItem)
local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local Value = Fusion.Value

return function (target)
  local ServerTimeValue = Value(0)

  local Item = CategoryItem {
    Parent = target,
    Size = UDim2.new(0.5,0,0.2,0),
    Icon = "Schedule",
    ItemName = "Server Age",
    ItemValue = ServerTimeValue
  }
  

  return function()
    Item:Destroy()
  end
end