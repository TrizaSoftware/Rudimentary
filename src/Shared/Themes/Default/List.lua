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
    Children = {
      New "ScrollingFrame" {
        Size = UDim2.new(1, 0, 0.83, 0),
        BorderSizePixel = 0
      }
    }
  }
end

return List