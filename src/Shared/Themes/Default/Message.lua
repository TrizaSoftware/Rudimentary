local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local Window = require(script.Parent.Window)
local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value

export type MessageProps = {
    Title: string,
    Text: string,
    Parent: Instance?,
    Countdown: typeof(Value),
    CloseCallback: () -> nil
}

local Message = function(props: MessageProps)
    return Window {
        Title = props.Title,
        TitleTextXAlignment = Enum.TextXAlignment.Left,
        TitleTextColor = Color3.fromRGB(173, 173, 173),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.63, 0, 0.17, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = props.Parent,
        Buttons = {
            {
                Icon = "Close",
                Color = Color3.fromRGB(173, 173, 173),
                HoverColor = Color3.fromRGB(224, 38, 38),
                Callback = props.CloseCallback
            }
        },
        Children = {
            New "TextLabel" {
                Size = UDim2.new(0.9, 0, 0.57, 0),
                Position = UDim2.new(0.05, 0, 0.27, 0),
                BackgroundTransparency = 1,
                TextScaled = true,
                Font = Enum.Font.Gotham,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = props.Text,

                [Children] = {
                    New "UITextSizeConstraint" {
                        MaxTextSize = 20,
                        MinTextSize = 1
                    },
                }
            },

            New "TextLabel" {
                Size = UDim2.new(0.2, 0, 0.1, 0),
                Position = UDim2.new(0, 0, 0.83, 0),
                BackgroundTransparency = 1,
                TextScaled = true,
                Font = Enum.Font.Gotham,
                TextColor3 = Color3.fromRGB(173, 173, 173),
                Text = Computed(function()
                    return `Closes in {props.Countdown:get()} second(s)`
                end, Fusion.cleanup)
            }
        }
    }

    --[[

    return New "Frame" {
        Parent = props.Parent,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BackgroundTransparency = 0.1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.63, 0, 0.17, 0),

        [Children] = {
            New "UICorner" {
                CornerRadius = UDim.new(0, 5)
            },
            New "TextLabel" {
                Size = UDim2.new(0.9, 0, 0.57, 0),
                Position = UDim2.new(0.05, 0, 0.27, 0),
                BackgroundTransparency = 1,
                TextScaled = true,
                Font = Enum.Font.Gotham,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = props.Text,

                [Children] = {
                    New "UITextSizeConstraint" {
                        MaxTextSize = 25,
                        MinTextSize = 1
                    },
                }
            },
            New "Frame" {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Size = UDim2.new(1, 0, 0, 23),

                [Children] = {
                    New "UICorner" {
                        CornerRadius = UDim.new(0, 3)
                    },
                    New "TextLabel" {
                        Position = UDim2.new(0, 0,0.15, 0),
                        TextScaled = true,
                        TextColor3 = Color3.fromRGB(173, 173, 173),
                        Size = UDim2.new(1, 0,0.701, 0),
                        Text = props.Title,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        FontFace = Font.fromEnum(Enum.Font.Gotham),
        
                        [Children] = {
                            New "UITextSizeConstraint" {
                                MaxTextSize = 25,
                                MinTextSize = 1
                            },
                        }
                    },
                    IconButton {
                        Icon = "Close",
                        Callback = props.CloseCallback,
                        Color = Color3.fromRGB(173, 173, 173),
                        HoverColor = Color3.fromRGB(224, 38, 38),
                        Size = UDim2.new(0, 25, 1, 0),
                        Position = UDim2.new(0.95, 0, 0, 0)
                    }
                }
            },
        }
    }
    ]]
end

return Message