local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children

export type CategoryProps = {
  SizeX: UDim,
  Title: string,
  Items: {Frame},
  Parent: Instance
}

local function Category(props: CategoryProps)
  return New "Frame" {
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Size = UDim2.new(props.SizeX, UDim.new(0,0)),
    Parent = props.Parent,

    [Children] = {
      New "TextLabel" {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = props.Title,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 0, 20),
        TextScaled = true,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left
      },
      New "Frame" {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(UDim.new(1, 0), UDim.new(0,0)),
        
        [Children] = {
          New "UIListLayout" {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 10)
          },
          table.unpack(props.Items or {})
        }
      }
    }
  }
end

return Category