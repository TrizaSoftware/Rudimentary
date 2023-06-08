local MarketplaceService = game:GetService("MarketplaceService")
local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local Value = Fusion.Value

local Category = require(script.Parent.Category)
local CategoryItem = require(script.Parent.CategoryItem)

return function (target: Instance)
  local ServerTimeValue = Value(0)
  local GameNameValue = Value("")

  task.spawn(function()
    local Info = MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
    GameNameValue:set(Info.Name)
  end)

  local CategoryItems = {
    CategoryItem {
      ItemName = "Name",
      ItemValue = GameNameValue,
      Size = UDim2.new(1,0,0,55),
      Icon = "Home"
    },
    CategoryItem {
      Icon = "Schedule",
      ItemName = "Server Age",
      ItemValue = ServerTimeValue,
      Size = UDim2.new(1,0,0,55),
    }
  }

  
  local Thread = coroutine.create(function()
    while true do
      ServerTimeValue:set(ServerTimeValue:get() + 1)
      task.wait(1)
    end
  end)

  coroutine.resume(Thread)

  local CreatedCategory = Category {
    Items = CategoryItems,
    Title = "Game Info",
    SizeX = UDim.new(0.4, 0),
    Parent = target
  }

  return function ()
    CreatedCategory:Destroy()
    coroutine.close(Thread)
  end
end