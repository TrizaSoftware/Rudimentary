local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Tween = Fusion.Tween
local Computed = Fusion.Computed
local Value = Fusion.Value

local IconButton = require(script.Parent.IconButton)
export type WindowProps = {
  Title: string,
  Resizable: boolean,
  Buttons: {
    IconButton.IconButtonProps
  },
  Parent: Instance,
  AnchorPoint: Vector2,
  Position: UDim2,
  Size: UDim2,
  Children: {
    Instance
  }
}

local function Window(props: WindowProps)
  return New "Frame" {
    Parent = props.Parent,
    Size = props.Size,
    AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
    Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
    ClipsDescendants = true,
    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
    BackgroundTransparency = 0.1,

    [Children] = {
      New "UICorner" {
        CornerRadius = UDim.new(0, 5)
      },

      New "Frame" {
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Size = UDim2.new(1, 0, 0, 27),

        [Children] = {
          New "UICorner" {
            CornerRadius = UDim.new(0, 3)
          },
          New "TextLabel" {
            Position = UDim2.new(0.032, 0,0.15, 0),
            TextScaled = true,
            TextColor3 = Color3.fromRGB(173, 173, 173),
            Size = UDim2.new(0.526, 0,0.701, 0),
            Text = props.Title,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.fromEnum(Enum.Font.Gotham),

            [Children] = {
              New "UITextSizeConstraint" {
                MaxTextSize = 25,
                MinTextSize = 1
              }
            }
          },
          New "Frame" {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.649, 0,0, 0),
            Size = UDim2.new(0.35, 0,1, 0),

            [Children] = {
              New "UIGridLayout" {
                CellPadding = UDim2.new(0, 5, 0, 0),
                CellSize = UDim2.new(0, 27, 1, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder
              },
              Computed(function()
                local Buttons = {}

                for i, buttonProps in props.Buttons or {} do
                  local Button = IconButton(buttonProps)
                  Button.LayoutOrder = i
                  table.insert(Buttons, Button)
                end

                return Buttons
              end, Fusion.cleanup)
            }
          }
        }
      },
      New "Frame" {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.new(0, 0, 0.0935, 0),
        Size = UDim2.new(1, 0, 0.91, 0),

        [Children] = {
          table.unpack(props.Children or {})
        }
      }
    }
  }
end

return Window