local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Computed = Fusion.Computed

local MaterialIcons = require(script.Parent.Parent.Parent.MaterialIcons)

export type IconButtonProps = {
  Icon: string,
  Size: UDim2,
  Position: UDim2,
  Color: Color3,
  HoverColor: Color3,
  Callback: () -> nil,
  Parent: Instance
}

local function IconButton(props: IconButtonProps)
  local Hovered = Value(false)

  return New "Frame" {
    Size = props.Size,
    Position = props.Position,
    BackgroundTransparency = 1,
    Parent = props.Parent,

    [Children] = {
      New "ImageButton" {
        BackgroundTransparency = 1,
        Image = `rbxassetid://{MaterialIcons[props.Icon or "Error"]}`,
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 2,
        ImageColor3 = Tween(Computed(function()
          return not Hovered:get() and props.Color or (props.HoverColor or props.Color)
        end, Fusion.cleanup), TweenInfo.new(0.4, Enum.EasingStyle.Quint)),
        
        [OnEvent "MouseEnter"] = function()
          Hovered:set(true)
        end,
    
        [OnEvent "MouseLeave"] = function()
          Hovered:set(false)
        end,

        [OnEvent "MouseButton1Click"] = props.Callback or function () end
      },
      [Children] = {
        New "Frame" {
          BorderSizePixel = 0,
          BackgroundColor3 = props.Color,
          BackgroundTransparency = 0.4,
          ZIndex = 1,
          AnchorPoint = Vector2.new(0.5, 0.5),
          Position = UDim2.new(0.5, 0, 0.5, 0),
          Size = Tween(Computed(function()
            return Hovered:get() and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 0, 0)
          end, Fusion.cleanup), TweenInfo.new(0.4, Enum.EasingStyle.Quint)),

          [Children] = {
            New "UICorner" {
              CornerRadius = UDim.new(0, 50)
            }
          }
        }
      }
    }
  }
end

return IconButton