local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local New = Fusion.New

local Window = require(script.Parent.Window)

return function (target: Instance)
  local TestWindow = Window {
    Title = "Test",
    Parent = target,
    Size = UDim2.new(0.2, 0, 0, 300),
    Buttons = {
      {
        Icon = "Search",
        Color = Color3.fromRGB(173, 173, 173),
        Parent = target,
        Callback = function()
          print("Button Clicked")
        end
      },
      {
        Icon = "Menu",
        Color = Color3.fromRGB(173, 173, 173),
        Parent = target,
        Callback = function()
          print("Button Clicked")
        end
      },
      {
        Icon = "Close",
        Color = Color3.fromRGB(173, 173, 173),
        HoverColor = Color3.fromRGB(224, 38, 38),
        Parent = target,
        Callback = function()
          print("Button Clicked")
        end
      },
    },
    Children = {
    }
  }

  return function ()
    TestWindow:Destroy()
  end
end