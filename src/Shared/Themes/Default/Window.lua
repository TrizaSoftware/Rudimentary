local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Tween = Fusion.Tween
local Computed = Fusion.Computed
local Value = Fusion.Value

export type WindowProps = {
  Title: string,
  Resizable: boolean,
  Buttons: {
    {
      Icon: string,
      Callback: () -> nil
    }
  },
  Parent: Instance,
  Size: UDim2
}

local function Window(props: WindowProps)
  return New "Frame" {
    Parent = props.Parent,
    Size = props.Size,

    [Children] = {
      New "Frame" {
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        [Children] = {
          New "UICorner" {
            CornerRadius = UDim.new(0, 3)
          }
        }
      }
    }
  }
end

return Window