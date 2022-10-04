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
        Signal:Fire(true)
    end)

    No.Clicked:Connect(function()
        Signal:Fire(false)
    end)

    Window.WindowInstance.Topbar.close.MouseButton1Click:Connect(function()
        Signal:Fire(false)
    end)

    return self
end

return ConfirmationPrompt