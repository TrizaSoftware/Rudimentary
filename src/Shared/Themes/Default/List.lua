local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local Window = require(script.Parent.Window)

export type ListProps = {
  Title: string,
  Elements: any,
  Parent: Instance
}

local function List(props: ListProps)
  return Window {
    Title = props.Title,
    Parent = props.Parent,
    Size = UDim2.new(0.2, 0, 0, 300),
    Buttons = {
      {
        Icon = "Close",
        Color = Color3.fromRGB(173, 173, 173),
        HoverColor = Color3.fromRGB(224, 38, 38),
      }
    },
    Children = {
      New "ScrollingFrame" {
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 0.83, 0),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
        TopImage = "rbxassetid://13742230380",
        MidImage = "rbxassetid://13742230380",
        BottomImage = "rbxassetid://13742230380"
      }
    }
  }
end

return List