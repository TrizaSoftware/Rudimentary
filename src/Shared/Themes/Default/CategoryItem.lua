local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local MaterialIcons = require(script.Parent.Parent.Parent.MaterialIcons)

export type CategoryItemProps = {
  Size: UDim2,
  Parent: Frame,
  Icon: string,
  ItemName: string,
  ItemValue: any
}

local function CategoryItem(props: CategoryItemProps)
  return New "Frame" {
    Name = "CategoryItem",
    Size = props.Size,
    Position = UDim2.new(0.25, 0, 0.35, 0),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Parent = props.Parent,
    [Children] = {
      New "ImageLabel" {
        Size = UDim2.new(0.074, 0,0.763, 0),
        Position = UDim2.new(0.024, 0,0.119, 0),
        BackgroundTransparency = 1,
        Image = `rbxassetid://{MaterialIcons[props.Icon or "Error"]}`,
        ScaleType = Enum.ScaleType.Fit
      },
      New "TextLabel" {
        Size = UDim2.new(0.24, 0, 0.327, 0),
        Position = UDim2.new(0.118, 0, 0.33, 0),
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        TextScaled = true,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = props.ItemName or "Error",
        TextXAlignment = Enum.TextXAlignment.Left,

        [Children] = {
          New "UITextSizeConstraint" {
            MaxTextSize = 20,
            MinTextSize = 1
          }
        }
      },
      New "TextLabel" {
        Size = UDim2.new(0.247, 0, 0.67, 0),
        Position = UDim2.new(0.708, 0, 0.152, 0),
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        TextScaled = true,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = Computed(function()
          return props.ItemValue:get()
        end, Fusion.cleanup),
        TextXAlignment = Enum.TextXAlignment.Center,

        [Children] = {
          New "UITextSizeConstraint" {
            MaxTextSize = 20,
            MinTextSize = 1
          }
        }
      },
      --[[
      New "UIAspectRatioConstraint" {
        AspectRatio = 5.7
      },
      ]]
      New "UICorner" {
        CornerRadius = UDim.new(0, 10)
      },
      New "UIStroke" {
        Color = Color3.fromRGB(255, 255, 255),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
      }
    }
  }
end

return CategoryItem