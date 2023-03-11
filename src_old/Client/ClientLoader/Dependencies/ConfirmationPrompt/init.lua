local Dependencies = script:WaitForChild("Dependencies")
local Signal = require(Dependencies.Signal)
local ConfirmationPrompt = {}
ConfirmationPrompt.__index = ConfirmationPrompt

function ConfirmationPrompt.new(Client, message)
    local self = setmetatable({}, ConfirmationPrompt)
    self.Response = Signal.new()
    local Window = Client.UI.Make("Window", "Confirmation Prompt")
    local ActualWindow = Window.WindowInstance
    local Message = Window:addItem("TextLabel", {
        Font = Enum.Font.Gotham,
        TextScaled = true,
        Text = message,
        Size = UDim2.new(1,0,1,0),
        Parent = "Window",
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255,255,255)
    })
    Window:addItem("UITextSizeConstraint", {
        MaxTextSize = 20,
        MinTextSize = 10,
        Parent = Message
    })
    Window.WindowInstance.AnchorPoint = Vector2.new(0.5,0.5)
    Window.WindowInstance.Size = UDim2.new(0.224, 0,0.246, 0)
    Window.WindowInstance.Position = UDim2.new(0.499, 0,0.499, 0)
    Window:addItem("UIAspectRatioConstraint", {
        AspectRatio = Window.WindowInstance.AbsoluteSize.X / Window.WindowInstance.AbsoluteSize.Y,
        Parent = "Window"
    })
    local Yes = Client.UI.Make("Button")
    Yes.Color = Color3.fromRGB(27, 180, 27)
   -- Yes.TextColor = Color3.fromRGB(255,255,255)
    Yes.Size = UDim2.new(0.3,0,0.15,0)
    Yes.Position = UDim2.new(0.15,0,0.8,0)
    Yes.Style = "Outlined"
    Yes.Text = "Yes"
    Yes.Parent = ActualWindow
    local No = Client.UI.Make("Button")
    No.Color = Color3.fromRGB(182, 21, 21)
   -- No.TextColor = Color3.fromRGB(255,255,255)
    No.Size = UDim2.new(0.3,0,0.15,0)
    No.Position = UDim2.new(0.55,0,0.8,0)
    No.Style = "Outlined"
    No.Text = "No"
    No.Parent = ActualWindow

    Yes.Clicked:Connect(function()
        self.Response:Fire(true)
        Window.FaderInstance:fadeOut(1)
    end)

    No.Clicked:Connect(function()
        self.Response:Fire(false)
        Window.FaderInstance:fadeOut(1)
    end)

    Window.WindowInstance.Topbar.close.MouseButton1Click:Connect(function()
        self.Response:Fire(false)
    end)
    
    task.spawn(function()
        task.wait(1)
        local Connection = nil
        Connection = Window.FaderInstance.FadedOut:Connect(function()
            pcall(function()
                Window:Destroy()
            end)
            Connection:Disconnect()
        end)
    end)

    return self
end

return ConfirmationPrompt