local IconButton = require(script.Parent.IconButton)

return function (target: Instance)
  local Button = IconButton {
    Icon = "Home",
    Color = Color3.fromRGB(255, 255, 255),
    HoverColor = Color3.fromRGB(82, 179, 142),
    Size = UDim2.new(0, 50, 0, 50),
    Parent = target,
    Callback = function()
      print("Button Clicked")
    end
  }

  return function ()
    Button:Destroy()
  end
end